import 'package:amorfiapp/pages/edit_recipe.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/edit_button.dart';
import 'package:amorfiapp/widgets/print_button.dart';
import 'package:amorfiapp/widgets/update_data_button.dart';
import 'package:flutter/material.dart';

class InputRecipePage extends StatefulWidget {
  const InputRecipePage({super.key});

  @override
  State<InputRecipePage> createState() => _InputRecipePageState();
}

class _InputRecipePageState extends State<InputRecipePage> {
  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToEditRecipePage() {
    _navigateToPage(const EditRecipePage());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: yellowColor,
        shadowColor: blackColor.withOpacity(1),
        elevation: 5,
        automaticallyImplyLeading: false,
        titleSpacing: 15,
        actions: [
          EditButton(onPressed: _navigateToEditRecipePage),
          const PrintButton(),
          const UpdateDataButton(),
          const Padding(padding: EdgeInsets.only(right: 20))// Memberikan jarak antara button dan tepi
        ],
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