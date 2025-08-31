import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class UpdateDataButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const UpdateDataButton({super.key, this.onPressed});

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Confirmation'),
          content: const Text('Are you sure you want to update the data?'),
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
                  const SnackBar(content: Text('Data is updating...')),
                );
                onPressed?.call();
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
      onTap: () => _showUpdateDialog(context),
      child: Container(
        width: 65,
        height: 40,
        decoration: BoxDecoration(
          color: blueColor,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
        ),
        child: Center(
          child: Icon(
            Icons.autorenew_rounded,
            size: 30,
            color: whiteColor,
          ),
        ),
      ),
    );
  }
}
