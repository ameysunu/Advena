import 'package:advena_flutter/models/recommendation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecommendationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user;

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
      _firestore.collection('recommendations').doc(user!.uid).set({
        'interests': interests,
        'socialPreferences': socialPreferences.toJson()
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print("Exception caught $e");
      throw Exception("Exception caught $e");
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
}
