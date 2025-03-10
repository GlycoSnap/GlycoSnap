import sys
import json
import numpy as np
import cv2
import base64
from ultralytics import YOLO
import firebase_admin
from firebase_admin import credentials, storage

# Initialize Firebase
cred = credentials.Certificate("/app/credentials.json")
firebase_admin.initialize_app(cred, {
    'storageBucket': 'glycosnap-c605c.firebasestorage.app'
})

# Download the model from Firebase Storage
def download_model():
    bucket = storage.bucket()
    blob = bucket.blob('glycosnap_model.pt') 
    blob.download_to_filename('/tmp/glycosnap_model.pt')

# Load Model from Firebase Storage
download_model()
model_path = "/tmp/glycosnap_model.pt"
yolo_model = YOLO(model_path)

def decode_image(image_base64):
    image_data = base64.b64decode(image_base64)
    np_arr = np.frombuffer(image_data, np.uint8)
    return cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

def predict_glycemic_load(image_base64):
    image = decode_image(image_base64)
    results = yolo_model.predict(image, imgsz=320, conf=0.5)

    response = {'glycemic_load': {}}
    
    for r in results:
        for box in r.boxes:
            class_name = r.names[int(box.cls)]
            response['glycemic_load'][class_name] = 10  # Dummy Value

    return response

if __name__ == "__main__":
    data = json.loads(sys.argv[1])
    image = data.get("image")
    response = predict_glycemic_load(image)
    print(json.dumps(response))