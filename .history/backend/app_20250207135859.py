from flask import Flask, request, jsonify
import numpy as np
import cv2
import base64
from ultralytics import YOLO

app = Flask(__name__)

model_path = 'C:/Users/USER/OneDrive/Desktop/glycosnap/glycosnap_model.pt'
yolo_model = YOLO(model_path)  # Replace with actual loading method

# Define GI values and carbohydrate densities
GI_VALUES = {
    'ugali': 67,
    'beef': 0,
    'kales': 3,
    'chapati': 52,
    'ndengu': 38,
    'spinach': 15,
    'rice': 73,
    'beans': 20,
    'cabbage': 10
}

CARB_DENSITY = {
    'ugali': 1.725,
    'beef': 0,
    'kales': 0.45,
    'chapati': 0.36,
    'ndengu': 0.675,
    'spinach': 0.45,
    'rice': 0.525,
    'beans': 0.675,
    'cabbage': 0.375
}

def calculate_area(mask):
    return np.count_nonzero(mask)

def calculate_glycemic_load(class_name, area_cm2):
    gi = GI_VALUES.get(class_name, 0)
    carbs_g = area_cm2 * CARB_DENSITY.get(class_name, 0)
    return (gi * carbs_g) / 100 if gi > 0 else 0

def calculate_total_glycemic_load(results):
    total_gl = sum(results['glycemic_load'].values())
    print(f"Total Glycemic Load: {total_gl:.2f}")
    return total_gl

def categorize_glycemic_load(total_gl):
    if total_gl <= 10:
        return 'Low glycemic load'
    elif 11 <= total_gl <= 19:
        return 'Medium glycemic load'
    else:
        return 'High glycemic load'

def decode_image(image_base64):
    # Add necessary padding if missing
    missing_padding = len(image_base64) % 4
    if missing_padding != 0:
        image_base64 += '=' * (4 - missing_padding)
    image_data = base64.b64decode(image_base64)
    np_arr = np.frombuffer(image_data, np.uint8)
    return cv2.imdecode(np_arr, cv2.IMREAD_COLOR)


@app.route('/')
def home():
    return 'Welcome to the Food Segmentation and Glycemic Load API!'

@app.route('/favicon.ico')
def favicon():
    return '', 204  # No Content response

@app.route('/predict_gl', methods=['POST'])
def predict_and_calculate_gl():
    image_data = request.json.get('image')
    if not image_data:
        return jsonify({'error': 'No image provided'}), 400

    image = decode_image(image_data)
    
    # Perform inference with YOLOv8 model to get segmentation masks and areas
    results = yolo_model.predict(image, save=True, imgsz=320, conf=0.5)
    
    # Dictionary to store glycemic load results and segmentation details
    response = {
        'glycemic_load': {},
        'segmentation_results': []
    }

    if not results:
        return jsonify({'error': 'No objects detected'}), 400

    # Iterate through each detected instance in results
    for r in results:
        boxes = r.boxes  # Get the Boxes object containing the bounding boxes
        masks = r.masks  # Get the Masks object containing the segmentation masks
        names = r.names  # Get the names of the detected classes
        
        if boxes is None or masks is None:
            continue  # Skip this result if no boxes or masks

        # Iterate through each mask and its corresponding box
        for mask, box in zip(masks, boxes):
            class_idx = int(box.cls)  # Get the class index from the box
            class_name = names[class_idx]  # Get the class name using the index
            
            # Calculate the area of the segmentation mask
            mask_np = mask.data.cpu().numpy()  # Convert mask to numpy array
            area = np.sum(mask_np)  # Sum of all pixels in the mask
            
            # Calculate Glycemic Load (GL) for the food item
            if area > 0:
                # Convert segmented area to square centimeters (or appropriate unit)
                area_cm2 = area * (0.0264583333 ** 2)  # Example pixel to cm conversion
                
                # Calculate carbohydrates using carbohydrate density
                carbs_g = area_cm2 * CARB_DENSITY.get(class_name, 0)
                
                # Calculate Glycemic Load (GL) using GI and carbs in grams
                gi = GI_VALUES.get(class_name, 0)
                gl = (gi * carbs_g) / 100 if gi > 0 else 0
                
                # Store Glycemic Load for this food item
                response['glycemic_load'][class_name] = gl

                # Add segmentation results
                response['segmentation_results'].append({
                    'class_name': class_name,
                    'area_cm2': area_cm2,
                })
                

    # Return the detailed results as JSON
    total_glycemic_load = calculate_total_glycemic_load(response)
    response['total_glycemic_load'] = total_glycemic_load
    response['glycemic_load_category'] = categorize_glycemic_load(total_glycemic_load)
    
    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
