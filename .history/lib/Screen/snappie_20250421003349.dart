import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _responseMessage = '';
  bool _isLoading = false;

  // Replace with your backend URL
  final String apiUrl = const String.fromEnvironment('FASTAPI_URL',
      defaultValue: 'http://192.168.0.102:8000');

  // Function to pick an image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  // Function to send image to backend
  Future<void> _sendImage() async {
    if (_image == null) {
      setState(() {
        _responseMessage = 'Please select an image first.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });

    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$apiUrl/chatbot2/'));
      request.files
          .add(await http.MultipartFile.fromPath('file', _image!.path));
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      setState(() {
        _responseMessage =
            jsonResponse['message'] ?? 'No response from server.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Function to send text query to backend
  Future<void> _sendTextQuery() async {
    if (_controller.text.isEmpty) {
      setState(() {
        _responseMessage = 'Please enter a query.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });

    try {
      var response = await http.post(
        Uri.parse('$apiUrl/nutrition-query/'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'query': _controller.text},
      );

      var jsonResponse = jsonDecode(response.body);

      setState(() {
        _responseMessage =
            jsonResponse['message'] ?? 'No response from server.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

