import 'dart:io';

import 'package:amorfiapp/helper/image_picker_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DummyPage extends StatefulWidget {
  const DummyPage({super.key});

  @override
  State<DummyPage> createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  ImagePickerHelper imagePicker = ImagePickerHelper();

File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(child: const Text('Pick Image'),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              final result = await imagePicker
                                      .pickImage(ImageSource.gallery);
                                  if (result != null) {
                                    setState(() {
                                      image = File(result.path);
                                    });
                                  }
                                  // Untuk menutup dialog
                                  Navigator.pop(context);
                            },
                            icon: const Icon(Icons.image),
                          ),
                          IconButton(
                            onPressed: () async {
                              final result = await imagePicker
                                      .pickImage(ImageSource.camera);
                                  if (result != null) {
                                    setState(() {
                                      image = File(result.path);
                                    });
                                  }
                                  // Untuk menutup dialog
                                  Navigator.pop(context);
                            },
                            icon: const Icon(Icons.camera_alt),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
             
            ),
const SizedBox(
              height: 20,
            ),
            image == null ? const Placeholder() : Image.file(image!),
          ],
        ),
      ),
    );
  }
  
}