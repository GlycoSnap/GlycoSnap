

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
            onError: AppTheme.lightOnSurface),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            visit = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
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
            onTap: (int index) {
              onTabTapped(index);
            },
          ),
        ),
      ),
    );
  }
}