import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:glycosnap/main.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';

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
  bool _isLoading = false; // Track loading state

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        if (userCredential.user != null) {
          Get.offAll(() => const MainScreen());
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          default:
            errorMessage = 'Login failed: ${e.message}';
        }
        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar('Error', 'An unexpected error occurred: $e',
            snackPosition: SnackPosition.BOTTOM);
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor2,
            borderRadius: BorderRadius.circular(15),
          ),
          width: size.width * 0.85,
          height: size.height * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: ListView(
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
                    _buildTextField(
                        emailController, "Email", Icons.email, false),
                    SizedBox(height: size.height * 0.05), // Adjusted spacing
                    _buildTextField(
                        passwordController, "Password", Icons.lock, true),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.toNamed('/forgot-password'),
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              PrettyWaveButton(
                backgroundColor: colorLight,
                horizontalPadding: 120,
                onPressed: () {
                  if (!_isLoading) {
                    _signInWithEmailAndPassword();
                  }
                },
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              SizedBox(height: size.height * 0.06),
              _buildSocialLoginSection(size),
              SizedBox(height: size.height * 0.07),
              GestureDetector(
                onTap: () => Get.toNamed('/register'),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Not a member? ",
                        style: TextStyle(
                          color: colorDark,
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "Register now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorLight,
                          fontSize: 16,
                        ),
                      ),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isPassword,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      keyboardType: isPassword
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: white,
        labelText: label,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : Icon(icon, color: Colors.black26),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        if (label == "Email" &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        if (label == "Password" && value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildSocialLoginSection(Size size) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 3,
              width: size.width * 0.17,
              color: Colors.black12,
            ),
            const Text(
              "  Or continue with  ",
              style: TextStyle(fontSize: 16),
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
            _buildSocialIcon("images/google.png"),
            _buildSocialIcon("images/apple.png"),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(String image) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Image.asset(image, height: 35),
    );
  }
}
