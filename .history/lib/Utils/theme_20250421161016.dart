import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xff0C3B60);
  static const Color lightSecondary = Color(0xFFCDE9E6);
  static const Color lightSurface = Color(0xffFDFFFF);
  static const Color lightSurfaceContainer = Color(0xFFE5F6F6);
  static const Color lightOnSurface = Color(0xff000000);
  static const Color lightOnPrimary = Color(0xffFFFFFF);
  static const Color lightOnSecondary = Color(0xffFFFFFF);
  static const Color lightError = Color.fromARGB(255, 255, 0, 0);

  // Dark Theme Colors
  static const Color darkPrimary = Color(0xff47B2A5);
  static const Color darkSecondary = Color(0xff48cae4);
  static const Color darkSurface = Color(0xff000000);
  static const Color darkSurfaceContainer = colorDar;
  static const Color darkOnSurface = Color(0xffFFFFFF);
  static const Color darkOnPrimary = Color(0xffFFFFFF);
  static const Color darkOnSecondary = Color(0xff000000);
  static const Color darkError = Color.fromARGB(255, 255, 0, 0);

  // Theme controller
  static final ThemeController themeController = ThemeController();

  // Get current theme mode
  static ThemeMode get themeMode => themeController.themeMode;

  // Get current theme data
  static ThemeData get themeData => themeController.themeData;

  // Helper method to get text style
  static TextStyle textStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    bool isSecondary = false,
  }) {
    return TextStyle(
      color: isSecondary
          ? themeController.textSecondaryColor
          : themeController.textColor,
      fontFamily: 'Poppins',
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  // Helper method to get card style
  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: context.isDarkMode
              ? const Color(0xff0C3B60).withOpacity(0.3)
              : const Color.fromARGB(255, 162, 196, 193).withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // Helper method to get button style
  static ButtonStyle buttonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class ThemeController extends GetxController {
  final RxBool _isDarkMode = false.obs;
  bool get isDarkMode => _isDarkMode.value;
  ThemeMode get themeMode =>
      _isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  // Color getters
  Color get backgroundColor =>
      _isDarkMode.value ? AppTheme.darkSurface : AppTheme.lightSurface;
  Color get surfaceColor =>
      _isDarkMode.value ? AppTheme.darkSurface : AppTheme.lightSurface;
  Color get textColor =>
      _isDarkMode.value ? AppTheme.darkOnSurface : AppTheme.lightOnSurface;
  Color get textSecondaryColor => _isDarkMode.value
      ? AppTheme.darkOnSurface.withOpacity(0.7)
      : AppTheme.lightOnSurface.withOpacity(0.7);
  Color get accentColor =>
      _isDarkMode.value ? AppTheme.darkPrimary : AppTheme.lightPrimary;

  // Theme data
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        brightness: _isDarkMode.value ? Brightness.dark : Brightness.light,
        colorScheme: ColorScheme(
          brightness: _isDarkMode.value ? Brightness.dark : Brightness.light,
          primary:
              _isDarkMode.value ? AppTheme.darkPrimary : AppTheme.lightPrimary,
          onPrimary: _isDarkMode.value
              ? AppTheme.darkOnPrimary
              : AppTheme.lightOnPrimary,
          secondary: _isDarkMode.value
              ? AppTheme.darkSecondary
              : AppTheme.lightSecondary,
          onSecondary: _isDarkMode.value
              ? AppTheme.darkOnSecondary
              : AppTheme.lightOnSecondary,
          error: _isDarkMode.value ? AppTheme.darkError : AppTheme.lightError,
          onError: _isDarkMode.value
              ? AppTheme.darkOnSurface
              : AppTheme.lightOnSurface,
          surface:
              _isDarkMode.value ? AppTheme.darkSurface : AppTheme.lightSurface,
          onSurface: _isDarkMode.value
              ? AppTheme.darkOnSurface
              : AppTheme.lightOnSurface,
          background:
              _isDarkMode.value ? AppTheme.darkSurface : AppTheme.lightSurface,
          onBackground: _isDarkMode.value
              ? AppTheme.darkOnSurface
              : AppTheme.lightOnSurface,
          surfaceContainer: _isDarkMode.value
              ? AppTheme.darkSurfaceContainer
              : AppTheme.lightSurfaceContainer,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor:
              _isDarkMode.value ? AppTheme.darkSurface : AppTheme.lightSurface,
          foregroundColor: _isDarkMode.value
              ? AppTheme.darkOnSurface
              : AppTheme.lightOnSurface,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTheme.textStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardTheme(
          color: _isDarkMode.value
              ? AppTheme.darkSurfaceContainer
              : AppTheme.lightSurfaceContainer,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isDarkMode.value
                ? AppTheme.darkPrimary
                : AppTheme.lightPrimary,
            foregroundColor: _isDarkMode.value
                ? AppTheme.darkOnPrimary
                : AppTheme.lightOnPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _isDarkMode.value
                ? AppTheme.darkPrimary
                : AppTheme.lightPrimary,
          ),
        ),
        iconTheme: IconThemeData(
          color: _isDarkMode.value
              ? AppTheme.darkOnSurface
              : AppTheme.lightOnSurface,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: _isDarkMode.value
              ? AppTheme.darkSurfaceContainer
              : AppTheme.lightSurfaceContainer,
          titleTextStyle: AppTheme.textStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: AppTheme.textStyle(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = prefs.getBool('darkMode') ?? false;
  }

  Future<void> toggleTheme() async {
    _isDarkMode.value = !_isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode.value);
    Get.changeThemeMode(themeMode);
  }
}