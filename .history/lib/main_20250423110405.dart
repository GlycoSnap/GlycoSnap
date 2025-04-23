import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glycosnap/Screen/meal_provider.dart';
import 'package:glycosnap/Authenticate/user_provider.dart';
import 'package:glycosnap/Screen/signup_questions.dart';
import 'package:glycosnap/Screen/slides.dart';
import 'package:glycosnap/Screen/login.dart';
import 'package:glycosnap/Screen/splash_screen.dart';
import 'package:glycosnap/Screen/notifications.dart';
import 'package:glycosnap/Screen/add_food.dart';
import 'package:glycosnap/Screen/community.dart';
import 'package:glycosnap/Screen/home_page.dart';
import 'package:glycosnap/Screen/review.dart';
import 'package:glycosnap/Screen/settings.dart';
import 'package:glycosnap/Utils/theme.dart';
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

  // 1) load env
  await dotenv.load(fileName: ".env");
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_KEY'];
  if (supabaseUrl == null || supabaseKey == null) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_KEY in .env');
  }

  // 2) init Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  // 3) load theme pref
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('darkMode') ?? false;

  // 4) start app
  runApp(
    MultiProvider(
      providers: [
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
      // your splash route remains at "/"
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const MySplashScreen()),
        GetPage(name: '/signUpQuestions', page: () => const SignUpQuestions()),
        GetPage(name: '/slides', page: () => const Slides()),
        GetPage(name: '/login', page: () => const Login()),
        GetPage(name: '/add_food', page: () => const AddFood()),
        GetPage(name: '/notifications', page: () => const Notifications()),
      ],
      // once splash is done it should Navigate to AuthWrapper or MainScreen directly
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    

    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return const MySplashScreen();
    } else {
      return const MainScreen();
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
