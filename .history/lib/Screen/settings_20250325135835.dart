import 'package:flutter/material.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  bool _isDarkMode = false;
  // Grams setting (true = use grams, false = use an alternative measurement)
  bool _useGrams = true;
  // Dark mode color - using the color you specified
  final Color _darkModeColor = const Color(0xFF12181B);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Load saved preferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _useGrams = prefs.getBool('useGrams') ?? true;
    });
  }

  // Update dark mode preference and change the theme
  Future<void> _updateDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _isDarkMode = value;
    });
    // Update the theme using GetX
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // Update grams setting preference
  Future<void> _updateGrams(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useGrams', value);
    setState(() {
      _useGrams = value;
    });
  }

  // Show dialog for unimplemented features
  void _showFeatureDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? _darkModeColor : Colors.white,
          title: Text(
            'Feature Not Implemented',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'The $feature feature will be implemented in a future update.',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: _isDarkMode ? Colors.lightBlueAccent : Colors.blue,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show dialog for logout confirmation
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? _darkModeColor : Colors.white,
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white70 : Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Implement actual logout functionality here
                Navigator.of(context).pop();
                // Navigate to login screen
                Get.offAllNamed('/login'); // Make sure you have this route defined
              },
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show dialog for account deletion confirmation
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? _darkModeColor : Colors.white,
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white70 : Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Implement account deletion here
                Navigator.of(context).pop();
                // Navigate to login screen after deletion
                Get.offAllNamed('/login'); // Make sure you have this route defined
              },
              child: Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show dialog for share app functionality
  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? _darkModeColor : Colors.white,
          title: Text(
            'Share App',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'Share this app with friends and family!',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white70 : Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                // Implement share functionality here
                // You'll need to add the share package to your pubspec.yaml
                Navigator.of(context).pop();
              },
              child: Text(
                'Share',
                style: TextStyle(
                  color: _isDarkMode ? Colors.lightBlueAccent : Colors.blue,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Adjust the background based on dark mode using the specified color
      backgroundColor: _isDarkMode ? _darkModeColor : const Color(0xffFDFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _isDarkMode ? const Color(0xff333333) : const Color(0xffBEE1DD),
        toolbarHeight: 60,
        title: Container(
          child: Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'OpenSauce',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : colorDark,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SettingsList(
        lightTheme: SettingsThemeData(
          settingsListBackground: const Color(0xffFDFFFF),
          settingsSectionBackground: Colors.white,
          tileDescriptionTextColor: Colors.black54,
        ),
        darkTheme: SettingsThemeData(
          settingsListBackground: _darkModeColor,
          settingsSectionBackground: _darkModeColor.withOpacity(0.9),
          tileDescriptionTextColor: Colors.white70,
        ),
        sections: [
          SettingsSection(
            margin: const EdgeInsetsDirectional.all(5),
            title: Text(
              'General Settings',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: _isDarkMode ? Colors.white70 : colorDark,
              ),
            ),
            tiles: [

              // Dark Mode Toggle
              SettingsTile.switchTile(
                onToggle: (value) {
                  _updateDarkMode(value);
                },
                initialValue: _isDarkMode,
                leading: Icon(
                  Icons.dark_mode,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                title: Text(
                  'Dark mode',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                description: Text(
                  'Enable dark theme for the app',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),

              // Grams setting toggle
              SettingsTile.switchTile(
                onToggle: (value) {
                  _updateGrams(value);
                },
                initialValue: _useGrams,
                leading: Icon(
                  Icons.scale,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                title: Text(
                  'Use grams',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                description: Text(
                  _useGrams ? 'Using grams as unit' : 'Using ounces as unit',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),

              // Change Password
              SettingsTile(
                title: Text(
                  'Change Password',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                leading: Icon(
                  Icons.key,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: (BuildContext context) {
                  _showFeatureDialog(context, 'Change Password');
                },
              ),

              // Notifications
              SettingsTile(
                title: Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                leading: Icon(
                  Icons.notifications_active_rounded,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: (BuildContext context) {
                  _showFeatureDialog(context, 'Notifications');
                },
              ),
            ],
          ),

          SettingsSection(
            margin: const EdgeInsetsDirectional.all(5),
            title: Text(
              'Account Settings',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: _isDarkMode ? Colors.white70 : colorDark,
              ),
            ),
            tiles: [
              SettingsTile(
                title: Text(
                  'Account',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                leading: Icon(
                  Icons.account_circle,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: (BuildContext context) {
                  Get.toNamed('/account');
                },
              ),
              SettingsTile(
                title: Text(
                  'Dietary history',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                leading: Icon(
                  Icons.library_books,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: (BuildContext context) {
                  _showFeatureDialog(context, 'Dietary history');
                },
              ),
              SettingsTile(
                title: Text(
                  'Delete Account',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                leading: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: (BuildContext context) {
                  _showDeleteAccountDialog(context);
                },
              ),
              SettingsTile(
                title: Text(
                  'Log Out',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                leading: Icon(
                  Icons.logout,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: (BuildContext context) {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
          SettingsSection(
            margin: const EdgeInsetsDirectional.all(5),
            title: Text(
              'Information',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: _isDarkMode ? Colors.white70 : colorDark,
              ),
            ),
            tiles: [
              SettingsTile(
                title: Text(
                  'About App',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                leading: Icon(
                  Icons.phone_android,
                  color: _isDarkMode ? Colors.white : Colors.black,
    ),
                onPressed: (BuildContext context) {
                  _showFeatureDialog(context, 'About App');
                },
              ),
              SettingsTile(
                title: Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                leading: Icon(
                  Icons.file_copy,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: (BuildContext context) {
                  _showFeatureDialog(context, 'Terms & Conditions');
                },
              ),
              SettingsTile(
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                leading: Icon(
                  Icons.verified_user,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: (BuildContext context) {
                  _showFeatureDialog(context, 'Privacy Policy');
                },
              ),
              SettingsTile(
                title: Text(
                  'Share This App',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                leading: Icon(
                  Icons.share,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
                onPressed: (BuildContext context) {
                  _showShareDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}