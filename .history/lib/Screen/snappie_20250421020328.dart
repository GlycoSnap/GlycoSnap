import 'dart:io'; import 'package:flutter/material.dart'; import 'package:glycosnap/Utils/colors.dart'; import 'package:http/http.dart' as http; import 'package:image_picker/image_picker.dart'; import 'dart:convert';

class ChatPage extends StatefulWidget { const ChatPage({super.key});

@override State createState() => _ChatPageState(); }

class _ChatPageState extends State with TickerProviderStateMixin { final TextEditingController _controller = TextEditingController(); final ImagePicker _picker = ImagePicker(); bool _isLoading = false; final List<Map<String, String>> _messages = []; final ScrollController _scrollController = ScrollController();

// Replace with your backend URL final String apiUrl = const String.fromEnvironment('FASTAPI_URL', defaultValue: 'http://192.168.0.102:8000');

@override void dispose() { _scrollController.dispose(); _controller.dispose(); super.dispose(); }

// Function to pick and analyze an image Future _pickImage() async { final XFile? image = await _picker.pickImage(source: ImageSource.gallery); if (image != null) { setState(() { _messages.add({ 'type': 'query', 'text': '', 'image': image.path, }); _isLoading = true; });