import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  static final FirestoreHelper _instance = FirestoreHelper._internal();
  factory FirestoreHelper() => _instance;
  FirestoreHelper._internal();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> updateProductData(
      String productId, String title, String imageUrl,
      {String? title2, String? label}) async {
    try {
      final data = {
        'title': title,
        'image': imageUrl,
        'title2': title2 ?? '',
        'label': label ?? '',
        'updated_at': FieldValue.serverTimestamp(),
      };

      await firestore
          .collection('remaining_stock')
          .doc(productId)
          .update(data);
      print('Product data updated successfully for product $productId');
    } catch (error) {
      print('Failed to update product data for $productId: $error');
      rethrow;
    }
  }

  Future<String> addItem(String title, String imageURL,
      {String? title2, String? label, int price = 0}) async {
    try {
      final productData = {
        'title': title,
        'image': imageURL,
        'title2': title2 ?? '',
        'label': label ?? '',
        'price': price,
        'quantity': 0,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      final remainingStockRef = await firestore.collection('remaining_stock').add(productData);
      await firestore.collection('input_item').add(productData);
      
      print('New product added successfully with ID: ${remainingStockRef.id}');
      return remainingStockRef.id;
    } catch (error) {
      print('Failed to add new product: $error');
      rethrow;
    }
  }

  Future<void> deleteOrderData(String orderId) async {
    try {
      final orderDoc = await firestore.collection('order_data').doc(orderId).get();
      if (orderDoc.exists) {
        await firestore.collection('archive_orders').add({
          ...orderDoc.data()!,
          'original_id': orderId,
          'action': 'deleted',
          'archived_at': FieldValue.serverTimestamp(),
        });
      }

      await firestore.collection('order_data').doc(orderId).delete();
      print('Order data deleted successfully for order $orderId');
    } catch (error) {
      print('Failed to delete order data for $orderId: $error');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRemainingStockData() async {
    try {
      final snapshot = await firestore
          .collection('remaining_stock')
          .orderBy('title', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    } catch (error) {
      print('Failed to get remaining stock data: $error');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getInputItemData() async {
    try {
      final snapshot = await firestore
          .collection('input_item')
          .orderBy('title', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();
    } catch (error) {
      print('Failed to get input item data: $error');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getIngredientData({
    String? searchQuery,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      Query query = firestore.collection('ingredients_management');
      
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      } else {
        query = query.orderBy('title', descending: false);
      }
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      
      List<Map<String, dynamic>> ingredients = snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        ingredients = ingredients.where((ingredient) {
          final title = (ingredient['title'] as String? ?? '').toLowerCase();
          final values = ingredient['values'] as List<dynamic>? ?? [];
          final expiryDate = (ingredient['expiry_date'] as String? ?? '').toLowerCase();

          if (title.contains(query)) return true;
          if (expiryDate.contains(query)) return true;
          
          for (var value in values) {
            if (value.toString().toLowerCase().contains(query)) return true;
          }
          
          return false;
        }).toList();
      }

      return ingredients;
    } catch (error) {
      print('Failed to get ingredient data: $error');
      rethrow;
    }
  }

  Future<void> addToItemManagement(String title, String imageURL,
      {String? title2, String? label}) async {
    try {
      final data = {
        'title': title,
        'image': imageURL,
        'title2': title2 ?? '',
        'label': label ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await firestore.collection('input_item').add(data);
      print('New item added to item management');
    } catch (error) {
      print('Failed to add item to item management: $error');
      rethrow;
    }
  }

  Future<String> addToIngredientsManagement(
    String title, 
    String imageURL, {
    List<String>? values,
    String? expiryDate,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final data = {
        'title': title.trim(),
        'image': imageURL,
        'values': values ?? [],
        'expiry_date': expiryDate ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'created_by': 'ingredients_management',
        ...?additionalData,
      };

      final docRef = await firestore.collection('ingredients_management').add(data);
      print('New ingredient added to ingredients management with ID: ${docRef.id}');
      return docRef.id;
    } catch (error) {
      print('Failed to add ingredient to ingredients management: $error');
      rethrow;
    }
  }

  Future<void> updateIngredientInManagement(
    String ingredientId, 
    String title, 
    String imageURL, {
    List<String>? values,
    String? expiryDate,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final docRef = firestore
          .collection('ingredients_management')
          .doc(ingredientId);
      
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Ingredient with ID $ingredientId not found');
      }

      await _createIngredientBackup(ingredientId, docSnapshot.data()!, 'updated');

      final updateData = {
        'title': title.trim(),
        'image': imageURL,
        'values': values ?? [],
        'expiry_date': expiryDate ?? '',
        'updated_at': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      await docRef.update(updateData);
      print('Ingredient updated successfully in ingredients management');
    } catch (error) {
      print('Failed to update ingredient in ingredients management: $error');
      rethrow;
    }
  }

  Future<void> deleteIngredientFromManagement(String ingredientId) async {
    try {
      final docRef = firestore
          .collection('ingredients_management')
          .doc(ingredientId);
      
      final docSnapshot = await docRef.get();
      
      if (!docSnapshot.exists) {
        throw Exception('Ingredient with ID $ingredientId not found');
      }

      // Create backup before deleting
      await _createIngredientBackup(ingredientId, docSnapshot.data()!, 'deleted');

      await docRef.delete();
      print('Ingredient deleted successfully from ingredients management');
    } catch (error) {
      print('Failed to delete ingredient from ingredients management: $error');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getIngredientById(String ingredientId) async {
    try {
      final doc = await firestore
          .collection('ingredients_management')
          .doc(ingredientId)
          .get();
      if (doc.exists) {
        return {
          ...doc.data()!,
          'id': doc.id,
        };
      }
      return null;
    } catch (error) {
      print('Failed to get ingredient by ID: $error');
      rethrow;
    }
  }

  Future<bool> ingredientExists(String ingredientId) async {
    try {
      final doc = await firestore
          .collection('ingredients_management')
          .doc(ingredientId)
          .get();
      return doc.exists;
    } catch (error) {
      print('Failed to check ingredient existence: $error');
      return false;
    }
  }

  Future<void> batchUpdateIngredients(Map<String, Map<String, dynamic>> updates) async {
    try {
      final batch = firestore.batch();
      
      for (final entry in updates.entries) {
        final ingredientId = entry.key;
        final updateData = entry.value;
        
        final docRef = firestore
            .collection('ingredients_management')
            .doc(ingredientId);
        
        batch.update(docRef, {
          ...updateData,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      print('Batch update completed for ${updates.length} ingredients');
    } catch (error) {
      print('Failed to batch update ingredients: $error');
      rethrow;
    }
  }

  Future<void> batchDeleteIngredients(List<String> ingredientIds) async {
    try {
      final batch = firestore.batch();
      
      for (final ingredientId in ingredientIds) {
        final doc = await firestore
            .collection('ingredients_management')
            .doc(ingredientId)
            .get();
        
        if (doc.exists) {
          await _createIngredientBackup(ingredientId, doc.data()!, 'batch_deleted');
          
          batch.delete(firestore
              .collection('ingredients_management')
              .doc(ingredientId));
        }
      }
      
      await batch.commit();
      print('Batch delete completed for ${ingredientIds.length} ingredients');
    } catch (error) {
      print('Failed to batch delete ingredients: $error');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchIngredients(String query) async {
    try {
      final snapshot = await firestore
          .collection('ingredients_management')
          .orderBy('title')
          .get();

      final allIngredients = snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      if (query.isEmpty) return allIngredients;

      final searchQuery = query.toLowerCase();
      return allIngredients.where((ingredient) {
        final title = (ingredient['title'] as String? ?? '').toLowerCase();
        final values = ingredient['values'] as List<dynamic>? ?? [];
        final expiryDate = (ingredient['expiry_date'] as String? ?? '').toLowerCase();

        if (title.contains(searchQuery)) return true;
        
        if (expiryDate.contains(searchQuery)) return true;
        
        for (var value in values) {
          if (value.toString().toLowerCase().contains(searchQuery)) return true;
        }
        
        return false;
      }).toList();
    } catch (error) {
      print('Failed to search ingredients: $error');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getExpiringSoonIngredients({int daysAhead = 7}) async {
    try {
      final snapshot = await firestore
          .collection('ingredients_management')
          .get();

      final now = DateTime.now();
      final cutoffDate = now.add(Duration(days: daysAhead));

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .where((ingredient) {
            final expiryDate = ingredient['expiry_date'] as String?;
            if (expiryDate == null || expiryDate.isEmpty) return false;
            
            try {
              final parts = expiryDate.split('/');
              if (parts.length == 3) {
                final expiryDateTime = DateTime(
                  int.parse(parts[2]), // year
                  int.parse(parts[1]), // month
                  int.parse(parts[0]), // day
                );
                
                return expiryDateTime.isBefore(cutoffDate) && 
                       expiryDateTime.isAfter(now.subtract(const Duration(days: 1)));
              }
            } catch (e) {
              print('Error parsing expiry date $expiryDate: $e');
            }
            
            return false;
          })
          .toList();
    } catch (error) {
      print('Failed to get expiring ingredients: $error');
      rethrow;
    }
  }

  Future<void> _createIngredientBackup(
    String originalId, 
    Map<String, dynamic> data, 
    String action,
  ) async {
    try {
      await firestore.collection('archive_ingredients').add({
        ...data,
        'original_id': originalId,
        'action': action,
        'archived_at': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      print('Warning: Failed to create ingredient backup: $error');
      // Don't throw error as this is not critical
    }
  }

  // Order Management Methods
  Future<String> addOrderData(Map<String, dynamic> orderData) async {
    try {
      final data = {
        ...orderData,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      final docRef = await firestore.collection('order_data').add(data);
      print('Order data added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (error) {
      print('Failed to add order data: $error');
      rethrow;
    }
  }

  Future<void> editOrderData(Map<String, dynamic> orderData, String id) async {
    try {
      final updateData = {
        ...orderData,
        'updated_at': FieldValue.serverTimestamp(),
      };

      await firestore.collection('order_data').doc(id).update(updateData);
      print('Order data updated successfully for order $id');
    } catch (error) {
      print('Failed to edit order data: $error');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOrderData({
    String? status,
    String? customerId,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  }) async {
    try {
      Query query = firestore.collection('order_data');
      
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }
      
      if (customerId != null) {
        query = query.where('customerId', isEqualTo: customerId);
      }
      
      if (fromDate != null) {
        query = query.where('created_at', isGreaterThanOrEqualTo: fromDate);
      }
      
      if (toDate != null) {
        query = query.where('created_at', isLessThanOrEqualTo: toDate);
      }
      
      query = query.orderBy('customerName', descending: false);
      
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => {
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              })
          .toList();
    } catch (error) {
      print('Failed to fetch order data: $error');
      rethrow;
    }
  }

  Future<User?> createPin(String pin) async {
    try {
      final usersRef = firestore.collection('users');
      final user = await usersRef.doc(pin).get();
      if (user.exists) {
        final userData = user.data()!;
        return User(
          role: userData['role'], 
          email: userData['email'],
          uid: user.id,
        );
      } else {
        return null;
      }
    } catch (error) {
      print('Failed to create pin: $error');
      return null;
    }
  }

  Future<String> getImage(String docId) async {
    try {
      final imageRef = firestore.collection('image');
      final snapshot = await imageRef.doc(docId).get();
      return snapshot.data()?['image'] ?? '';
    } catch (error) {
      print('Failed to get image: $error');
      return '';
    }
  }

  Future<void> saveOrderToFirestore({
    required String customerName,
    required String customerAddress,
    required String customerNumber,
    required List<Map<String, dynamic>> newOrderItems,
  }) async {
    try {
      if (customerName.trim().isEmpty) {
        throw ArgumentError('Customer name tidak boleh kosong');
      }
      if (newOrderItems.isEmpty) {
        throw ArgumentError('Order items tidak boleh kosong');
      }

      final docId = '${customerName}_$customerNumber'.replaceAll(' ', '_');
      final docRef = firestore.collection('order_notifications').doc(docId);

      await firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        List<Map<String, dynamic>> existingItems = [];

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data['orderItems'] != null) {
            existingItems = List<Map<String, dynamic>>.from(data['orderItems']);
          }
        }

        final allOrderItems = [...existingItems, ...newOrderItems];

        transaction.set(docRef, {
          'customerName': customerName,
          'customerAddress': customerAddress,
          'customerNumber': customerNumber,
          'orderItems': allOrderItems,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      print('Failed to save order: $error');
      rethrow;
    }
  }

  Future<void> clearCurrentCustomerData() async {
    try {
      await firestore
          .collection('temp_order_data')
          .doc('current_customer')
          .delete();
    } catch (e) {
      print("Gagal menghapus current_customer: $e");
    }
  }


  Future<void> saveImage(String docId, String imageUrl) async {
    try {
      await firestore.collection('image').doc(docId).set({
        'image': imageUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });
      print('Image saved successfully for doc $docId');
    } catch (error) {
      print('Failed to save image: $error');
      rethrow;
    }
  }
  static Future<void> deleteOldArchives({
    required String collectionName,
    int daysOld = 30,
  }) async {
    try {
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: daysOld));

      final QuerySnapshot oldArchives = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('archived_at', isLessThan: cutoffDate)
          .get();

      if (oldArchives.docs.isEmpty) {
        print('No old archives to delete from $collectionName');
        return;
      }

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

  static Future<void> deleteOldArchivesIngredients({
    required String collectionName,
    int daysOld = 30,
  }) async {
    await deleteOldArchives(collectionName: collectionName, daysOld: daysOld);
  }

  static Future<void> deleteAllOldArchives({int daysOld = 30}) async {
    await Future.wait([
      deleteOldArchives(collectionName: 'archive_management', daysOld: daysOld),
      deleteOldArchives(collectionName: 'archive_ingredients', daysOld: daysOld),
      deleteOldArchives(collectionName: 'archive_orders', daysOld: daysOld),
    ]);
  }

  Future<Map<String, int>> getIngredientStatistics() async {
    try {
      final snapshot = await firestore
          .collection('ingredients_management')
          .get();

      final total = snapshot.docs.length;
      int withExpiry = 0;
      int expiringSoon = 0;
      int expired = 0;
      final now = DateTime.now();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final expiryDate = data['expiry_date'] as String?;
        
        if (expiryDate != null && expiryDate.isNotEmpty) {
          withExpiry++;
          
          try {
            final parts = expiryDate.split('/');
            if (parts.length == 3) {
              final expiryDateTime = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month
                int.parse(parts[0]), // day
              );
              
              final difference = expiryDateTime.difference(now).inDays;
              
              if (difference < 0) {
                expired++;
              } else if (difference <= 7) {
                expiringSoon++;
              }
            }
          } catch (e) {
            print('Error parsing expiry date $expiryDate: $e');
          }
        }
      }

      return {
        'total': total,
        'withExpiry': withExpiry,
        'expiringSoon': expiringSoon,
        'expired': expired,
        'withoutExpiry': total - withExpiry,
      };
    } catch (error) {
      print('Failed to get ingredient statistics: $error');
      return {
        'total': 0,
        'withExpiry': 0,
        'expiringSoon': 0,
        'expired': 0,
        'withoutExpiry': 0,
      };
    }
  }

  Future<bool> validateIngredientData(Map<String, dynamic> data) async {
    try {
      if (data['title'] == null || (data['title'] as String).trim().isEmpty) {
        throw Exception('Title is required');
      }
      if ((data['title'] as String).trim().length < 2) {
        throw Exception('Title must be at least 2 characters long');
      }

      final expiryDate = data['expiry_date'] as String?;
      if (expiryDate != null && expiryDate.isNotEmpty) {
        final parts = expiryDate.split('/');
        if (parts.length != 3) {
          throw Exception('Expiry date must be in DD/MM/YYYY format');
        }
        
        try {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          
          if (day < 1 || day > 31) {
            throw Exception('Invalid day in expiry date');
          }
          if (month < 1 || month > 12) {
            throw Exception('Invalid month in expiry date');
          }
          if (year < DateTime.now().year) {
            throw Exception('Expiry date cannot be in the past');
          }
          
          final date = DateTime(year, month, day);
          if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
            throw Exception('Expiry date cannot be in the past');
          }
        } catch (e) {
          throw Exception('Invalid expiry date format');
        }
      }

      final values = data['values'];
      if (values != null && values is! List) {
        throw Exception('Values must be a list');
      }

      return true;
    } catch (error) {
      print('Validation error: $error');
      rethrow;
    }
  }

  Future<void> clearCollection(String collectionName) async {
    try {
      final snapshot = await firestore.collection(collectionName).get();
      final batch = firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('Cleared collection: $collectionName');
    } catch (error) {
      print('Failed to clear collection $collectionName: $error');
      rethrow;
    }
  }

  Future<void> healthCheck() async {
    try {
      final testDoc = await firestore
          .collection('health_check')
          .doc('test')
          .get();
      
      print('Firestore health check: ${testDoc.exists ? "Connected" : "Connected (new)"}');
    } catch (error) {
      print('Firestore health check failed: $error');
      rethrow;
    }
  }
}

class User {
  final String role;
  final String email;
  final String uid;

  const User({
    required this.role, 
    required this.email,
    required this.uid,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'email': email,
        'uid': uid,
      };

  @override
  String toString() => 'User(role: $role, email: $email, uid: $uid)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          role == other.role &&
          email == other.email &&
          uid == other.uid;

  @override
  int get hashCode => role.hashCode ^ email.hashCode ^ uid.hashCode;
}