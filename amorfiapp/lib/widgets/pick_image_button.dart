import 'dart:io';

import 'package:amorfiapp/controller/image_notifier.dart';
import 'package:amorfiapp/helper/image_picker_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PickImage extends StatefulWidget {
  const PickImage({super.key});

  @override
  State<PickImage> createState() => _PickImageState();
}

class _PickImageState extends State<PickImage> {
  ImagePickerHelper imagePicker = ImagePickerHelper();

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 32, // Ukuran icon yang lebih kecil
                          onPressed: () async {
                            final result = await imagePicker
                                .pickImage(ImageSource.gallery);
                            if (result != null) {
                              context
                                  .read<ImageNotifier>()
                                  .setImage(File(result.path));
                            }
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.image),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          iconSize: 32, // Ukuran icon yang lebih kecil
                          onPressed: () async {
                            final result =
                                await imagePicker.pickImage(ImageSource.camera);
                            if (result != null) {
                              context
                                  .read<ImageNotifier>()
                                  .setImage(File(result.path));
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
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          border: Border.all(color: blackColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Consumer<ImageNotifier>(builder: (context, value, child) {
          return context.watch<ImageNotifier>().image == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_a_photo, size: 50),
                      const SizedBox(height: 5),
                      Text('Pick Image',
                          style: blackTextStyle.copyWith(fontSize: 17)),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    context.watch<ImageNotifier>().image!,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                );
        }),
      ),
    );
  }
}
