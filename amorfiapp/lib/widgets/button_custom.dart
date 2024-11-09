import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class ButtonCustom extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const ButtonCustom({
    super.key,
    required this.label, // Label akan menjadi judul tombol
    required this.onPressed, // Fungsi yang akan dipanggil saat tombol ditekan
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: blueColor,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Menambahkan border radius
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label, // Menggunakan label sebagai teks tombol
            style: whiteTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
          ),
        ],
      ),
    );
  }
}
