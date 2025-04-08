import 'package:flutter/material.dart';

class MealProvider with ChangeNotifier {
  final List<Meal> _breakfast = [];
  final List<Meal> _lunch = [];
  final List<Meal> _supper = [];

  List<Meal> get breakfast => _breakfast;
  List<Meal> get lunch => _lunch;
  List<Meal> get supper => _supper;

  void addMeal(String mealType, Meal meal) {
    if (mealType == 'breakfast') {
      _breakfast.add(meal);
    } else if (mealType == 'lunch') {
      _lunch.add(meal);
    } else if (mealType == 'supper') {
      _supper.add(meal);
    }
    notifyListeners();
  }
}

class Meal {
  final String name;
  final double glycemicLoad;

  Meal({required this.name, required this.glycemicLoad});
}
