from fastapi import FastAPI, UploadFile, File, Form
from ultralytics import YOLO
import cv2
import numpy as np
from io import BytesIO
import google.generativeai as genai

#initialize FastAPI
app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Welcome to the Glycosnap Chatbot API!"}

#Model
model = YOLO("") 

#Initialise Gemini
genai.configure(api_key="AIzaSyAZm5KvRtMP1_2kBgv-y3DLBXKryp9QFsk")
gemini_model = genai.GenerativeModel("gemini-1.5-flash")

#Detect food items
def detect_food(image_bytes):

    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    results = model(img)

    detected_items  = []
    for result in results:
        for box in result.boxes:
            label = model.names[int(box.cls)]
            confidence = float(box.conf)
            detected_items.append({"label": label, "confidence": confidence})
    return detected_items

# Generate Gemini response for image-based queries
def generate_gemini_response_for_image(food_items):
    if not food_items:
        return "I couldn't detect any food items in the image. Please try uploading another one!"
    food_list = ", ".join([item["label"] for item in food_items])
    prompt = f"The user uploaded an image with these food items: {food_list}. Provide nutritional advice and a meal plan suggestion."
    try:
        response = gemini_model.generate_content(
            prompt,
            generation_config={"max_output_tokens": 300}
        )
        return response.text
    except Exception as e:
        return f"Error generating response: {str(e)}"

# Generate Gemini response for text-based queries
def generate_gemini_response_for_text(query: str):
    prompt = f"The user asked: {query}. Provide a helpful response about nutrition or meal planning."
    try:
        response = gemini_model.generate_content(
            prompt,
            generation_config={"max_output_tokens": 300}
        )
        return response.text
    except Exception as e:
        return f"Error generating response: {str(e)}"

# Endpoint for image uploads
@app.post("/chatbot2/")
async def chatbot2(file: UploadFile = File(...)):
    image_bytes = await file.read()
    food_items = detect_food(image_bytes)
    response = generate_gemini_response_for_image(food_items)
    return {"message": response}

# Endpoint for text queries
@app.post("/nutrition-query/")
async def nutrition_query(query: str = Form(...)):
    response = generate_gemini_response_for_text(query)
    return {"message": response}
