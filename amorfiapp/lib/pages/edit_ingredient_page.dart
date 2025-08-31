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
  final TextEditingController _expiryDateController = TextEditingController();
  bool _isLoading = false;
  late List<String> _values;

  ImagePickerHelper imagePickerHelper = ImagePickerHelper();
  File? image;
  String imageURL = "";
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.ingredientData['title'] ?? '');
    _values = List<String>.from(widget.ingredientData['values'] ?? []);
    _expiryDateController.text = widget.ingredientData['expiry_date'] ?? '';
    imageURL = widget.ingredientData['image'] ?? '';
    
    // Add listeners to detect changes
    _titleController.addListener(_onDataChanged);
    _expiryDateController.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    setState(() {
      _hasChanges = true;
    });
  }

  @override
  void dispose() {
    _titleController.removeListener(_onDataChanged);
    _expiryDateController.removeListener(_onDataChanged);
    _titleController.dispose();
    _valueController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  Future<void> _updateIngredient() async {
    if (!_validateInput()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = widget.ingredientData['image'] ?? '';

      // Upload image baru jika ada
      if (context.read<ImageNotifier>().image != null) {
        imageUrl = await _storageHelper.uploadImageToStorage(
          context.read<ImageNotifier>().image!,
          _titleController.text.trim(),
        );
      } else if (image != null) {
        imageUrl = await _storageHelper.uploadImageToStorage(
          image!,
          _titleController.text.trim(),
        );
      }

      // Cek apakah dokumen ada sebelum update
      final docRef = _firestore
          .collection('ingredients_management')
          .doc(widget.ingredientId);
      
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Ingredient document not found');
      }

      // Prepare update data
      final updateData = {
        'title': _titleController.text.trim(),
        'image': imageUrl,
        'values': _values,
        'expiry_date': _expiryDateController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Update dokumen
      await docRef.update(updateData);

      // Create backup in archive
      await _createArchiveBackup(updateData);

      // Reset image notifier setelah berhasil
      if (context.read<ImageNotifier>().image != null) {
        try {
          context.read<ImageNotifier>().setImage(null);
        } catch (e) {
          print('ImageNotifier clear method not available: $e');
        }
      }

      // Reset local image
      if (mounted) {
        setState(() {
          image = null;
          _hasChanges = false;
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Ingredient updated successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate successful update
      }
    } catch (e) {
      print('Error updating ingredient: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Failed to update ingredient: ${e.toString()}'),
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
  }

  Future<void> _createArchiveBackup(Map<String, dynamic> updateData) async {
    try {
      await _firestore.collection('archive_ingredients').add({
        ...updateData,
        'original_id': widget.ingredientId,
        'action': 'updated',
        'archived_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Warning: Failed to create archive backup: $e');
      // Don't throw error as this is not critical
    }
  }

  bool _validateInput() {
    if (_titleController.text.trim().isEmpty) {
      _showValidationError('Ingredient name cannot be empty');
      return false;
    }
    
    if (_titleController.text.trim().length < 2) {
      _showValidationError('Ingredient name must be at least 2 characters');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      XFile? result = await imagePickerHelper.pickImage(source);
      if (result != null) {
        setState(() {
          image = File(result.path);
          _hasChanges = true;
        });
        
        // Update ImageNotifier jika diperlukan
        context.read<ImageNotifier>().setImage(File(result.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addValue() {
    if (_valueController.text.trim().isNotEmpty) {
      final newValue = _valueController.text.trim();
      if (!_values.contains(newValue)) {
        setState(() {
          _values.add(newValue);
          _valueController.clear();
          _hasChanges = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 8),
                Text('Value already exists'),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _removeValue(String value) {
    setState(() {
      _values.remove(value);
      _hasChanges = true;
    });
  }

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
        _expiryDateController.text = "${picked.day}/${picked.month}/${picked.year}";
        _hasChanges = true;
      });
    }
  }

  Widget _buildImageContainer() {
    // Prioritas: image lokal > ImageNotifier > network image > placeholder
    
    if (image != null) {
      // Jika ada image lokal yang baru dipilih
      return Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: FileImage(image!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (context.watch<ImageNotifier>().image != null) {
      // Jika ada image dari ImageNotifier
      return Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: FileImage(context.watch<ImageNotifier>().image!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // Gunakan image URL yang ada atau placeholder
      final String imageUrl = widget.ingredientData['image']?.toString() ?? '';
      
      return Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: imageUrl.isEmpty ? Colors.grey[300] : null,
          border: Border.all(
            color: greyColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 130,
                  height: 130,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        color: blueColor,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 130,
                      height: 130,
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Image Error',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Photo',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('You have unsaved changes. Are you sure you want to leave?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      ) ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: newBlueColor,
          shape: Border(bottom: BorderSide(color: blueColor.withOpacity(0.2))),
          automaticallyImplyLeading: false,
          titleSpacing: 15,
          title: Row(
            children: [
              BackButtonCustom(onPressed: () async {
                if (await _onWillPop()) {
                  Navigator.pop(context);
                }
              }),
              const SizedBox(width: 5),
              Expanded(
                child: Text('Edit Ingredient',
                    style: blueTextStyle.copyWith(
                      fontSize: 25,
                      fontWeight: semiBold,
                    )),
              ),
              if (_hasChanges)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
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
                      child: GestureDetector(
                        onTap: () async {
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return Material(
                                type: MaterialType.transparency,
                                child: Center(
                                  child: Material(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 200,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Select Image Source',
                                            style: blackTextStyle.copyWith(
                                              fontSize: 16,
                                              fontWeight: semiBold,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  IconButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      await _pickImage(ImageSource.gallery);
                                                    },
                                                    icon: Icon(
                                                      Icons.photo_library,
                                                      size: 32,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Gallery',
                                                    style: greyTextStyle.copyWith(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  IconButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      await _pickImage(ImageSource.camera);
                                                    },
                                                    icon: Icon(
                                                      Icons.camera_alt,
                                                      size: 32,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Camera',
                                                    style: greyTextStyle.copyWith(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
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
                        child: _buildImageContainer(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Form Section
                    SizedBox(
                      width: 500,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ingredient Name Field
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

                          // Expiry Date Field
                          Text(
                            'Expiry Date (Optional)',
                            style: blackTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: medium,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _expiryDateController,
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
                          const SizedBox(height: 20),

                          // Values Section
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
                                  onSubmitted: (_) => _addValue(),
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
                                  onPressed: _addValue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Values Display
                          if (_values.isNotEmpty) ...[
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
                                        onDeleted: () => _removeValue(value),
                                        backgroundColor: lightGreyColor,
                                        side: BorderSide(
                                          color: greyColor.withOpacity(0.3),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: SaveButtonCustom(
                              isLoading: _isLoading,
                              label: _isLoading ? 'Updating...' : 'Update Ingredient',
                              onPressed: _isLoading ? null : _updateIngredient,
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
      ),
    );
  }
}