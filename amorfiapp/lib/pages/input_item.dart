import 'package:amorfiapp/pages/edit_item.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/edit_button.dart';
import 'package:amorfiapp/widgets/print_button.dart';
import 'package:amorfiapp/widgets/update_data_button.dart';
import 'package:flutter/material.dart';

class InputItemPage extends StatefulWidget {
  const InputItemPage({super.key});

  @override
  State<InputItemPage> createState() => _InputItemPageState();
}

class _InputItemPageState extends State<InputItemPage> {
  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToEditItemPage() {
    _navigateToPage(const EditItemPage());
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
          EditButton(onPressed: _navigateToEditItemPage),
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
                'Input Item',
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