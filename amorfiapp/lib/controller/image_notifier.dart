import 'dart:io';

import 'package:flutter/material.dart';

class ImageNotifier extends ChangeNotifier {
  File? _imageFile;
  String? _networkImageUrl;
  bool _disposed = false;

  File? get image => _imageFile;

  bool get isNetworkImage => _networkImageUrl != null && _imageFile == null;

  String? get networkImageUrl => _networkImageUrl;

  bool get disposed => _disposed;

  void setImage(File? newImage) {
    if (_disposed) return;
    _imageFile = newImage;
    _networkImageUrl = null;
    notifyListeners();
  }

  void setNetworkImage(String url) {
    if (_disposed) return;
    if (url.isNotEmpty) {
      _networkImageUrl = url;
      _imageFile = null;
      notifyListeners();
    }
  }

  void resetImage() {
    if (_disposed) return;
    _imageFile = null;
    _networkImageUrl = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
