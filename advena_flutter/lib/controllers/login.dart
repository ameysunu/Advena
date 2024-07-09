import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<List<dynamic>> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return [true, userCredential.user];
    } catch (e) {
      throw FirebaseAuthException(message: e.toString(), code: 'ERROR');
    }
  }

// Always run keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw FirebaseAuthException(message: e.toString(), code: 'ERROR');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

    Future<List<dynamic>> registerUser(String email, String password, String confirmPassword) async {
    try {

      if(password != confirmPassword){
        throw FirebaseAuthException(message: 'Passwords do not match', code: 'ERROR');
      }

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      return [true, userCredential.user];
    } catch (e) {
      throw FirebaseAuthException(message: e.toString(), code: 'ERROR');
    }
  }
}
