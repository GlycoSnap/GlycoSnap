from flask import Flask, request, jsonify
import numpy as np
import cv2
import base64
from ultralytics import YOLO

app = Flask(__name__)

model_path = 'C:/Users/USER/OneDrive/Desktop/glycosnap/glycosnap_model.pt'
yolo_model = YOLO(model_path)  # Replace with actual loading method

GI_VALUES = {
    'ugali': 67,
    'beef': 0,
    'kales': 3
}

CARB_DENSITY = {
    'ugali': 1.725,
    'beef': 0,
    'kales': 0.45
}

def calculate_area(mask):
    return np.count_nonzero(mask)

def calculate_glycemic_load(class_name, area_cm2):
    gi = GI_VALUES.get(class_name, 0)
    carbs_g = area_cm2 * CARB_DENSITY.get(class_name, 0)
    return (gi * carbs_g) / 100 if gi > 0 else 0

def decode_image(image_base64):
    image_data = base64.b64decode(image_base64)
    np_arr = np.frombuffer(image_data, np.uint8)
    return cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

@app.route('/predict_gl', methods=['POST'])
def predict_gl():
    data = request.get_json()
    image_base64 = data['image']
    image = decode_image(image_base64)

    # Run YOLOv8 inference, replace with your actual method
    results = yolo_model.predict(image)
    results = []  # Placeholder for results from YOLOv8

    glycemic_load_results = {}

    for result in results:
        boxes = result['boxes']  # Replace with actual result structure
        masks = result['masks']  # Replace with actual result structure
        names = result['names']  # Replace with actual result structure

        for mask, box in zip(masks, boxes):
            class_idx = int(box['cls'])  # Replace with actual structure
            class_name = names[class_idx]

            area_pixels = calculate_area(mask)
            area_cm2 = area_pixels * (0.0264583333 ** 2)  # Example pixel to cm conversion

            gl = calculate_glycemic_load(class_name, area_cm2)
            glycemic_load_results[class_name] = gl

    return jsonify(glycemic_load_results)

if __name__ == '__main__':
    app.run(debug=True)

