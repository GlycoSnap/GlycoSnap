import sys
import json
import numpy as np
import cv2
import base64
from flask import Flask, request, jsonify
from ultralytics import YOLO
import firebase_admin
from firebase_admin import credentials, storage

# Create Flask application instance
app = Flask(__name__)

# Initialize Firebase
def initialize_firebase():
    try:
        cred = credentials.Certificate("/app/credentials.json")
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'glycosnap-c605c.firebasestorage.app'
        })
    except Exception as e:
        app.logger.error(f"Firebase initialization failed: {str(e)}")
        sys.exit(1)

# Download the model from Firebase Storage
def download_model():
    try:
        bucket = storage.bucket()
        blob = bucket.blob('glycosnap_model.pt')
        blob.download_to_filename('/tmp/glycosnap_model.pt')
        app.logger.info("Model downloaded successfully")
    except Exception as e:
        app.logger.error(f"Model download failed: {str(e)}")
        sys.exit(1)

# Load YOLO model
def load_yolo_model():
    try:
        model = YOLO('/tmp/glycosnap_model.pt')
        app.logger.info("Model loaded successfully")
        return model
    except Exception as e:
        app.logger.error(f"Model loading failed: {str(e)}")
        sys.exit(1)

# Initialize Firebase and load model before first request
@app.before_first_request
def initialize_app():
    initialize_firebase()
    download_model()
    app.yolo_model = load_yolo_model()

def decode_image(image_base64):
    try:
        image_data = base64.b64decode(image_base64)
        np_arr = np.frombuffer(image_data, np.uint8)
        return cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    except Exception as e:
        app.logger.error(f"Image decoding failed: {str(e)}")
        return None

@app.route('/predict', methods=['POST'])
def predict_glycemic_load():
    try:
        data = request.json
        if not data or 'image' not in data:
            return jsonify({"error": "No image provided"}), 400
            
        image = decode_image(data['image'])
        if image is None:
            return jsonify({"error": "Invalid image format"}), 400

        results = app.yolo_model.predict(image, imgsz=320, conf=0.5)
        response = {'glycemic_load': {}}
        
        for r in results:
            for box in r.boxes:
                class_name = r.names[int(box.cls)]
                response['glycemic_load'][class_name] = 10  # Dummy Value

        return jsonify(response)

    except Exception as e:
        app.logger.error(f"Prediction failed: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)