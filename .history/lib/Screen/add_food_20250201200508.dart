import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glycosnap/Screen/meal_provider.dart';
import 'package:glycosnap/Screen/meal_selection.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  bool _isMealSelectionVisible = false;
  String? _foodName;
  final double _glycemicLoad = 0.0;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final String baseUrl =
      'http://10.5.17.78:5000'; // Replace with your Flask server URL

  Future<Map<String, dynamic>>? _glycemicLoadFuture;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      setState(() {
        _imageFile = File(pickedFile!.path);
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  String _imageToBase64(File image) {
    final bytes = image.readAsBytesSync();
    return base64Encode(bytes);
  }
  Future<Map<String, dynamic>> _predictAndCalculateGL() async {
    if (_imageFile == null) {
      // Show an error if no image is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return {}; // Return an empty map to maintain the return type consistency
    }

    try {
      var base64Image = _imageToBase64(_imageFile!);
      final response = await http.post(
        Uri.parse('$baseUrl/predict_gl'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load glycemic load data');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to calculate glycemic load')),
      );
      return {}; // Return an empty map to maintain the return type consistency
    }
  }

  /*Future<void> _handleResults(BuildContext context) async {
  try {
    final data = await _predictAndCalculateGL();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealSelectionScreen(data: data),
      ),
    );
  } catch (e) {
    // Handle error
    print('Error: $e');
  }
}*/

  void _toggleMealSelection() {
    setState(() {
      _isMealSelectionVisible = !_isMealSelectionVisible;
    });
  }

  // Function to handle meal addition
  void _addMeal(BuildContext context, String mealType) {
    final meal =
        Meal(name: _foodName ?? 'Unknown', glycemicLoad: _glycemicLoad);

    Provider.of<MealProvider>(context, listen: false).addMeal(mealType, meal);
    Navigator.pop(context); // Navigate back or perform another action
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: lightBackground,
        toolbarHeight: 60,
        title: SizedBox(
          width: 150,
          child: Image.asset('images/logo.png'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: [
          Container(
            height: 1000,
            decoration: BoxDecoration(
              color: lightBackground,
            ),
            child: Column(
              children: [
                // Camera and Gallery section
                Stack(
                  children: [
                    Container(
                      width: 380,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: const Color(0xffBEE1DD),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 50,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'TAKE A PICTURE OF YOUR FOOD',
                                style: TextStyle(
                                  fontFamily: 'OpenSauce',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () => _pickImage(ImageSource.camera),
                            child: const Text('Open Camera'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Stack(
                  children: [
                    Container(
                      width: 380,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: const Color(0xffBEE1DD),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: Colors.black,
                                size: 50,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'UPLOAD A PICTURE OF FOOD',
                                style: TextStyle(
                                  fontFamily: 'OpenSauce',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            child: const Text('Open Gallery'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Display selected image here
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Image.file(
                      _imageFile!,
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Color(0xff0C3B60)),
                  ),
                  onPressed: () {
                    setState(() {
                      _glycemicLoadFuture = _predictAndCalculateGL();
                    });
                  },
                  child: const Text(
                    'Calculate Glycemic Load',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PoppinsBold',
                      fontSize: 17,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Display results
                _glycemicLoadFuture == null
    ? Container()
    : FutureBuilder<Map<String, dynamic>>(
        future: _glycemicLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            final glycemicLoadCategory = data['glycemic_load_category'];
            Color categoryColor;

            // Set the color based on the glycemic load category
            if (glycemicLoadCategory == 'Low glycemic load') {
              categoryColor = Colors.green;
            } else if (glycemicLoadCategory == 'Medium glycemic load') {
              categoryColor = Colors.orange;
            } else {
              categoryColor = Colors.red;
            }

            return SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 216, 240, 240),
                ),
                alignment: Alignment.topCenter,
                width: 300,
                height: 230,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Glycemic Load Results:',
                      style: TextStyle(
                        fontFamily: 'PoppinsBold',
                        fontSize: 18,
                      ),
                    ),
                    ...data['glycemic_load'].entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '${entry.key}: ${entry.value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Total Glycemic Load: ',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${data['total_glycemic_load'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'PoppinsBold',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                          Text(
                            '$glycemicLoadCategory',
                            style: TextStyle(
                              fontFamily: 'PoppinsBold',
                              fontSize: 16,
                              color: categoryColor,
                            ),
                          ),
                       
                  ],
                ),
              ),
            );
          }
        },
      ),


                /*ElevatedButton(
                  onPressed: _toggleMealSelection,
                  child: Text('Add to: '),
                ),
                if (_isMealSelectionVisible)
                  Column(
                    children: [
                      ListTile(
                        title: Text('Breakfast'),
                        onTap: () {
                          _addMeal(context, 'breakfast');
                        },
                      ),
                      ListTile(
                        title: Text('Lunch'),
                        onTap: () {
                          _addMeal(context, 'lunch');
                        },
                      ),
                      ListTile(
                        title: Text('Supper'),
                        onTap: () {
                          _addMeal(context, 'supper');
                        },
                      ),
                    ],
                  ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }
}
