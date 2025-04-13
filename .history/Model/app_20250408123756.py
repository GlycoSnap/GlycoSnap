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
from calories import get_calories
import tempfile
import os
from inference_sdk import InferenceHTTPClient


rf_client = InferenceHTTPClient(
    api_url="https://detect.roboflow.com",
    api_key="5107l8sgQ6y11V5Z7bRl"
)

# Create Flask application instance
app = Flask(__name__)

FOOD_DATA = {
    "beef": {"gi": 0, "carbs_per_100g": 0},       # No carbs in beef
    "kales": {"gi": 15, "carbs_per_100g": 8},       # Kale has ~8g of carbs per 100g
    "ugali": {"gi": 66, "carbs_per_100g": 78},       # Ugali has ~78g carbs per 100g
    "rice": {"gi": 73, "carbs_per_100g": 28},        # White rice values
    "chapati": {"gi": 52, "carbs_per_100g": 50},      # Whole wheat chapati
    "beans": {"gi": 28, "carbs_per_100g": 20},        # Cooked kidney beans
    "cabbage": {"gi": 10, "carbs_per_100g": 6},       # Cooked cabbage
    "spinach": {"gi": 15, "carbs_per_100g": 3.6},     # Spinach (low carb)
    "ndengu": {"gi": 25, "carbs_per_100g": 16}        # Mung beans (green grams)
}

def get_model_path():
    if os.getenv('DOCKER_ENV') == 'true':
        return '/app/model/glycosnap_model.pt'  # Docker path
    else:
        return os.path.join(os.path.dirname(os.path.abspath(__file__)), 
                            'model', 'glycosnap_model.pt')

# Initialize app and load model from local storage
def initialize_app():
    try:
        # Ensure model directory exists
        model_path = get_model_path()
        os.makedirs(os.path.dirname(model_path), exist_ok=True)

        # Check if model file exists locally; if not, throw an error.
        if not os.path.exists(model_path):
            raise FileNotFoundError("Model file not found. Please place glycosnap_model.pt in the 'model' folder.")

        # Register the actual class, NOT a string
        torch.serialization.add_safe_globals([ultralytics.nn.tasks.SegmentationModel])

        # Load YOLO model using the local file path
        app.yolo_model = YOLO(model_path)
        app.logger.info("Model loaded successfully")

    except Exception as e:
        app.logger.error(f"Initialization failed: {str(e)}")
        sys.exit(1)

@app.route('/')
def home():
    return jsonify({"message": "GlycoSnap API is running!"})

# Run initialization before first request
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

@app.route('/predict', methods=['POST'])
@app.route('/predict', methods=['POST'])
def predict_glycemic_load():
    try:
        data = request.json
        if not data or 'image' not in data:
            return jsonify({"error": "No image provided"}), 400

        # 1️⃣ Decode the incoming base64 image
        image = decode_image(data['image'])
        if image is None:
            return jsonify({"error": "Invalid image format"}), 400

        # 2️⃣ Write to a temp file for Roboflow SDK
        tmp = tempfile.NamedTemporaryFile(suffix='.jpg', delete=False)
        cv2.imwrite(tmp.name, image)
        tmp.close()

        # 3️⃣ Call Roboflow workflow instead of YOLO.predict()
        rf_result = rf_client.run_workflow(
            workspace_name="glycosnapv2",
            workflow_id="custom-workflow-2",
            images={"image": tmp.name},
            use_cache=True
        )

        # clean up the temp file
        os.unlink(tmp.name)

        # 4️⃣ Parse predictions (same area→GL logic as before)
        response = {'glycemic_load': {}, 'total_glycemic_load': 0.0}
        segmented_areas = {}
        for pred in rf_result.get("predictions", []):
            class_name = pred["class"]               # e.g. "rice", "beans"
            mask_pts    = pred["mask"]               # polygon pts [[x,y],…]
            area_pixels = cv2.contourArea(np.array(mask_pts))
            area_cm2    = area_pixels * 0.001        # your scaling factor
            segmented_areas[class_name] = segmented_areas.get(class_name, 0) + area_cm2

        # 5️⃣ Compute GL per food item
        for food, area in segmented_areas.items():
            info     = FOOD_DATA[food]
            gi       = info["gi"]
            carbs_g  = area * (info["carbs_per_100g"] / 100)
            gl       = (gi * carbs_g) / 100 if gi > 0 else 0
            gl       = min(gl, 100)
            response['glycemic_load'][food] = gl
            response['total_glycemic_load'] += gl

        # 6️⃣ Assign category & return
        total = response['total_glycemic_load']
        if total <= 10:
            response['glycemic_load_category'] = "Low glycemic load"
        elif total <= 20:
            response['glycemic_load_category'] = "Medium glycemic load"
        else:
            response['glycemic_load_category'] = "High glycemic load"
        response['food_name'] = ", ".join(response['glycemic_load'].keys())

        return jsonify(response)

    except Exception as e:
        app.logger.error(f"Prediction failed: {str(e)}")
        return jsonify({"error": "Prediction failed"}), 500


@app.route('/calories', methods=['POST'])
def get_food_calories():
    data = request.json
    if not data or "food_name" not in data:
        return jsonify({"error": "No food name provided"}), 400
    
    result = get_calories(data["food_name"])
    return jsonify(result)

if __name__ == "__main__":
    initialize_app()
    app.run(host="0.0.0.0", port=5000)
