import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

Future<void> downloadModel() async {
  final storageRef = FirebaseStorage.instance.ref().child('glycosnap_model.pt');  
  final file = File('/tmp/glycosnap_model.pt');
  await storageRef.writeToFile(file);
}