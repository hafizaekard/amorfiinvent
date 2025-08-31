import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/pages/sign_in_page.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class SuperadminAppDrawer extends StatefulWidget {
  const SuperadminAppDrawer({
    super.key,
  });

  @override
  _SuperadminAppDrawerState createState() => _SuperadminAppDrawerState();
}

class _SuperadminAppDrawerState extends State<SuperadminAppDrawer> {
  void _navigateToSignInPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SignInPage()),
      (Route<dynamic> route) => false,
    );
  }

  FirestoreHelper helper = FirestoreHelper();
  bool isLoading = false;

  Future<void> _showSignOutDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Sign Out',
            style: blackTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semiBold,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: blackTextStyle.copyWith(
              fontSize: 14,
              fontWeight: normal,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'No',
                style: blackTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToSignInPage();
              },
              child: Text(
                'Yes',
                style: redTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: lightGreyColor,
        child: Column(
          children: [
            Container(
              child: AppBar(
                backgroundColor: newBlueColor,
                automaticallyImplyLeading: false,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Setting',
                        style: blackTextStyle.copyWith(
                            fontSize: 20, fontWeight: semiBold)),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: blueColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.menu_rounded,
                            color: whiteColor,
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              title: Text('Sign Out Account',
                  style: blackTextStyle.copyWith(
                      fontSize: 16, fontWeight: normal)),
              onTap: _showSignOutDialog,
            ),
          ],
        ),
      ),
    );
  }
}
