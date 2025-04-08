import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glycosnap/Screen/meal_provider.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  bool _isMealSelectionVisible = false;
  String? _foodName;
  final double _glycemicLoad = 0.0;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final String baseUrl =
      'http://192.168.0.101:5000/predict'; //Replace with your Flask server URL
//run ipconfig in cmd or powershell and find the ipv4 address under Wi-Fi

  Future<Map<String, dynamic>>? _glycemicLoadFuture;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _glycemicLoadFuture = _predictAndCalculateGL(); // Trigger calculation
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  String _imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }


  Future<Map<String, dynamic>> _predictAndCalculateGL() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return {
        'glycemic_load': 0.0,
        'total_glycemic_load': 0.0
      }; // Return default values
    }
    try {
      var base64Image = _imageToBase64(_imageFile!);
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('Server Response: $data'); // Debugging line
        return {
          'glycemic_load': data['glycemic_load'] ?? {},
          'total_glycemic_load': data['total_glycemic_load'] ?? 0.0,
          'glycemic_load_category': data['glycemic_load_category'] ?? 'Unknown',
          'food_name': data['food_name'] ?? 'Unknown Food',
        };
      } else {
        throw Exception('Failed to load glycemic load data');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to calculate glycemic load')),
      );
      return {
        'glycemic_load': 0.0,
        'total_glycemic_load': 0.0,
        'glycemic_load_category': 'Unknown',
        'food_name': 'Unknown Food',
      }; // Return default values on failure
    }
  }

  void _showMealSelectionDialog(
      BuildContext context, String foodName, double glycemicLoad) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Meal'),
          content: const Text('Which meal do you want to add this to?'),
          actions: [
            TextButton(
              onPressed: () {
                _addMeal(context, 'breakfast', foodName, glycemicLoad);
                Navigator.pop(context);
              },
              child: const Text('Breakfast'),
            ),
            TextButton(
              onPressed: () {
                _addMeal(context, 'lunch', foodName, glycemicLoad);
                Navigator.pop(context);
              },
              child: const Text('Lunch'),
            ),
            TextButton(
              onPressed: () {
                _addMeal(context, 'supper', foodName, glycemicLoad);
                Navigator.pop(context);
              },
              child: const Text('Supper'),
            ),
          ],
        );
      },
    );
  }

  void _toggleMealSelection() {
    setState(() {
      _isMealSelectionVisible = !_isMealSelectionVisible;
    });
  }

  // Function to handle meal addition
  void _addMeal(BuildContext context, String mealType, String foodName,
      double glycemicLoad) {
    final meal = Meal(name: foodName, glycemicLoad: glycemicLoad);
    Provider.of<MealProvider>(context, listen: false).addMeal(mealType, meal);
  }

  