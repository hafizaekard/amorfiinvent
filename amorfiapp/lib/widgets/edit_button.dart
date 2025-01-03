import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label; // Tambahkan parameter label
  final double width; // Tambahkan parameter width

  const EditButton({super.key, required this.onPressed, required this.label, required this.width});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: width,
        height: 40, // Tinggi sama seperti UpdateDataButton
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center( // Pusatkan teks di dalam Container
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
