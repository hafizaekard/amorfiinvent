import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
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
                onPressed: (){
                  Navigator.pop(context);
                }),
            
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Add Recipe',
                style: blueTextStyle.copyWith(
                  fontSize: 25,
                  fontWeight: semiBold,
                )
              ),
            ),
          ],
        ),
      ),
    );
  }
}