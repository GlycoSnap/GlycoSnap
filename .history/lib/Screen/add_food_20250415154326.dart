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
      'http://10.5.19.48:5000/predict'; //Replace with your Flask server URL
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
    // Get screen dimensions
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding; // For SafeArea-like padding

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: lightBackground,
        toolbarHeight: size.height * 0.08, // 8% of screen height
        title: SizedBox(
          width: size.width * 0.4, // 40% of screen width
          child: Image.asset('images/logo.png'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05), // 5% padding on sides
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Camera section
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.9, // 90% of screen width
                      height: size.height * 0.15, // 18% of screen height
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: const Color(0xffBEE1DD),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              height:
                                  size.height * 0.01), // 2% of screen height
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: size.width * 0.12, // 12% of screen width
                              ),
                              SizedBox(
                                  width:
                                      size.width * 0.02), // 3% of screen width
                              Text(
                                'TAKE A PICTURE OF YOUR FOOD',
                                style: TextStyle(
                                  fontFamily: 'OpenSauce',
                                  fontSize:
                                      size.width * 0.040, // Scaled font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _pickImage(ImageSource.camera),
                            child: Text(
                              'Open Camera',
                              style: TextStyle(
                                  fontSize:
                                      size.width * 0.04), // Scaled font size
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.015), // 3% of screen height

                // Gallery section
                Stack(
                  children: [
                    Container(
                      width: size.width * 0.9, // 90% of screen width
                      height: size.height * 0.15, // 18% of screen height
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: const Color(0xffBEE1DD),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                              height:
                                  size.height * 0.02), // 2% of screen height
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: Colors.black,
                                size: size.width * 0.12, // 12% of screen width
                              ),
                              SizedBox(
                                  width:
                                      size.width * 0.015), // 3% of screen width
                              Text(
                                'UPLOAD A PICTURE OF FOOD',
                                style: TextStyle(
                                  fontFamily: 'OpenSauce',
                                  fontSize:
                                      size.width * 0.040, // Scaled font size
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          
                          ElevatedButton(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            child: Text(
                              'Open Gallery',
                              style: TextStyle(
                                  fontSize:
                                      size.width * 0.04), // Scaled font size
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                 // 1.5% of screen height

                // Display selected image
                if (_imageFile != null)
                  Padding(
                    padding: EdgeInsets.only(
                        top: size.height * 0.02), // 2% of screen height
                    child: Image.file(
                      _imageFile!,
                      width: size.width * 0.7, // 90% of screen width
                      height: size.height * 0.3, // 30% of screen height
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: size.height * 0.015), // 1.5% of screen height

                // Calculate button
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        const WidgetStatePropertyAll(Color(0xff0C3B60)),
                    padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(
                        horizontal: size.width * 0.04, // 10% of screen width
                        vertical: size.height * 0.015, // 1.5% of screen height
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _glycemicLoadFuture = _predictAndCalculateGL();
                    });
                  },
                  child: Text(
                    'Calculate Glycemic Load',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'PoppinsBold',
                      fontSize: size.width * 0.045, // Scaled font size
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.015), // 2.5% of screen height

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
                              categoryColor = Colors.orange;
                            } else if (glycemicLoadCategory ==
                                'High glycemic load') {
                              categoryColor = Colors.red;
                            } else {
                              categoryColor = Colors.black; // Fallback color
                            }

                            // Safely handle the glycemic_load field
                            final glycemicLoad = data['glycemic_load']
                                    is Map<String, dynamic>
                                ? data['glycemic_load'] as Map<String, dynamic>
                                : <String, dynamic>{};

                            // Safely handle total glycemic load
                            final totalGL =
                                (data['total_glycemic_load'] as num?)
                                        ?.toDouble() ??
                                    0.0;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      size.width * 0.8, // 80% of screen width
                                  height:
                                      size.height * 0.3, // 30% of screen height
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color.fromARGB(
                                        255, 216, 240, 240),
                                  ),
                                  padding: EdgeInsets.all(
                                      size.width * 0.03), // 3% padding
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ...glycemicLoad.entries.map((entry) {
                                          final value = (entry.value as num?)
                                                  ?.toStringAsFixed(2) ??
                                              'N/A';
                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: size.height *
                                                    0.005), // Scaled padding
                                            child: Text(
                                              '${entry.key}: $value',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: size.width *
                                                    0.04, // Scaled font size
                                                color: Colors.black,
                                              ),
                                            ),
                                          );
                                        }),
                                        SizedBox(
                                            height: size.height *
                                                0.01), // 2% of screen height
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'Total Glycemic Load: ',
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: size.width *
                                                      0.04, // Scaled font size
                                                  color: Colors.black,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    totalGL.toStringAsFixed(2),
                                                style: TextStyle(
                                                  fontFamily: 'PoppinsBold',
                                                  fontSize: size.width *
                                                      0.04, // Scaled font size
                                                  color: categoryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                       
                                        Text(
                                          glycemicLoadCategory,
                                          style: TextStyle(
                                            fontFamily: 'PoppinsBold',
                                            fontSize: size.width *
                                                0.04, // Scaled font size
                                            color: categoryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    height: size.height *
                                        0.025), // 2.5% of screen height
                                ElevatedButton(
                                  onPressed: () {
                                    final foodName =
                                        data['food_name']?.toString() ??
                                            'Unknown Food';
                                    _showMealSelectionDialog(
                                        context, foodName, totalGL);
                                  },
                                  style: ButtonStyle(
                                    padding: WidgetStatePropertyAll(
                                      EdgeInsets.symmetric(
                                        horizontal: size.width *
                                            0.1, // 10% of screen width
                                        vertical: size.height *
                                            0.015, // 1.5% of screen height
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Add to Meal',
                                    style: TextStyle(
                                        fontSize: size.width *
                                            0.04), // Scaled font size
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
