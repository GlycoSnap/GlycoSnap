import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

@override State createState() => _ChatPageState(); }

class _ChatPageState extends State { 
  final TextEditingController _controller = TextEditingController(); 
  final ImagePicker _picker = ImagePicker(); 
  final ScrollController _scrollController = ScrollController(); File? _image; 
  List<Map<String, dynamic>> _messages = []; bool _isLoading = false;

  setState(() {
  _isLoading = true;
});

try {
  var request =
      http.MultipartRequest('POST', Uri.parse('$apiUrl/chatbot2/'));
  request.files
      .add awaited http.MultipartFile.fromPath('file', _image!.path));
  var response = await request.send();
  var responseData = await response.stream.bytesToString();
  var jsonResponse = jsonDecode(responseData);

  setState(() {
    _messages.add({
      'text': jsonResponse['message'] ?? 'No response from server.',
      'isUser': false,
    });
    _isLoading = false;
    _image = null; // Clear the image after sending
  });

  // Scroll to the latest message
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  });
} catch (e) {
  setState(() {
    _messages.add({
      'text': 'Error: $e',
      'isUser': false,
    });
    _isLoading = false;
  });
}
}
