import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';
final TextEditingController itemNameController = TextEditingController();


void dataSheet(BuildContext context){
  showModalBottomSheet(
    context: context, 
    builder: (BuildContext){
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text('Add Item',
            style: blackTextStyle.copyWith(fontSize: 20, fontWeight: bold)
            ),
          ),
          TextField(
            controller: itemNameController,
            decoration: const InputDecoration(
              hintText: 'Item Name',
            ),
          ),
          ElevatedButton(onPressed: (){}, child: const Text('Add Item'))
        ],
      );
    });
}