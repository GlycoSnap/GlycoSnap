import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:intl/intl.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, d').format(DateTime.now());
    List<String> dateParts = formattedDate.split(', ');
    String dayName = dateParts[0];
    String dayNumber = dateParts[1];

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        backgroundColor: lightBackground,
        toolbarHeight: 80,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                
               
                Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: 
                      Stack(
                        children: [
                          Container(
                            width: 370,
                            height: 650,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color.fromARGB(255, 205, 233, 230),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 162, 196, 193),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: Offset(0, 0),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(20.0),
                              color: Color.fromARGB(255, 205, 233, 230),
                            ),
                          ),
                          
                           Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'You have no new notifications ',
                      style: const TextStyle(
                        fontFamily: 'OpenSauce',
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                        ],
                      ),
                ),
         ], ),
                ),
              ],
            ),
          );
 
  }
}
