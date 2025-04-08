import requests

NUTRITIONIX_APP_ID = "8f4db196"
NUTRITIONIX_APP_KEY = ""

def get_calories(food_name):
    url = "https://trackapi.nutritionix.com/v2/natural/nutrients"
    headers = {
        "Content-Type": "application/json",
        "x-app-id": NUTRITIONIX_APP_ID,
        "x-app-key": NUTRITIONIX_APP_KEY
    }
    data = {"query": food_name}
    
    response = requests.post(url, json=data, headers=headers)
    
    if response.status_code == 200:
        return response.json()
    else:
        return {"error": "Failed to fetch data"}
