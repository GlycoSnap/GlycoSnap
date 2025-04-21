import 'dart:io'; import 'package:flutter/material.dart'; import 'package:glycosnap/Utils/colors.dart'; import 'package:http/http.dart' as http; import 'package:image_picker/image_picker.dart'; import 'dart:convert';

class ChatPage extends StatefulWidget { const ChatPage({super.key});

@override State createState() => _ChatPageState(); }

class _ChatPageState extends State with TickerProviderStateMixin { final TextEditingController _controller = TextEditingController(); final ImagePicker _picker = ImagePicker(); bool _isLoading = false; final List<Map<String, String>> _messages = []; final ScrollController _scrollController = ScrollController();

// Replace with your backend URL 
final String apiUrl = const String.fromEnvironment('FASTAPI_URL', defaultValue: 'http://192.168.0.102:8000');

@override void dispose() { _scrollController.dispose(); _controller.dispose(); super.dispose(); }

// Helper function to scroll to the bottom 
void scrollToBottom() { WidgetsBinding.instance.addPostFrameCallback(() { _scrollController.animateTo( _scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut, ); }); }

// Function to pick and analyze an image 
Future _pickImage() async { final XFile? image = await _picker.pickImage(source: ImageSource.gallery); if (image != null) { setState(() { _messages.add({ 'type': 'query', 'text': '', 'image': image.path, }); _isLoading = true; }); _scrollToBottom();
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
Future _sendTextQuery() async { if (_controller.text.isEmpty) { return; 
// Silently ignore empty queries 
} setState(() { _messages.add({ 'type': 'query', 'text': _controller.text, }); _isLoading = true; _controller.clear(); }); _scrollToBottom();

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

