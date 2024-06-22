import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';

class HomeController {
  XFile? profileImage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> updateDisplayName(
      String displayName, String dob, Function(User) onUserUpdate) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updateProfile(displayName: displayName, photoURL: null);
      await user.reload();
      User? updatedUser = FirebaseAuth.instance.currentUser;

      _firestore
          .collection('appusers')
          .doc(user.uid)
          .set({'username': displayName, 'dob': dob}, SetOptions(merge: true));
      onUserUpdate(updatedUser!);
    }
  }
}
