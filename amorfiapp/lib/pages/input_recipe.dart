import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:flutter/material.dart';

class InputRecipePage extends StatefulWidget {
  const InputRecipePage({super.key});

  @override
  State<InputRecipePage> createState() => _InputRecipePageState();
}

class _InputRecipePageState extends State<InputRecipePage> {
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
                'Input Recipe',
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