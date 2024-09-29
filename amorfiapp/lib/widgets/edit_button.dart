import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
  const EditButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: blackColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)), // Sudut button
        ),
      ),
      child: const Text(
        'Edit',
        style: TextStyle(
          color: Colors.white, // Warna teks
          fontSize: 16, // Ukuran font
          fontWeight: FontWeight.bold, // Ketebalan font
        ),
      ),
    );
  }
}
