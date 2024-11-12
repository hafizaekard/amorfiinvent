import 'dart:io';

import 'package:amorfiapp/controller/image_notifier.dart';
import 'package:amorfiapp/helper/image_picker_helper.dart';
import 'package:amorfiapp/helper/storage_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/save_button_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditIngredientPage extends StatefulWidget {
  final String ingredientId;
  final Map<String, dynamic> ingredientData;

  const EditIngredientPage({
    super.key,
    required this.ingredientId,
    required this.ingredientData,
  });

  @override
  State<EditIngredientPage> createState() => _EditIngredientPageState();
}

class _EditIngredientPageState extends State<EditIngredientPage> {
  final StorageHelper _storageHelper = StorageHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late TextEditingController _titleController;
  final TextEditingController _valueController = TextEditingController();
  bool _isLoading = false;
  late List<String> _values;

  ImagePickerHelper imagePickerHelper = ImagePickerHelper();
  File? image ;
  String imageURL = "";

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.ingredientData['title']);
    _values = List<String>.from(widget.ingredientData['values'] ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  StorageHelper storageHelper = StorageHelper();

  Future<void> _updateIngredient() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = widget.ingredientData['image'];
      
      // Upload new image if selected
      if (context.read<ImageNotifier>().image != null) {
        imageUrl = await _storageHelper.uploadImageToStorage(
          context.read<ImageNotifier>().image!,
          _titleController.text,
        );
      }

      await _firestore
          .collection('ingredients_management')
          .doc(widget.ingredientId)
          .update({
        'title': _titleController.text,
        'image': imageUrl,
        'values': _values,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update ingredient: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              child: Text('Edit Ingredient',
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
                    child: GestureDetector(onTap: () async{
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
                                          XFile? result = await imagePickerHelper.pickImage(ImageSource.camera);
                                          if (result != null) {
                                            image = File(result.path);
                                            imageURL = await storageHelper.uploadImageToStorage(image!, _titleController.text);

                                            setState(() {
                                              
                                            });
                                          }
                                          Navigator.pop(context);
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
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.ingredientData['image']),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
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
                              hintText: 'Ingredient Name',
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
                          label: 'Update',
                          onPressed: _isLoading ? null : _updateIngredient,
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