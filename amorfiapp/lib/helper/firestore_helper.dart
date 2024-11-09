import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fungsi untuk memperbarui quantity berdasarkan koleksi tertentu
  static Future<void> updateItemQuantity(String collection, String documentId, int quantity) async {
    try {
      await FirebaseFirestore.instance
          .collection(collection)
          .doc(documentId)
          .update({'quantity': quantity});
      print('Quantity updated successfully in $collection');
    } catch (error) {
      print('Failed to update quantity in $collection: $error');
      rethrow;
    }
  }

  // Add this method to your FirestoreHelper class
Future<void> updateItemInCollections(
  String itemId,
  String title,
  String imageUrl, {
  String? title2,
  String? label,
}) async {
  final Map<String, dynamic> data = {
    'title': title,
    'image': imageUrl,
    'title2': title2 ?? '',
    'label': label ?? '',
  };

  // Update in all three collections
  await FirebaseFirestore.instance
      .collection('item_management')
      .doc(itemId)
      .update(data);

  await FirebaseFirestore.instance
      .collection('input_item')
      .doc(itemId)
      .update(data);

  await FirebaseFirestore.instance
      .collection('remaining_stock')
      .doc(itemId)
      .update(data);
}

  Future<void> inputItem(String title, String imageURL, {String? title2, String? label}) async {
    CollectionReference collection = firestore.collection('input_item');
    await collection.add({
      'title': title,
      'image': imageURL,
      'title2': title2 ?? '',
      'label': label ?? '',
    });
  }

  Future<void> deleteOrderData(String itemId) async {
    try {
      // Menghapus dokumen berdasarkan ID di koleksi order_data
      await firestore.collection('order_data').doc(itemId).delete();
      print('Order data with ID $itemId deleted successfully');
    } catch (error) {
      print('Failed to delete order data with ID $itemId: $error');
      rethrow;
    }
  }

  // Menambahkan item ke koleksi remaining_stock
  Future<void> addToRemainingStock(String title, String imageURL, {String? title2, String? label}) async {
    CollectionReference collection = firestore.collection('remaining_quantities');
    await collection.add({
      'title': title,
      'image': imageURL,
      'title2': title2 ?? '',
      'label': label ?? '',
    });
  }

  // Fungsi untuk menambah data pada koleksi input_quantities
  Future<void> addToInputItem(String title, String imageURL, {String? title2, String? label}) async {
    CollectionReference collection = firestore.collection('input_quantities');
    await collection.add({
      'title': title,
      'image': imageURL,
      'title2': title2 ?? '',
      'label': label ?? '',
    });
  }

  Future<void> inputIngredient(String title, String imageURL, {required List<String> values}) async {
    CollectionReference collection = firestore.collection('input_ingredient');
    await collection.add({
      'title': title,
      'image': imageURL,
      'values': values,
    });
  }

  Future<void> addToInputIngredient(String title, String imageURL, {List<String>? values}) async {
    CollectionReference collection = firestore.collection('ingredient_quantities');
    await collection.add({
      'title': title,
      'image': imageURL,
      'values': values ?? [],
      'timestamp': DateTime.now(),
    });
  }

  


  // Mengambil semua quantity dari koleksi remaining_quantities
  Future<List<Map<String, dynamic>>> getRemainingQuantities() async {
    final snapshot = await firestore.collection('remaining_quantities').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Mengambil semua quantity dari koleksi input_quantities
  Future<List<Map<String, dynamic>>> getInputQuantities() async {
    final snapshot = await firestore.collection('input_quantities').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getIngredientQuantities() async {
    final snapshot = await firestore.collection('ingredient_quantities').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addToItemManagement(String title, String imageURL, {String? title2, String? label}) async {
    CollectionReference collection = firestore.collection('item_management');
    await collection.add({
      'title': title,
      'image': imageURL,
      'title2': title2 ?? '',
      'label': label ?? '',
    });
  }

  Future<void> addToIngredientsManagement(String title, String imageURL, {List<String>? values}) async {
    CollectionReference collection = firestore.collection('ingredients_management');
    await collection.add({
      'title': title,
      'image': imageURL,
      'values': values ?? [],
    });
  }

  Future<void> addOrderData(Map<String, dynamic> orderData) async {
    CollectionReference collection = firestore.collection('order_data');
    try {
      await collection.add(orderData);
      print('Order data added successfully');
    } catch (error) {
      print('Failed to add order data: $error');
      rethrow;
    }
  }

  

  Future<List<Map<String, dynamic>>> getOrderData() async {
    final snapshot = await firestore.collection('order_data').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<User?> createPin(String pin) async {
    CollectionReference users = firestore.collection('users');
    final user = await users.doc(pin).get();
    if (user.exists) {
      return User(role: user['role'], email: user['email']);
    } else {
      return null;
    }
  }

  Future<String> getImage(String docId) async {
    CollectionReference image = firestore.collection('image');
    final snapshot = await image.doc(docId).get();
    return snapshot['image'];
  }

  // Fungsi untuk menghapus arsip yang berusia lebih dari 7 hari
  static Future<void> deleteOldArchives() async {
    try {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      
      final QuerySnapshot oldArchives = await FirebaseFirestore.instance
          .collection('archive_management')
          .where('timestamp', isLessThan: oneHourAgo)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in oldArchives.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('Deleted ${oldArchives.docs.length} old archive(s)');
    } catch (e) {
      print('Error deleting old archives: $e');
    }
  }

  
}

 Future<void> deleteOldArchives() async {
    try {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      
      final QuerySnapshot oldArchives = await FirebaseFirestore.instance
          .collection('archive_ingredients')
          .where('timestamp', isLessThan: oneHourAgo)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in oldArchives.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('Deleted ${oldArchives.docs.length} old archive(s)');
    } catch (e) {
      print('Error deleting old archives: $e');
    }
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
