import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  StorageService() : ref = FirebaseStorage.instance.ref();

  final Reference ref;

  Future<void> uploadFile(String fileName, XFile file) async {
    try {
      final imageRef = ref.child(fileName);
      final imageBytes = await file.readAsBytes();
      await imageRef.putData(imageBytes);
    } catch (e) {
      print('Could not upload file.');
    }
  }

  Future<Uint8List?> getFile(String fileName) async {
    try {
    final imageRef = ref.child(fileName);
    return imageRef.getData();
    } catch (e) {
      print('Could not get file.');
    }
  }
}