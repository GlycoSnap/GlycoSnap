import 'package:flutter/material.dart';
import 'package:glycosnap/Authenticate/api_service.dart';
import 'package:glycosnap/Authenticate/user_provider.dart';
import 'package:glycosnap/Screen/snappie.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'meal_provider.dart';
import 'package:glycosnap/Screen/quiz.dart'; 
import 'package:flutter_animate/flutter_animate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int visit = 0;
  String? selectedMeal; // Track which meal is currently selected
  double glycemicLoad = 0; // Fetch from storage
  double calories = 0; // Fetch from storage
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isTextVisible = false;

  double calculateTotalGlycemicLoad(List<Meal> meals) {
    return meals.fold(0.0, (sum, meal) => sum + meal.glycemicLoad);
  }

 @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Fetch meals on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MealProvider>(context, listen: false).fetchMeals();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTextBubble() {
    setState(() {
      _isTextVisible = !_isTextVisible;
      if (_isTextVisible) {
        _animationController.forward(); // Slide out
      } else {
        _animationController.reverse(); // Slide back
      }
    });
  }

  void _openChat() {
    Get.to(() => const ChatPage());
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final size = MediaQuery.of(context).size; // Get screen dimensions
    final colorScheme = Theme.of(context).colorScheme; // Access ColorScheme

    String formattedDate = DateFormat('EEEE, d').format(DateTime.now());
    List<String> dateParts = formattedDate.split(', ');
    String dayName = dateParts[0];
    String dayNumber = dateParts[1];

    // Calculate total glycemic load for all meals
    final totalGlycemicLoad = calculateTotalGlycemicLoad([
      ...mealProvider.breakfast,
      ...mealProvider.lunch,
      ...mealProvider.supper,
    ]);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        toolbarHeight: size.height * 0.11, // 10% of screen height
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                RichText(
  text: TextSpan(
    children: [
      TextSpan(
        text: 'Hello, ',
        style: TextStyle(
          fontFamily: 'OpenSauce',
          fontSize: size.width * 0.055,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      TextSpan(
        text: Provider.of<UserProvider>(context).userProfile?['first_name'] ?? 'User',
        style: TextStyle(
          fontFamily: 'OpenSauce',
          fontSize: size.width * 0.055,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    ],
  ),
),
                SizedBox(width: size.width * 0.015),
                Text(
                  '👋',
                  style: TextStyle(fontSize: size.width * 0.04),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.008),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: dayName,
                    style: TextStyle(
                      fontFamily: 'OpenSauce',
                      fontSize: size.width * 0.035,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text: ', $dayNumber',
                    style: TextStyle(
                      fontFamily: 'OpenSauce',
                      fontSize: size.width * 0.035,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: size.width * 0.05),
            child: IconButton(
              onPressed: () {
                Get.toNamed('/notifications');
              },
              icon: Icon(
                Icons.notifications,
                size: size.width * 0.07,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const QuizAccessWidget(),
            mealProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    // Progress circle
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.02),
                      child: Container(
                        width: size.width * 0.9,
                        height: size.height * 0.19,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.4),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 0),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(20.0),
                          color: colorScheme.secondary,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: size.height * 0.01,
                              left: size.width * 0.01,
                              child: CircularPercentIndicator(
                                key: ValueKey(totalGlycemicLoad),
                                animation: true,
                                animationDuration: 1000,
                                radius: size.width * 0.18,
                                lineWidth: size.width * 0.03,
                                percent:
                                    (totalGlycemicLoad / 100).clamp(0.0, 1.0),
                                progressColor: colorScheme.primary,
                                backgroundColor: colorScheme.surface,
                                circularStrokeCap: CircularStrokeCap.round,
                                center: Text(
                                  totalGlycemicLoad.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontFamily: 'OpenSauce',
                                    fontSize: size.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: size.height * 0.04,
                              left: size.width * 0.07,
                              child: CircularPercentIndicator(
                                animation: true,
                                animationDuration: 1000,
                                radius: size.width * 0.12,
                                lineWidth: size.width * 0.025,
                                percent: (calories / 2000).clamp(0.0, 1.0),
                                progressColor: colorScheme.secondary,
                                backgroundColor: colorScheme.surface,
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                            ),
                            Positioned(
                              top: size.height * 0.067,
                              left: size.width * 0.135,
                              child: Image.asset(
                                'images/onigiri.png',
                                width: size.width * 0.12,
                              ),
                            ),
                            Positioned(
                              top: size.height * 0.06,
                              left: size.width * 0.4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: size.width * 0.05,
                                        height: size.width * 0.05,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: size.width * 0.015),
                                        child: Text(
                                          'Glycemic Load',
                                          style: TextStyle(
                                            fontFamily: 'OpenSauce',
                                            fontSize: size.width * 0.035,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    children: [
                                      Container(
                                        width: size.width * 0.05,
                                        height: size.width * 0.05,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: colorScheme.onPrimary,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: size.width * 0.015),
                                        child: Text(
                                          'Calories',
                                          style: TextStyle(
                                            fontFamily: 'OpenSauce',
                                            fontSize: size.width * 0.035,
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: size.height * 0.06,
                              left: size.width * 0.75,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    totalGlycemicLoad.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontFamily: 'OpenSauce',
                                      fontSize: size.width * 0.035,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Text(
                                    '${calories.toStringAsFixed(0)} cal',
                                    style: TextStyle(
                                      fontFamily: 'OpenSauce',
                                      fontSize: size.width * 0.035,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
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
                    SizedBox(height: size.height * 0.025),
                    _buildMealSection(
                      context,
                      size,
                      'Breakfast',
                      'images/breakfast.jpeg',
                      mealProvider.breakfast,
                      'breakfast',
                    ),
                    SizedBox(height: size.height * 0.03),
                    _buildMealSection(
                      context,
                      size,
                      'Lunch',
                      'images/lunch.jpeg',
                      mealProvider.lunch,
                      'lunch',
                    ),
                    SizedBox(height: size.height * 0.03),
                    _buildMealSection(
                      context,
                      size,
                      'Supper',
                      'images/supper.jpeg',
                      mealProvider.supper,
                      'supper',
                    ),
                    SizedBox(height: size.height * 0.1),
                  ],
                ),
                SizedBox(height: size.height * 0.03), // Bottom padding
              ],
            ),
            // Floating bot button at bottom right
     Positioned(
              bottom: size.height * 0.02,
              right: size.width * 0.05,
              child: GestureDetector(
                onTap: _openChat,
                child: Container(
                  width: size.width * 0.3,
                  height: size.width * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary,
                        blurRadius: 10,
                        spreadRadius: 4,
                      ),
                    ],
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 0.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'images/bot1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMealSection(BuildContext context, Size size, String title,
      String imagePath, List<Meal> meals, String mealType) {
    final bool isSelected = selectedMeal == mealType;
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: colorScheme.secondary.withOpacity(0.4),
          collapsedBackgroundColor: colorScheme.secondary.withOpacity(0.4),
          onExpansionChanged: (expanded) {
            setState(() {
              selectedMeal = expanded ? mealType : null;
            });
          },
          title: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: size.width * 0.04),
                child: Container(
                  width: size.width * 0.1,
                  height: size.width * 0.1,
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
                padding: EdgeInsets.only(left: size.width * 0.08),
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: size.width * 0.06,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          children: [
            SizedBox(
              height: size.height * 0.25,
              child: ListView(
                children: meals.map((meal) {
                  String category;
                  Color textColor;

                  if (meal.glycemicLoad >= 20) {
                    category = "High";
                    textColor = Colors.red;
                  } else if (meal.glycemicLoad >= 11) {
                    category = "Medium";
                    textColor = Colors.orangeAccent;
                  } else {
                    category = "Low";
                    textColor = Colors.green; // Fallback, as ColorScheme lacks green
                  }
                  return Container(
                    margin: EdgeInsets.all(size.width * 0.025),
                    padding: EdgeInsets.all(size.width * 0.025),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: size.height * 0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Glycemic Load: ${meal.glycemicLoad.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: size.width * 0.035,
                              ),
                            ),
                            Text(
                              category,
                              style: TextStyle(
                                color: textColor,
                                fontSize: size.width * 0.035,
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

class QuizAccessWidget extends StatelessWidget {
  const QuizAccessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Provider.of<ApiService>(context, listen: false).getQuizProgress(),
      builder: (context, snapshot) {
        String progressText = 'Loading...';
        bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        if (snapshot.hasData) {
          final progress = snapshot.data!;
          final completed = progress['completed_quizzes'] as int;
          final total = progress['total_quizzes'] as int;
          progressText = '$completed/$total quizzes completed';
        } else if (snapshot.hasError) {
          progressText = 'Error loading progress';
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LearnTab(),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test Your Nutrition Knowledge!',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          progressText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LearnTab(),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Take a Quiz'),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.quiz,
                    size: 50,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0.0);
      },
    );
  }
}