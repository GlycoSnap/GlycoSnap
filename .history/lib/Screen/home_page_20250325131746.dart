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

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);

    String formattedDate = DateFormat('EEEE, d').format(DateTime.now());
    List<String> dateParts = formattedDate.split(', ');
    String dayName = dateParts[0];
    String dayNumber = dateParts[1];

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: lightBackground,
        toolbarHeight: 80,
        title: SizedBox(
          width: 150,
          child: Image.asset(
            'images/logo.png',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
                onPressed: () {
                  Get.toNamed('/notifications');
                },
                icon: Icon(
                  Icons.notifications,
                  size: 30,
                  color: colorDark,
                )),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            decoration: BoxDecoration(
              color: lightBackground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: dayName,
                          style: const TextStyle(
                            fontFamily: 'OpenSauce',
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ', $dayNumber',
                          style: const TextStyle(
                            fontFamily: 'OpenSauce',
                            fontSize: 17,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Welcome back, ',
                            style: TextStyle(
                              fontFamily: 'OpenSauce',
                              fontSize: 17,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Nanami!',
                            style: TextStyle(
                              fontFamily: 'OpenSauce',
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      '😊',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),

                // Progress circle
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 370,
                            height: 180,
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
                          ),
                          Positioned(
                            top: 15,
                            left: 6,
                            child: CircularPercentIndicator(
                              animation: true,
                              animationDuration: 3000,
                              radius: 70.0,
                              lineWidth: 11.0,
                              percent: glycemicLoad / 100,
                              progressColor: const Color(0xff071332),
                              backgroundColor: white,
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                          ),
                          Positioned(
                            top: 38,
                            left: 28,
                            child: CircularPercentIndicator(
                              animation: true,
                              animationDuration: 3000,
                              radius: 48.0,
                              lineWidth: 10.0,
                              percent: calories / 2000,
                              progressColor:
                                  const Color.fromARGB(255, 0, 154, 181),
                              backgroundColor: white,
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                          ),
                          Positioned(
                            top: 60,
                            left: 50,
                            child: Image.asset(
                              'images/onigiri.png',
                              width: 50,
                            ),
                          ),
                          Positioned(
                            top: 50,
                            left: 160,
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 20.0,
                                          height: 20.0,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xff071332),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Text(
                                            'Glycemic Load',
                                            style: TextStyle(
                                              fontFamily: 'OpenSauce',
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Container(
                                          width: 20.0,
                                          height: 20.0,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color.fromARGB(
                                                255, 0, 154, 181),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Text(
                                            'Calories',
                                            style: TextStyle(
                                              fontFamily: 'OpenSauce',
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 50,
                            left: 310,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  glycemicLoad.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff071332),
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  '${calories.toStringAsFixed(0)} cal',
                                  style: const TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 132, 156),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Breakfast
                const SizedBox(height: 20),
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
                            padding: const EdgeInsets.only(left: 15),
                            child: Container(
                              width: 40,
                              height: 40,
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
                          const Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: Text(
                              'Breakfast',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        SizedBox(
                          height: 200, // Adjust as needed
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
                                margin: EdgeInsets.all(10),
                                padding: EdgeInsets.all(10),
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                        height:
                                            5), // Spacing between name and details
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Glycemic Load: ${meal.glycemicLoad.toStringAsFixed(1)}',
                                          style: TextStyle(color: whit),
                                        ),
                                        Text(
                                          category,
                                          style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold),
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
                const SizedBox(height: 30),
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
                            padding: const EdgeInsets.only(left: 15),
                            child: Container(
                              width: 40,
                              height: 40,
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
                          const Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: Text(
                              'Lunch',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        SizedBox(
                          height: 200, // Adjust as needed
                          child: ListView(
                            children: mealProvider.lunch.map((meal) {
                              return ListTile(
                                title: Text(meal.name),
                                subtitle: Text(
                                    'Glycemic Load: ${meal.glycemicLoad.toStringAsFixed(1)}'),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Supper
                const SizedBox(height: 30),
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
                            padding: const EdgeInsets.only(left: 15),
                            child: Container(
                              width: 40,
                              height: 40,
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
                          const Padding(
                            padding: EdgeInsets.only(left: 35),
                            child: Text(
                              'Supper',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        SizedBox(
                          height: 200, // Adjust as needed
                          child: ListView(
                            children: mealProvider.supper.map((meal) {
                              return ListTile(
                                title: Text(meal.name),
                                subtitle: Text(
                                    'Glycemic Load: ${meal.glycemicLoad.toStringAsFixed(1)}'),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
