import 'package:amorfiapp/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:amorfiapp/pages/forgot_password.dart';
import 'package:amorfiapp/pages/sign_in_options.dart';
import 'package:amorfiapp/pages/sign_up_page.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/form_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false; // Loading state variable

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToSignInOptionsPage() {
    _navigateToPage(const SignInOptionsPage());
  }

  void _navigateToSignUpPage() {
    _navigateToPage(const SignUpPage());
  }

  void _navigateToForgotPasswordPage() {
    _navigateToPage(const ForgotPasswordPage());
  }

  Future<void> _signIn() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // Check if email and password fields are not empty
    if (email.isEmpty || password.isEmpty) {
      print("Email and Password are required.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and Password are required.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading to true
    });

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isLoading = false; // Set loading to false
    });

    if (user != null) {
      print("User successfully signed in");
       _navigateToPage(const SignInOptionsPage()); // Redirect to homepage
    } else {
      print("Failed to sign in");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 100, top: 75),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin Portal Sign In',
                      style: blackTextStyle.copyWith(
                        fontSize: 25,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Enter your credentials to access the admin dashboard. Your role is crucial in keeping the inventory up to date.',
                      style: blackTextStyle.copyWith(
                        fontSize: 17,
                        fontWeight: normal,
                      ),
                    ),
                    const SizedBox(height: 190),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Email',
                  style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 14),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 500,
                  child: FormContainerWidget(
                    controller: _emailController,
                    hintText: "Enter Your Email",
                    isPasswordField: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Password',
                  style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 14),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 500,
                  child: FormContainerWidget(
                    controller: _passwordController,
                    hintText: "Enter Your Password",
                    isPasswordField: true,
                    keyboardType: TextInputType.visiblePassword,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 370),
              child: TextButton(
                onPressed: _navigateToForgotPasswordPage,
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(transparentColor),
                ),
                child: Text(
                  'Forgot Password ?', 
                  style: blackTextStyle.copyWith(
                    fontSize: 13, 
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 500,
              child: GestureDetector(
                onTap: _isLoading ? null : _signIn, // Disable the button when loading
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: blackColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: _isLoading // Show loading indicator or text
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                          )
                        : Text(
                            "Sign In",
                            style: whiteTextStyle.copyWith(fontSize: 14, fontWeight: bold),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: blackTextStyle.copyWith(fontSize: 14, fontWeight: normal),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: _navigateToSignUpPage,
                  child: Text(
                    "Sign Up",
                    style: blackTextStyle.copyWith(fontSize: 13.5, fontWeight: semiBold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
