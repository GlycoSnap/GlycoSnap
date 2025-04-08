import sys
import json
import numpy as np
import cv2
import base64
import os  
from flask import Flask, request, jsonify
from ultralytics import YOLO
import torch
from torch.nn.modules.container import Sequential
import firebase_admin
from firebase_admin import credentials, storage

# Create Flask application instance
app = Flask(__name__)



def get_model_path():
    if os.getenv('DOCKER_ENV') == 'true':
        return '/app/model/glycosnap_model.pt'  # Docker path
    else:
        return os.path.join(os.path.dirname(os.path.abspath(__file__)), 'model', 'glycosnap_model.pt')
# Get credentials path dynamically
def get_credentials_path():
    # Check if running in Docker (environment variable)
    if os.getenv('DOCKER_ENV') == 'true':
        return '/app/credentials/credentials.json'  # Docker path
    else:
        # Local development path
        return os.path.join(
            os.path.dirname(os.path.abspath(__file__)), 
            'credentials', 
            'credentials.json'
        )

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

        # Load the model
        app.yolo_model = YOLO(model_path)
        app.logger.info("Model loaded successfully")

    except Exception as e:
        app.logger.error(f"Initialization failed: {str(e)}")
        sys.exit(1)

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
    initialize_app()  # Initialize before running
    app.run(host="0.0.0.0", port=5000)