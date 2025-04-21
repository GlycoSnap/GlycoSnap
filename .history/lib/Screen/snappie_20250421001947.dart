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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorDarkest,
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.03),
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
            Stack(
              children: 
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: size.height * 0.02),
              child: Image.asset('images/bot2.png', height: size.height * 0.3),
            ),
            ),
            SizedBox(height: size.height * 0.02),
            // Centered text without \t
            Container(
              alignment: Alignment.center,
              child: Text(
                "I can help you with nutrition\nand meal queries!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'OpenSauce',
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: white,
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            // Image picker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Pick Image'),
                ),
                ElevatedButton(
                  onPressed: _sendImage,
                  child: const Text('Analyze Image'),
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
            // Text query input with camera and send icons
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color.fromARGB(255, 255, 255, 255),
                ), // Camera icon at start
                suffixIcon: const Icon(
                  Icons.send_rounded,
                  color: Color.fromARGB(255, 255, 255, 255),
                ), // Send icon at end
                filled: true,
                fillColor: backgroundColor3.withValues(alpha: 0.2),
                labelStyle: TextStyle(color: white),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Color.fromARGB(0, 255, 255, 255), width: 1),
                ),
              ),
              style: TextStyle(color: white),
            ),
            SizedBox(height: size.height * 0.02),
            ElevatedButton(
              onPressed: _sendTextQuery,
              child: const Text('Send Query'),
            ),
            SizedBox(height: size.height * 0.02),
            // Response display
            if (_isLoading) const CircularProgressIndicator(),
            if (_responseMessage.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _responseMessage,
                    style: TextStyle(fontSize: size.width * 0.04, color: white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
