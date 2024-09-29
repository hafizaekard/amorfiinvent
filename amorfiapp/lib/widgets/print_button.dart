import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class PrintButton extends StatelessWidget {
  const PrintButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Aksi ketika tombol print diklik
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Print Confirmation'),
              content: const Text('Are you sure you want to print?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Menutup dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Aksi ketika pengguna mengkonfirmasi pencetakan
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Printing...')),
                    );
                  },
                  child: const Text('Print'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: 65,  // Sesuaikan dengan ukuran tombol 'UpdateDataButton'
        height: 40, // Sesuaikan dengan ukuran tombol 'UpdateDataButton'
        decoration: BoxDecoration(
          color: blackColor, 
        ),
        child: Icon(
          Icons.print_rounded, // Ikon print
          size: 30, // Ukuran ikon
          color: whiteColor,// Warna ikon (ubah jika diperlukan)
        ),
      ),
    );
  }
}
