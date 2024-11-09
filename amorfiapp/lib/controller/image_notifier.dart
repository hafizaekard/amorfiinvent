import 'dart:io';

import 'package:flutter/material.dart';

class ImageNotifier extends ChangeNotifier {
  File? _imageFile;
  String? _networkImageUrl;
  bool _disposed = false;

  // Getter untuk mendapatkan image (bisa File atau null)
  File? get image => _imageFile;

  // Getter untuk mengecek apakah image adalah network image
  bool get isNetworkImage => _networkImageUrl != null && _imageFile == null;

  // Getter untuk mendapatkan network image URL
  String? get networkImageUrl => _networkImageUrl;

  // Getter untuk mengecek apakah notifier sudah disposed
  bool get disposed => _disposed;

  // Method untuk set image dari File
  void setImage(File? newImage) {
    if (_disposed) return;
    _imageFile = newImage;
    _networkImageUrl = null;
    notifyListeners();
  }

  // Method untuk set image dari URL
  void setNetworkImage(String url) {
    if (_disposed) return;
    if (url.isNotEmpty) {
      _networkImageUrl = url;
      _imageFile = null;
      notifyListeners();
    }
  }

  // Method untuk reset semua image
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