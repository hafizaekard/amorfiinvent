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

  Future<String> getImage(String docId) async {
    CollectionReference image = FirebaseFirestore.instance.collection('image');
    final snapshot = await image.doc(docId).get();
    return snapshot['image'];
}
void main() async {

    String imageFromInput = await getImage('input_item');
    print('URL gambar input: $imageFromInput');
    String imageFromOrder = await getImage('order_data');
    print('URL gambar order: $imageFromOrder');
    String imageFromRemaining = await getImage('remaining_stock');
    print('URL gambar remaining: $imageFromRemaining');
    String imageFromArchive = await getImage('archive_management');
    print('URL gambar archive: $imageFromArchive');
    String imageFromProduction = await getImage('production_manager');
    print('URL gambar production: $imageFromProduction');
    String imageFromIngredients = await getImage('ingredients_manager');
    print('URL gambar ingredients: $imageFromIngredients');
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

