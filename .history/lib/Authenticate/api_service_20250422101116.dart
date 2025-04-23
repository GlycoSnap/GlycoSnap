import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.145.159:3000/api'; // Update to deployed URL later

  Future<void> addMeal({
    required String foodName,
    required double glycemicLoad,
    required String mealType,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');
    final token = await user.getIdToken();

    final response = await http.post(
      Uri.parse('$baseUrl/meals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'food_name': foodName,
        'glycemic_load': glycemicLoad,
        'meal_type': mealType,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add meal: ${response.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getMeals() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');
    final token = await user.getIdToken();

    final response = await http.get(
      Uri.parse('$baseUrl/meals'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch meals: ${response.body}');
    }

    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }
}