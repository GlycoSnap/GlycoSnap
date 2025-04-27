import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glycosnap/Authenticate/api_service.dart';

class DailyQuizScreen extends StatefulWidget {
  const DailyQuizScreen({Key? key}) : super(key: key);

  @override
  _DailyQuizScreenState createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  Map<String, dynamic>? _quiz;
  int? _selectedOption;
  bool? _isCorrect;
  bool _submitted = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDailyQuiz();
  }

  Future<void> _loadDailyQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final storedDate = prefs.getString('quiz_date');
    final storedQuiz = prefs.getString('daily_quiz');

    print('LoadDailyQuiz: Today=$today, StoredDate=$storedDate, StoredQuiz=$storedQuiz');

    if (storedDate == today && storedQuiz != null) {
      // Use cached quiz for today
      print('Using cached quiz: $storedQuiz');
      setState(() {
        _quiz = jsonDecode(storedQuiz);
        _isLoading = false;
      });
      return;
    }

    // Fetch new random quiz
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final quizzes = await apiService.getQuizzes();
      print('Fetched quizzes: $quizzes');
      if (quizzes.isEmpty) {
        setState(() {
          _error = 'No quizzes available';
          _isLoading = false;
        });
        return;
      }

      // Select random quiz
      quizzes.shuffle();
      final selectedQuiz = quizzes.first;
      print('Selected quiz: $selectedQuiz');

      // Cache quiz
      await prefs.setString('quiz_date', today);
      await prefs.setString('daily_quiz', jsonEncode(selectedQuiz));

      setState(() {
        _quiz = selectedQuiz;
        _isLoading = false;
      });
    } catch (e) {
      print('Error in loadDailyQuiz: $e');
      setState(() {
        _error = 'Error loading quiz: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('SharedPreferences cleared');
    await _loadDailyQuiz();
  }

  void _submitAnswer() async {
    if (_selectedOption == null || _submitted) return;

    setState(() {
      _submitted = true;
      _isCorrect = _selectedOption == _quiz!['correct_option'];
    });

    try {
      print('Submitting quiz result for quiz_id: ${_quiz!['id']}');
      await Provider.of<ApiService>(context, listen: false).saveQuizResult(
        quizId: _quiz!['id'],
        selectedOption: _selectedOption!,
        isCorrect: _isCorrect!,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isCorrect! ? 'Correct! Great job!' : 'Incorrect. Try again tomorrow!'),
          backgroundColor: _isCorrect! ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      print('SubmitAnswer error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving result: $e')),
      );
      // Clear cache on foreign key or invalid quiz ID error
      if (e.toString().contains('Invalid quiz ID') || e.toString().contains('foreign key constraint')) {
        await _clearCache();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quiz cache refreshed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorDarkest,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: TextStyle(color: red)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDailyQuiz,
                child: Text('Retry'),
              ),
              ElevatedButton(
                onPressed: _clearCache,
                child: Text('Clear Cache (Debug)'),
              ),
            ],
          ),
        ),
      );
    }

    final options = _quiz!['options'] as List<dynamic>;
    final correctOption = _quiz!['correct_option'] as int;
    final explanation = _quiz!['explanation'] as String?;

    return Scaffold(
      backgroundColor: colorDarkest,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorLight.withOpacity(0.2),
                    colorDark.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Quiz content
            Column(
              children: [
                // Question section
                Container(
                  height: size.height * 0.3,
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      _quiz!['question'],
                      style: TextStyle(
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: white,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
                // Options section
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final isSelected = _selectedOption == index;
                      final isCorrectOption = index == correctOption;

                      return GestureDetector(
                        onTap: _submitted
                            ? null
                            : () {
                                setState(() {
                                  _selectedOption = index;
                                });
                              },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _submitted
                                ? (isCorrectOption
                                    ? Colors.green.withOpacity(0.8)
                                    : (isSelected && !_isCorrect!
                                        ? Colors.red.withOpacity(0.8)
                                        : Colors.grey.shade300))
                                : (isSelected
                                    ? Colors.yellow.withOpacity(0.5)
                                    : Colors.lightBlue),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected
                                  ? Colors.yellow
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: size.width * 0.05,
                              color: _submitted
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ).animate().scale(duration: 300.ms);
                    },
                  ),
                ),
                // Explanation and Submit button
                if (_submitted && explanation != null)
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Explanation: $explanation',
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _selectedOption == null || _submitted
                        ? null
                        : _submitAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorDark,
                      foregroundColor: backgroundColor1,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.1,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      _submitted ? 'Done' : 'Submit',
                      style: TextStyle(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().scale(duration: 300.ms),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}