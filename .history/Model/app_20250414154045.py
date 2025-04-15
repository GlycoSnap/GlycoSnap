import sys
import json
import numpy as np
import cv2
import base64
import os
from flask import Flask, request, jsonify
import tempfile
from calories import get_calories
from ultralytics import YOLO

app = Flask(__name__)

# Load YOLO model
model_path = "/app/model/glycosnapv2.pt"
try:
    model = YOLO(model_path)
    app.logger.info(f"Loaded YOLO model from {model_path}")
except Exception as e:
    app.logger.error(f"Failed to load YOLO model: {str(e)}")
    model = None

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
    "ndengu": 0.9,
    "sweet potatoes": 1.0,
    "cassava": 1.2,
    "arrowroots": 1.1,
    "pilau": 1.2,
    "mandazi": 0.8
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

        if model is None:
            return jsonify({"error": "Model not loaded"}), 500

        tmp = tempfile.NamedTemporaryFile(suffix='.jpg', delete=False)
        cv2.imwrite(tmp.name, image)
        tmp.close()

        # Run YOLO inference
        results = model.predict(tmp.name, save=False, conf=0.5)
        app.logger.info(f"YOLO results: {results}")

        os.unlink(tmp.name)

        response = {'glycemic_load': {}, 'total_glycemic_load': 0.0}
        segmented_areas = {}
        predictions = []

        # Process YOLO results
        for result in results:
            if hasattr(result, 'masks') and result.masks is not None:
                for mask, cls, conf in zip(result.masks.xy, result.boxes.cls, result.boxes.conf):
                    try:
                        class_id = int(cls)
                        class_name = result.names[class_id].lower()
                        if conf < 0.5:
                            app.logger.warning(f"Low confidence {conf} for {class_name}, skipping")
                            continue
                        # Convert mask points to contour
                        contour = np.array([[x, y] for x, y in mask], dtype=np.float32)
                        area_pixels = cv2.contourArea(contour)
                        if area_pixels is None or area_pixels <= 0:
                            app.logger.warning(f"Invalid contour area for {class_name}: {area_pixels}")
                            continue
                        area_cm2 = area_pixels * 0.001
                        segmented_areas[class_name] = segmented_areas.get(class_name, 0) + area_cm2
                        app.logger.info(f"Processed {class_name}: area_cm2={area_cm2}")
                    except Exception as e:
                        app.logger.error(f"Error processing prediction for {class_name}: {str(e)}")
                        continue
            else:
                app.logger.warning("No masks found in YOLO result")

        if not segmented_areas:
            app.logger.info("No valid predictions found")
            return jsonify({
                "glycemic_load": {},
                "total_glycemic_load": 0.0,
                "glycemic_load_category": "Low glycemic load",
                "food_name": ""
            }), 200

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
        return jsonify({"error": "No food_name provided"}), 400
    
    result = get_calories(data["food_name"])
    return jsonify(result)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)