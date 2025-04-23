import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glycosnap/Screen/meal_provider.dart';
import 'package:glycosnap/Screen/snappie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final bool _isTextVisible = false;
  bool _isMealSelectionVisible = false;
  String? _foodName;
  final double _glycemicLoad = 0.0;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final String baseUrl = const String.fromEnvironment(
  'FLASK_API_URL',
  defaultValue: 'http://192.168.0.102:5000',
);

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
      return {'glycemic_load': 0.0, 'total_glycemic_load': 0.0};
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
        print('Server Response: $data');
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
      };
    }
  }

 void _showMealSelectionDialog(BuildContext context, String foodName, double glycemicLoad) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing dialog during async
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add to Meal'),
          content: Text('Add $foodName to which meal?'),
          actions: [
            TextButton(
              onPressed: () async {
                await _addMeal(dialogContext, 'breakfast', foodName, glycemicLoad);
              },
              child: const Text('Breakfast'),
            ),
            TextButton(
              onPressed: () async {
                await _addMeal(dialogContext, 'lunch', foodName, glycemicLoad);
              },
              child: const Text('Lunch'),
            ),
            TextButton(
              onPressed: () async {
                await _addMeal(dialogContext, 'supper', foodName, glycemicLoad);
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

Future<void> _addMeal(BuildContext dialogContext, String mealType, String foodName, double glycemicLoad) async {
    try {
      final meal = Meal(name: foodName, glycemicLoad: glycemicLoad);
      final mealProvider = Provider.of<MealProvider>(context, listen: false);
      await mealProvider.addMeal(mealType, meal);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to $mealType')),
      );
      Navigator.pop(dialogContext); // Close dialog
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().replaceFirst('Exception: Failed to add meal: ', '');
      if (errorMessage.startsWith('{"error":"')) {
        try {
          final errorJson = jsonDecode(errorMessage);
          errorMessage = errorJson['error'];
        } catch (_) {}
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add meal: $errorMessage'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  

  void _openChat() {
    Get.to(() => const ChatPage());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
        toolbarHeight: size.height * 0.08,
        title: SizedBox(
          width: size.width * 0.4,
          child: Image.asset('images/logo.png'),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          height: size.height, // Ensure Stack takes full screen height
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
                            width: size.width * 0.9,
                            height: size.height * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: colorScheme.secondary,
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: size.height * 0.01),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: colorScheme.onSurface,
                                      size: size.width * 0.12,
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    Text(
                                      'TAKE A PICTURE OF YOUR FOOD',
                                      style: TextStyle(
                                        fontFamily: 'OpenSauce',
                                        fontSize: size.width * 0.040,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll( Colors.white,),
                                  ),
                                  onPressed: () =>
                                      _pickImage(ImageSource.camera),
                                  child: Text(
                                    'Open Camera',
                                    style:
                                        TextStyle(
                                          fontSize: size.width * 0.04,
                                          color: Colors.black,),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.015),

                      // Gallery section
                      Stack(
                        children: [
                          Container(
                            width: size.width * 0.9,
                            height: size.height * 0.15,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: colorScheme.secondary,
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
                                      color: colorScheme.onSurface,
                                      size: size.width * 0.12,
                                    ),
                                    SizedBox(width: size.width * 0.015),
                                    Text(
                                      'UPLOAD A PICTURE OF FOOD',
                                      style: TextStyle(
                                        fontFamily: 'OpenSauce',
                                        fontSize: size.width * 0.040,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(Colors.white,),
                                  ),
                                  onPressed: () =>
                                      _pickImage(ImageSource.gallery),
                                  child: Text(
                                    'Open Gallery',
                                    style:
                                        TextStyle(fontSize: size.width * 0.04,
                                        color: Colors.black,),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Display selected image
                      if (_imageFile != null)
                        Padding(
                          padding: EdgeInsets.only(top: size.height * 0.02),
                          child: Image.file(
                            _imageFile!,
                            width: size.width * 0.7,
                            height: size.height * 0.3,
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: size.height * 0.015),

                      // Calculate button
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStatePropertyAll(colorScheme.primary),
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(
                              horizontal: size.width * 0.04,
                              vertical: size.height * 0.015,
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
                            fontSize: size.width * 0.045,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.015),

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
                                      data['glycemic_load_category']
                                              ?.toString() ??
                                          'Unknown';
                                  Color categoryColor;

                                  if (glycemicLoadCategory ==
                                      'Low glycemic load') {
                                    categoryColor = Colors.green;
                                  } else if (glycemicLoadCategory ==
                                      'Medium glycemic load') {
                                    categoryColor = Colors.orangeAccent;
                                  } else if (glycemicLoadCategory ==
                                      'High glycemic load') {
                                    categoryColor = Colors.red;
                                  } else {
                                    categoryColor = colorScheme.onSurface;
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: size.width * 0.8,
                                        height: size.height * 0.25,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: colorScheme.secondary.withValues(alpha: 0.7),
                                        ),
                                        padding:
                                            EdgeInsets.all(size.width * 0.03),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ...glycemicLoad.entries
                                                  .map((entry) {
                                                final value = (entry.value
                                                            as num?)
                                                        ?.toStringAsFixed(2) ??
                                                    'N/A';
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: size.height *
                                                          0.005),
                                                  child: Text(
                                                    '${entry.key}: $value',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize:
                                                          size.width * 0.04,
                                                      color:
                                                          colorScheme.onSurface,
                                                    ),
                                                  ),
                                                );
                                              }),
                                              SizedBox(
                                                  height: size.height * 0.01),
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text:
                                                          'Total Glycemic Load: ',
                                                      style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            size.width * 0.04,
                                                        color:
                                                            colorScheme.onSurface,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: totalGL
                                                          .toStringAsFixed(2),
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'PoppinsBold',
                                                        fontSize:
                                                            size.width * 0.04,
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
                                                  fontSize: size.width * 0.04,
                                                  color: categoryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.015),
                                      ElevatedButton(
                                        onPressed: () {
                                          final foodName =
                                              data['food_name']?.toString() ??
                                                  'Unknown Food';
                                          _showMealSelectionDialog(
                                              context, foodName, totalGL);
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  colorScheme.primary),
                                          padding: WidgetStatePropertyAll(
                                            EdgeInsets.symmetric(
                                              horizontal: size.width * 0.1,
                                              vertical: size.height * 0.015,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Add to Meal',
                                          style: TextStyle(
                                            fontSize: size.width * 0.04,
                                            color: Colors.white,
                                            fontFamily: 'PoppinsBold',
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.03),
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
              bottom: size.height * 0.02,
              right: size.width * 0.05,
              child: GestureDetector(
                onTap: _openChat,
                child: Container(
                  width: size.width * 0.3,
                  height: size.width * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary,
                        blurRadius: 10,
                        spreadRadius: 4,
                      ),
                    ],
                    border: Border.all(
                      color: colorScheme.surface,
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
            ),
          ],
        ),
      ),
    ),
    );
  }
}