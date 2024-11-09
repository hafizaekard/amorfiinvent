import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class SelectButton extends StatelessWidget {
  final String label;
   final double width;
  final bool isSelected;
  final VoidCallback onPressed;

  const SelectButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onPressed, required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        height: 40,
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: whiteColor,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
