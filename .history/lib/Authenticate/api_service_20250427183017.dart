import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final SupabaseClient supabase = Supabase.instance.client;

  ApiService() {
    print('ApiService initialized with Supabase client');
  }

  // Helper to get Supabase JWT token
  Future<String?> _getAuthToken() async {
    final session = supabase.auth.currentSession;
    return session?.accessToken;
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.glycosnap://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign up with Google
  Future<void> signUpWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.glycosnap://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error signing up with Google: $e');
      rethrow;
    }
  }

  // Fetch meals for the authenticated user
  Future<List<dynamic>> getMeals() async {
    try {
      final response = await supabase
          .from('meals')
          .select()
          .order('created_at', ascending: false);

      if (response == null) {
        throw Exception('Failed to fetch meals: No data returned');
      }

      return response;
    } catch (e) {
      print('Error fetching meals: $e');
      throw Exception(
          'Failed to fetch meals. Please check your internet connection.');
    }
  }

  // Add a meal for the authenticated user
  Future<void> addMeal({
  required String foodName,
  required double glycemicLoad,
  required String mealType,
}) async {
  try {
    final response = await supabase.from('meals').insert({
      'foodname': foodName, // Changed from 'food_name' to 'name'
      'glycemic_load': glycemicLoad,
      'meal_type': mealType,
      'created_at': DateTime.now().toIso8601String(),
      'user_id': supabase.auth.currentUser?.id, // Add user_id for RLS
    });

    if (response == null) {
      throw Exception('Failed to add meal: No response from server');
    }
    print('Meal added successfully');
  } catch (e) {
    print('Error adding meal: $e');
    throw Exception(
        'Failed to add meal. Please check your internet connection.');
  }
}
}