import 'package:flutter/material.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'meal_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int visit = 0;
  String? selectedMeal; // Track which meal is currently selected

  double glycemicLoad = 0; // Fetch from storage
  double calories = 0; // Fetch from storage

  double calculateTotalGlycemicLoad(List<Meal> meals) {
    return meals.fold(0.0, (sum, meal) => sum + meal.glycemicLoad);
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final size = MediaQuery.of(context).size; // Get screen dimensions

    String formattedDate = DateFormat('EEEE, d').format(DateTime.now());
    List<String> dateParts = formattedDate.split(', ');
    String dayName = dateParts[0];
    String dayNumber = dateParts[1];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        toolbarHeight: size.height * 0.1, // 10% of screen height
        title: SizedBox(
          width: size.width * 0.4, // 40% of screen width
          child: Image.asset('images/logo.png'),
        ),
        actions: [
          Padding(
            padding:
                EdgeInsets.only(right: size.width * 0.05), // 5% of screen width
            child: IconButton(
              onPressed: () {
                Get.toNamed('/notifications');
              },
              icon: Icon(
                Icons.notifications,
                size: size.width * 0.08, // Scaled icon size
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding:
              EdgeInsets.symmetric(horizontal: size.width * 0.05), // 5% padding
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date display
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: dayName,
                        style: TextStyle(
                          fontFamily: 'OpenSauce',
                          fontSize: size.width * 0.045, // Scaled font size
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: ', $dayNumber',
                        style: TextStyle(
                          fontFamily: 'OpenSauce',
                          fontSize: size.width * 0.045, // Scaled font size
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.015), // 1.5% of screen height

                // Welcome message
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome back, ',
                            style: TextStyle(
                              fontFamily: 'OpenSauce',
                              fontSize: size.width * 0.045, // Scaled font size
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          TextSpan(
                            text: 'Nanami!',
                            style: TextStyle(
                              fontFamily: 'OpenSauce',
                              fontSize: size.width * 0.045, // Scaled font size
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: size.width * 0.015), // 1.5% of screen width
                    Text(
                      '😊',
                      style: TextStyle(
                          fontSize: size.width * 0.06), // Scaled emoji size
                    ),
                  ],
                ),

                // Progress circle
                Padding(
                  padding: EdgeInsets.only(
                      top: size.height * 0.02), // 2% of screen height
                  child: Container(
                    width: size.width * 0.9, // 90% of screen width
                    height: size.height * 0.25, // 25% of screen height
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20.0),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: size.height * 0.02, // 2% of screen height
                          left: size.width * 0.02, // 2% of screen width
                          child: CircularPercentIndicator(
                            animation: true,
                            animationDuration: 3000,
                            radius: size.width * 0.18, // Scaled radius
                            lineWidth: size.width * 0.03, // Scaled line width
                            percent: (calculateTotalGlycemicLoad(
                                        mealProvider.breakfast) /
                                    100)
                                .clamp(0.0, 1.0),
                            progressColor:
                                Theme.of(context).colorScheme.primary,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.06, // 6% of screen height
                          left: size.width * 0.08, // 8% of screen width
                          child: CircularPercentIndicator(
                            animation: true,
                            animationDuration: 3000,
                            radius: size.width * 0.12, // Scaled radius
                            lineWidth: size.width * 0.025, // Scaled line width
                            percent: (calories / 2000).clamp(0.0, 1.0),
                            progressColor:
                                Theme.of(context).colorScheme.secondary,
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.08, // 8% of screen height
                          left: size.width * 0.14, // 14% of screen width
                          child: Image.asset(
                            'images/onigiri.png',
                            width: size.width * 0.12, // Scaled image size
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.06, // 6% of screen height
                          left: size.width * 0.4, // 40% of screen width
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width:
                                        size.width * 0.05, // Scaled circle size
                                    height:
                                        size.width * 0.05, // Scaled circle size
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width *
                                            0.015), // Scaled padding
                                    child: Text(
                                      'Glycemic Load',
                                      style: TextStyle(
                                        fontFamily: 'OpenSauce',
                                        fontSize: size.width *
                                            0.035, // Scaled font size
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: size.height *
                                      0.02), // 2% of screen height
                              Row(
                                children: [
                                  Container(
                                    width:
                                        size.width * 0.05, // Scaled circle size
                                    height:
                                        size.width * 0.05, // Scaled circle size
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: size.width *
                                            0.015), // Scaled padding
                                    child: Text(
                                      'Calories',
                                      style: TextStyle(
                                        fontFamily: 'OpenSauce',
                                        fontSize: size.width *
                                            0.035, // Scaled font size
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.06, // 6% of screen height
                          left: size.width * 0.75, // 75% of screen width
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                calculateTotalGlycemicLoad([
                                  ...mealProvider.breakfast,
                                  ...mealProvider.lunch,
                                  ...mealProvider.supper
                                ]).toStringAsFixed(1),
                                style: TextStyle(
                                  fontFamily: 'OpenSauce',
                                  fontSize:
                                      size.width * 0.035, // Scaled font size
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              SizedBox(
                                  height: size.height *
                                      0.02), // 2% of screen height
                              Text(
                                '${calories.toStringAsFixed(0)} cal',
                                style: TextStyle(
                                  fontFamily: 'OpenSauce',
                                  fontSize:
                                      size.width * 0.035, // Scaled font size
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Meal sections
                SizedBox(height: size.height * 0.025), // 2.5% of screen height
                _buildMealSection(
                  context,
                  size,
                  'Breakfast',
                  'images/breakfast.jpeg',
                  mealProvider.breakfast,
                  'breakfast',
                ),
                SizedBox(height: size.height * 0.03), // 3% of screen height
                _buildMealSection(
                  context,
                  size,
                  'Lunch',
                  'images/lunch.jpeg',
                  mealProvider.lunch,
                  'lunch',
                ),
                SizedBox(height: size.height * 0.03), // 3% of screen height
                _buildMealSection(
                  context,
                  size,
                  'Supper',
                  'images/supper.jpeg',
                  mealProvider.supper,
                  'supper',
                ),
                SizedBox(height: size.height * 0.03), // Bottom padding
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(BuildContext context, Size size, String title,
      String imagePath, List<Meal> meals, String mealType) {
    final bool isSelected = selectedMeal == mealType;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          collapsedBackgroundColor: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          onExpansionChanged: (expanded) {
            setState(() {
              selectedMeal = expanded ? mealType : null;
            });
          },
          title: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.04), // 4% of screen width
                child: Container(
                  width: size.width * 0.1, // 10% of screen width
                  height: size.width * 0.1, // 10% of screen width (square)
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: size.width * 0.08), // 8% of screen width
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: size.width * 0.06, // Scaled font size
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          children: [
            SizedBox(
              height: size.height * 0.25, // 25% of screen height
              child: ListView(
                children: meals.map((meal) {
                  String category;
                  Color textColor;

                  if (meal.glycemicLoad >= 20) {
                    category = "High";
                    textColor = Colors.red;
                  } else if (meal.glycemicLoad >= 11) {
                    category = "Medium";
                    textColor = Colors.orange;
                  } else {
                    category = "Low";
                    textColor = Colors.green;
                  }
                  return Container(
                    margin: EdgeInsets.all(size.width * 0.025), // Scaled margin
                    padding:
                        EdgeInsets.all(size.width * 0.025), // Scaled padding
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: size.width * 0.04, // Scaled font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                            height:
                                size.height * 0.005), // 0.5% of screen height
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Glycemic Load: ${meal.glycemicLoad.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize:
                                    size.width * 0.035, // Scaled font size
                              ),
                            ),
                            Text(
                              category,
                              style: TextStyle(
                                color: textColor,
                                fontSize:
                                    size.width * 0.035, // Scaled font size
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
