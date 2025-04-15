import sys
import json
import numpy as np
import cv2
import base64
import os
from flask import Flask, request, jsonify
from inference_sdk import InferenceHTTPClient
import tempfile
from calories import get_calories

app = Flask(__name__)

rf_client = InferenceHTTPClient(
    api_url="https://detect.roboflow.com",
    api_key=os.getenv("ROBOFLOW_API_KEY", "5107l8sgQ6y11V5Z7bRl")
)

def load_food_data():
    try:
        with open("food_data.json", "r") as f:
            return json.load(f)
    except FileNotFoundError:
        app.logger.error("food_data.json not found")
        return {}
    except json.JSONDecodeError:
        app.logger.error("Invalid food_data.json format")
        return {}

FOOD_DATA = load_food_data()
FALLBACK_FOOD = {"gi": 50, "carbs_per_100g": 20}

@app.route('/')
def home():
    return jsonify({"message": "GlycoSnap API is running!"})

def decode_image(image_base64):
    try:
        image_data = base64.b64decode(image_base64)
        np_arr = np.frombuffer(image_data, np.uint8)
        return cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    except Exception as e:
        app.logger.error(f"Image decoding failed: {str(e)}")
        return None

def calculate_glycemic_load(gi, carbs):
    return (gi * carbs) / 100

FOOD_DENSITY = {
    "default": 1.0,
    "rice": 1.3,
    "ugali": 1.5,
    "kales": 0.2,
    "spinach": 0.2,
    "beans": 0.8,
    "chapati": 0.9,
    "cabbage": 0.3,
    "ndengu": 0.9
}

@app.route('/predict', methods=['POST'])
def predict_glycemic_load():
    try:
        data = request.json
        if not data or 'image' not in data:
            return jsonify({"error": "No image provided"}), 400

        image = decode_image(data['image'])
        if image is None:
            return jsonify({"error": "Invalid image format"}), 400

        tmp = tempfile.NamedTemporaryFile(suffix='.jpg', delete=False)
        cv2.imwrite(tmp.name, image)
        tmp.close()

        rf_result = rf_client.run_workflow(
            workspace_name="glycosnapv2",
            workflow_id="custom-workflow-2",
            images={"image": tmp.name},
            use_cache=True
        )
        app.logger.info(f"Roboflow result: {rf_result}")  # Log response for debugging

        os.unlink(tmp.name)

        response = {'glycemic_load': {}, 'total_glycemic_load': 0.0}
        segmented_areas = {}
        # Handle rf_result as a list of predictions
        predictions = rf_result if isinstance(rf_result, list) else rf_result.get("predictions", [])
        for pred in predictions:
            class_name = pred["class"].lower()
            mask_pts = pred["mask"]
            area_pixels = cv2.contourArea(np.array(mask_pts))
            area_cm2 = area_pixels * 0.001
            segmented_areas[class_name] = segmented_areas.get(class_name, 0) + area_cm2

        for food, area in segmented_areas.items():
            info = FOOD_DATA.get(food, FALLBACK_FOOD)
            gi = info["gi"]
            carbs_g = area * (info["carbs_per_100g"] / 100)
            gl = calculate_glycemic_load(gi, carbs_g) if gi > 0 else 0
            gl = min(gl, 100)
            response['glycemic_load'][food] = gl
            response['total_glycemic_load'] += gl

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
    app.run(host="0.0.0.0", port=5000)