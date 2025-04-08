def get_calories(food_name):
    # Example implementation (customize as needed)
    calorie_data = {
        "beef": 250,    # kcal per 100g
        "kales": 49,
        "ugali": 130,
        "rice": 130,
        "chapati": 300,
        "beans": 132,
        "cabbage": 25,
        "spinach": 23,
        "ndengu": 116
    }
    return {"calories": calorie_data.get(food_name.lower(), "Unknown food")}