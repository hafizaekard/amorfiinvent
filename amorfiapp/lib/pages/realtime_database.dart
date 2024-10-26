import 'package:amorfiapp/pages/data_sheet.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class RealTimeDatabase extends StatefulWidget {
  const RealTimeDatabase({super.key});

  @override
  State<RealTimeDatabase> createState() => _RealTimeDatabaseState();
}

class _RealTimeDatabaseState extends State<RealTimeDatabase> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
      centerTitle: true,
      title: Text('Realtime Database'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => dataSheet(context),
        child: const Text('Add Item')),
    );
  }
}