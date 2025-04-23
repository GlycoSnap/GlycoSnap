import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading    => _isLoading;

  UserProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    // Listen for Supabase auth events
    _supabase.auth.onAuthStateChange.listen((data) {
      final event   = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        fetchUserProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _userProfile = null;
        notifyListeners();
      }
    });  // :contentReference[oaicite:1]{index=1}
  }

  Future<void> fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final response = await _supabase
          .from('users')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      _userProfile = response as Map<String, dynamic>?;
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
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Not logged in');

      final profile = {
        'user_id':      user.id,
        'first_name':   firstName,
        'last_name':    lastName,
        'gender':       gender,
        'date_of_birth': dateOfBirth,
        'height':       height,
        'weight':       weight,
        'email':        user.email,
      };

      // Upsert into your RLS‑protected table
      await _supabase
          .from('users')
          .upsert(profile, onConflict: ['user_id']);

      _userProfile = profile;
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
