import 'package:flutter/material.dart';

class MealSelectionScreen extends StatefulWidget {
  @override
  _MealSelectionScreenState createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> {
  // State variable to control the visibility of the meal selection options
  bool _isMealSelectionVisible = false;

  // Function to toggle visibility
  void _toggleMealSelection() {
    setState(() {
      _isMealSelectionVisible = !_isMealSelectionVisible;
      print('Meal selection visibility toggled: $_isMealSelectionVisible'); // Debug print
    });
  }

  // Function to handle meal addition
  void _addMeal(BuildContext context, String mealType) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to $mealType')),
      );
      print('Meal added: $mealType'); // Debug print
    } catch (e) {
      print('Error adding meal: $e'); // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building MealSelectionScreen'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Selection'),
        backgroundColor: Colors.blue, // Ensure AppBar is visible
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _toggleMealSelection,
              child: Text('Select Meal'),
            ),
            if (_isMealSelectionVisible)
              Column(
                children: [
                  ListTile(
                    title: Text('Breakfast'),
                    onTap: () {
                      _addMeal(context, 'breakfast');
                    },
                  ),
                  ListTile(
                    title: Text('Lunch'),
                    onTap: () {
                      _addMeal(context, 'lunch');
                    },
                  ),
                  ListTile(
                    title: Text('Supper'),
                    onTap: () {
                      _addMeal(context, 'supper');
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
