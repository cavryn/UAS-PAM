import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CameraService {
  static Future<String?> takeAndUploadPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);

    if (file == null) return null;

    final ref = FirebaseStorage.instance
        .ref('checkin/${DateTime.now().millisecondsSinceEpoch}.jpg');

    await ref.putFile(File(file.path));
    return await ref.getDownloadURL();
  }
}
