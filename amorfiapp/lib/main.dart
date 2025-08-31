import 'dart:math';

import 'package:amorfiapp/controller/image_notifier.dart';
import 'package:amorfiapp/helper/notification_helper.dart';
import 'package:amorfiapp/view/splashscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationHelper.instance.requestNotificationPermission();
  await NotificationHelper.instance.initializeNotifications();

  FirebaseFirestore.instance
      .collection("notification")
      .doc("notification")
      .snapshots()
      .listen((event) {
    final data = event.data();
    if (data != null && data['title'] != '' && data['body'] != '') {
      NotificationHelper.instance.showNotification(
        id: Random().nextInt(1000),
        title: data['title'],
        body: data['body'],
        payload: 'order_data',
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ImageNotifier(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Amorfi Invent',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
