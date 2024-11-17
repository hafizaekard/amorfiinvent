import 'dart:developer';

import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/print_button.dart';
import 'package:amorfiapp/widgets/skeleton/skeleton_input_item.dart';
import 'package:amorfiapp/widgets/update_data_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InputItemPage extends StatefulWidget {
  const InputItemPage({super.key});

  @override
  State<InputItemPage> createState() => _InputItemPageState();
}

class _InputItemPageState extends State<InputItemPage> {
  final Map<String, TextEditingController> _controllers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final Map<String, int> itemQuantities = {};

  Stream<QuerySnapshot> get items {
  return _firestore
      .collection('input_item')
      .orderBy('title', descending: false)
      .snapshots();
}

  @override
void initState() {
  super.initState();
  _loadQuantities();
  _listenToQuantityChanges();
}

void _listenToQuantityChanges() {
  _firestore
      .collection('input_item')
      .snapshots()
      .listen((snapshot) {
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('quantity')) {
        setState(() {
          itemQuantities[doc.id] = data['quantity'] as int;
          if (_controllers.containsKey(doc.id)) {
            _controllers[doc.id]!.text = data['quantity'].toString();
          }
        });
      }
    }
  });
}

  @override
  void dispose() {
    _scrollController.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _loadQuantities() async {
    var quantitiesDoc =
        await _firestore.collection('input_item').doc('quantity').get();
    if (quantitiesDoc.exists) {
      setState(() {
        Map<String, dynamic> data =
            quantitiesDoc.data() as Map<String, dynamic>;
        itemQuantities.clear();
        data.forEach((key, value) {
          itemQuantities[key] = value as int;
          if (_controllers.containsKey(key)) {
            _controllers[key]!.text = value.toString();
          }
        });
      });
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  Future<void> _saveQuantities() async {
    await _firestore.collection('input_item').doc('quantity').set(
          itemQuantities.map((key, value) => MapEntry(key, value)),
          SetOptions(merge: true),
        );
  }

  Future<void> _updateQuantityInFirestore(
      String documentId, int newQuantity) async {
    try {
      await _firestore
          .collection('input_item')
          .doc(documentId)
          .update({'quantity': newQuantity});
    } catch (e) {
      print('Error updating quantity: $e');
    }
  }

  void _increaseQuantity(String documentId) {
    setState(() {
      itemQuantities[documentId] = (itemQuantities[documentId] ?? 0) + 1;
      _getController(documentId).text = itemQuantities[documentId].toString();
    });
    _saveQuantities();
    // Tambahkan update ke Firestore
    _updateQuantityInFirestore(documentId, itemQuantities[documentId]!);
  }

  void _decreaseQuantity(String documentId) {
    if ((itemQuantities[documentId] ?? 0) > 0) {
      setState(() {
        itemQuantities[documentId] = (itemQuantities[documentId] ?? 0) - 1;
        _getController(documentId).text = itemQuantities[documentId].toString();
      });
      _saveQuantities();
      // Tambahkan update ke Firestore
      _updateQuantityInFirestore(documentId, itemQuantities[documentId]!);
    }
  }

  Future<void> refreshData() async {
    try {
      final timestamp = DateTime.now();
      final archiveRef = _firestore.collection('archive_management').doc();

      final items = await _firestore.collection('input_item').get();
      final archiveData = <String, dynamic>{
        'timestamp': timestamp,
        'source': 'input_item',
        'items': [],
      };

      for (var doc in items.docs) {
        final itemData = doc.data();
        final quantity = itemQuantities[doc.id] ?? 0;
        if (quantity > 0) {
          archiveData['items'].add({
            'itemId': doc.id,
            'title': itemData['title'],
            'quantity': quantity,
            'image': itemData['image'],
            'label': itemData['label'], // Menambahkan label
            'title2': itemData['title2'], // Menambahkan title2
          });
        }
      }

      await archiveRef.set(archiveData);

      // Reset semua kuantitas di Firestore
      WriteBatch batch = _firestore.batch();
      for (var doc in items.docs) {
        final docRef = _firestore.collection('input_item').doc(doc.id);
        batch.update(docRef, {'quantity': 0}); // Atur quantity menjadi 0
      }
      await batch.commit();

      // Reset kuantitas lokal di aplikasi
      setState(() {
        itemQuantities.clear();
        _controllers.forEach((key, controller) {
          controller.text = '0';
        });
      });

      await _firestore.collection('input_item').doc('quantity').delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('The data was successfully refreshed and archived')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to refresh data')),
      );
    }
  }

  TextEditingController _getController(String documentId) {
    if (!_controllers.containsKey(documentId)) {
      _controllers[documentId] = TextEditingController(
        text: (itemQuantities[documentId] ?? 0).toString(),
      );
    }
    return _controllers[documentId]!;
  }

  void _updateQuantityFromInput(String documentId, String value) {
    int? newQuantity = int.tryParse(value);
    if (newQuantity != null && newQuantity >= 0) {
      setState(() {
        itemQuantities[documentId] = newQuantity;
      });
      _saveQuantities();
      // Tambahkan update ke Firestore
      _updateQuantityInFirestore(documentId, newQuantity);
    }
  }

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: newBlueColor,
        shape: Border(bottom: BorderSide(color: blueColor.withOpacity(0.2))),
        automaticallyImplyLeading: false,
        titleSpacing: 15,
        actions: [
          const PrintButton(),
          UpdateDataButton(onPressed: refreshData),
          const Padding(padding: EdgeInsets.only(right: 30))
        ],
        title: Row(
          children: [
            BackButtonCustom(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Input Item',
                style: blueTextStyle.copyWith(
                  fontSize: 25,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: lightGreyColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: items,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData) {
            return ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return const SkeletonItemPage();
              },
            );
          }

          final sortedDocs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final String titleA =
                  (a.data() as Map<String, dynamic>)['title'] as String;
              final String titleB =
                  (b.data() as Map<String, dynamic>)['title'] as String;
              return titleA.toLowerCase().compareTo(titleB.toLowerCase());
            });

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                children: sortedDocs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: greyColor.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: (data['label']?.isEmpty == true &&
                                  data['title2']?.isEmpty == true)
                              ? Align(
                                  alignment: Alignment
                                      .centerLeft, // Align the title to the left
                                  child: Text(
                                    data['title'],
                                    style: blackTextStyle.copyWith(
                                      fontSize: 16,
                                      fontWeight: bold,
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'],
                                      style: blackTextStyle.copyWith(
                                        fontSize: 16,
                                        fontWeight: bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        if (data['label']?.isNotEmpty == true)
                                          Text(
                                            data['label'],
                                            style: blueTextStyle.copyWith(
                                              fontSize: 15,
                                              fontWeight: normal,
                                            ),
                                          ),
                                        if (data['label']?.isNotEmpty == true &&
                                            data['title2']?.isNotEmpty == true)
                                          const SizedBox(width: 3),
                                        if (data['title2']?.isNotEmpty == true)
                                          Text(
                                            data['title2'],
                                            style: blueTextStyle.copyWith(
                                              fontSize: 14,
                                              fontWeight: normal,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _decreaseQuantity(document.id),
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(Icons.remove,
                                    color: whiteColor, size: 18),
                              ),
                            ),
                            SizedBox(
                              width: 50,
                              child: TextField(
                                controller: _getController(document.id),
                                textAlign: TextAlign.center,
                                onSubmitted: (value) {
                                  _updateQuantityFromInput(document.id, value);
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8),
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  if (value.isEmpty) return;
                                  int? newValue = int.tryParse(value);
                                  if (newValue != null) {
                                    _updateQuantityFromInput(
                                        document.id, value);
                                  }
                                },
                                style: blackTextStyle.copyWith(
                                    fontSize: 16, fontWeight: bold),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () async {
                                _increaseQuantity(document.id);
                                log(document.id.toString(),
                                    name: 'Document ID');
                                await firebaseFirestore
                                    .collection('input_item')
                                    .doc(document.id)
                                    .update(
                                        {'quantity': FieldValue.increment(1)});
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(Icons.add,
                                    color: whiteColor, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
