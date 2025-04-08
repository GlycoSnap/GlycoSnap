import 'package:flutter/material.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:get/get.dart';

class Settings extends StatefulWidget {
  const Settings ({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffBEE1DD),
        toolbarHeight: 60,
        title: Container(
          child: Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'OpenSauce',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorDark,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: 
      SettingsList(
        sections: [
          SettingsSection(
            margin: const EdgeInsetsDirectional.all(5),
            title: Text('General Settings',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: colorDark,
            ),),
            tiles: [
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: false,
                leading: const Icon(Icons.dark_mode,
                color: Colors.black,),
                title: const Text('Dark mode',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),),
              ),
              SettingsTile(
                title: const Text('Change Password',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),
                ),
                leading: const Icon(Icons.key,
                color: Colors.black,),
                //trailing: ,
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: const Text('Notifications',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),
                ),
                leading: const Icon(Icons.notifications_active_rounded,
                color: Colors.black,),
                //switchValue: value,
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
          SettingsSection(
            margin: const EdgeInsetsDirectional.all(5),
            title: Text('Account Settings',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: colorDark,
            ),),
            tiles: [
              SettingsTile(
                title: const Text('Account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),
                ),
                leading: const Icon(
                  Icons.account_circle,
                  color: Colors.black,
                  ),
                onPressed: (BuildContext context) {
                  Get.toNamed('/account');
                },
              ),
              SettingsTile(
                title: const Text('Dietary history',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),),
                leading: const Icon(Icons.library_books,
                color: Colors.black,),
                //trailing: ,
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: const Text('Delete Account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),
                ),
                leading: const Icon(Icons.delete,
                color: Colors.black,),
                //trailing: ,
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: const Text('Log Out',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),
                ),
                leading: const Icon(Icons.logout,
                color: Colors.black,),
                //trailing: ,
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
          SettingsSection(
            margin: const EdgeInsetsDirectional.all(5),
            title: Text('Information',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: colorDark,
            ),),
            tiles: [
              SettingsTile(
                title: const Text('About App',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),
                ),
                leading: const Icon(
                  Icons.phone_android,
                  color: Colors.black,
                  ),
                //trailing: ,
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: const Text('Terms & Conditions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),
                ),
                leading: const Icon(Icons.file_copy,
                color: Colors.black,),
                //trailing: ,
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: const Text('Privacy Policy',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),
                ),
                leading: const Icon(Icons.verified_user,
                color: Colors.black,),
                //trailing: ,
                onPressed: (BuildContext context) {},
              ),
              SettingsTile(
                title: const Text('Share This App',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.black,
                ),
                ),
                leading: const Icon(Icons.share,
                color: Colors.black,),
                //trailing: ,
                onPressed: (BuildContext context) {},
              ),
            ],
          ),
        ],
      ),
      
      
    );
  }
}