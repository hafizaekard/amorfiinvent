import 'dart:developer';

import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/pages/ingredients_page.dart';
import 'package:amorfiapp/pages/production_page.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class SignInOptionsPage extends StatefulWidget {
  const SignInOptionsPage({super.key});

  @override
  State<SignInOptionsPage> createState() => _SignInOptionsPageState();
}

class _SignInOptionsPageState extends State<SignInOptionsPage> {
  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  FirestoreHelper helper = FirestoreHelper();
  final int _pinLength = 4;
  TextEditingController pinController = TextEditingController();
  bool isLoading = false;

  Future<void> _showPinDialog(bool isProductionManager) async {
    pinController.clear();
    bool isDialogLoading = false;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: SizedBox(
                height: 300,
                width: 300,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Text(
                        'Enter PIN',
                        style: blackTextStyle.copyWith(
                          fontSize: 15,
                          fontWeight: semiBold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: pinController,
                      obscureText: true,
                      maxLength: _pinLength,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        counterText: " ",
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isDialogLoading
                          ? null
                          : () async {
                              if (pinController.text.length != _pinLength) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('The PIN must be 4 characters in length.'),
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                isDialogLoading = true;
                              });

                              try {
                                final user = await helper.createPin(pinController.text);
                                log(user.toString());

                                if (user == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Incorrect PIN. Please try again.'),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).pop(); // Close the dialog
                                  if (isProductionManager) {
                                    _navigateToPage(const ProductionPage());
                                  } else {
                                    _navigateToPage(const IngredientsPage());
                                  }
                                }
                              } finally {
                                setState(() {
                                  isDialogLoading = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: blackColor),
                      child: isDialogLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : Text('SEND', style: whiteTextStyle),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: newBlueColor,
        shape: Border(bottom: BorderSide(color: blueColor.withOpacity(0.2))),
        automaticallyImplyLeading: false,
        titleSpacing: 15,
        title: Row(
          children: [
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Sign In Options',
                style: blueTextStyle.copyWith(
                  fontSize: 25,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: lightGreyColor,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Select according to your role:',
                style: blackTextStyle.copyWith(fontSize: 25),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionContainer(0),
                  const SizedBox(width: 30),
                  _buildOptionContainer(1),
                ],
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: blackColor.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionContainer(int index) {
    return FutureBuilder<String>(
      future: FirestoreHelper().getImage(
        index == 0 ? 'production_manager' : 'ingredients_manager'
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 120,
            width: 150,
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.2),
                  spreadRadius: 0.1,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 120,
            width: 150,
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.2),
                  spreadRadius: 0.1,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return Container(
            height: 120,
            width: 150,
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.2),
                  spreadRadius: 0.1,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(child: Text('No image')),
          );
        }

        return InkWell(
          onTap: () => _showPinDialog(index == 0),
          highlightColor: transparentColor,
          splashColor: transparentColor,
          child: Container(
            height: 120,
            width: 150,
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withOpacity(0.2),
                  spreadRadius: 0.1,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                ),
              ],
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.network(
                snapshot.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        );
      },
    );
  }
}
