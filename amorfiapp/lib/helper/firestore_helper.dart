import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Memperbarui kuantitas berdasarkan koleksi tertentu
  

  // Memperbarui data produk
  Future<void> updateProductData(String productId, String title, String imageUrl, {String? title2, String? label}) async {
    try {
      final data = {
        'title': title,
        'image': imageUrl,
        'title2': title2 ?? '',
        'label': label ?? '',
      };
      
      await FirebaseFirestore.instance
          .collection('remaining_stock')
          .doc(productId)
          .update(data);
      print('Product data updated successfully for product $productId');
    } catch (error) {
      print('Failed to update product data for $productId: $error');
      rethrow;
    }
  }

  // Menyimpan data produk baru
  Future<void> addItem(String title, String imageURL, {String? title2, String? label}) async {
    try {
      final productData = {
        'title': title,
        'image': imageURL,
        'title2': title2 ?? '',
        'label': label ?? '',
        'quantity': 0,
      };
      await firestore.collection('remaining_stock').add(productData);
      await firestore.collection('input_item').add(productData);
      print('New product added successfully');
    } catch (error) {
      print('Failed to add new product: $error');
      rethrow;
    }
  }

  // Menghapus data order
 Future<void> deleteOrderData(String orderId) async {
    try {
      await firestore.collection('order_data').doc(orderId).delete();
      print('Order data deleted successfully for order $orderId');
    } catch (error) {
      print('Failed to delete order data for $orderId: $error');
      rethrow;
    }
  }

  // Menyimpan data input ingredient
  Future<void> inputIngredient(String title, String imageURL, {required List<String> values}) async {
    try {
      await firestore.collection('input_ingredient').add({
        'title': title,
        'image': imageURL,
        'values': values,
      });
      print('New ingredient added successfully');
    } catch (error) {
      print('Failed to add new ingredient: $error');
      rethrow;
    }
  }

  // Menyimpan data input ingredient (versi lain)
  Future<void> addToInputIngredient(String title, String imageURL, {List<String>? values}) async {
    try {
      await firestore.collection('input_ingredient').add({
        'title': title,
        'image': imageURL,
        'values': values ?? [],
        'timestamp': DateTime.now(),
      });
      print('New ingredient added successfully');
    } catch (error) {
      print('Failed to add new ingredient: $error');
      rethrow;
    }
  }

  // Mengambil semua data kuantitas dari koleksi remaining_stock
  Future<List<Map<String, dynamic>>> getRemainingStockData() async {
    final snapshot = await firestore.collection('remaining_stock').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Mengambil semua data kuantitas dari koleksi input_item
  Future<List<Map<String, dynamic>>> getInputItemData() async {
    final snapshot = await firestore.collection('input_item').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // Mengambil semua data ingredient dari koleksi input_ingredient
  Future<List<Map<String, dynamic>>> getIngredientData() async {
    final snapshot = await firestore.collection('input_ingredient').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  

  // Menyimpan data item untuk manajemen item
  Future<void> addToItemManagement(String title, String imageURL, {String? title2, String? label}) async {
    try {
      await firestore.collection('input_item').add({
        'title': title,
        'image': imageURL,
        'title2': title2 ?? '',
        'label': label ?? '',
      });
      print('New item added to item management');
    } catch (error) {
      print('Failed to add item to item management: $error');
      rethrow;
    }
  }

  // Menyimpan data ingredient untuk manajemen ingredient
  Future<void> addToIngredientsManagement(String title, String imageURL, {List<String>? values}) async {
    try {
      await firestore.collection('input_ingredient').add({
        'title': title,
        'image': imageURL,
        'values': values ?? [],
      });
      print('New ingredient added to ingredients management');
    } catch (error) {
      print('Failed to add ingredient to ingredients management: $error');
      rethrow;
    }
  }

  // Menyimpan data order
  Future<void> addOrderData(Map<String, dynamic> orderData) async {
    try {
      await firestore.collection('order_data').add(orderData);
      print('Order data added successfully');
    } catch (error) {
      print('Failed to add order data: $error');
      rethrow;
    }
  }

  Future<void> editOrderData(Map<String, dynamic> orderData, String id) async {
    await firestore.collection('order_data').doc(id).update(orderData);
  }

  // Mengambil semua data order
  Future<List<Map<String, dynamic>>> getOrderData() async {
    try {
      final snapshot = await firestore.collection('order_data')
          .orderBy('customerName', descending: false)
          .get();
          
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id, // Menambahkan document ID ke data
      }).toList();
    } catch (error) {
      print('Failed to fetch order data: $error');
      rethrow;
    }
  }

  // Membuat user berdasarkan pin
  Future<User?> createPin(String pin) async {
    final usersRef = firestore.collection('users');
    final user = await usersRef.doc(pin).get();
    if (user.exists) {
      return User(role: user['role'], email: user['email']);
    } else {
      return null;
    }
  }

  // Mengambil gambar berdasarkan ID dokumen
  Future<String> getImage(String docId) async {
    final imageRef = firestore.collection('image');
    final snapshot = await imageRef.doc(docId).get();
    return snapshot['image'];
  }

  static Future<void> deleteOldArchives({required String collectionName}) async {
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
  static Future<void> deleteOldArchivesIngredients({required String collectionName}) async {
    try {
      final now = DateTime.now();
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      
      final QuerySnapshot oldArchives = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('timestamp', isLessThan: oneHourAgo)
          .get();

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in oldArchives.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      print('Deleted ${oldArchives.docs.length} old archive(s) from $collectionName');
    } catch (e) {
      print('Error deleting old archives from $collectionName: $e');
    }
  }

  // Helper method to delete archives from specific collections
  static Future<void> deleteAllOldArchives() async {
    await deleteOldArchives(collectionName: 'archive_management');
    await deleteOldArchivesIngredients(collectionName: 'archive_ingredients');
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