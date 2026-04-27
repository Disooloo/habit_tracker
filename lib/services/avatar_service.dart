import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AvatarService {
  AvatarService._();

  static final AvatarService instance = AvatarService._();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<XFile?> pickAvatar() {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
  }

  Future<String> uploadAvatar({
    required String uid,
    required XFile file,
  }) async {
    final ref = _storage.ref().child('avatars/$uid/avatar.jpg');
    final bytes = await file.readAsBytes();
    await ref.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }
}
