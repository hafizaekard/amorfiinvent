import 'package:amorfiapp/controller/image_notifier.dart';
import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/helper/storage_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/pick_image_button.dart';
import 'package:amorfiapp/widgets/save_button_custom.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _title2Controller = TextEditingController();
  String? _selectedLabel;
  bool _isLoading = false;
  final List<String> _labelOptions = ['Ukuran', 'Topping', 'Motif', 'Rasa'];

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_formatPrice);
  }

  void _formatPrice() {
    final text = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return;

    final formatter = NumberFormat.decimalPattern('id');
    final newText = formatter.format(int.parse(text));

    if (newText != _priceController.text) {
      _priceController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
  }

  @override
  void dispose() {
    _priceController.removeListener(_formatPrice);
    _titleController.dispose();
    _priceController.dispose();
    _title2Controller.dispose();
    super.dispose();
  }

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
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 75,
                          child: TextField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              fillColor: whiteColor,
                              filled: true,
                              prefixText: 'Rp',
                              prefixStyle: blackTextStyle,
                              hintText: 'Price',
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
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Harga akan ditampilkan di halaman manajemen item setelah disimpan.',
                            style: greyTextStyle.copyWith(fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SaveButtonCustom(
                          isLoading: _isLoading,
                          label: 'Save',
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final imageUrl = await _storageHelper.uploadImageToStorage(
                                      context.read<ImageNotifier>().image!,
                                      _titleController.text,
                                    );

                                    final plainPrice = _priceController.text.replaceAll('.', '');

                                    await _firestoreHelper.addItem(
                                      _titleController.text,
                                      imageUrl,
                                      title2: _title2Controller.text.isNotEmpty ? _title2Controller.text : null,
                                      label: _selectedLabel,
                                      price: int.tryParse(plainPrice) ?? 0,
                                    );

                                    context.read<ImageNotifier>().resetImage();
                                    _titleController.clear();
                                    _priceController.clear();
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
                                      _isLoading = false;
                                    });
                                  }
                                },
                        )
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
