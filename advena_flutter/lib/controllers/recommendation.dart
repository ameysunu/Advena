import 'package:advena_flutter/models/recommendation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecommendationController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user;

  RecommendationController(this.user);

  Future<bool> onLoadRecommendation() async {
    final recommendations =
        _firestore.collection("recommendations").doc(user!.uid);

    recommendations.get().then((DocumentSnapshot snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        return true;
      }
    });
    return false;
  }

  Future<bool> recommendationFormOnSubmit(
      List<String> interests, SocialPreferences socialPreferences) async {
    try {
      print(user!.uid);
      _firestore.collection('recommendations').doc(user!.uid).set(
          {'interests': interests, 'socialPreferences': socialPreferences},
          SetOptions(merge: true));

      return true;
    } catch (e) {
      print("Exception caught $e");
      throw Exception("Exception caught $e");
    }
  }
}
