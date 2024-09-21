import 'package:amorfiapp/widgets/elevated_button.dart';
import 'package:amorfiapp/widgets/text_field_custom.dart';
import 'package:amorfiapp/widgets/text_field_custom_password.dart';
import 'package:flutter/material.dart';
import 'package:amorfiapp/shared/shared_values.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
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
                    'Start Your Admin Journey',
                    style: blackTextStyle.copyWith(
                      fontSize: 25,
                      fontWeight: semiBold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Sign up here to receive access to the admin section of the inventory system in this application.',
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
                  Text('Name', style: blackTextStyle.copyWith(fontWeight: semiBold),),
                  TextFieldCustom(
                    controller: nameController, 
                    hintText: 'Enter your name',
                    keyboardType: TextInputType.text,
                  ),
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
                    children: [
                      TextFieldCustomPassword(
                        controller: passwordController, 
                        hintText: 'Enter your password',
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
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

                  SizedBox(height: 15),
            SizedBox(
              width: 500,
              child: ElevatedButtonCustom(
                  text: 'Sign Up',
                  color: blackColor,
                  onPressed: () {
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
