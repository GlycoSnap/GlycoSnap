import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:glycosnap/Authenticate/api_service.dart';

class QuizScreen extends StatefulWidget {
  final Map<String, dynamic> quiz;

  const QuizScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? _selectedOption;
  bool? _isCorrect;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final options = widget.quiz['options'] as List<dynamic>;
    final correctOption = widget.quiz['correct_option'] as int;
    final explanation = widget.quiz['explanation'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.quiz['question'],
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ...options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return RadioListTile<int>(
                value: index,
                groupValue: _selectedOption,
                onChanged: _submitted
                    ? null
                    : (value) {
                        setState(() {
                          _selectedOption = value;
                        });
                      },
                title: Text(option),
                tileColor: _submitted
                    ? (index == correctOption
                        ? Colors.green.withOpacity(0.2)
                        : (index == _selectedOption && !_isCorrect!
                            ? Colors.red.withOpacity(0.2)
                            : null))
                    : null,
              );
            }).toList(),
            const SizedBox(height: 20),
            if (_submitted && explanation != null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Explanation: $explanation',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),
            const Spacer(),
            ElevatedButton(
              onPressed: _selectedOption == null || _submitted
                  ? null
                  : () async {
                      setState(() {
                        _submitted = true;
                        _isCorrect = _selectedOption == correctOption;
                      });
                      try {
                        await Provider.of<ApiService>(context, listen: false)
                            .saveQuizResult(
                          quizId: widget.quiz['id'],
                          selectedOption: _selectedOption!,
                          isCorrect: _isCorrect!,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isCorrect!
                                ? 'Correct! Well done!'
                                : 'Incorrect. Try another quiz!'),
                            backgroundColor:
                                _isCorrect! ? Colors.green : Colors.red,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
              child: const Text('Submit'),
            ).animate().scale(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

class LearnTab extends StatelessWidget {
  const LearnTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Provider.of<ApiService>(context, listen: false).getQuizzes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger rebuild to retry
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LearnTab(),
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final quizzes = snapshot.data ?? [];
          if (quizzes.isEmpty) {
            return const Center(child: Text('No quizzes available'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: quizzes.length,
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(quiz['question'] ?? 'Untitled Quiz'),
                  subtitle: Text(quiz['category'] ?? 'General'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizScreen(quiz: quiz),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}