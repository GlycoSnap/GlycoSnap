import 'package:flutter/material.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:glycosnap/main.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInAnonymously() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      // Successfully signed in
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to sign in anonymously: $e"),
        ),
      );
    }
  }

  void _validateAndProceed() {
    if (_formKey.currentState?.validate() ?? false) {
      print('Form validated');
      _signInAnonymously();
    } else {
      print('Form not validated');
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor2,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          width: size.width * 0.85,
          height: size.height * 0.85,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            children: [
              SizedBox(height: size.height * 0.03),
              Text(
                "Login",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'OpenSauce',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: colorDark,
                ),
              ),
              SizedBox(height: size.height * 0.04),
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
                        suffixIcon: const Icon(
                          Icons.email,
                          color: Colors.black26,
                        ),
                        filled: true,
                        fillColor: white,
                        labelText: 'Email',
                        labelStyle: const TextStyle(
                          color: Colors.black26,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your Email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
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
                        fillColor: white,
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                          color: Colors.black26,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black45,
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
                          return 'Please enter your Password';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '');
                },
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot Password?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'OpenSauce',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              PrettyWaveButton(
                backgroundColor: colorLight,
                horizontalPadding: 120,
                onPressed: _validateAndProceed,
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 3,
                    width: size.width * 0.17,
                    color: Colors.black12,
                  ),
                  Text(
                    "  Or continue with  ",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: colorDark,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    height: 3,
                    width: size.width * 0.17,
                    color: Colors.black12,
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.06),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  socialIcon("images/google.png"),
                  socialIcon("images/apple.png"),
                ],
              ),
              SizedBox(height: size.height * 0.07),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/slides');
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Not a member? ",
                        style: TextStyle(
                          color: colorDark,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "Register now",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: colorLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container socialIcon(String image) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: Image.asset(
        image,
        height: 35,
      ),
    );
  }
}
