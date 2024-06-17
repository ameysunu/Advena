import 'package:image_picker/image_picker.dart';

class HomeController {
  XFile? profileImage;
  List<dynamic> getGreetingMessage() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour < 12) {
      return ['Good Morning', true];
    } else if (hour < 18) {
      return ['Good Afternoon', true];
    } else {
      return ['Good Evening', false];
    }
  }

  Future<void> pickImage(Function(XFile) onImagePicked) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      profileImage = image;
      onImagePicked(image);
    }
  }
}
