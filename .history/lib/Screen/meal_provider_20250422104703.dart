import 'package:flutter/material.dart';
import '../Authenticate/api_service.dart'; // Adjust path if needed

class MealProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Meal> _breakfast = [];
  List<Meal> _lunch = [];
  List<Meal> _supper = [];
  bool _isLoading = false;

  MealProvider(this._apiService)

  List<Meal> get breakfast => _breakfast;
  List<Meal> get lunch => _lunch;
  List<Meal> get supper => _supper;
  bool get isLoading => _isLoading;

  

  Future<void> fetchMeals() async {
    try {
      _isLoading = true;
      notifyListeners();
      final meals = await _apiService.getMeals();
      _breakfast = meals
          .where((meal) => meal['meal_type'] == 'breakfast')
          .map((meal) => Meal(
                name: meal['food_name'],
                glycemicLoad: (meal['glycemic_load'] as num).toDouble(),
              ))
          .toList();
      _lunch = meals
          .where((meal) => meal['meal_type'] == 'lunch')
          .map((meal) => Meal(
                name: meal['food_name'],
                glycemicLoad: (meal['glycemic_load'] as num).toDouble(),
              ))
          .toList();
      _supper = meals
          .where((meal) => meal['meal_type'] == 'supper')
          .map((meal) => Meal(
                name: meal['food_name'],
                glycemicLoad: (meal['glycemic_load'] as num).toDouble(),
              ))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error fetching meals: $e');
    }
  }

  Future<void> addMeal(String mealType, Meal meal) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.addMeal(
        foodName: meal.name,
        glycemicLoad: meal.glycemicLoad,
        mealType: mealType,
      );
      await fetchMeals(); // Refresh meals from Supabase
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error adding meal: $e');
      throw e; // Let UI handle error
    }
  }
}

class Meal {
  final String name;
  final double glycemicLoad;

  Meal({required this.name, required this.glycemicLoad});
}