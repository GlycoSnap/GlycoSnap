import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:glycosnap/main.dart'; // For AuthWrapper
import 'package:glycosnap/Utils/colors.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller and fade animation
    _animationController = AnimationController(
      duration: const Duration(seconds: 3), // Duration of the fade-in effect
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Navigate to AuthWrapper when animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Get.off(() => const AuthWrapper());
      }
    });

    // Start the fade-in animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: lightBackground,
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 300),
            FadeTransition(
              opacity: _fadeAnimation,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Glyco',
                      style: TextStyle(
                        fontFamily: 'OpenSauce',
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff027a8f),
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    TextSpan(
                      text: 'Snap',
                      style: TextStyle(
                        fontFamily: 'OpenSauce',
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff071332),
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 45),
            Text(
              "Visualize wellness:\nTransforming plates into insights",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'OpenSauce',
                fontSize: 16,
                color: colorDark,
              ),
            ),
            const SizedBox(height: 150),
            // Removed Sign-up and Login buttons
          ],
        ),
      ),
    );
  }
}