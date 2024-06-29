import 'dart:convert';
import 'dart:io';
import 'package:advena_flutter/models/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class HomeController {
  XFile? profileImage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String get ticketMasterApi => dotenv.env['TICKETMASTER_API_KEY'] ?? '';

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

Future<EventApiResult> getEventsFromTicketMaster(String geoHash, String pageNumber) async {
  List<String> dateTimes = startEndDateTime();

  final String url =
      'https://app.ticketmaster.com/discovery/v2/events.json?size=1&apikey=$ticketMasterApi&geoPoint=${geoHash}&page=$pageNumber&startDateTime=${dateTimes[0]}&endDateTime=${dateTimes[1]}';
  print(url);
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return EventApiResult(data: EventApiResponse.fromJson(data));
    } else {
      final data = json.decode(response.body);
      return EventApiResult(error: EventApiErrorResponse.fromJson(data));
    }
  } catch (error) {
    return EventApiResult(error: EventApiErrorResponse(errors: [ErrorDetail(detail: 'Error fetching data: $error')]));
  }
}

String formatEventDate(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);

  String day = dateTime.day.toString();
  String daySuffix = 'th';
  if (day.endsWith('1') && !day.endsWith('11')) {
    daySuffix = 'st';
  } else if (day.endsWith('2') && !day.endsWith('12')) {
    daySuffix = 'nd';
  } else if (day.endsWith('3') && !day.endsWith('13')) {
    daySuffix = 'rd';
  }
  String formattedDay = day + daySuffix;

  String formattedMonth = DateFormat('MMMM').format(dateTime);
  String formattedYear = dateTime.year.toString();

  return '$formattedDay $formattedMonth $formattedYear';
}

List<String> startEndDateTime() {
  DateTime dateTime = DateTime.now().toUtc();
  DateTime tomorrow = dateTime.add(Duration(days: 90));

  String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(dateTime);
  String formattedEndDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(tomorrow);

  return [formattedDate, formattedEndDate];
}

}
