import 'dart:developer';
import 'dart:io';

import 'package:amorfiapp/helper/image_picker_helper.dart';
import 'package:amorfiapp/helper/storage_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditItemPage extends StatefulWidget {
  final String itemId;
  final Map<String, dynamic> itemData;

  const EditItemPage({
    super.key,
    required this.itemId,
    required this.itemData,
  });

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _title2Controller;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedLabel = "-";
  final List<String> _labelOptions = [
    'Ukuran',
    'Topping',
    'Motif',
    'Rasa',
    '-'
  ];

  ImagePickerHelper imagePickerHelper = ImagePickerHelper();
  File? image ;
  String imageURL = "";

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.itemData['title']);
    _title2Controller = TextEditingController(text: widget.itemData['title2']);
    // _labelController = TextEditingController(text: widget.itemData['label']);
    _selectedLabel = (widget.itemData["label"]).toString().isEmpty
        ? "-"
        : widget.itemData["label"];
    log(widget.itemData["label"]);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _title2Controller.dispose();
    // _labelController.dispose();
    super.dispose();
  }

  StorageHelper storageHelper = StorageHelper();

  Future<void> _updateItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore
            .collection('input_item')
            .doc(widget.itemId)
            .update({
          'title': _titleController.text,
          'title2': _title2Controller.text,
          'label': _selectedLabel,
          'image': imageURL == "" ? widget.itemData["image"] : imageURL,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item updated successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update item: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Item',
          style: blueTextStyle.copyWith(
            fontSize: 25,
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: newBlueColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: lightGreyColor,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () async {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return Material(
                            type: MaterialType.transparency,
                            child: Center(
                              child: Material(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 160, // Lebih lebar dari sebelumnya
                                  height: 80,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize:
                                            32, // Ukuran icon yang lebih kecil
                                        onPressed: () async {
                                          XFile? result = await imagePickerHelper.pickImage(ImageSource.gallery);
                                          if (result != null) {
                                            image = File(result.path);
                                            imageURL = await storageHelper.uploadImageToStorage(image!, _titleController.text);

                                            setState(() {
                                              
                                            });
                                          }
                                          Navigator.pop(context);
                                          
                                        },
                                        icon: const Icon(Icons.image),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        iconSize:
                                            32, 
                                        onPressed: () async {
                                         
                                        },
                                        icon: const Icon(Icons.camera_alt),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: image != null ? Image.file(image!) : Container(
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(widget.itemData["image"]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Title 2 field
                  TextFormField(
                    controller: _title2Controller,
                    decoration: InputDecoration(
                      labelText: 'Title 2 (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  
                  Container(
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Text(value),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedLabel = newValue.toString();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const SizedBox(height: 24),

                  // Update button
                  ElevatedButton(
                    onPressed: _updateItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Update Item',
                      style: whiteTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: semiBold,
                      ),
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
