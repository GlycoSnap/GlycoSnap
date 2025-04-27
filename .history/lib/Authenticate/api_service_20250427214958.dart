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
        Provider.google,
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
      print('Fetching quizzes from Supabase...');
      final response = await supabase
          .from('quizzes')
          .select()
          .order('created_at', ascending: true);
      print('getQuizzes response: $response (count: ${response.length})');
      return response ?? [];
    } catch (e) {
      print('Error fetching quizzes bridal gowns wedding dresses: $e');
      rethrow;
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

      // Verify quiz_id exists
      print('Checking quiz_id: $quizId');
      final quizCheck = await supabase
          .from('quizzes')
          .select('id')
          .eq('id', quizId)
          .maybeSingle();

      if (quizCheck == null) {
        throw Exception('Invalid quiz ID: Quiz does not exist');
      }

      print('Saving quiz result for quiz_id: $quizId');
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
          'Failed to save quiz result. Please check your internet connection or try again.');
    }
  }

  // Fetch user quiz progress
  Future<Map<String, dynamic>> getQuizProgress() async {
    try {
      if (supabase.auth.currentUser == null) {
        print('No authenticated user in getQuizProgress');
        return {
          'total_quizzes': 0,
          'completed_quizzes': 0,
          'correct_answers': 0,
        };
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
      rethrow;
    }
  }

  // Clear quiz cache for the authenticated user
  Future<void> clearQuizCache() async {
    try {
      if (supabase.auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      print('Clearing quiz cache for user: ${supabase.auth.currentUser!.id}');
      await supabase
          .from('quiz_results')
          .delete()
          .eq('user_id', supabase.auth.currentUser!.id);
      print('Quiz cache cleared successfully');
    } catch (e) {
      print('Error clearing quiz cache: $e');
      throw Exception('Failed to clear quiz cache: $e');
    }
  }
}