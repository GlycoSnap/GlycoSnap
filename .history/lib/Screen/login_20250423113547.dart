import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';
import 'package:glycosnap/main.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Force-clear any existing session so AuthWrapper will show Login, not MainScreen
    Supabase.instance.client.auth.signOut();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email:    emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 1) Handle Supabase error
      if (res.error != null) {
        Get.snackbar(
          'Login Error',
          res.error!.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 2) Ensure we actually have a session & user
      final session = res.session;
      if (session == null || session.user == null) {
        Get.snackbar(
          'Login Error',
          'Could not retrieve session. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 3) Success → navigate into the app
      Get.offAll(() => const MainScreen());
    } catch (e) {
      Get.snackbar(
        'Unexpected Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Container(
          width: size.width * 0.85,
          height: size.height * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
          ),
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                        controller:   emailController,
                        label:        "Email",
                        icon:         Icons.email,
                        isPassword:   false),
                    SizedBox(height: size.height * 0.05),
                    _buildTextField(
                        controller:   passwordController,
                        label:        "Password",
                        icon:         Icons.lock,
                        isPassword:   true),
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
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              PrettyWaveButton(
                backgroundColor: Theme.of(context).colorScheme.primary,
                horizontalPadding: 80,
                onPressed: _isLoading
                    ? null
                    : () => _signInWithEmailAndPassword(),  // wrap async
                child: _isLoading
                    ? CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : Text(
                        'Login',
                        style: TextStyle(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              SizedBox(height: size.height * 0.06),
              _buildSocialLoginSection(size),
              SizedBox(height: size.height * 0.07),
              GestureDetector(
                onTap: () => Get.toNamed('/slides'),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Not a member? ",
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      ),
                      TextSpan(
                        text: "Register now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isPassword,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      keyboardType:
          isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
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
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.12),
            ),
            Text(
              "  Or continue with  ",
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
              ),
            ),
            Container(
              height: 3,
              width: size.width * 0.17,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.12),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Image.asset(image, height: 35),
    );
  }
}
