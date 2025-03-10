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

# Define glycemic index (GI) and carbohydrate content per 100g for common foods
# Replace these values with accurate data from reliable sources
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

def estimate_portion_size(box, image_area):
    """
    Estimate portion size based on the bounding box area relative to the image area.
    Returns the estimated weight in grams.
    """
    # Calculate the area of the bounding box
    box_area = (box[2] - box[0]) * (box[3] - box[1])  # width * height

    # Estimate portion size as a percentage of the total image area
    portion_percentage = box_area / image_area

    # Assume the average plate area corresponds to ~500g of food
    # Adjust this assumption based on your use case
    return portion_percentage * 500  # Estimated weight in grams

@app.route('/predict', methods=['POST'])
def predict_glycemic_load():
    try:
        data = request.json
        if not data or 'image' not in data:
            return jsonify({"error": "No image provided"}), 400

        image = decode_image(data['image'])
        if image is None:
            return jsonify({"error": "Invalid image format"}), 400

        # Get image dimensions for portion size estimation
        image_height, image_width, _ = image.shape
        image_area = image_height * image_width

        results = app.yolo_model.predict(image, imgsz=320, conf=0.5)
        response = {'glycemic_load': {}, 'total_glycemic_load': 0.0}

        for r in results:
            for box in r.boxes:
                class_name = r.names[int(box.cls)]
                if class_name in FOOD_DATA:
                    # Estimate portion size in grams
                    portion_size_grams = estimate_portion_size(box.xyxy[0].cpu().numpy(), image_area)

                    # Calculate carbohydrate content for the portion size
                    carbs_per_100g = FOOD_DATA[class_name]["carbs_per_100g"]
                    carbs = (carbs_per_100g * portion_size_grams) / 100

                    # Calculate glycemic load
                    gi = FOOD_DATA[class_name]["gi"]
                    gl = calculate_glycemic_load(gi, carbs)

                    response['glycemic_load'][class_name] = gl
                    response['total_glycemic_load'] += gl
                else:
                    response['glycemic_load'][class_name] = 0.0  # Default value for unknown foods

        # Add glycemic load category based on total GL
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