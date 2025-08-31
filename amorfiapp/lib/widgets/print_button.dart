import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class PrintButton extends StatelessWidget {
  final BorderRadiusGeometry borderRadius;

  const PrintButton({
    super.key,
    this.borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Print Confirmation'),
              content: const Text('Are you sure you want to print?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
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
        width: 65,
        height: 40,
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Icon(
            Icons.print_rounded,
            size: 30,
            color: whiteColor,
          ),
        ),
      ),
    );
  }
}
