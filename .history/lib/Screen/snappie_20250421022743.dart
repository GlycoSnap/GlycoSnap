import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State createState() => _ChatPageState();
}

class _ChatPageState extends State with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // Replace with your backend URL
  final String apiUrl = const String.fromEnvironment('FASTAPI_URL',
      defaultValue: 'http://192.168.0.102:8000');

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // Helper function to scroll to the bottom
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Function to pick and analyze an image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _messages.add({
          'type': 'query',
          'text': '',
          'image': image.path,
        });
        _isLoading = true;
      });
      _scrollToBottom();

      // Analyze the image
      try {
        var request =
            http.MultipartRequest('POST', Uri.parse('$apiUrl/chatbot2/'));
        request.files
            .add(await http.MultipartFile.fromPath('file', image.path));
        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);

        setState(() {
          _messages.add({
            'type': 'response',
            'text': jsonResponse['message'] ?? 'No response from server.',
          });
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _messages.add({
            'type': 'response',
            'text': 'Error: $e',
          });
          _isLoading = false;
        });
      }

      _scrollToBottom();
    }
  }

  // Function to send text query to backend
  Future<void> _sendTextQuery() async {
    if (_controller.text.isEmpty) {
      return; // Silently ignore empty queries
    }
    setState(() {
      _messages.add({
        'type': 'query',
        'text': _controller.text,
      });
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      var response = await http.post(
        Uri.parse('$apiUrl/nutrition-query/'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'query': _controller.text},
      );

      var jsonResponse = jsonDecode(response.body);

      setState(() {
        _messages.add({
          'type': 'response',
          'text': jsonResponse['message'] ?? 'No response from server.',
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'type': 'response',
          'text': 'Error: $e',
        });
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: colorDarkest,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.all(size.width * 0.03),
              children: [
                SizedBox(height: size.height * 0.15),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hello, I\'m ',
                        style: TextStyle(
                          fontFamily: 'OpenSauce',
                          fontSize: size.width * 0.065,
                          fontWeight: FontWeight.bold,
                          color: white,
                        ),
                      ),
                      TextSpan(
                        text: 'Snappie!',
                        style: TextStyle(
                          fontFamily: 'OpenSauce',
                          fontSize: size.width * 0.065,
                          fontWeight: FontWeight.bold,
                          color: colorLight2,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                // Stack for bot image with glowing circle
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: size.height * 0.3,
                        height: size.height * 0.27,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorDark.withValues(alpha: 0.1),
                          boxShadow: [
                            BoxShadow(
                              color: colorDark.withValues(alpha: 1.2),
                              blurRadius: 40,
                              spreadRadius: 15,
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'images/bot3.png',
                        height: size.height * 0.3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                // Centered text
                Text(
                  "I can help you with nutrition\nand meal queries!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OpenSauce',
                    fontSize: size.width * 0.040,
                    color: white,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                Container(
                  color: backgroundColor3.withValues(alpha: 0.1),
                  child:Text(
                  "Upload a food image or type a question",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'OpenSauce',
                    fontSize: size.width * 0.030,
                    color: white,
                  ),
                ),
                ),
                SizedBox(height: size.height * 0.05),
                // Chat messages
                ..._messages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final message = entry.value;
                  final isQuery = message['type'] == 'query';
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.005,
                      horizontal: size.width * 0.02,
                    ),
                    child: Align(
                      alignment: isQuery
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: size.width * 0.7,
                        ),
                        padding: EdgeInsets.all(size.width * 0.03),
                        decoration: BoxDecoration(
                          color: isQuery
                              ? colorLight2.withOpacity(0.8)
                              : white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message['image'] != null)
                              Image.file(
                                File(message['image']!),
                                width: size.width * 0.5,
                                fit: BoxFit.cover,
                              ),
                            if (message['text']!.isNotEmpty)
                              Text(
                                message['text']!,
                                style: TextStyle(
                                  color: isQuery ? Colors.black : white,
                                  fontSize: size.width * 0.04,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.all(size.height * 0.01),
                    child: const TypingIndicator(),
                  ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
          // Text query input at the bottom
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.03,
              vertical: size.width * 0.02,
            ),
            color: colorDarkest,
            child: SafeArea(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: IconButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: _pickImage,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onPressed: _sendTextQuery,
                  ),
                  filled: true,
                  fillColor: backgroundColor3.withValues(alpha: 0.2),
                  labelStyle: TextStyle(color: white),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(0, 255, 255, 255), width: 1),
                  ),
                ),
                style: TextStyle(color: white),
                textInputAction: TextInputAction.send,
                onSubmitted: (value) => _sendTextQuery(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Typing Indicator Widget
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) => AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: white.withOpacity(
                        0.5 + (0.5 * ((_animation.value + index / 3) % 1))),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}