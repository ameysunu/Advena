import 'dart:convert';
import 'package:advena_flutter/models/recommendation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;

class RecommendationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user;
  final loc.Location location = loc.Location();

  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return null;
      }
    }

    final locData = await location.getLocation();
    return LatLng(locData.latitude ?? 0.0, locData.longitude ?? 0.0);
  }

  Future<String> getCityCountry(LatLng location) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String city = place.locality ?? place.administrativeArea ?? '';
        String country = place.country ?? '';
        return '$city, $country';
      } else {
        return 'Unknown location';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  RecommendationController(this.user);

  Stream<bool> onLoadRecommendation() {
    return _firestore
        .collection("recommendations")
        .doc(user!.uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      print("Data $data");
      return data != null;
    });
  }

  Future<bool> recommendationFormOnSubmit(
      List<String> interests, SocialPreferences socialPreferences) async {
    try {
      print(user!.uid);
      await _firestore.collection('recommendations').doc(user!.uid).set({
        'interests': interests,
        'socialPreferences': socialPreferences.toJson()
      }, SetOptions(merge: true));

      // Run the background tasks
      Future.microtask(() async {
        var latlng = await getCurrentLocation();

        if (latlng != null) {
          var userLocation = await getCityCountry(latlng);
          await initiateRecommendationEngine(
              user!, true, userLocation, interests, socialPreferences);
          await initiateRecommendationEngine(
              user!, false, userLocation, interests, socialPreferences);
        }
      });

      return true;
    } catch (e) {
      print("Exception caught $e");
      throw Exception("Exception caught $e");
    }
  }

  Future<void> initiateRecommendationEngine(
      User user,
      bool isInterests,
      String userLocation,
      List<String> interests,
      SocialPreferences socialPref) async {
    String recommendationEngineUrl =
        dotenv.env['RECOMMENDATION_ENGINE_ENDPOINT'] ?? '';
    final url = Uri.parse(recommendationEngineUrl);
    final body = {
      "userId": user.uid,
      "userLocation": userLocation,
      "isInterests": isInterests,
      "interests": interests,
      "socialPreferences": socialPref
    };

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body));

    if (response.statusCode == 200) {
      print("Successfully generated recommendation data");
    }
  }

  Future<String> getCurrentUserFriends() async {
    try {
      final docRef = _firestore.collection("cities").doc("SF");
      docRef.get().then(
        (DocumentSnapshot doc) {
          final data = doc.data() as Map<String, dynamic>;
          return "$data Data";
        },
      );
    } catch (e) {
      print("Exception caught $e");
      return "Exception caught $e";
    }

    return "null";
  }

  List<GeminiInterestsResponse>? sanitizeGeminiInterestsJson(
      String rawResponse) {
    if (rawResponse.startsWith('```json') && rawResponse.endsWith('```')) {
      String sanitizedString =
          rawResponse.substring(7, rawResponse.length - 3).trim();
      List<dynamic> jsonData = jsonDecode(sanitizedString);
      List<GeminiInterestsResponse> responseJson = jsonData
          .map((item) => GeminiInterestsResponse.fromJson(item))
          .toList();

      return responseJson;
    }
    return null;
  }
}
