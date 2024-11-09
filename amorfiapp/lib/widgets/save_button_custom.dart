import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';

class SaveButtonCustom extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;

  const SaveButtonCustom({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.label = 'Save',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? greyColor : blueColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: whiteColor,
                  strokeWidth: 2.0,
                ),
              )
            : Text(
                label,
                style: whiteTextStyle.copyWith(fontSize: 16, fontWeight: semiBold),
              ),
      ),
    );
  }
}
