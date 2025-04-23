import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final String baseUrl = const String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://192.168.0.102:3000',
  );
  final SupabaseClient supabase = Supabase.instance.client;

  ApiService() {
    print('ApiService initialized with baseUrl: $baseUrl');
  }

  // Helper to get Supabase JWT token
  Future<String?> _getAuthToken() async {
    final session = supabase.auth.currentSession;
    return session?.accessToken;
  }

  // Fetch meals for the authenticated user
  Future<List<dynamic>> getMeals() async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authenticated user');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/meals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch meals: ${response.body}');
    }
  }

  // Add a meal for the authenticated user
  Future<void> addMeal({
    required String foodName,
    required double glycemicLoad,
    required String mealType,
  }) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('No authenticated user');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/meals'),
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
}