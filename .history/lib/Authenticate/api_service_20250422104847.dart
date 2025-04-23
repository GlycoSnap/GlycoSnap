import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://192.168.145.159:3000/api'; // Update to deployed URL later

  Future<void> addMeal({
    required String foodName,
    required double glycemicLoad,
    required String mealType,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');
    final token = await user.getIdToken();
    print('Adding meal for user: ${user.uid}, token: $token');
    print(
        'Payload: food_name=$foodName, glycemic_load=$glycemicLoad, meal_type=$mealType');
    try {
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
      print('Response: ${response.statusCode} ${response.body}');
      if (response.statusCode != 201) {
        try {
          final errorJson = jsonDecode(response.body);
          throw Exception(errorJson['error'] ?? 'Unknown error');
        } catch (_) {
          throw Exception('Failed to add meal: ${response.body}');
        }
      }
    } catch (e) {
      print('Error in addMeal: $e');
      rethrow; // Pass to caller (AddFood)
    }
  }

 Future<List<Map<String, dynamic>>> getMeals() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('Not logged in');
  final token = await user.getIdToken();
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/meals'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('Get meals response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch meals: ${response.body}');
    }
  } catch (e) {
    print('Error in getMeals: $e');
    rethrow;
  }
}
