import 'package:flutter/material.dart';
import 'package:glycosnap/main.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:glycosnap/Authenticate/user_provider.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:glycosnap/Authenticate/api_service.dart';

class SignUpQuestions extends StatefulWidget {
  const SignUpQuestions({super.key});

  @override
  State<SignUpQuestions> createState() => _SignUpQuestionsState();
}

class _SignUpQuestionsState extends State<SignUpQuestions> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController fnameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();

  @override
  void dispose() {
    fnameController.dispose();
    surnameController.dispose();
    super.dispose();
  }

  void _validateAndProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      Get.to(
        () => Question2(
          profileData: {
            'first_name': fnameController.text.trim(),
            'last_name': surnameController.text.trim(),
          },
        ),
        transition: Transition.zoom,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.all(size.width * 0.04),
              width: size.width * 0.9,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearPercentIndicator(
                    lineHeight: size.height * 0.035,
                    barRadius: const Radius.circular(20.0),
                    percent: 0.25,
                    animation: true,
                    animationDuration: 500,
                    backgroundColor: colorDark,
                    progressColor: colorLight,
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    "Before we get started we would love to get to know you better",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontFamily: 'Poppins',
                      fontSize: size.width * 0.04,
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: fnameController,
                          keyboardType: TextInputType.name,
                          autocorrect: false,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            labelText: 'First name',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height * 0.05),
                        TextFormField(
                          controller: surnameController,
                          keyboardType: TextInputType.name,
                          autocorrect: false,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            labelText: 'Surname',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your surname';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PrettyWaveButton(
                        backgroundColor: colorScheme.surface,
                        horizontalPadding: size.width * 0.12,
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      PrettyWaveButton(
                        backgroundColor: colorScheme.primary,
                        horizontalPadding: size.width * 0.12,
                        onPressed: _validateAndProceed,
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Gender { male, female, preferNotToSay }

class Question2 extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const Question2({super.key, required this.profileData});

  @override
  State<Question2> createState() => _Question2State();
}

class _Question2State extends State<Question2> {
  Gender? _character = Gender.male;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController datePickerController = TextEditingController();

  @override
  void dispose() {
    datePickerController.dispose();
    super.dispose();
  }

  Future<void> onTapFunction({required BuildContext context}) async {
    final colorScheme = Theme.of(context).colorScheme;

    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime.now(),
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              surface: colorScheme.surface,
              onSurface: colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      datePickerController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  void _validateAndProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProfileData = Map<String, dynamic>.from(widget.profileData)
        ..addAll({
          'gender': _character.toString().split('.').last,
          'date_of_birth': datePickerController.text,
        });
      Get.to(
        () => Question3(profileData: updatedProfileData),
        transition: Transition.zoom,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(size.width * 0.04),
              width: size.width * 0.9,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearPercentIndicator(
                    lineHeight: size.height * 0.035,
                    barRadius: const Radius.circular(20.0),
                    percent: 0.5,
                    animation: true,
                    animationDuration: 500,
                    backgroundColor: colorDark,
                    progressColor: colorLight,
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    "Just a few details about you",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontFamily: 'OpenSauce',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    "What is your gender?",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            'Male',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          leading: Radio(
                            value: Gender.male,
                            groupValue: _character,
                            onChanged: (Gender? value) {
                              setState(() {
                                _character = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Female',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          leading: Radio(
                            value: Gender.female,
                            groupValue: _character,
                            onChanged: (Gender? value) {
                              setState(() {
                                _character = value;
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Prefer not to say',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          leading: Radio(
                            value: Gender.preferNotToSay,
                            groupValue: _character,
                            onChanged: (Gender? value) {
                              setState(() {
                                _character = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: size.height * 0.06),
                        Text(
                          "Date of birth",
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: size.height * 0.015),
                        SizedBox(
                          width: size.width * 0.65,
                          child: TextFormField(
                            controller: datePickerController,
                            readOnly: true,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              hintText: "Click here to select date",
                              filled: true,
                              fillColor: colorScheme.surface,
                              hintStyle: TextStyle(
                                color: colorScheme.onSurface.withAlpha(179),
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w200,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                  color: colorScheme.outline,
                                  width: 1,
                                ),
                              ),
                            ),
                            onTap: () => onTapFunction(context: context),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your date of birth';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PrettyWaveButton(
                        backgroundColor: colorScheme.surface,
                        horizontalPadding: size.width * 0.12,
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      PrettyWaveButton(
                        backgroundColor: colorScheme.primary,
                        horizontalPadding: size.width * 0.12,
                        onPressed: _validateAndProceed,
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Question3 extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const Question3({super.key, required this.profileData});

  @override
  State<Question3> createState() => _Question3State();
}

class _Question3State extends State<Question3> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void _validateAndProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedProfileData = Map<String, dynamic>.from(widget.profileData)
        ..addAll({
          'height': double.tryParse(heightController.text.trim()),
          'weight': double.tryParse(weightController.text.trim()),
        });
      Get.to(
        () => CreateAccount(profileData: updatedProfileData),
        transition: Transition.zoom,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(size.width * 0.04),
              width: size.width * 0.9,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearPercentIndicator(
                    lineHeight: size.height * 0.035,
                    barRadius: const Radius.circular(20.0),
                    percent: 0.75,
                    animation: true,
                    animationDuration: 500,
                    backgroundColor: colorDark,
                    progressColor: colorLight,
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    "Your body metrics",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontFamily: 'OpenSauce',
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          autocorrect: false,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 12, 0, 0),
                              child: Text(
                                'cm',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: size.width * 0.04,
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            labelText: 'Height',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height * 0.05),
                        TextFormField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          autocorrect: false,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 12, 0, 0),
                              child: Text(
                                'kg',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: size.width * 0.04,
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            labelText: 'Weight',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PrettyWaveButton(
                        backgroundColor: colorScheme.surface,
                        horizontalPadding: size.width * 0.12,
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      PrettyWaveButton(
                        backgroundColor: colorScheme.primary,
                        horizontalPadding: size.width * 0.12,
                        onPressed: _validateAndProceed,
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CreateAccount extends StatefulWidget {
  final Map<String, dynamic> profileData;
  const CreateAccount({super.key, required this.profileData});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool isChecked = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUpWithGoogle() async {
    if (!isChecked) {
      Get.snackbar(
        'Error',
        'Please agree to the terms of service and privacy policy',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.signUpWithGoogle();
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Save the profile if the user is authenticated
        await Provider.of<UserProvider>(context, listen: false).saveUserProfile(
          firstName: widget.profileData['first_name'],
          lastName: widget.profileData['last_name'],
          gender: widget.profileData['gender'],
          dateOfBirth: widget.profileData['date_of_birth'],
          height: widget.profileData['height'],
          weight: widget.profileData['weight'],
        );

        // Navigate to MainScreen
        Get.offAll(() => const MainScreen());
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign up with Google: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createAccountWithEmailAndPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!isChecked) {
      Get.snackbar(
        'Error',
        'Please agree to the terms of service and privacy policy',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign up with Supabase
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check if there's an error from Supabase
      if (res.user == null) {
        Get.snackbar(
          'Info',
          'Please check your email to confirm your account.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Verify that the user is logged in (session exists)
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        Get.snackbar(
          'Info',
          'Please check your email to confirm your account.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Save the profile if the user is authenticated
      await Provider.of<UserProvider>(context, listen: false).saveUserProfile(
        firstName: widget.profileData['first_name'],
        lastName: widget.profileData['last_name'],
        gender: widget.profileData['gender'],
        dateOfBirth: widget.profileData['date_of_birth'],
        height: widget.profileData['height'],
        weight: widget.profileData['weight'],
      );

      // Navigate to MainScreen
      Get.offAll(() => const MainScreen());
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.surface,
        toolbarHeight: size.height * 0.05,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              width: size.width * 0.9,
              padding: EdgeInsets.all(size.width * 0.04),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearPercentIndicator(
                    lineHeight: size.height * 0.035,
                    barRadius: const Radius.circular(20.0),
                    percent: 1.0,
                    animation: true,
                    animationDuration: 500,
                    backgroundColor: colorDark,
                    progressColor: colorLight,
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    "Create Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'OpenSauce',
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.05,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: Icon(
                              Icons.email,
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height * 0.03),
                        TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          autocorrect: false,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: colorScheme.onSurface.withAlpha(179),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height * 0.03),
                        TextFormField(
                          controller: confirmPasswordController,
                          keyboardType: TextInputType.visiblePassword,
                          autocorrect: false,
                          obscureText: !_isPasswordVisible,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: colorScheme.onSurface.withAlpha(179),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "I agree to terms of service and privacy policy",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: size.width * 0.030,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                    activeColor: colorScheme.secondary,
                  ),
                  SizedBox(height: size.height * 0.02),
                  PrettyWaveButton(
                    backgroundColor: colorScheme.primary,
                    horizontalPadding: size.width * 0.25,
                    onPressed: () {
                      if (!_isLoading) {
                        _createAccountWithEmailAndPassword();
                      }
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Sign Up',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 3,
                        width: size.width * 0.17,
                        color: colorScheme.onSurface.withAlpha(20),
                      ),
                      Text(
                        "  Or continue with  ",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: colorScheme.primary,
                          fontSize: size.width * 0.035,
                        ),
                      ),
                      Container(
                        height: 3,
                        width: size.width * 0.17,
                        color: colorScheme.onSurface.withAlpha(20),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      socialIcon("images/google.png", size),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                  InkWell(
                    onTap: () {
                      Get.toNamed('/login');
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Already a member? ",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w300,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.035,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PrettyWaveButton(
                        backgroundColor: colorScheme.surface,
                        horizontalPadding: size.width * 0.15,
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget socialIcon(String image, Size size) {
    return GestureDetector(
      onTap: () {
        if (image.contains('google')) {
          _signUpWithGoogle();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.015,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).colorScheme.onPrimary, width: 2),
        ),
        child: Image.asset(image, height: size.height * 0.03),
      ),
    );
  }
}

extension on supabase.AuthResponse {
  get error => null;
}
