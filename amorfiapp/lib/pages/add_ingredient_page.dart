import 'package:amorfiapp/controller/image_notifier.dart';
import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/helper/storage_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/pick_image_button.dart';
import 'package:amorfiapp/widgets/save_button_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  bool _isLoading = false;
  final List<String> _values = [];

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: blueColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _expiryController.text = "${picked.day}/${picked.month}/${picked.year}";
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
              child: Text('Add Ingredient',
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
                  // Image Section
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: PickImage(),
                  ),
                  const SizedBox(height: 20),
                  
                  // Form Section
                  SizedBox(
                    width: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Name Field
                        Text(
                          'Ingredient Name *',
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            fillColor: whiteColor,
                            filled: true,
                            hintText: 'Enter ingredient name',
                            hintStyle: greyTextStyle,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: blueColor, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Value Section
                        Text(
                          'Additional Information',
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _valueController,
                                decoration: InputDecoration(
                                  fillColor: whiteColor,
                                  filled: true,
                                  hintText: 'Add information (e.g., Pcs, Kg, L)',
                                  hintStyle: greyTextStyle.copyWith(fontSize: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: blueColor, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                ),
                                onSubmitted: (_) {
                                  if (_valueController.text.trim().isNotEmpty) {
                                    final newValue = _valueController.text.trim();
                                    if (!_values.contains(newValue)) {
                                      setState(() {
                                        _values.add(newValue);
                                        _valueController.clear();
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                color: blueColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  if (_valueController.text.trim().isNotEmpty) {
                                    final newValue = _valueController.text.trim();
                                    if (!_values.contains(newValue)) {
                                      setState(() {
                                        _values.add(newValue);
                                        _valueController.clear();
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Information already exists'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        // Display Values
                        if (_values.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Added Information:',
                            style: blackTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: medium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: _values
                                .map((value) => Chip(
                                      label: Text(
                                        value,
                                        style: blackTextStyle.copyWith(fontSize: 12),
                                      ),
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 16,
                                      ),
                                      onDeleted: () {
                                        setState(() {
                                          _values.remove(value);
                                        });
                                      },
                                      backgroundColor: lightGreyColor,
                                      side: BorderSide(
                                        color: greyColor.withOpacity(0.3),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Expiry Date Field (Now below values)
                        Text(
                          'Expiry Date (Optional)',
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: medium,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _expiryController,
                          readOnly: true,
                          onTap: _selectExpiryDate,
                          decoration: InputDecoration(
                            fillColor: whiteColor,
                            filled: true,
                            hintText: 'Select expiry date',
                            hintStyle: greyTextStyle,
                            suffixIcon: Icon(Icons.calendar_today, color: greyColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: greyColor.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: blueColor, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: SaveButtonCustom(
                            isLoading: _isLoading,
                            label: _isLoading ? 'Saving...' : 'Save Ingredient',
                            onPressed: _isLoading ? null : () async {
                              // Validation
                              if (_titleController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(Icons.warning, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Please enter ingredient name'),
                                      ],
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              if (_titleController.text.trim().length < 2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(Icons.warning, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Ingredient name must be at least 2 characters'),
                                      ],
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              final imageNotifier = context.read<ImageNotifier>();
                              if (imageNotifier.image == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: const [
                                        Icon(Icons.warning, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('Please select an image'),
                                      ],
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              try {
                                print("Starting save process...");

                                // Upload image
                                final imageUrl = await _storageHelper.uploadImageToStorage(
                                  imageNotifier.image!,
                                  _titleController.text.trim(),
                                );

                                // Prepare data
                                Map<String, dynamic> ingredientData = {
                                  'title': _titleController.text.trim(),
                                  'image': imageUrl,
                                  'values': _values,
                                  'created_at': FieldValue.serverTimestamp(),
                                  'updated_at': FieldValue.serverTimestamp(),
                                };

                                // Add expiry date if provided
                                if (_expiryController.text.trim().isNotEmpty) {
                                  ingredientData['expiry_date'] = _expiryController.text.trim();
                                }

                                // Save to Firestore using enhanced helper
                                final docId = await _firestoreHelper.addToIngredientsManagement(
                                  _titleController.text.trim(),
                                  imageUrl,
                                  values: _values,
                                  expiryDate: _expiryController.text.trim().isEmpty 
                                      ? null 
                                      : _expiryController.text.trim(),
                                );

                                // Reset form
                                imageNotifier.resetImage();
                                _titleController.clear();
                                _expiryController.clear();
                                setState(() {
                                  _values.clear();
                                });

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: const [
                                          Icon(Icons.check_circle, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Ingredient successfully added'),
                                        ],
                                      ),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  
                                  // Navigate back with success result
                                  Navigator.pop(context, true);
                                }
                              } catch (e) {
                                print("Error saving ingredient: $e");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.error, color: Colors.white),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text('Failed to add ingredient: ${e.toString()}'),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            },
                          ),
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

  @override
  void dispose() {
    _titleController.dispose();
    _expiryController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}