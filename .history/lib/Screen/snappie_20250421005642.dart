import 'dart:io'; import 'package:flutter/material.dart'; import 'package:glycosnap/Utils/colors.dart'; import 'package:http/http.dart' as http; import 'package:image_picker/image_picker.dart'; import 'dart:convert';

class ChatPage extends StatefulWidget { const ChatPage({super.key});

@override State createState() => _ChatPageState(); }

class _ChatPageState extends State { 
  final TextEditingController _controller = TextEditingController(); 
  final ImagePicker _picker = ImagePicker(); 
  final ScrollController _scrollController = ScrollController(); File? _image; List<Map<String, dynamic>> _messages = []; bool _isLoading = false;

