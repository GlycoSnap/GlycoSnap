import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = const String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://192.168.0.102:3000',
  );
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

  // Fetch quizzes
  Future<List<dynamic>> getQuizzes() async {
    try {
      final response = await supabase
          .from('quizzes')
          .select()
          .order('created_at', ascending: true);

      if (response == null) {
        throw Exception('Failed to fetch quizzes: No data returned');
      }

      return response;
    } catch (e) {
      print('Error fetching quizzes: $e');
      throw Exception(
          'Failed to fetch quizzes. Please check your internet connection.');
    }
  }

  // Save quiz result
  Future<void> saveQuizResult({
    required String quizId,
    required int selectedOption,
    required bool isCorrect,
  }) async {
    try {
      if (supabase.auth.currentUser == null) {
        throw Exception('User not authenticated');
      }
      await supabase.from('quiz_results').insert({
        'user_id': supabase.auth.currentUser!.id,
        'quiz_id': quizId,
        'selected_option': selectedOption,
        'is_correct': isCorrect,
        'attempted_at': DateTime.now().toIso8601String(),
      });
      print('Quiz result saved successfully');
    } catch (e) {
      print('Error saving quiz result: $e');
      throw Exception(
          'Failed to save quiz result. Please check your internet connection.');
    }
  }

  // Fetch user quiz progress
  Future<Map<String, dynamic>> getQuizProgress() async {
    try {
      if (supabase.auth.currentUser == null) {
        throw Exception('User not authenticated');
      }
      final results = await supabase
          .from('quiz_results')
          .select()
          .eq('user_id', supabase.auth.currentUser!.id);

      final quizzes = await supabase.from('quizzes').select().count();

      final totalQuizzes = quizzes.count;
      final completedQuizzes = results.length;
      final correctAnswers = results.where((r) => r['is_correct']).length;

      return {
        'total_quizzes': totalQuizzes,
        'completed_quizzes': completedQuizzes,
        'correct_answers': correctAnswers,
      };
    } catch (e) {
      print('Error fetching quiz progress: $e');
      throw Exception(
          'Failed to fetch quiz progress. Please check your internet connection.');
    }
  }
}
}