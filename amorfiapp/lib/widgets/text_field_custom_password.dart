import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class TextFieldCustomPassword extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const TextFieldCustomPassword({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  }) : super(key: key);

  @override
  _TextFieldCustomPasswordState createState() => _TextFieldCustomPasswordState();
}

class _TextFieldCustomPasswordState extends State<TextFieldCustomPassword> {
  String _errorText = ''; // Menyimpan pesan kesalahan

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: greyTextStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
             errorText: _errorText.isNotEmpty ? _errorText : null, // Menampilkan pesan kesalahan
          ),
          onChanged: (value) {
            // Validasi panjang password hingga maksimal 8 karakter
            if (value.length > 8) {
              widget.controller.text = value.substring(0, 8);
              widget.controller.selection = TextSelection.fromPosition(
                TextPosition(offset: widget.controller.text.length),
              );
              setState(() {
                _errorText = 'Password must be up to 8 characters long.';
              });
            } else {
              setState(() {
                _errorText = ''; // Tidak ada kesalahan jika panjangnya benar
              });
            }
          },
        ),
      ),
    );
  }
}
