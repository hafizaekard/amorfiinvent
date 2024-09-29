import 'package:amorfiapp/pages/ingredients_page.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';

class PinIngredientsManagerPage extends StatefulWidget {
  const PinIngredientsManagerPage({super.key});

  @override
  State<PinIngredientsManagerPage> createState() => _PinIngredientsManagerPageState();
}

class _PinIngredientsManagerPageState extends State<PinIngredientsManagerPage> {
  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  final TextEditingController _pinController = TextEditingController();
  final int _pinLength = 4;
  bool _isLoading = false; // Menyimpan state loading

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkPin() async {
    String inputPin = _pinController.text;

    // Cek apakah input PIN sesuai dengan panjang yang diinginkan
    if (inputPin.length != _pinLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The PIN must consist of 4 digits.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Tampilkan loading
    });

    // Simulasi penundaan untuk memberikan kesan loading (bisa dihapus jika tidak diperlukan)
    await Future.delayed(const Duration(seconds: 2));

    // Logika untuk memeriksa apakah PIN adalah 3690
    if (inputPin == '3690') {
      // Arahkan ke halaman input ingredients
      _navigateToPage(const IngredientsPage());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN. Please try again.')),
      );
    }

    setState(() {
      _isLoading = false; // Sembunyikan loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: yellowColor,
        shadowColor: blackColor.withOpacity(1),
        elevation: 5,
        automaticallyImplyLeading: false,
        titleSpacing: 15,
        title: Row(
          children: [
            BackButtonCustom(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                '',
                style: blueTextStyle.copyWith(
                  fontSize: 25,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: _isLoading // Cek apakah sedang loading
            ? const CircularProgressIndicator() // Tampilkan indikator loading
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Enter your access PIN as an ingredients manager',
                  style: blackTextStyle.copyWith(fontSize: 25, fontWeight: semiBold)),
                  const SizedBox(height: 55),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _pinController,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: "Enter 4 digit PIN",
                        hintStyle: greyTextStyle.copyWith(fontSize: 17),
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true, // Mengaburkan input
                      maxLength: _pinLength,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _checkPin(); // Panggil fungsi untuk cek PIN
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blackColor,
                    ),
                    child: Text('SEND', style: whiteTextStyle.copyWith(fontWeight: semiBold)),
                  ),
                ],
              ),
      ),
    );
  }
}
