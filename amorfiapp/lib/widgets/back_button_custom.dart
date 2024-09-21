import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class BackButtonCustom extends StatelessWidget {
  final Color iconColor;
  final VoidCallback onPressed;

  const BackButtonCustom({
    super.key,
    this.iconColor = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.arrow_back_ios_new_rounded, 
        color: blueColor,
        size: 25),
      onPressed: onPressed,
      splashColor: whiteColor.withOpacity(0.1),
      highlightColor: whiteColor.withOpacity(0.1)
    );
  }
}