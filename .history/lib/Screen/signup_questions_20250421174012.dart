

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
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: white,
        toolbarHeight: size.height * 0.05,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: white,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Center(
              child: Container(
                alignment: Alignment.center,
                width: size.width * 0.9,
                padding: EdgeInsets.all(size.width * 0.04), // Scaled padding
                decoration: BoxDecoration(
                  color: backgroundColor2,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Fit content height
                  children: [
                    LinearPercentIndicator(
                      lineHeight: size.height * 0.028, // Scaled height
                      barRadius: const Radius.circular(20.0),
                      percent: 1.0,
                      animation: true,
                      animationDuration: 500,
                      backgroundColor: colorDark,
                      progressColor: colorLight,
                    ),
                    SizedBox(
                        height: size.height * 0.025), // 2.5% of screen height
                    Text(
                      "Create Account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'OpenSauce',
                        fontWeight: FontWeight.bold,
                        fontSize: size.width * 0.05, // Scaled font size
                        color: black,
                      ),
                    ),
                    SizedBox(height: size.height * 0.03), // 5% of screen height
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
                              suffixIcon:
                                  const Icon(Icons.email, color: Colors.black),
                              filled: true,
                              fillColor: white,
                              labelText: 'Email',
                              labelStyle:
                                  const TextStyle(color: Colors.black54),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                              height:
                                  size.height * 0.025), // 3.5% of screen height
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
                              labelStyle:
                                  const TextStyle(color: Colors.black54),
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
                                return 'Please enter your Password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                              height:
                                  size.height * 0.025), // 3.5% of screen height
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
                              fillColor: white,
                              labelText: 'Confirm Password',
                              labelStyle:
                                  const TextStyle(color: Colors.black54),
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
                                return 'Please confirm your Password';
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
                    SizedBox(
                        height: size.height * 0.035), // 3.5% of screen height
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "I agree to terms of service and privacy policy",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: size.width * 0.03, // Scaled font size
                          color: black,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    SizedBox(
                        height: size.height * 0.015), // 1.5% of screen height
                    PrettyWaveButton(
                      backgroundColor: colorLight,
                      horizontalPadding: size.width * 0.20, // Scaled padding
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
                                fontSize:
                                    size.width * 0.045, // Scaled font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    SizedBox(
                        height: size.height * 0.025), // 2.5% of screen height
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
                            fontSize: size.width * 0.035, // Scaled font size
                          ),
                        ),
                        Container(
                          height: 3,
                          width: size.width * 0.17,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    SizedBox(
                        height: size.height * 0.025), // 2.5% of screen height
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        socialIcon("images/google.png", size), // Pass size here
                      ],
                    ),
                    SizedBox(
                        height: size.height * 0.025), // 3.5% of screen height
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
                                color: colorDark,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w300,
                                fontSize:
                                    size.width * 0.035, // Scaled font size
                              ),
                            ),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: colorLight,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    size.width * 0.035, // Scaled font size
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                        height: size.height * 0.020), // 3.5% of screen height
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        PrettyWaveButton(
                          backgroundColor: white,
                          horizontalPadding:
                              size.width * 0.15, // Scaled padding
                          child: Text(
                            'Back',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: size.width * 0.040, // Scaled font size
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Question3()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container socialIcon(String image, Size size) {
    // Added size parameter
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04, // Scaled padding
        vertical: size.height * 0.015, // Scaled padding
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Image.asset(image, height: size.height * 0.03), // Scaled height
    );
  }
}