import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class EditButton extends StatelessWidget {
   final VoidCallback onPressed; // Parameter untuk menerima aksi ketika tombol ditekan
   
   const EditButton({super.key, required this.onPressed}); // Menjadikan onPressed sebagai parameter wajib

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: blackColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)), // Sudut button
        ),
      ),
      child: Text(
        'Edit',
        style: TextStyle(
          color: whiteColor, // Warna teks
          fontSize: 16, // Ukuran font
          fontWeight: FontWeight.bold, // Ketebalan font
        ),
      ),
    );
  }
}
