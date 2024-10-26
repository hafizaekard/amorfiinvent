import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class UpdateDataButton extends StatefulWidget {
  const UpdateDataButton({super.key});

  @override
  State<UpdateDataButton> createState() => _UpdateDataButtonState();
}

class _UpdateDataButtonState extends State<UpdateDataButton> {
  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Confirmation'),
          content: const Text('Are you sure you want to update the data?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform refresh action
                Navigator.of(context).pop(); // Close dialog after confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data is updating...')),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showUpdateDialog, // Show dialog when button is clicked
      child: Container(
        width: 65,  // Adjust the size as per PrintButton
        height: 40, // Adjust the size as per PrintButton
        decoration: BoxDecoration(
          color: blueColor, // Background color (adjust if needed)
          borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)), // Border radius
        ),
        child: Icon(
          Icons.autorenew_rounded, // Refresh icon
          size: 30, // Icon size
          color: whiteColor, // Icon color
        ),
      ),
    );
  }
}
