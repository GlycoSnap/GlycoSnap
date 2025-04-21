import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glycosnap/Screen/meal_provider.dart';
import 'package:glycosnap/Screen/notifications.dart';
import 'package:glycosnap/Screen/signup_questions.dart';
import 'package:glycosnap/Screen/settings.dart';
import 'package:glycosnap/Screen/add_food.dart';
import 'package:glycosnap/Screen/community.dart';
import 'package:glycosnap/Screen/home_page.dart';
import 'package:glycosnap/Screen/review.dart';
import 'package:glycosnap/Screen/slides.dart';
import 'package:glycosnap/Screen/splash_screen.dart';
import 'package:glycosnap/Screen/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:glycosnap/Utils/theme.dart';

const List<TabItem> items = [
  TabItem(icon: Icons.home, title: 'Home'),
  TabItem(icon: Icons.auto_graph_outlined, title: 'Review'),
  TabItem(icon: Icons.add_a_photo_outlined, title: 'Camera'),
  TabItem(icon: Icons.people_outline_outlined, title: 'Community'),
  TabItem(icon: Icons.settings, title: 'Settings'),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkMode') ?? false;

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: 'GlycoSnapApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await FirebaseAppCheck.instance.activate();

    runApp(
      ChangeNotifierProvider(
        create: (_) => MealProvider(),
        child: MyApp(isDarkMode: isDarkMode),
      ),
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;
  const MyApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GlycoSnap',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: AppTheme.lightPrimary,
          onPrimary: AppTheme.lightOnPrimary,
          secondary: AppTheme.lightSecondary,
          onSecondary: AppTheme.lightOnPrimary,
          error: AppTheme.lightError,
          onError: AppTheme.lightOnSurface,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: AppTheme.darkPrimary,
          onPrimary: AppTheme.darkOnPrimary,
          secondary: AppTheme.darkSecondary,
          onSecondary: AppTheme.darkOnPrimary,
          error: AppTheme.darkError,
          onError: AppTheme.darkOnSurface,
          surface: AppTheme.darkSurface,
          onSurface: AppTheme.darkOnSurface,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AuthWrapper(), // <-- Replace the home screen logic.
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const MySplashScreen()),
        GetPage(name: '/signUpQuestions', page: () => const SignUpQuestions()),
        GetPage(name: '/slides', page: () => const Slides()),
        GetPage(name: '/login', page: () => const Login()),
        GetPage(name: '/add_food', page: () => const AddFood()),
        GetPage(name: '/notifications', page: () => const Notifications()),
      ],
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MySplashScreen(); // Show your splash or loader
        } else if (snapshot.hasData) {
          return const MainScreen(); // User is logged in
        } else {
          return const Login(); // User is not logged in
        }
      },
    );
  }
}
