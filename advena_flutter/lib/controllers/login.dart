import 'package:advena_flutter/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginController {

  LoginController() {
    initializeFirebase();
  }
  void initializeFirebase() {
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  Future<bool> loginUser(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
          throw FirebaseAuthException(message: e.toString(), code: 'ERROR');

    }
  }
}
