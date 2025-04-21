
import 'dart:io'; import 'package:flutter/material.dart'; import 'package:glycosnap/Utils/colors.dart'; import 'package:http/http.dart' as http; import 'package:image_picker/image_picker.dart'; import 'dart:convert';

class ChatPage extends StatefulWidget { const ChatPage({super.key});

@override State createState() => _ChatPageState(); }

class _ChatPageState extends State { final TextEditingController _controller = TextEditingController(); final ImagePicker _picker = ImagePicker(); final ScrollController _scrollController = ScrollController(); File? _image; List<Map<String, dynamic>> _messages = []; bool _isLoading = false;

// Replace with your backend URL final String apiUrl = const String.fromEnvironment('FASTAPI_URL', defaultValue: 'http://192.168.0.102:8000');

// Function to pick an image Future _pickImage() async { final XFile? image = await _picker.pickImage(source: ImageSource.gallery); if (image != null) { setState(() { _image = File(image.path); }); } }

// Function to send image to backend Future _sendImage() async { if (_image == null) { return; // Silently ignore if no image is selected }

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

// Function to send text query to backend Future _sendTextQuery() async { if (_controller.text.isEmpty) { return; // Silently ignore empty queries }

final query = _controller.text;
setState(() {
  _messages.add({
    'text': query,
    'isUser': true,
  });
  _isLoading = true;
  _controller.clear(); // Clear the TextField
});

// Scroll to the latest message
WidgetsBinding.instance.addPostFrameCallback((_) {
  _scrollController.animateTo(
    _scrollController.position.maxScrollExtent,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
});

try {
  var response = await http.post(
    Uri.parse('$apiUrl/nutrition-query/'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {'query': query},
  );

  var jsonResponse = jsonDecode(response.body);

  setState(() {
    _messages.add({
      'text': jsonResponse['message'] ?? 'No response from server.',
      'isUser': false,
    });
    _isLoading = false;
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

@override Widget build(BuildContext context) { final size = MediaQuery.of(context).size;
return Scaffold(
  backgroundColor: colorDarkest,
  body: Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
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
                ListView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message['isUser'] as bool;
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: size.height * 0.005,
                          horizontal: size.width * 0.02,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.01,
                          horizontal: size.width * 0.04,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? colorLight2.withOpacity(0.8)
                              : white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: size.width * 0.7,
                        ),
                        child: Text(
                          message['text'] as String,
                          style: TextStyle(
                            color: isUser ? white : white,
                            fontSize: size.width * 0.04,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (_isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                    child: const CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
        // Text query input
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
  ),
);
