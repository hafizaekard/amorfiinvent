import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/pages/edit_profile_production.dart';
import 'package:amorfiapp/pages/ingredients_page.dart';
import 'package:amorfiapp/pages/privacy_and_security_production.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class ProductionAppDrawer extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? profileImageUrl;

  const ProductionAppDrawer({
    super.key,
    this.userName,
    this.userEmail,
    this.profileImageUrl,
  });

  @override
  _ProductionAppDrawerState createState() => _ProductionAppDrawerState();
}

class _ProductionAppDrawerState extends State<ProductionAppDrawer> {
  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToEditProfileProductionPage() {
    _navigateToPage(const EditProfileProductionPage());
  }

  void _navigateToPrivacyAndSecurityProductionPage() {
    _navigateToPage(const PrivacyAndSecurityProductionPage());
  }

  FirestoreHelper helper = FirestoreHelper();
  final int _pinLength = 4;
  TextEditingController pinController = TextEditingController();
  bool isLoading = false;

  Future<void> _showPinDialog() async {
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

                            if (pinController.text == "2580") {
                              Navigator.of(context).pop(); // Close the dialog
                              _navigateToPage(const PrivacyAndSecurityProductionPage());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Incorrect PIN. Please try again.'),
                                ),
                              );
                            }

                            setState(() {
                              isDialogLoading = false;
                            });
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: blackColor),
                    child: isDialogLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
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

Future<void> _showSwitchAccountDialog() async {
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
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'If you want to switch accounts, enter the account switching PIN',
                      textAlign: TextAlign.center,
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

                            if (pinController.text == "3690") {
                              Navigator.of(context).pop(); // Close the dialog
                              _navigateToPage(const IngredientsPage());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Incorrect PIN. Please try again.'),
                                ),
                              );
                            }

                            setState(() {
                              isDialogLoading = false;
                            });
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: blackColor),
                    child: isDialogLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                              strokeWidth: 2,
                            ),
                          )
                        : Text('SWITCH', style: whiteTextStyle),
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
    return Drawer(
      child: Column(
        children: [
          Container(
            color: blueColor,
            child: AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Profile', style: blackTextStyle.copyWith(fontSize: 20, fontWeight: semiBold)),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: newpurpleColor,
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
          UserAccountsDrawerHeader(
            accountName: Text(widget.userName ?? 'User Name', style: blackTextStyle),
            accountEmail: Text(widget.userEmail ?? 'email@example.com', style: blackTextStyle),
            currentAccountPicture: CircleAvatar(
              backgroundImage: widget.profileImageUrl != null && widget.profileImageUrl!.isNotEmpty
                  ? NetworkImage(widget.profileImageUrl!)
                  : const AssetImage('assets/images/default_profile.png') as ImageProvider,
            ),
            decoration: BoxDecoration(
              color: bgpurpleColor,
            ),
          ),
          ListTile(
            title: Text('Edit Profile', style: blackTextStyle.copyWith(fontSize: 16, fontWeight: normal)),
            tileColor: bgpurpleColor,
            onTap: _navigateToEditProfileProductionPage,
          ),
          ListTile(
            title: Text('Privacy and Security', style: blackTextStyle.copyWith(fontSize: 16, fontWeight: normal)),
            tileColor: bgpurpleColor,
            onTap: _showPinDialog,
          ),
          ListTile(
            title: Text('Switch Account', style: blackTextStyle.copyWith(fontSize: 16, fontWeight: normal)),
            tileColor: bgpurpleColor,
            onTap: _showSwitchAccountDialog,
          ),
        ],
      ),
    );
  }
}