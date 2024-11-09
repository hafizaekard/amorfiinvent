// edit_item_page.dart
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  late TextEditingController _labelController;
  late TextEditingController _imageController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.itemData['title']);
    _title2Controller = TextEditingController(text: widget.itemData['title2']);
    _labelController = TextEditingController(text: widget.itemData['label']);
    _imageController = TextEditingController(text: widget.itemData['image']);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _title2Controller.dispose();
    _labelController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _updateItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('item_management').doc(widget.itemId).update({
          'title': _titleController.text,
          'title2': _title2Controller.text,
          'label': _labelController.text,
          'image': _imageController.text,
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
                  // Preview current image
                  if (_imageController.text.isNotEmpty)
                    Container(
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(_imageController.text),
                          fit: BoxFit.cover,
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

                  // Label field
                  TextFormField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      labelText: 'Label (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image URL field
                  TextFormField(
                    controller: _imageController,
                    decoration: InputDecoration(
                      labelText: 'Image URL',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: whiteColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an image URL';
                      }
                      return null;
                    },
                  ),
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