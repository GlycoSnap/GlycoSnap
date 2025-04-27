import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Authenticate/api_service.dart';
import 'Screen/meal_provider.dart';
import 'Authenticate/user_provider.dart';
import 'Screen/signup_questions.dart';
import 'Screen/slides.dart';
import 'Screen/login.dart';
import 'Screen/splash_screen.dart';
import 'Screen/notifications.dart';
import 'Screen/add_food.dart';
import 'Screen/community.dart';
import 'Screen/home_page.dart';
import 'Screen/review.dart';
import 'Screen/settings.dart';
import 'Utils/theme.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';

const List<TabItem> items = [
  TabItem(icon: Icons.home, title: 'Home'),
  TabItem(icon: Icons.auto_graph_outlined, title: 'Review'),
  TabItem(icon: Icons.add_a_photo_outlined, title: 'Camera'),
  TabItem(icon: Icons.people_outline_outlined, title: 'Community'),
  TabItem(icon: Icons.settings, title: 'Settings'),
];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  final prefs = await SharedPreferences.getInstance();
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_KEY'];
  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_KEY in .env');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // Load theme and onboarding preferences
  
  final isDarkMode = prefs.getBool('darkMode') ?? false;

  // Start app
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MyApp(isDarkMode: isDarkMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;
  const MyApp({Key? key, required this.isDarkMode}) : super(key: key);

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
          surface: Colors.white, // Ensure light background
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
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
          surface: Colors.grey[900]!, // Ensure dark background
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const AuthWrapper()),
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
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    print('AuthWrapper: session=$session, user=${supabase.auth.currentUser}');

    if (session != null && supabase.auth.currentUser != null) {
      return const MainScreen();
    } else {
      supabase.auth.refreshSession().then((response) {
        if (response.session != null) {
          Get.offNamed('/');
        }
      });
      return const MySplashScreen();
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

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
    setState(() => visit = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: PageView(
        controller: _pageController,
        onPageChanged: (i) => setState(() => visit = i),
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: BottomBarDefault(
            items: items,
            backgroundColor: Colors.transparent,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            colorSelected: Theme.of(context).colorScheme.primary,
            iconSize: 24,
            indexSelected: visit,
            titleStyle: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
            onTap: onTabTapped,
          ),
        ),
      ),
    );
  }
}