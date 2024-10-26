import 'dart:io';

import 'package:amorfiapp/helper/image_picker_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  ImagePickerHelper imagePicker = ImagePickerHelper();
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
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
                            constraints: const BoxConstraints(
                              maxWidth: 150,
                              maxHeight: 75,
                            ),
                            width: 150,
                            height: 75,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Ikon Gallery
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    final result = await imagePicker.pickImage(ImageSource.gallery);
                                    if (result != null) {
                                      setState(() {
                                        image = File(result.path);
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.image, size: 40),
                                ),
                                // Ikon Camera
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    final result = await imagePicker.pickImage(ImageSource.camera);
                                    if (result != null) {
                                      setState(() {
                                        image = File(result.path);
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.camera_alt, size: 40),
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
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  border: Border.all(color: blackColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: image == null 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo, size: 50),
                          const SizedBox(height: 5),
                          Text('Pick Image', style: blackTextStyle.copyWith(fontSize: 17)),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        image!,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}