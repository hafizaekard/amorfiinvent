import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';


class StorageHelper {
  Future<String> uploadImageToStorage(File path, String name) async {
    final storageRef = FirebaseStorage.instance.ref();

    final file = File(path.path);

    final uploadTask = storageRef
    .child('images/$name')
    .putFile(file);

  final snapshot = await uploadTask.whenComplete(() => null);

  return snapshot.ref.getDownloadURL();
  }
}