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
      backgroundColor: lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: lightBackground,
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
                color: colorDark,
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
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: ', $dayNumber',
                        style: TextStyle(
                          fontFamily: 'OpenSauce',
                          fontSize: size.width * 0.045, // Scaled font size
                          color: Colors.black,
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
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Nanami!',
                            style: TextStyle(
                              fontFamily: 'OpenSauce',
                              fontSize: size.width * 0.045, // Scaled font size
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                    height: size.height * 0.19, // 25% of screen height
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 205, 233, 230),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 162, 196, 193),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 0),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20.0),
                      color: const Color.fromARGB(255, 205, 233, 230),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: size.height * 0.01, // 2% of screen height
                          left: size.width * 0.01, // 2% of screen width
                          child: CircularPercentIndicator(
                            animation: true,
                            animationDuration: 3000,
                            radius: size.width * 0.18, // Scaled radius
                            lineWidth: size.width * 0.03, // Scaled line width
                            percent: (calculateTotalGlycemicLoad(
                                        mealProvider.breakfast) /
                                    100)
                                .clamp(0.0, 1.0),
                            progressColor: const Color(0xff071332),
                            backgroundColor: Colors.white,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.04, // 6% of screen height
                          left: size.width * 0.07, // 8% of screen width
                          child: CircularPercentIndicator(
                            animation: true,
                            animationDuration: 3000,
                            radius: size.width * 0.12, // Scaled radius
                            lineWidth: size.width * 0.025, // Scaled line width
                            percent: (calories / 2000).clamp(0.0, 1.0),
                            progressColor:
                                const Color.fromARGB(255, 0, 154, 181),
                            backgroundColor: Colors.white,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.067, // 8% of screen height
                          left: size.width * 0.135, // 14% of screen width
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
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xff071332),
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
                                        color: Colors.black,
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
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromARGB(255, 0, 154, 181),
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
                                        color: Colors.black,
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
                                  color: const Color(0xff071332),
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
                                  color: const Color.fromARGB(255, 0, 132, 156),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Breakfast
                SizedBox(height: size.height * 0.025), // 2.5% of screen height
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      backgroundColor: const Color(0xFFE5F6F6),
                      collapsedBackgroundColor: const Color(0xFFE5F6F6),
                      title: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: size.width * 0.04), // 4% of screen width
                            child: Container(
                              width: size.width * 0.1, // 10% of screen width
                              height: size.width *
                                  0.1, // 10% of screen width (square)
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'images/breakfast.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: size.width * 0.08), // 8% of screen width
                            child: Text(
                              'Breakfast',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: size.width * 0.06, // Scaled font size
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        SizedBox(
                          height: size.height * 0.25, // 25% of screen height
                          child: ListView(
                            children: mealProvider.breakfast.map((meal) {
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
                                margin: EdgeInsets.all(
                                    size.width * 0.025), // Scaled margin
                                padding: EdgeInsets.all(
                                    size.width * 0.025), // Scaled padding
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal.name,
                                      style: TextStyle(
                                        color: colorDark,
                                        fontSize: size.width *
                                            0.04, // Scaled font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                        height: size.height *
                                            0.005), // 0.5% of screen height
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Glycemic Load: ${meal.glycemicLoad.toStringAsFixed(1)}',
                                          style: TextStyle(
                                            color: black,
                                            fontSize: size.width *
                                                0.035, // Scaled font size
                                          ),
                                        ),
                                        Text(
                                          category,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: size.width *
                                                0.035, // Scaled font size
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
                ),

                // Lunch
                SizedBox(height: size.height * 0.03), // 3% of screen height
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      backgroundColor: backgroundColor3,
                      collapsedBackgroundColor: backgroundColor3,
                      title: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: size.width * 0.04), // 4% of screen width
                            child: Container(
                              width: size.width * 0.1, // 10% of screen width
                              height: size.width *
                                  0.1, // 10% of screen width (square)
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'images/lunch.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: size.width * 0.08), // 8% of screen width
                            child: Text(
                              'Lunch',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: size.width * 0.06, // Scaled font size
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        SizedBox(
                          height: size.height * 0.25, // 25% of screen height
                          child: ListView(
                            children: mealProvider.lunch.map((meal) {
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
                                margin: EdgeInsets.all(
                                    size.width * 0.025), // Scaled margin
                                padding: EdgeInsets.all(
                                    size.width * 0.025), // Scaled padding
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal.name,
                                      style: TextStyle(
                                        color: colorDark,
                                        fontSize: size.width *
                                            0.04, // Scaled font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                        height: size.height *
                                            0.005), // 0.5% of screen height
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Glycemic Load: ${meal.glycemicLoad.toStringAsFixed(1)}',
                                          style: TextStyle(
                                            color: black,
                                            fontSize: size.width *
                                                0.035, // Scaled font size
                                          ),
                                        ),
                                        Text(
                                          category,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: size.width *
                                                0.035, // Scaled font size
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
                ),

                // Supper
                SizedBox(height: size.height * 0.03), // 3% of screen height
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      backgroundColor: backgroundColor3,
                      collapsedBackgroundColor: backgroundColor3,
                      title: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: size.width * 0.04), // 4% of screen width
                            child: Container(
                              width: size.width * 0.1, // 10% of screen width
                              height: size.width *
                                  0.1, // 10% of screen width (square)
                              clipBehavior: Clip.antiAlias,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'images/supper.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: size.width * 0.08), // 8% of screen width
                            child: Text(
                              'Supper',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: size.width * 0.06, // Scaled font size
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        SizedBox(
                          height: size.height * 0.25, // 25% of screen height
                          child: ListView(
                            children: mealProvider.supper.map((meal) {
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
                                margin: EdgeInsets.all(
                                    size.width * 0.025), // Scaled margin
                                padding: EdgeInsets.all(
                                    size.width * 0.025), // Scaled padding
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal.name,
                                      style: TextStyle(
                                        color: colorDark,
                                        fontSize: size.width *
                                            0.04, // Scaled font size
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                        height: size.height *
                                            0.005), // 0.5% of screen height
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Glycemic Load: ${meal.glycemicLoad.toStringAsFixed(1)}',
                                          style: TextStyle(
                                            color: black,
                                            fontSize: size.width *
                                                0.035, // Scaled font size
                                          ),
                                        ),
                                        Text(
                                          category,
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: size.width *
                                                0.035, // Scaled font size
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
                ),

                Padding(
                  padding: EdgeInsets.only(
                      top: size.height * 0.02), // 2% of screen height
                  child: Container(
                    width: size.width * 0.9, // 90% of screen width
                    height: size.height * 0.19, // 25% of screen height
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 205, 233, 230),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 162, 196, 193),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 0),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(20.0),
                      color: const Color.fromARGB(255, 205, 233, 230),
                    ),
                    child: 
                        
                        Positioned(
                          top: size.height * 0.067, // 8% of screen height
                          left: size.width * 0.35, // 14% of screen width
                          child: Image.asset(
                            'images/bot1.png',
                            width: size.width * 0.12, // Scaled image size
                          ),
                        ),
                        
                  ),
                    ),
               ],
                ),


                SizedBox(height: size.height * 0.03), // Bottom padding            ),
          ],
        ),
      ),
    );
  }
}
