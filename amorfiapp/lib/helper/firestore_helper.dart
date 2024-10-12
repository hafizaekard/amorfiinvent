import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future <User?> createPin(String pin)async{
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final user = await users.doc(pin).get();
    if (user.exists) {
      return User(role: user['role'], email: user['email']);
    } else {
      return null;
    }
  }

  switchAccount(String text) {}
}

class User {
  final String role;
  final String email;

  const User({required this.role, required this.email});

  Map<String, dynamic> toJson() => {
        'role': role,
        'email': email,
      };
}

