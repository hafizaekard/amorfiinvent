import 'package:amorfiapp/controller/image_notifier.dart';
import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/helper/storage_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/pick_image_button.dart';
import 'package:amorfiapp/widgets/save_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final StorageHelper _storageHelper = StorageHelper();
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _title2Controller = TextEditingController();
  String? _selectedLabel;
  bool _isLoading = false; // Variabel untuk loading
  final List<String> _labelOptions = ['Ukuran', 'Topping', 'Motif', 'Rasa'];

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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedLabel,
                                    hint: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'Label (Optional)',
                                        style: greyTextStyle.copyWith(fontSize: 14),
                                      ),
                                    ),
                                    isExpanded: true,
                                    items: _labelOptions.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                          child: Text(value),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedLabel = newValue;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _title2Controller,
                                decoration: InputDecoration(
                                  hintText: 'Value (Optional)',
                                  hintStyle: greyTextStyle.copyWith(fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SaveButtonCustom(
                          isLoading: _isLoading,
                          label: 'Save',
                          onPressed: _isLoading ? null : () async {
                            setState(() {
                              _isLoading = true; // Setel ke loading
                            });

                            try {
                              final imageUrl = await _storageHelper.uploadImageToStorage(
                                context.read<ImageNotifier>().image!,
                                _titleController.text,
                              );

                              await _firestoreHelper.inputItem(
                                _titleController.text,
                                imageUrl,
                                title2: _title2Controller.text.isNotEmpty ? _title2Controller.text : null,
                                label: _selectedLabel,
                              );

                              await _firestoreHelper.addToRemainingStock(
                                _titleController.text,
                                imageUrl,
                                title2: _title2Controller.text.isNotEmpty ? _title2Controller.text : null,
                                label: _selectedLabel,
                              );

                              await _firestoreHelper.addToItemManagement(
                                _titleController.text,
                                imageUrl,
                                title2: _title2Controller.text.isNotEmpty ? _title2Controller.text : null,
                                label: _selectedLabel,
                              );

                              context.read<ImageNotifier>().resetImage();
                              _titleController.clear();
                              _title2Controller.clear();
                              setState(() {
                                _selectedLabel = null;
                              });

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Item successfully added'),
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
