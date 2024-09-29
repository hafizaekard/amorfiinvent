import 'package:amorfiapp/pages/edit_profile_ingredient.dart';
import 'package:amorfiapp/pages/privacy_and_security_ingredient.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class IngredientAppDrawer extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? profileImageUrl;

  const IngredientAppDrawer({
    super.key,
    this.userName,
    this.userEmail,
    this.profileImageUrl,
  });

  @override
  _IngredientAppDrawerState createState() => _IngredientAppDrawerState();
}

class _IngredientAppDrawerState extends State<IngredientAppDrawer> {
  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToEditProfileIngredientPage() {
    _navigateToPage(const EditProfileIngredientPage());
  }

  void _navigateToPrivacyAndSecurityIngredientPage() {
    _navigateToPage(const PrivacyAndSecurityIngredientPage());
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
                  Text('Profile', style: blackTextStyle.copyWith(fontSize: 20, fontWeight: semiBold)), // Judul AppBar
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
            onTap: () {
              _navigateToEditProfileIngredientPage();
            },
          ),
          ListTile(
            title: Text('Privacy and Security', style: blackTextStyle.copyWith(fontSize: 16, fontWeight: normal)),
            tileColor: bgpurpleColor,
            onTap: () {
              _navigateToPrivacyAndSecurityIngredientPage();
            },
          ),
        ],
      ),
    );
  }
}
