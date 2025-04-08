import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glycosnap/Screen/meal_provider.dart';
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
      'http://10.5.18.155:5000/predict'; //Replace with your Flask server URL
//run ipconfig in cmd or powershell and find the ipv4 address under Wi-Fi

  Future<Map<String, dynamic>>? _glycemicLoadFuture;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _glycemicLoadFuture = _predictAndCalculateGL(); // Trigger calculation
        });
      }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
      return {
        'glycemic_load': 0.0,
        'total_glycemic_load': 0.0
      }; // Return default values
    }
    try {
      var base64Image = _imageToBase64(_imageFile!);

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('Server Response: $data'); // Debugging line
        return {
          'glycemic_load': data['glycemic_load'] ?? {},
          'total_glycemic_load': data['total_glycemic_load'] ?? 0.0,
          'glycemic_load_category': data['glycemic_load_category'] ?? 'Unknown',
          'food_name': data['food_name'] ?? 'Unknown Food',
        };
      } else {
        throw Exception('Failed to load glycemic load data');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to calculate glycemic load')),
      );
      return {
        'glycemic_load': 0.0,
        'total_glycemic_load': 0.0,
        'glycemic_load_category': 'Unknown',
        'food_name': 'Unknown Food',
      }; // Return default values on failure
    }
  }

  void _showMealSelectionDialog(
      BuildContext context, String foodName, double glycemicLoad) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Meal'),
          content: const Text('Which meal do you want to add this to?'),
          actions: [
            TextButton(
              onPressed: () {
                _addMeal(context, 'breakfast', foodName, glycemicLoad);
                Navigator.pop(context);
              },
              child: const Text('Breakfast'),
            ),
            TextButton(
              onPressed: () {
                _addMeal(context, 'lunch', foodName, glycemicLoad);
                Navigator.pop(context);
              },
              child: const Text('Lunch'),
            ),
            TextButton(
              onPressed: () {
                _addMeal(context, 'supper', foodName, glycemicLoad);
                Navigator.pop(context);
              },
              child: const Text('Supper'),
            ),
          ],
        );
      },
    );
  }

  void _toggleMealSelection() {
    setState(() {
      _isMealSelectionVisible = !_isMealSelectionVisible;
    });
  }

  // Function to handle meal addition
  void _addMeal(BuildContext context, String mealType, String foodName,
      double glycemicLoad) {
    final meal = Meal(name: foodName, glycemicLoad: glycemicLoad);
    Provider.of<MealProvider>(context, listen: false).addMeal(mealType, meal);
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
      body: SingleChildScrollView(
        child: Column(
          spacing: 10,
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
                      backgroundColor:
                          WidgetStatePropertyAll(Color(0xff0C3B60)),
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('No data available'));
                            } else {
                              final data = snapshot.data!;
                              final glycemicLoadCategory =
                                  data['glycemic_load_category']?.toString() ??
                                      'Unknown';
                              Color categoryColor;

                              // Set the color based on the glycemic load category
                              if (glycemicLoadCategory == 'Low glycemic load') {
                                categoryColor = Colors.green;
                              } else if (glycemicLoadCategory ==
                                  'Medium glycemic load') {
                                categoryColor =
                                    Colors.yellow; // Updated to yellow
                              } else if (glycemicLoadCategory ==
                                  'High glycemic load') {
                                categoryColor = Colors.red;
                              } else {
                                categoryColor = Colors
                                    .black; // fallback color for unknown category
                              }

                              // Safely handle the glycemic_load field
                              final glycemicLoad =
                                  data['glycemic_load'] is Map<String, dynamic>
                                      ? data['glycemic_load']
                                          as Map<String, dynamic>
                                      : <String, dynamic>{};

                              // Safely handle total glycemic load
                              final totalGL =
                                  (data['total_glycemic_load'] as num?)
                                          ?.toDouble() ??
                                      0.0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SingleChildScrollView(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: const Color.fromARGB(
                                            255, 216, 240, 240),
                                      ),
                                      alignment: Alignment.topCenter,
                                      width: 300,
                                      height: 230,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Glycemic Load Results:',
                                            style: TextStyle(
                                              fontFamily: 'PoppinsBold',
                                              fontSize: 18,
                                            ),
                                          ),
                                          ...glycemicLoad.entries.map((entry) {
                                            final value = (entry.value as num?)
                                                    ?.toStringAsFixed(2) ??
                                                'N/A';
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0),
                                              child: Text(
                                                '${entry.key}: $value',
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
                                                  text: totalGL
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                    fontFamily: 'PoppinsBold',
                                                    fontSize: 16,
                                                    color: categoryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          // New widget to display category text
                                          Text(
                                            glycemicLoadCategory,
                                            style: TextStyle(
                                              fontFamily: 'PoppinsBold',
                                              fontSize: 16,
                                              color: categoryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      final foodName =
                                          data['food_name']?.toString() ??
                                              'Unknown Food';
                                      _showMealSelectionDialog(
                                          context, foodName, totalGL);
                                    },
                                    child: const Text('Add to Meal'),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
