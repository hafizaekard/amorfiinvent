import 'package:amorfiapp/pages/ingredients_page.dart';
import 'package:amorfiapp/pages/pin_ingredients.dart';
import 'package:amorfiapp/pages/pin_production.dart';
import 'package:amorfiapp/pages/production_page.dart';
import 'package:amorfiapp/pages/sign_in_options.dart';
import 'package:amorfiapp/pages/sign_in_page.dart'; // Pastikan untuk mengimpor halaman Sign In
import 'package:amorfiapp/pages/sign_up_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amorfi Invent',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SignUpPage(),
        '/signin': (context) => const SignInPage(),
        '/signInOptions': (context) => const SignInOptionsPage(),
        '/pinProduction' : (context) => const PinProductionManagerPage(),
        '/pinIngredients' : (context) => const PinIngredientsManagerPage(),
        '/productionPage' : (context) => const ProductionPage(),
        '/ingredientsPage' : (context) => const IngredientsPage(),
      },
    );
  }
}
