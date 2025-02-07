import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:glycosnap/Authenticate/pic_storage.dart';
import 'package:glycosnap/Utils/colors.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  StorageService storage = StorageService();
  Uint8List? pickedImage;

  @override
  void initState() {
    super.initState();
    getProfilePicture();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onProfileTapped,
      child: Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 184, 229, 224),
        shape: BoxShape.circle,
        image: pickedImage != null
        ? DecorationImage(
          fit: BoxFit.cover,
          image: Image.memory(
            pickedImage!,
            fit: BoxFit.cover,
          ).image,
        )
        : null,
      ),
      
      ),
    );
  }

  Future<void> onProfileTapped() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    await storage.uploadFile('user1.jpg', image);

    final imageBytes = await image.readAsBytes();
    setState(() => pickedImage = imageBytes);
  }

  Future<void> getProfilePicture() async {
    final imageBytes = await storage.getFile('user1.jpg');
    if (imageBytes == null) return;
    setState(() => pickedImage = imageBytes);
  }
}