import 'package:flutter/material.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find<SettingsController>();
  
  final isDarkMode = false.obs;
  final preferredUnit = "Grams".obs;

  static Future<void> init() async {
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }

    final prefs = await SharedPreferences.getInstance();
    final controller = SettingsController.to;

    controller.isDarkMode.value = prefs.getBool("darkMode") ?? false;
    controller.preferredUnit.value = prefs.getString("preferredUnit") ?? "Grams";
  }

  void setDarkMode(bool value) async {
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);
  }

  void setPreferredUnit(String unit) async {
    preferredUnit.value = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("preferredUnit", unit);
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final controller = Get.put(SettingsController()); // Ensure the controller is initialized

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = controller.isDarkMode.value;
      final textColor = isDarkMode ? Colors.white : Colors.black;
      final titleColor = isDarkMode ? Colors.white70 : colorDark;

      return Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xffFDFFFF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xffBEE1DD),
          toolbarHeight: 60,
          title: Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'OpenSauce',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : colorDark,
            ),
          ),
          centerTitle: true,
        ),
        body: SettingsList(
          sections: [
            SettingsSection(
              margin: const EdgeInsetsDirectional.all(5),
              title: Text(
                'General Settings',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: titleColor),
              ),
              tiles: [
                SettingsTile.switchTile(
                  onToggle: (value) => controller.setDarkMode(value),
                  initialValue: controller.isDarkMode.value,
                  leading: const Icon(Icons.dark_mode, color: Colors.black),
                  title: Text(
                    'Dark mode',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: textColor),
                  ),
                ),
                SettingsTile(
                  title: Text(
                    'Preferred Unit',
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: textColor),
                  ),
                  leading: const Icon(Icons.scale, color: Colors.black),
                  trailing: Text(controller.preferredUnit.value, style: TextStyle(color: textColor)),
                  onPressed: (BuildContext context) => _showUnitDialog(context),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showUnitDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Select Unit",
      content: Column(
        children: [
          ListTile(
            title: const Text("Grams"),
            onTap: () {
              controller.setPreferredUnit("Grams");
              Get.back();
            },
          ),
          ListTile(
            title: const Text("Ounces"),
            onTap: () {
              controller.setPreferredUnit("Ounces");
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}