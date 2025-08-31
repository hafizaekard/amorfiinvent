import 'package:amorfiapp/helper/firebase_auth_services.dart';
import 'package:amorfiapp/pages/sign_in_page.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
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

  String? selectedRole;

  void _selectRole(String role) {
    setState(() {
      selectedRole = role;
    });
  }

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
      appBar: AppBar(
        backgroundColor: newBlueColor,
        shape: Border(bottom: BorderSide(color: blueColor.withOpacity(0.2))),
        automaticallyImplyLeading: false,
        titleSpacing: 15,
        title: Row(
          children: [
            BackButtonCustom(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 100, top: 50),
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
                    const SizedBox(height: 50),
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
                  style: blackTextStyle.copyWith(
                      fontWeight: semiBold, fontSize: 14),
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
                  style: blackTextStyle.copyWith(
                      fontWeight: semiBold, fontSize: 14),
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
                  style: blackTextStyle.copyWith(
                      fontWeight: semiBold, fontSize: 14),
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
                const SizedBox(height: 10),
                Text('Choose a role',
                    style: blackTextStyle.copyWith(
                        fontWeight: semiBold, fontSize: 14)),
                const SizedBox(height: 10),
                SizedBox(
                  width: 500,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectRole('Production Manager'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedRole == 'Production Manager'
                                    ? blackColor
                                    : blackColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: selectedRole == 'Production Manager'
                                  ? whiteColor
                                  : whiteColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio<String>(
                                  value: 'Production Manager',
                                  groupValue: selectedRole,
                                  onChanged: (value) {
                                    _selectRole(value!);
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Production Manager',
                                  style: blackTextStyle.copyWith(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectRole('Ingredient Manager'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedRole == 'Ingredient Manager'
                                    ? blackColor
                                    : blackColor,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              color: selectedRole == 'Ingredient Manager'
                                  ? whiteColor
                                  : whiteColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio<String>(
                                  value: 'Ingredient Manager',
                                  groupValue: selectedRole,
                                  onChanged: (value) {
                                    _selectRole(value!);
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ingredient Manager',
                                  style: blackTextStyle.copyWith(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
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
                    color: blueColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Next",
                      style: whiteTextStyle.copyWith(
                          fontSize: 14, fontWeight: bold),
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
                  style:
                      blackTextStyle.copyWith(fontSize: 14, fontWeight: normal),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: _navigateToSignInPage,
                  child: Text(
                    "Sign In",
                    style: blackTextStyle.copyWith(
                        fontSize: 13.5, fontWeight: semiBold),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 50,
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

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      print('All fields are required');
      return;
    }

    print('before');
    User? user = await _auth.signUpWithEmailAndPassword(name, email, password);
    print('after');

    if (user != null) {
      print("User successfully created");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('User successfully created! Please verify your email.')));
      Navigator.pushNamed(context, "/signin");
    } else {
      print("Failed to create user");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to create user. Please try again.')));
    }
  }
}
