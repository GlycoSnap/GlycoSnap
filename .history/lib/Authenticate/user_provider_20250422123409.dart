import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  UserProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        print('Auth state changed: uid=${user?.uid}, email=${user?.email}');
        if (user != null) {
          await fetchUserProfile();
        } else {
          _userProfile = null;
          notifyListeners();
        }
      }, onError: (error) {
        print('Auth state error: $error');
      });
    } catch (e) {
      print('Error setting up auth listener: $e');
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      _isLoading = true;
      notifyListeners();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');
      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', user.uid)
          .maybeSingle();
      _userProfile = response;
      print('Fetched user profile: $_userProfile');
    } catch (e) {
      print('Error fetching user profile: $e');
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserProfile({
    required String firstName,
    required String lastName,
    String? gender,
    String? dateOfBirth,
    double? height,
    double? weight,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');
      final profile = {
        'user_id': user.uid,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'date_of_birth': dateOfBirth,
        'height': height,
        'weight': weight,
        'email': user.email,
        'created_at': DateTime.now().toIso8601String(),
      };
      await _supabase.from('users').upsert(profile, onConflict: 'user_id');
      _userProfile = profile;
      print('Saved user profile: $profile');
    } catch (e) {
      print('Error saving user profile: $e');
      throw Exception('Failed to save profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}