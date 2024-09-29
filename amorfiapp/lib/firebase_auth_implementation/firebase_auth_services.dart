import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign-in method
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('Some error occurred during sign in: $e');
    }
    return null;
  }

  // Sign-up method
  Future<User?> signUpWithEmailAndPassword(String name, String email, String password) async {
    try {
      // Create a user with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name
      await credential.user?.updateProfile(displayName: name);

      // Kirim email verifikasi
      await credential.user?.sendEmailVerification(); // Mengirim email verifikasi

      // Kembalikan pengguna yang terdaftar
      return credential.user;
    } catch (e) {
      print('Some error occurred during sign up: $e');
    }
    return null;
  }
}
