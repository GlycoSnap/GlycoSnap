import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://I/flutter (27135): Server Response: {detected_foods: [mukimo, chicken, kachumbari], food_name: mukimo, kachumbari, chicken, glycemic_load: {chicken: 0, kachumbari: 9.632451394961935, mukimo: 29.088102290443736}, glycemic_load_category: High glycemic load, known_foods: [mukimo, chicken], total_glycemic_load: 38.72055368540567, unknown_foods: [kachumbari]}
W/WindowOnBackDispatcher(27135): sendCancelIfRunning: isInProgress=falsecallback=io.flutter.embedding.android.FlutterActivity$1@e8e130
I/flutter (27135): Error adding meal: ClientException with SocketException: Connection refused (OS Error: Connection refused, errno = 111), address = localhost, port = 39820, uri=http://localhost:3000/api/meals:3000/api'; // Update to deployed URL later

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