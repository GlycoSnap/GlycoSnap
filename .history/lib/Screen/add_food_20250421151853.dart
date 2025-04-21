import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:glycosnap/Screen/meal_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> with SingleTickerProviderStateMixin {
  bool _isMealSelectionVisible = false;
  String? _foodName;
  final double _glycemicLoad = 0.0;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final String baseUrl =
      'http://192.168.0.101:5000/predict'; //Replace with your Flask server URL
//run ipconfig in cmd or powershell and find the ipv4 address under Wi-Fi

  Future<Map<String, dynamic>>? _glycemicLoadFuture;

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isTextVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTextBubble() {
    setState(() {
      _isTextVisible = !_isTextVisible;
      if (_isTextVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _glycemicLoadFuture = _predictAndCalculateGL();
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
        SnackBar(content: Text('No image selected')),
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
        print('Server Response: $data'); // Debug print
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
        SnackBar(content: Text('Failed to calculate glycemic load')),
      );
      return {
        'glycemic_load': 0.0,
        'total_glycemic_load': 0.0,
        'glycemic_load_category': 'Unknown',
        'food_name': 'Unknown Food',
      };
    }
  }

  void _showMealSelectionDialog(
      BuildContext context, String foodName, double glycemicLoad) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Add to Meal',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'Which meal do you want to add this to?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _addMeal(context, 'breakfast', foodName, glycemicLoad);
                Navigator.pop(context);
              },
              child: Text(
                'Breakfast',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _addMeal(context, 'lunch', foodName, glycemicLoad);
                Navigator.pop(context);
              },
              child: Text(
                'Lunch',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _addMeal(context, 'supper', foodName, glycemicLoad);
                Navigator.pop(context);
              },
              child: Text(
                'Supper',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Poppins',
                ),
              ),
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

//Add meal to meal provider
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        toolbarHeight: size.height * 0.08,
        title: SizedBox(
          width: size.width * 0.4,
          child: Image.asset('images/logo.png'),
        ),
      ),
      body: Container(
        height: size.height,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Camera section
                    Stack(
                      children: [
                        Container(
                          width: size.width * 0.9, // 90% of screen width
                          height: size.height * 0.18, // 18% of screen height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: size.height * 0.02),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    size: size.width * 0.12,
                                  ),
                                  SizedBox(
                                      width: size.width *
                                          0.03), // 3% of screen width
                                  Text(
                                    'TAKE A PICTURE OF YOUR FOOD',
                                    style: TextStyle(
                                      fontFamily: 'OpenSauce',
                                      fontSize: size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              ElevatedButton(
                                onPressed: () => _pickImage(ImageSource.camera),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: Text(
                                  'Open Camera',
                                  style: TextStyle(
                                    fontSize: size.width * 0.04,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.03), // 3% of screen height

                    // Gallery section
                    Stack(
                      children: [
                        Container(
                          width: size.width * 0.9, // 90% of screen width
                          height: size.height * 0.18, // 18% of screen height
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: size.height * 0.02),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    size: size.width * 0.12,
                                  ),
                                  SizedBox(width: size.width * 0.03),
                                  Text(
                                    'UPLOAD A PICTURE OF FOOD',
                                    style: TextStyle(
                                      fontFamily: 'OpenSauce',
                                      fontSize: size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              ElevatedButton(
                                onPressed: () =>
                                    _pickImage(ImageSource.gallery),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                child: Text(
                                  'Open Gallery',
                                  style: TextStyle(
                                    fontSize: size.width * 0.04,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.015),

                    // Display selected image
                    if (_imageFile != null)
                      Padding(
                        padding: EdgeInsets.only(top: size.height * 0.02),
                        child: Image.file(
                          _imageFile!,
                          width: size.width * 0.9,
                          height: size.height * 0.3,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: size.height * 0.015),

                    // Calculate button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.1,
                          vertical: size.height * 0.015,
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
                          fontFamily: 'PoppinsBold',
                          fontSize: size.width * 0.045,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.025),

                    // Display results
                    _glycemicLoadFuture == null
                        ? Container()
                        : FutureBuilder<Map<String, dynamic>>(
                            future: _glycemicLoadFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    'Error: ${snapshot.error}',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No data available',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                );
                              } else {
                                final data = snapshot.data!;
                                final glycemicLoadCategory =
                                    data['glycemic_load_category']
                                            ?.toString() ??
                                        'Unknown';
                                Color categoryColor;

                                if (glycemicLoadCategory ==
                                    'Low glycemic load') {
                                  categoryColor = Colors.green;
                                } else if (glycemicLoadCategory ==
                                    'Medium glycemic load') {
                                  categoryColor = Colors.orange;
                                } else if (glycemicLoadCategory ==
                                    'High glycemic load') {
                                  categoryColor = Colors.red;
                                } else {
                                  categoryColor =
                                      Theme.of(context).colorScheme.onSurface;
                                }

                                final glycemicLoad = data['glycemic_load']
                                        is Map<String, dynamic>
                                    ? data['glycemic_load']
                                        as Map<String, dynamic>
                                    : <String, dynamic>{};

                                final totalGL =
                                    (data['total_glycemic_load'] as num?)
                                            ?.toDouble() ??
                                        0.0;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: size.width * 0.8,
                                      height: size.height * 0.3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1),
                                      ),
                                      padding:
                                          EdgeInsets.all(size.width * 0.03),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Glycemic Load Results:',
                                              style: TextStyle(
                                                fontFamily: 'PoppinsBold',
                                                fontSize: size.width * 0.05,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.01),
                                            ...glycemicLoad.entries
                                                .map((entry) {
                                              final value = (entry.value
                                                          as num?)
                                                      ?.toStringAsFixed(2) ??
                                                  'N/A';
                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        size.height * 0.005),
                                                child: Text(
                                                  '${entry.key}: $value',
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: size.width * 0.04,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                              );
                                            }),
                                            SizedBox(
                                                height: size.height * 0.02),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        'Total Glycemic Load: ',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize:
                                                          size.width * 0.04,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: totalGL
                                                        .toStringAsFixed(2),
                                                    style: TextStyle(
                                                      fontFamily: 'PoppinsBold',
                                                      fontSize:
                                                          size.width * 0.04,
                                                      color: categoryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.015),
                                            Text(
                                              glycemicLoadCategory,
                                              style: TextStyle(
                                                fontFamily: 'PoppinsBold',
                                                fontSize: size.width * 0.04,
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: size.width * 0.1,
                                          vertical: size.height * 0.015,
                                        ),
                                      ),
                                      child: Text(
                                        'Add to Meal',
                                        style: TextStyle(
                                          fontSize: size.width * 0.04,
                                          fontFamily: 'Poppins',
                                        ),
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
            // Floating bot button at bottom right
            Positioned(
              bottom: size.height *
                  0.02, // Adjust this value to position above navbar
              right: size.width * 0.05,
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  // Text bubble
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_animation.value, 0),
                        child: _isTextVisible
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.04,
                                  vertical: size.height * 0.015,
                                ),
                                margin:
                                    EdgeInsets.only(right: size.width * 0.35),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF023047),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Hi! I\'m Snappie!',
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      );
                    },
                  ),
                  // Button
                  GestureDetector(
                    onTap: _toggleTextBubble,
                    child: Container(
                      width: size.width * 0.15,
                      height: size.width * 0.15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF023047),
                            blurRadius: 10,
                            spreadRadius: 4,
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white,
                          width: 0.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'images/bot1.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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