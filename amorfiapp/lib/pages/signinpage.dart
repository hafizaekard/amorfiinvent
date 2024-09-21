import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/elevated_button.dart';
import 'package:amorfiapp/widgets/text_field_custom.dart';
import 'package:amorfiapp/widgets/text_field_custom_password.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 100, top: 75),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Portal Login',
                    style: blackTextStyle.copyWith(
                      fontSize: 25,
                      fontWeight: semiBold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Enter your credentials to access the admin dashboard. Your role is crucial in keeping the inventory up to date.',
                    style: blackTextStyle.copyWith(
                      fontSize: 17,
                      fontWeight: normal,
                    ),
                  ),
                  const SizedBox(height: 175),
                ],
              ),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text('Email', style: blackTextStyle.copyWith(fontWeight: semiBold)),
                  TextFieldCustom(
                    controller: emailController, 
                    hintText: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  Text('Password', style: blackTextStyle.copyWith(fontWeight: semiBold)),
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextFieldCustomPassword(
                        controller: passwordController, 
                        hintText: 'Enter your password',
                        obscureText: _obscurePassword,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off: Icons.visibility,
                            color: blackColor,),
                            onPressed: (){
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },))
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 370),
                    child: TextButton(
                      child: Text(
                        'Forgot Password ?', 
                        style: blackTextStyle.copyWith(
                          fontSize: 13, 
                          fontWeight: semiBold,
                        ),
                      ),
                      onPressed: () {
                        // Aksi jika diperlukan, tetapi tanpa efek visual
                      },
                      style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(transparentColor),
                      ),
                    ),
                  ),
                  
                  
                  SizedBox(height: 10),
                  // ElevatedButton for Sign Up
                  SizedBox(
                    width: 500,
                    child: ElevatedButtonCustom(
                      text: 'Sign In',
                      color: blackColor,
                      onPressed: () {
                        // Handle sign up action
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
