import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
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
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _loadDailyQuiz();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadDailyQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
    final storedDate = prefs.getString('quiz_date');
    final storedQuiz = prefs.getString('daily_quiz');

    print(
        'LoadDailyQuiz: Today=$today, StoredDate=$storedDate, StoredQuiz=$storedQuiz');

    if (storedDate == today && storedQuiz != null) {
      print('Using cached quiz: $storedQuiz');
      setState(() {
        _quiz = jsonDecode(storedQuiz);
        _isLoading = false;
      });
      return;
    }

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

      quizzes.shuffle();
      final selectedQuiz = quizzes.first;
      print('Selected quiz: $selectedQuiz');

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
      if (_isCorrect!) {
        _confettiController.play();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isCorrect!
                ? 'Correct! Great job! 🎉'
                : 'Incorrect. Try again tomorrow! 😊',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: white,
            ),
          ),
          backgroundColor: _isCorrect! ? Colors.green.shade700 : red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('SubmitAnswer error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error saving result: $e',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              color: white,
            ),
          ),
          backgroundColor: red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      );
      if (e.toString().contains('Invalid quiz ID') ||
          e.toString().contains('foreign key constraint')) {
        await _clearCache();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quiz cache refreshed. Please try again.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: white,
              ),
            ),
            backgroundColor: colorDark,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorDarkest,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorLight,
                      strokeWidth: 3,
                    ),
                  )
                : _error != null
                    ? _buildErrorUI(size)
                    : _buildQuizUI(size),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.02,
              numberOfParticles: 50,
              gravity: 0.2,
              shouldLoop: false,
              colors: [
                colorLight,
                Colors.yellow,
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.purple,
                white,
              ],
              minimumSize: const Size(10, 10),
              maximumSize: const Size(20, 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI(Size size) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: red,
              size: size.width * 0.1,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: size.width * 0.045,
                color: colorDarkest,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDailyQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorDark,
                foregroundColor: black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _clearCache,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorDark,
                side: BorderSide(color: colorDark, width: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Clear Cache (Debug)',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizUI(Size size) {
    final options = _quiz!['options'] as List<dynamic>;
    final correctOption = _quiz!['correct_option'] as int;
    final explanation = _quiz!['explanation'] as String?;

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            color: colorDarkest,
          ),
        ),
        // Quiz content
        Column(
          children: [
            // Header with question
            Container(
              height: size.height * 0.28,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/quiz.jpeg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.all(
                    Radius.circular(30),
                  ),
                ),
                child: Center(
                  child: Text(
                    _quiz!['question'],
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: size.width * 0.06,
                      fontWeight: FontWeight.bold,
                      color: white,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
            // Options section
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: _submitted
                            ? (isCorrectOption
                                ? Colors.green // correct answer
                                : (isSelected && !_isCorrect!
                                    ? Colors.redAccent // wrong answer selected
                                    : Colors.white.withOpacity(0.85))) // others
                            : (isSelected
                                ? colorLight2 // selected, before submit
                                : Colors.white, // unselected

                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected ? colorLight : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w600,
                          color: _submitted
                              ? white
                              : (_submitted || isSelected
                                  ? colorDarkest
                                  : colorDark),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                      .animate()
                      .scale(duration: 400.ms)
                      .fadeIn(duration: 400.ms, delay: (100 * index).ms);
                },
              ),
            ),
            // Explanation and Submit button
            if (_submitted && explanation != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Explanation: $explanation',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w500,
                    color: colorDarkest,
                    height: 1.5,
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: _selectedOption == null || _submitted
                    ? null
                    : _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorDark,
                  foregroundColor: white,
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.15,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.3),
                  disabledBackgroundColor: colorDark.withOpacity(0.5),
                  disabledForegroundColor: white.withOpacity(0.7),
                ),
                child: Text(
                  _submitted ? 'Done' : 'Submit',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ).animate().scale(duration: 400.ms).fadeIn(duration: 400.ms),
            ),
          ],
        ),
      ],
    );
  }
}
