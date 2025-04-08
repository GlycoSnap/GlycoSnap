/*import 'package:flutter/material.dart';
import 'package:glycosnap/Authenticate/profile_picture.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:settings_ui/settings_ui.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xffBEE1DD),
        toolbarHeight: 60,
        title: Text(
          'Account',
          style: TextStyle(
            fontFamily: 'OpenSauce',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorDark,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: ProfilePicture(),
            ),
          const SizedBox(height: 50),
          Expanded(
            child: SettingsList(
              brightness: Brightness.light,
              lightTheme: SettingsThemeData(
                settingsListBackground: Colors.white,
                trailingTextColor : Colors.black,
                settingsSectionBackground: Colors.white,
                tileHighlightColor: Colors.purple,
                titleTextColor: Colors.black,
                leadingIconsColor: Colors.black,
                settingsTileTextColor: colorDark,
                inactiveSubtitleColor: Colors.red,
              ),
              sections: [
                SettingsSection(
                  margin: const EdgeInsetsDirectional.all(5),
                  tiles: [
                    SettingsTile(
                      title: const Text(
                        'Username',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: const Icon(
                        Icons.person,
                      ),
                      trailing: const Text(
                        'Nanami Kento',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                        ),
                      ),
                      onPressed: (context) {
                        // Handle change password logic here
                      },
                    ),
                    SettingsTile(
                      title: const Text(
                        'Phone',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: const Icon(
                        Icons.phone,
                      ),
                      trailing: const Text(
                        '0123456789',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                        ),
                      ),
                      onPressed: (context) {
                        // Handle change password logic here
                      },
                    ),
                    SettingsTile(
                      title: const Text(
                        'Email',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: const Icon(
                        Icons.email,
                      ),
                      trailing: const Text(
                        'nanamikento@gmail.com',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                        ),
                      ),
                      onPressed: (context) {
                        // Handle change password logic here
                      },
                    ),
                    SettingsTile(
                      title: const Text(
                        'Date of Birth',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: const Icon(
                        Icons.calendar_month,
                      ),
                      trailing: const Text(
                        '03/05/2003',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                        ),
                      ),
                      onPressed: (context) {
                        // Handle notifications logic here
                      },
                    ),
                    SettingsTile(
                      title: const Text(
                        'Gender',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: const Icon(
                        Icons.transgender,
                      ),
                      trailing: const Text(
                        'Male',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                        ),
                      ),
                      onPressed: (context) {
                        // Handle notifications logic here
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

