import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MeetupController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> meetupLists(List<String>? interests) {
    print("INTEREST: ${interests}");
    return _firestore
        .collection('meetuplist')
        .where('interests', arrayContainsAny: interests)
        .snapshots();
  }

  Future<List<String>?> loadUserInterests(User? user) async {
    print("USER: USERID - ${user?.uid}");
    try {
      DocumentSnapshot doc =
          await _firestore.collection('recommendations').doc(user!.uid).get();
      if (doc.exists) {
        List<String> interests = List<String>.from(doc.get('interests'));
        return interests;
      }
      return null;
    } catch (e) {
      print('Error retrieving interests: $e');
      return null;
    }
  }
}
