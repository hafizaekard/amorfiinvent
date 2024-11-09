import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class PrintButton extends StatelessWidget {
  final BorderRadiusGeometry borderRadius; // Add a border radius property

  // Update the constructor to accept a border radius
  const PrintButton({
    super.key,
    this.borderRadius = const BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)), // Default value
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Action when the print button is clicked
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Print Confirmation'),
              content: const Text('Are you sure you want to print?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Action when user confirms printing
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
        width: 65,  // Adjust to fit your needs
        height: 40, // Adjust to fit your needs
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: borderRadius, // Use the custom border radius
        ),
        child: Center(
          child: Icon(
            Icons.print_rounded, // Print icon
            size: 30, // Icon size
            color: whiteColor, // Icon color (change if needed)
          ),
        ),
      ),
    );
  }
}
