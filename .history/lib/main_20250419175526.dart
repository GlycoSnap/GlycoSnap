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
import 'package:glycosnap/Screen/login.dart';
import 'chat_page.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

const List<TabItem> items = [
  TabItem(
    icon: Icons.home,
    title: 'Home',
  ),
  TabItem(
    icon: Icons.auto_graph_outlined,
    title: 'Review',
  ),
  TabItem(
    icon: Icons.add_a_photo_outlined,
    title: 'Camera',
  ),
  TabItem(
    icon: Icons.people_outline_outlined,
    title: 'Community',
  ),
  TabItem(
    icon: Icons.settings,
    title: 'Settings',
  ),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkMode') ?? false;

  try {
    // Check if Firebase is already initialized and use a unique app name
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: 'GlycoSnapApp', // Give it a unique name
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const MySplashScreen(),
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int visit = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const HomePage(),
    const Review(),
    const AddFood(),
    const Community(),
    const Settings(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      visit = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    print('Building MainScreen'); // Debug print
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            visit = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 30, right: 32, left: 32),
        child: BottomBarDefault(
          items: items,
          backgroundColor: backgroundColor3,
          color: Colors.black38,
          colorSelected: colorDark,
          iconSize: 30,
          indexSelected: visit,
          titleStyle: const TextStyle(
            fontSize: 10,
            color: Colors.black,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
          onTap: (int index) {
            onTabTapped(index);
          },
        ),
      ),
    );
  }
}