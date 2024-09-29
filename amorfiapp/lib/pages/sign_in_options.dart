import 'package:amorfiapp/pages/pin_ingredients.dart';
import 'package:amorfiapp/pages/pin_production.dart';
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

  void _navigateToPinProductionManagerPage() {
    _navigateToPage(const PinProductionManagerPage());
  }

  void _navigateToPinIngredientsManagerPage() {
    _navigateToPage(const PinIngredientsManagerPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: yellowColor,
        shadowColor: blackColor.withOpacity(1),
        elevation: 5,
        automaticallyImplyLeading: false,
        titleSpacing: 30,
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
      backgroundColor: whiteColor,
      body: Column(
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
          )
        ],
      ),
    );
  }

  Widget _buildOptionContainer(int index) {
    return Container(
      height: 150,
      width: 250,
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
      child: InkWell(
        onTap: index == 0
            ? _navigateToPinProductionManagerPage
            : _navigateToPinIngredientsManagerPage,
        highlightColor: transparentColor,
        splashColor: transparentColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.system_update_alt_rounded,
              color: newpurpleColor,
              size: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                index == 0 ? 'Production Manager' : 'Ingredients Manager',
                style: newpurpleTextStyle.copyWith(
                  fontSize: 20,
                  fontWeight: normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}