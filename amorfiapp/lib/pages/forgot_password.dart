import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/form_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A password reset link has been sent to your email.'),
        ),
      );
      _emailController.clear();
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred.';
      if (e.code == 'user-not-found') {
        message = 'Pengguna tidak ditemukan.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: yellowColor,
        shadowColor: blackColor.withOpacity(1),
        elevation: 5,
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
            Expanded(
              child: Text(
                'Forgot Password',
                style: blueTextStyle.copyWith(
                  fontSize: 25,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
      body:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter your email address to receive the password reset link',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              SizedBox(
                  width: 500,
                  child: FormContainerWidget(
                    controller: _emailController,
                    hintText: "Email",
                    isPasswordField: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blackColor,
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                      ),
                      child: Text(
                        'Send Reset Link',
                        style: whiteTextStyle.copyWith(
                          fontSize: 15,
                          fontWeight: semiBold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      );
    
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
