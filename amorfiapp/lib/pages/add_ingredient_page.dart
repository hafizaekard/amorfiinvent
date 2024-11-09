import 'package:amorfiapp/controller/image_notifier.dart';
import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/helper/storage_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/pick_image_button.dart';
import 'package:amorfiapp/widgets/save_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddIngredientPage extends StatefulWidget {
  const AddIngredientPage({super.key});

  @override
  State<AddIngredientPage> createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  final StorageHelper _storageHelper = StorageHelper();
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  bool _isLoading = false; // Variabel untuk loading
  final List<String> _values = []; // List untuk menyimpan values yang ditambahkan

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: newBlueColor,
        shape: Border(bottom: BorderSide(color: blueColor.withOpacity(0.2))),
        automaticallyImplyLeading: false,
        titleSpacing: 15,
        title: Row(
          children: [
            BackButtonCustom(onPressed: () {
              Navigator.pop(context);
            }),
            const SizedBox(width: 5),
            Expanded(
              child: Text('Add Item',
                  style: blueTextStyle.copyWith(
                    fontSize: 25,
                    fontWeight: semiBold,
                  )),
            ),
          ],
        ),
      ),
      backgroundColor: lightGreyColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: PickImage(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 75,
                          child: TextField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              fillColor: whiteColor,
                              filled: true,
                              hintText: 'Item Name',
                              hintStyle: greyTextStyle,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _valueController,
                                decoration: InputDecoration(
                                  hintText: 'Value',
                                  hintStyle: greyTextStyle.copyWith(fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                if (_valueController.text.isNotEmpty) {
                                  setState(() {
                                    _values.add(_valueController.text);
                                    _valueController.clear();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Tampilkan list value yang ditambahkan
                        Wrap(
                          children: _values
                              .map((value) => Chip(
                                    label: Text(value),
                                    deleteIcon: const Icon(Icons.close),
                                    onDeleted: () {
                                      setState(() {
                                        _values.remove(value);
                                      });
                                    },
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 20),
                        SaveButtonCustom(
                          isLoading: _isLoading,
                          label: 'Save',
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true; // Setel ke loading
                                  });

                                  try {
                                    final imageUrl = await _storageHelper
                                        .uploadImageToStorage(
                                      context.read<ImageNotifier>().image!,
                                      _titleController.text,
                                    );

                                    await _firestoreHelper.inputIngredient(
                                      _titleController.text,
                                      imageUrl,
                                      values: _values,
                                    );

                                    await _firestoreHelper.addToIngredientsManagement(
                                      _titleController.text,
                                      imageUrl,
                                      values: _values,
                                    );

                                    context.read<ImageNotifier>().resetImage();
                                    _titleController.clear();
                                    setState(() {
                                      _values.clear();
                                    });

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Item successfully added'),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to add item: $e'),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading = false; // Setel loading ke false setelah selesai
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
