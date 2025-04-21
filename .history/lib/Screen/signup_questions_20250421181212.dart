import 'package:flutter/material.dart';
import 'package:glycosnap/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
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
        () => const Question2(),
        transition: Transition.zoom,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.topCenter,
              padding: EdgeInsets.all(size.width * 0.04),
              width: size.width * 0.9,
              decoration: BoxDecoration(
                color: backgroundColor2,
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
                      color: black,
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
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            filled: true,
                            fillColor: white,
                            labelText: 'First name',
                            labelStyle: const TextStyle(
                              color: Colors.black54,
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
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            filled: true,
                            fillColor: white,
                            labelText: 'Surname',
                            labelStyle: const TextStyle(
                              color: Colors.black54,
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
                        backgroundColor: white,
                        horizontalPadding: size.width * 0.12,
                        onPressed: () {
                          Get.back();
                        },
                        child:Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      PrettyWaveButton(
                        backgroundColor: colorLight,
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

enum Gender { male, female, prefernottosay }

class Question2 extends StatefulWidget {
  const Question2({super.key});

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
    DateTime? pickedDate = await showDatePicker(
      context: context,
      lastDate: DateTime.now(),
      firstDate: DateTime(1900),
      initialDate: DateTime.now(),
    );

    if (pickedDate != null) {
      datePickerController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  void _validateAndProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Question3()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(size.width * 0.04),
              width: size.width * 0.9,
              decoration: BoxDecoration(
                color: backgroundColor2,
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
                  const Text(
                    "Just a few details about you",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'OpenSauce',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  const Text(
                    "What is your gender?",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Male'),
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
                          title: const Text('Female'),
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
                          title: const Text('Prefer not say'),
                          leading: Radio(
                            value: Gender.prefernottosay,
                            groupValue: _character,
                            onChanged: (Gender? value) {
                              setState(() {
                                _character = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: size.height * 0.06),
                        const Text(
                          "Date of birth",
                          style: TextStyle(
                            color: Colors.black,
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
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              hintText: "Click here to select date",
                              filled: true,
                              fillColor: Colors.white,
                              hintStyle: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w200,
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
                        backgroundColor: Colors.white,
                        horizontalPadding: size.width * 0.12,
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpQuestions()),
                          );
                        },
                      ),
                      PrettyWaveButton(
                        backgroundColor: colorLight,
                        horizontalPadding: size.width * 0.12,
                        onPressed: _validateAndProceed,
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize:size.width * 0.045,
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
  const Question3({super.key});

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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateAccount()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(size.width * 0.04),
              width: size.width * 0.9,
              decoration: BoxDecoration(
                color: backgroundColor2,
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
                      color: black,
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
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: white,
                            labelText: 'Height',
                            labelStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height * 0.05),
                        TextFormField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          autocorrect: false,
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
                                  color: black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: white,
                            labelText: 'Weight',
                            labelStyle: const TextStyle(
                              color: Colors.black26,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight';
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
                        backgroundColor: white,
                        horizontalPadding: size.width * 0.12,
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Question2()),
                          );
                        },
                      ),
                      PrettyWaveButton(
                        backgroundColor: colorLight,
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
  const CreateAccount({super.key});

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccountWithEmailAndPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!isChecked) {
        Get.snackbar(
            'Error', 'Please agree to the terms of service and privacy policy',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        if (userCredential.user != null) {
          Get.offAll(() => const MainScreen());
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already registered.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format.';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak (minimum 6 characters).';
            break;
          default:
            errorMessage = 'Sign-up failed: ${e.message}';
        }
        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Error', 'An unexpected error occurred: $e',
            snackPosition: SnackPosition.BOTTOM);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
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
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: Icon(
                              Icons.email,
                              color: Colors.black87,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Email',
                            labelStyle: TextStyle(
                              color: Colors.black38,
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
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.black38,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
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
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(
                              color: Colors.black38,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
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
                    backgroundColor: colorScheme.secondary,
                    horizontalPadding: size.width * 0.25,
                    onPressed: () {
                      if (!_isLoading) {
                        _createAccountWithEmailAndPassword();
                      }
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
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
                        color: colorScheme.onSurface.withOpacity(0.2),
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
                        color: colorScheme.onSurface.withOpacity(0.2),
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
                        backgroundColor: colorScheme.onPrimary,
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
                          Navigator.pop(context);
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

  Container socialIcon(String image, Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.015,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 2),
      ),
      child: Image.asset(image, height: size.height * 0.03),
    );
  }
}