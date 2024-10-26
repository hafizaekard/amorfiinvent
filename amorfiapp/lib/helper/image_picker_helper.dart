import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  ImagePicker imagePicker = ImagePicker();

  Future pickImage(ImageSource source) async {
    final image = await imagePicker.pickImage(source: source);
    return image;
  }
}