import sys
import json
import numpy as np
import cv2
import base64
import os
from flask import Flask, request, jsonify
from ultralytics import YOLO
import ultralytics.nn.tasks
import torch
import torch.serialization
import firebase_admin
from firebase_admin import credentials, storage

# Create Flask application instance
app = Flask(__name__)


FOOD_DATA = {
    "beef": {"gi": 0, "carbs_per_100g": 0},  # No carbs in beef
    "kales": {"gi": 15, "carbs_per_100g": 8},  # Kale has ~8g of carbs per 100g
    "ugali": {"gi": 66, "carbs_per_100g": 78},  # Ugali (cornmeal porridge) has ~78g carbs per 100g
    "rice": {"gi": 73, "carbs_per_100g": 28},  # White rice values
    "chapati": {"gi": 52, "carbs_per_100g": 50},  # Whole wheat chapati
    "beans": {"gi": 28, "carbs_per_100g": 20},  # Cooked kidney beans
    "cabbage": {"gi": 10, "carbs_per_100g": 6},  # Cooked cabbage
    "spinach": {"gi": 15, "carbs_per_100g": 3.6},  # Spinach (low carb)
    "ndengu": {"gi": 25, "carbs_per_100g": 16},  # Mung beans (green grams)
}


def get_model_path():
    if os.getenv('DOCKER_ENV') == 'true':
        return '/app/model/glycosnap_model.pt'  # Docker path
    else:
        return os.path.join(os.path.dirname(os.path.abspath(__file__)), 'model', 'glycosnap_model.pt')

# Get credentials path dynamically
def get_credentials_path():
    if os.getenv('DOCKER_ENV') == 'true':
        return '/app/credentials/credentials.json'  # Docker path
    else:
        return os.path.join(os.path.dirname(os.path.abspath(__file__)), 'credentials', 'credentials.json')

# Initialize Firebase and load model during app startup
def initialize_app():
    try:
        # Firebase setup
        cred_path = get_credentials_path()
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'glycosnap-c605c.firebasestorage.app'
        })

        # Ensure model directory exists
        model_path = get_model_path()
        os.makedirs(os.path.dirname(model_path), exist_ok=True)

        # Download model if not found
        if not os.path.exists(model_path):
            bucket = storage.bucket()
            blob = bucket.blob('glycosnap_model.pt')
            blob.download_to_filename(model_path)
            app.logger.info("Model downloaded successfully")

        # **Register the actual class, NOT a string**
        torch.serialization.add_safe_globals([ultralytics.nn.tasks.SegmentationModel])

        # **Explicitly load the model**
        model_weights = torch.load(model_path, weights_only=False, map_location=torch.device('cpu'))

        # **Load YOLO model using the file path**
        app.yolo_model = YOLO(model_path)

        app.logger.info("Model loaded successfully")

    except Exception as e:
        app.logger.error(f"Initialization failed: {str(e)}")
        sys.exit(1)

@app.route('/')
def home():
    return jsonify({"message": "GlycoSnap API is running!"})

# Run initialization before first request using modern pattern
@app.before_request
def before_first_request():
    if not hasattr(app, 'yolo_model'):
        initialize_app()

def decode_image(image_base64):
    try:
        image_data = base64.b64decode(image_base64)
        np_arr = np.frombuffer(image_data, np.uint8)
        return cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    except Exception as e:
        app.logger.error(f"Image decoding failed: {str(e)}")
        return None

def calculate_glycemic_load(gi, carbs):
    """
    Calculate glycemic load (GL) using the formula:
    GL = (GI * Carbs) / 100
    """
    return (gi * carbs) / 100

FOOD_DENSITY = {
    "rice": 1.3,   # g/cm³
    "ugali": 1.5,
    "kales": 0.2,
    "spinach": 0.2,
    "beans": 0.8,
    "chapati": 0.9,
    "cabbage": 0.3,
    "ndengu": 0.9
}

def estimate_portion_size(box, image_area, class_name):
    """
    Estimates portion size in grams using bounding box area,
    image area, and food density.
    """
    box_area = (box[2] - box[0]) * (box[3] - box[1])  # width * height
    portion_percentage = box_area / image_area
    avg_plate_weight = 350  

    if class_name in FOOD_DENSITY:
        density_factor = FOOD_DENSITY[class_name]
    else:
        density_factor = 1  # Default for unknown foods

    return portion_percentage * avg_plate_weight * density_factor

@app.route('/predict', methods=['POST'])
def predict_glycemic_load():
    try:
        data = request.json
        if not data or 'image' not in data:
            return jsonify({"error": "No image provided"}), 400

        image = decode_image(data['image'])
        if image is None:
            return jsonify({"error": "Invalid image format"}), 400

        # Get image dimensions
        image_height, image_width, _ = image.shape
        image_area = image_height * image_width

        # Perform object segmentation
        results = app.yolo_model.predict(image, imgsz=320, conf=0.5, task="segment")

        response = {'glycemic_load': {}, 'total_glycemic_load': 0.0}

        segmented_areas = {}  # Dictionary to store segmented areas

        for r in results:
            for mask, box in zip(r.masks.xy, r.boxes):
                class_name = r.names[int(box.cls)]
                if class_name in FOOD_DATA:
                    # Calculate the segmented area in pixels
                    area_pixels = cv2.contourArea(np.array(mask))  

                    # Convert pixel area to cm² (scaling factor may need calibration)
                    area_cm2 = area_pixels * (0.0264583333 ** 2)  

                    segmented_areas[class_name] = area_cm2  

        # Glycemic Load Calculation
        for food_item, area_cm2 in segmented_areas.items():
            # Fetch food properties
            gi = FOOD_DATA[food_item]["gi"]
            carb_density = FOOD_DENSITY.get(food_item, 0)

            # Calculate carbohydrate content
            carbs_g = area_cm2 * carb_density

            # Calculate Glycemic Load
            gl = (gi * carbs_g) / 100 if gi > 0 else 0
            response['glycemic_load'][food_item] = gl
            response['total_glycemic_load'] += gl

        # Assign glycemic load category
        total_gl = response['total_glycemic_load']
        if total_gl <= 10:
            response['glycemic_load_category'] = "Low glycemic load"
        elif total_gl <= 20:
            response['glycemic_load_category'] = "Medium glycemic load"
        else:
            response['glycemic_load_category'] = "High glycemic load"

        # Add food name (optional)
        response['food_name'] = ", ".join(response['glycemic_load'].keys())

        return jsonify(response)

    except Exception as e:
        app.logger.error(f"Prediction failed: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500

if __name__ == "__main__":
    initialize_app()  # Initialize before running
    app.run(host="0.0.0.0", port=5000)