import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> updateDisplayName(String displayName, String dob,
      XFile? profileImage, Function(User) onUserUpdate) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.updateProfile(displayName: displayName, photoURL: null);
      await user.reload();
      User? updatedUser = FirebaseAuth.instance.currentUser;

      var userProfileImageUrl =
          await uploadProfileImageToFirebaseStorage(user.uid, profileImage);

      _firestore.collection('appusers').doc(user.uid).set({
        'username': displayName,
        'dob': dob,
        'profileImage': userProfileImageUrl
      }, SetOptions(merge: true));
      onUserUpdate(updatedUser!);
    }
  }

  Future<String> uploadProfileImageToFirebaseStorage(
      String uid, XFile? image) async {
    var fileName = 'appUsers/$uid.png';

    if (image != null) {
      try {
        File file = File(image.path);
        Reference storageReference =
            FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageReference.putFile(file);
        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        return 'Error uploading image to Firebase Storage: $e';
      }
    }
    print("Image is null");
    return 'Error: No image selected';
  }
}
