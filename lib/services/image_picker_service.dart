import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<XFile?> pickFromCamera() async {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 55,
      maxWidth: 1280,
      maxHeight: 1280,
    );
  }

  static Future<XFile?> pickFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 55,
      maxWidth: 1280,
      maxHeight: 1280,
    );
  }
}
