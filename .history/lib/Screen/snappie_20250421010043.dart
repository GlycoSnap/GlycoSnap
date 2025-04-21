import 'dart:io'; import 'package:flutter/material.dart'; import 'package:glycosnap/Utils/colors.dart'; import 'package:http/http.dart' as http; import 'package:image_picker/image_picker.dart'; import 'dart:convert';

class ChatPage extends StatefulWidget { const ChatPage({super.key});

@override State createState() => _ChatPageState(); }

class _ChatPageState extends State { final TextEditingController _controller = TextEditingController(); final ImagePicker _picker = ImagePicker(); File? _image; bool _isLoading = false; final List<Map<String, String>> _messages = []; // List to store queries and responses

// Replace with your backend URL 
final String apiUrl = const String.fromEnvironment('FASTAPI_URL', defaultValue: 'http://192.168.0.102:8000');

// Function to pick an image 
Future _pickImage() async { final XFile? image = await _picker.pickImage(source: ImageSource.gallery); if (image != null) { setState(() { _image = File(image.path); }); } }

// Function to send image to backend 
Future _sendImage() async { if (_image == null) { setState(() { _messages.add({ 'type': 'response', 'text': 'Please select an image first.', }); }); return; }