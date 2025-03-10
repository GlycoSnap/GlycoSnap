import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsController.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: SettingsController.to.isDarkMode.value
              ? ThemeData.dark()
              : ThemeData.light(),
          home: SettingsScreen(),
        ));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text("Appearance"),
            tiles: [
              SettingsTile.switchTile(
                title: Text("Dark Mode"),
                leading: Icon(Icons.dark_mode),
                initialValue: SettingsController.to.isDarkMode.value,
                onToggle: (value) => SettingsController.to.setDarkMode(value),
              ),
            ],
          ),
          SettingsSection(
            title: Text("Preferences"),
            tiles: [
              SettingsTile.navigation(
                title: Text("Preferred Units"),
                leading: Icon(Icons.scale),
                value: Text(SettingsController.to.preferredUnit.value),
                onPressed: (context) => _showUnitDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUnitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Select Preferred Unit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ["Grams", "Ounces"]
              .map((unit) => RadioListTile(
                    title: Text(unit),
                    value: unit,
                    groupValue: SettingsController.to.preferredUnit.value,
                    onChanged: (value) {
                      SettingsController.to.setPreferredUnit(value!);
                      Get.back();
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();
  var isDarkMode = false.obs;
  var preferredUnit = "Grams".obs;

  static Future<void> init() async {
    Get.put(SettingsController());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SettingsController.to.isDarkMode.value = prefs.getBool("darkMode") ?? false;
    SettingsController.to.preferredUnit.value = prefs.getString("preferredUnit") ?? "Grams";
  }

  void setDarkMode(bool value) async {
    isDarkMode.value = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);
  }

  void setPreferredUnit(String unit) async {
    preferredUnit.value = unit;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("preferredUnit", unit);
  }
}
