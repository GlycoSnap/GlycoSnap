import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:glycosnap/Utils/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glycosnap/Screen/account_settings.dart';
import 'package:glycosnap/Screen/login.dart';
import 'package:glycosnap/Screen/dietary_history.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _isDarkMode = false;
  // Grams setting (true = use grams, false = use an alternative measurement)
  bool _useGrams = true;
  // Dark mode color
  final Color _darkModeColor = AppTheme.darkSurface;

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
          backgroundColor:
              _isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
          title: Text(
            'Feature Not Implemented',
            style: TextStyle(
              color: _isDarkMode
                  ? AppTheme.darkOnSurface
                  : AppTheme.lightOnSurface,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'The $feature feature will be implemented in a future update.',
            style: TextStyle(
              color: _isDarkMode
                  ? AppTheme.darkOnSurface
                  : AppTheme.lightOnSurface,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: _isDarkMode
                      ? AppTheme.darkPrimary
                      : AppTheme.lightPrimary,
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.offAllNamed('/login');
              },
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
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
          backgroundColor:
              _isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: _isDarkMode
                  ? AppTheme.darkOnSurface
                  : AppTheme.lightOnSurface,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
            style: TextStyle(
              color: _isDarkMode
                  ? AppTheme.darkOnSurface
                  : AppTheme.lightOnSurface,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _isDarkMode
                      ? AppTheme.darkPrimary
                      : AppTheme.lightPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccount(context);
              },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: AppTheme.darkError,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(
              color: _isDarkMode ? AppTheme.darkPrimary : AppTheme.lightPrimary,
            ),
          );
        },
      );

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Delete user data from Supabase
      await Supabase.instance.client
          .from('users')
          .delete()
          .eq('user_id', user.id);

      // Delete user's meals
      await Supabase.instance.client
          .from('meals')
          .delete()
          .eq('user_id', user.id);

      // Delete the user's authentication
      await Supabase.instance.client.auth.admin.deleteUser(user.id);

      // Sign out
      await Supabase.instance.client.auth.signOut();

      // Close loading indicator
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login screen
      Get.offAll(() => const Login());
    } catch (e) {
      // Close loading indicator if it's showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete account: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                // Share the app using share_plus package

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

  // ADDED: About App dialog implementation
  void _showAboutAppDialog(BuildContext context) async {
    // Get app version information
    final packageInfo = await PackageInfo.fromPlatform();
    final String version = packageInfo.version;
    final String buildNumber = packageInfo.buildNumber;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? _darkModeColor : Colors.white,
          title: Text(
            'About GlycoSnap',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Image.asset(
                      'images/logo.png',
                      height: 80,
                      width: 80,
                    ),
                  ),
                ),
                Text(
                  'GlycoSnap',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Version: $version (Build $buildNumber)',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'GlycoSnap helps you track your glycemic intake through easy food scanning and smart nutrition tracking.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '© 2025 GlycoSnap Team\nAll rights reserved.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                    fontFamily: 'Poppins',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
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

  // ADDED: Show Privacy Policy dialog
  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? _darkModeColor : Colors.white,
          title: Text(
            'Privacy Policy',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Updated: March 2024',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white70 : Colors.black54,
                    fontFamily: 'Poppins',
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'At GlycoSnap, your privacy is a priority. This Privacy Policy explains how we collect, use, store, and protect your personal data when you use our services.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '1. Information We Collect',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'a. Personal Information\nWe may collect personal information such as:\n\n• Name, email address, and account credentials\n• Age, gender, and health-related preferences (optional)\n• Device identifiers and IP address',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'b. Health & Nutrition Data\n\n• Photos of meals for food recognition\n• Estimated glycemic load, portion size, calorie content, and nutritional insights\n• Feedback and input you provide regarding food habits',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'c. Device & App Usage Data\n\n• App interactions, session durations, and crash reports\n• Camera EXIF metadata (e.g., focal length, aperture) for depth estimation (only used locally or anonymized on backend)',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '2. How We Use Your Information',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We use your data to:\n\n• Detect and classify foods using AI models (YOLOv8, MiDaS)\n• Estimate portion size and glycemic load\n• Provide personalized nutritional feedback\n• Improve AI accuracy and enhance app performance\n• Conduct research and product development (in anonymized form)',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '3. How We Share Your Data',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We do not sell your personal data. We may share data:\n\n• With third-party services (e.g., Firebase) for authentication and storage\n• With analytics providers (e.g., Google Analytics for Firebase) in aggregated form\n• When required by law or to protect user safety and legal rights',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '4. Data Storage and Security',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Your data is encrypted during transmission (HTTPS) and at rest.\n• Photos are processed using secure servers; minimal image data is stored.\n• Authentication is managed via secure Firebase Authentication.\n• Access to backend services is restricted via role-based access control.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '5. Your Rights and Choices',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You can:\n\n• Access, update, or delete your account data\n• Request a copy of your stored information\n• Withdraw consent at any time\n• Opt out of analytics (via settings)\n\nTo exercise any of these rights, contact us at: privacy@glycosnap.ai',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '6. Children\'s Privacy',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'GlycoSnap is not intended for use by individuals under the age of 13. We do not knowingly collect personal data from children without parental consent.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '7. Data Retention',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We retain personal data only as long as necessary to:\n\n• Fulfill the purposes outlined in this policy\n• Comply with legal obligations\n• Improve app performance and user experience\n\nYou may request deletion of your data at any time.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '8. Changes to This Policy',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We may update this Privacy Policy occasionally. Changes will be reflected by the "Last Updated" date and notified via the app.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '9. Contact Us',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'If you have any questions or concerns about this Privacy Policy or your data, contact us at:\n\n📧 glycosnap@gmail.com\n🌍 glycosnap.jhubafrica.com/',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
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

  // ADDED: Show Terms and Conditions dialog
  void _showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? _darkModeColor : Colors.white,
          title: Text(
            'Terms and Conditions',
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to GlycoSnap. These Terms and Conditions ("Terms") govern your use of the GlycoSnap mobile application, website, and all related services (collectively, the "Service"). By using GlycoSnap, you agree to be bound by these Terms.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '1. Use of the Service',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You agree to:\n\n• Use GlycoSnap only for lawful purposes\n• Provide accurate information during registration and app use\n• Not misuse, hack, reverse-engineer, or interfere with our systems\n• Be responsible for maintaining the confidentiality of your account',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '2. User Eligibility',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'GlycoSnap is intended for individuals who are 13 years or older. If you are under 18, you must have parental or guardian consent to use the app.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '3. Health Disclaimer',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'GlycoSnap provides informational and educational services related to food recognition, glycemic load estimation, and nutrition. It does not constitute medical advice. Always consult a qualified healthcare provider before making changes to your diet or health routines.\n\nWe are not liable for any decisions made based on app output.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '4. Intellectual Property',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'All content, algorithms, models, images, and branding in GlycoSnap are the property of GlycoSnap or its licensors and are protected by copyright, trademark, and other intellectual property laws.\n\nYou may not copy, distribute, or reverse-engineer any part of the app without explicit written permission.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '5. User-Generated Content',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'You retain ownership of any images or information you upload. By submitting data, you grant GlycoSnap a non-exclusive, royalty-free license to use it for:\n\n• Processing food recognition\n• Improving AI models\n• Academic research (in anonymized form)\n\nYou agree not to upload harmful, offensive, or illegal content.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '6. Account Termination',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We reserve the right to suspend or terminate your account at any time if:\n\n• You violate these Terms\n• Your use poses a risk to the service or other users\n• We are required to do so by law or regulation\n\nYou may delete your account at any time via the app or by contacting us.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '7. Limitation of Liability',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'To the fullest extent permitted by law, GlycoSnap shall not be liable for:\n\n• Any indirect or incidental damages\n• Loss of data, profits, or health outcomes\n• Issues caused by third-party services (e.g., Firebase, camera API)',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '8. Modifications',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'We may update these Terms at any time. Continued use after updates means you accept the new Terms. Significant changes will be notified via email or in-app.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '9. Governing Law',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'These Terms shall be governed by and interpreted in accordance with the laws of the Republic of Kenya, without regard to its conflict of law provisions.',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '10. Contact Us',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'If you have questions or concerns regarding these Terms, please contact us at:\n\n📧 glycosnap@gmail.com\n🌍 glycosnap.jhubafrica.com/',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
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

  // Show dialog for change password
  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool _isLoading = false;
    bool _isCurrentPasswordVisible = false;
    bool _isNewPasswordVisible = false;
    bool _isConfirmPasswordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: _isDarkMode ? _darkModeColor : Colors.white,
              title: Text(
                'Change Password',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: !_isCurrentPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        labelStyle: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.black54,
                          fontFamily: 'Poppins',
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isCurrentPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color:
                                _isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _isCurrentPasswordVisible =
                                  !_isCurrentPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: !_isNewPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.black54,
                          fontFamily: 'Poppins',
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isNewPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color:
                                _isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _isNewPasswordVisible = !_isNewPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        labelStyle: TextStyle(
                          color: _isDarkMode ? Colors.white70 : Colors.black54,
                          fontFamily: 'Poppins',
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color:
                                _isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white70 : Colors.black54,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (newPasswordController.text !=
                              confirmPasswordController.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('New passwords do not match'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (newPasswordController.text.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'New password must be at least 6 characters'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          try {
                            final user =
                                Supabase.instance.client.auth.currentUser;
                            if (user == null) {
                              throw Exception('No user logged in');
                            }

                            // Update password
                            await Supabase.instance.client.auth.updateUser(
                              UserAttributes(
                                password: newPasswordController.text,
                              ),
                            );

                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Password updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Failed to update password: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        )
                      : Text(
                          'Update',
                          style: TextStyle(
                            color: _isDarkMode
                                ? Colors.lightBlueAccent
                                : Colors.blue,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            _isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
        toolbarHeight: 60,
        title: Container(
          child: Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'OpenSauce',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _isDarkMode
                  ? AppTheme.darkOnSurface
                  : AppTheme.lightOnSurface,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SettingsList(
        lightTheme: SettingsThemeData(
          settingsListBackground: AppTheme.lightSurface,
          settingsSectionBackground: AppTheme.lightSurface,
          tileDescriptionTextColor: AppTheme.lightOnSurface.withOpacity(0.7),
        ),
        darkTheme: SettingsThemeData(
          settingsListBackground: AppTheme.darkSurface,
          settingsSectionBackground: AppTheme.darkSurface.withOpacity(0.9),
          tileDescriptionTextColor: AppTheme.darkOnSurface.withOpacity(0.7),
        ),
        sections: [
          SettingsSection(
            margin: const EdgeInsetsDirectional.all(5),
            title: Text(
              'General Settings',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: _isDarkMode
                    ? AppTheme.darkOnSurface.withOpacity(0.7)
                    : AppTheme.lightOnSurface.withOpacity(0.7),
              ),
            ),
            tiles: [
              // Dark Mode Toggle
              SettingsTile(
                title: Text(
                  'Dark mode',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                description: Text(
                  'Enable dark theme for the app',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _isDarkMode
                        ? AppTheme.darkOnSurface.withOpacity(0.7)
                        : AppTheme.lightOnSurface.withOpacity(0.7),
                  ),
                ),
                leading: Icon(
                  Icons.dark_mode,
                  color: _isDarkMode
                      ? AppTheme.darkOnSurface
                      : AppTheme.lightOnSurface,
                ),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    _updateDarkMode(value);
                  },
                  activeColor: _isDarkMode
                      ? AppTheme.darkPrimary
                      : AppTheme.lightPrimary,
                  activeTrackColor: _isDarkMode
                      ? AppTheme.darkPrimary.withOpacity(0.5)
                      : AppTheme.lightPrimary.withOpacity(0.5),
                  inactiveThumbColor: _isDarkMode
                      ? AppTheme.darkOnSurface
                      : AppTheme.lightOnSurface,
                  inactiveTrackColor: _isDarkMode
                      ? AppTheme.darkOnSurface.withOpacity(0.1)
                      : AppTheme.lightOnSurface.withOpacity(0.1),
                ),
              ),
              SettingsTile(
                title: Text(
                  'Dietary history',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                leading: Icon(
                  Icons.library_books,
                  color: _isDarkMode
                      ? AppTheme.darkOnSurface
                      : AppTheme.lightOnSurface,
                ),
                onPressed: (BuildContext context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DietaryHistory(),
                    ),
                  );
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
                color: _isDarkMode
                    ? AppTheme.darkOnSurface.withOpacity(0.7)
                    : AppTheme.lightOnSurface.withOpacity(0.7),
              ),
            ),
            tiles: [
              SettingsTile(
                title: Text(
                  'Account',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                leading: Icon(
                  Icons.account_circle,
                  color: _isDarkMode
                      ? AppTheme.darkOnSurface
                      : AppTheme.lightOnSurface,
                ),
                onPressed: (BuildContext context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountSettings(),
                    ),
                  );
                },
              ),
              
              SettingsTile(
                title: Text(
                  'Delete Account',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                leading: Icon(
                  Icons.delete,
                  color: AppTheme.darkError,
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
                    color: _isDarkMode
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                leading: Icon(
                  Icons.logout,
                  color: _isDarkMode
                      ? AppTheme.darkOnSurface
                      : AppTheme.lightOnSurface,
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
                color: _isDarkMode
                    ? AppTheme.darkOnSurface.withOpacity(0.7)
                    : AppTheme.lightOnSurface.withOpacity(0.7),
              ),
            ),
            tiles: [
              SettingsTile(
                title: Text(
                  'About App',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                leading: Icon(
                  Icons.phone_android,
                  color: _isDarkMode
                      ? AppTheme.darkOnSurface
                      : AppTheme.lightOnSurface,
                ),
                onPressed: (BuildContext context) {
                  // UPDATED: Call new about app dialog method instead of feature dialog
                  _showAboutAppDialog(context);
                },
              ),
              SettingsTile(
                title: Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                leading: Icon(
                  Icons.file_copy,
                  color: _isDarkMode
                      ? AppTheme.darkOnSurface
                      : AppTheme.lightOnSurface,
                ),
                onPressed: (BuildContext context) {
                  _showTermsAndConditionsDialog(context);
                },
              ),
              SettingsTile(
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                leading: Icon(
                  Icons.verified_user,
                  color: _isDarkMode
                      ? AppTheme.darkOnSurface
                      : AppTheme.lightOnSurface,
                ),
                onPressed: (BuildContext context) {
                  _showPrivacyPolicyDialog(context);
                },
              ),
              SettingsTile(
                title: Text(
                  'Share This App',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: _isDarkMode
                        ? AppTheme.darkOnSurface
                        : AppTheme.lightOnSurface,
                  ),
                ),
                leading: Icon(
                  Icons.share,
                  color: _isDarkMode
                      ? AppTheme.darkOnSurface
                      : AppTheme.lightOnSurface,
                ),
                onPressed: (BuildContext context) {
                  _showFeatureDialog(context, 'Share App');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
