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

class _ChatPageState extends State {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isLoading = false;
  final List<Map<String, String>> _messages =
      []; // List to store queries and responses

// Replace with your backend URL 
final String apiUrl = const String.fromEnvironment('FASTAPI_URL',
      defaultValue: 'http://192.168.0.102:8000');

// Function to pick an image
  Future _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

// Function to send image to backend
  Future _sendImage() async {
    if (_image == null) {
      setState(() {
        _messages.add({
          'type': 'response',
          'text': 'Please select an image first.',
        });
      });
      return;
    }
    setState(() {
      _isLoading = true;
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
  }

// Function to send text query to backend 
Future _sendTextQuery() async { if (_controller.text.isEmpty) { return; 
// Silently ignore empty queries
}
// Add the query to the message list
setState(() {
  _messages.add({
    'type': 'query',
    'text': _controller.text,
  });
  _isLoading = true;
});

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
    _controller.clear(); // Clear the TextField after submission
  });
} catch (e) {
  setState(() {
    _messages.add({
      'type': 'response',
      'text': 'Error: $e',
    });
    _isLoading = false;
    _controller.clear();
  });
}
}

@override Widget build(BuildContext context) { final size = MediaQuery.of(context).size;
return Scaffold(
  backgroundColor: colorDarkest,
  body: Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.03).copyWith(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.15),
                RichText(
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: size.height * 0.3,
                      height: size.height * 0.27,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorDark.withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: colorLight2.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'images/bot2.png',
                      height: size.height * 0.3,
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.025),
                // Centered text
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "I can help you with nutrition\nand meal queries!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'OpenSauce',
                      fontSize: size.width * 0.040,
                      color: white,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                // Image picker
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      icon: const Icon(
                        Icons.image,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      label: Text(
                        'Pick Image',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.05),
                    ElevatedButton(
                      onPressed: _sendImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Analyze Image',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_image != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    child: Image.file(
                      _image!,
                      height: size.height * 0.2,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: size.height * 0.02),
                // Chat messages
                Container(
                  constraints: BoxConstraints(
                    maxHeight: size.height * 0.3,
                  ),
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isQuery = message['type'] == 'query';
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.005,
                          horizontal: size.width * 0.02,
                        ),
                        child: Align(
                          alignment: isQuery ? Alignment.centerRight : Alignment.centerLeft,
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
                            child: Text(
                              message['text']!,
                              style: TextStyle(
                                color: isQuery ? Colors.black : white,
                                fontSize: size.width * 0.04,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.all(size.height * 0.01),
                    child: const CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        // Text query input at the bottom
        Padding(
          padding: EdgeInsets.all(size.width * 0.03).copyWith(
            bottom: MediaQuery.of(context).viewInsets.bottom + size.width * 0.03,
          ),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(
                Icons.camera_alt_outlined,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                onPressed: _sendTextQuery,
              ),
              filled: true,
              fillColor: backgroundColor3.withOpacity(0.2),
              labelStyle: TextStyle(color: white),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide:
                    const BorderSide(color: Color.fromARGB(0, 255, 255, 255), width: 1),
              ),
            ),
            style: TextStyle(color: white),
            textInputAction: TextInputAction.send,
            onSubmitted: (value) => _sendTextQuery(),
          ),
        ),
      ],
    ),
  );
}
}