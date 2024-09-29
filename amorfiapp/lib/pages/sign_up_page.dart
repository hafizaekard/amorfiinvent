import 'package:amorfiapp/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:amorfiapp/pages/sign_in_page.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/form_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      'Start Your Admin Journey',
                      style: blackTextStyle.copyWith(
                        fontSize: 25,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Sign up here to receive access to the admin section of the inventory system in this application.',
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
                  'Name',
                  style: blackTextStyle.copyWith(fontWeight: semiBold, fontSize: 14),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 500,
                  child: FormContainerWidget(
                    controller: _nameController,
                    hintText: "Enter Your Name",
                    isPasswordField: false,
                    keyboardType: TextInputType.name,
                  ),
                ),
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
                const SizedBox(height: 30),
              ],
            ),
            SizedBox(
              width: 500,
              child: GestureDetector(
                onTap: _signUp,
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: blackColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Sign Up",
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
                  "Already have an account?",
                  style: blackTextStyle.copyWith(fontSize: 14, fontWeight: normal),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: _navigateToSignInPage,
                  child: Text(
                    "Sign In",
                    style: blackTextStyle.copyWith(fontSize: 13.5, fontWeight: semiBold),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _navigateToSignInPage() {
    Navigator.of(context).push(CustomPageRoute(page: const SignInPage()));
  }

  void _signUp() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    // Ensure all fields are filled
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      print('All fields are required');
      return;
    }

    // Sign up the user using FirebaseAuthService
    print('before');
    User? user = await _auth.signUpWithEmailAndPassword(name, email, password);
    print('after');


    if (user != null) {
  print("User successfully created");
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('User successfully created! Please verify your email.'))
  );
  Navigator.pushNamed(context, "/signin");
} else {
  print("Failed to create user");
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Failed to create user. Please try again.'))
  );
}
  }
}
