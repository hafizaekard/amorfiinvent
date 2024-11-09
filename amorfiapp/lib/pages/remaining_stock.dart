import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/print_button.dart';
import 'package:amorfiapp/widgets/skeleton/skeleton_input_item.dart';
import 'package:amorfiapp/widgets/update_data_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RemainingStockPage extends StatefulWidget {
  const RemainingStockPage({super.key});

  @override
  State<RemainingStockPage> createState() => _RemainingStockPageState();
}

class _RemainingStockPageState extends State<RemainingStockPage> {
  final Map<String, TextEditingController> _controllers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> get items {
    return _firestore
        .collection('item_management')
        .orderBy('title', descending: false)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _loadQuantities();
  }

  Future<void> _loadQuantities() async {
    var quantitiesDoc = await _firestore
        .collection('remaining_quantities')
        .doc('current')
        .get();
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

  final Map<String, int> itemQuantities = {};

  Future<void> _saveQuantities() async {
    await _firestore.collection('remaining_quantities').doc('current').set(
          itemQuantities.map((key, value) => MapEntry(key, value)),
          SetOptions(merge: true),
        );
  }

/*************  ✨ Codeium Command ⭐  *************/
  /// Increases the quantity of an item by 1 for the given document ID, updates
  /// the corresponding text controller, and saves the updated quantities to
  /// Firestore.
  /// ****  d853fac7-a594-447f-b96e-79d26ba7ea47  ******
  void _increaseQuantity(String documentId) {
    itemQuantities[documentId] = (itemQuantities[documentId] ?? 0) + 1;
    _getController(documentId).text = itemQuantities[documentId].toString();
    _saveQuantities();
  }

  void _decreaseQuantity(String documentId) {
    if ((itemQuantities[documentId] ?? 0) > 0) {
      itemQuantities[documentId] = (itemQuantities[documentId] ?? 0) - 1;
      _getController(documentId).text = itemQuantities[documentId].toString();
    }
    _saveQuantities();
  }

  Future<void> refreshData() async {
  try {
    final timestamp = DateTime.now();
    final archiveRef = _firestore.collection('archive_management').doc();

    final items = await _firestore.collection('item_management').get();
    final archiveData = <String, dynamic>{
      'timestamp': timestamp,
      'source': 'remaining_quantities',
      'items': [],
    };

    // Create a map of current quantities before clearing
    final Map<String, int> currentQuantities = Map.from(itemQuantities);

    // Prepare archive data - only items with quantities > 0
    for (var doc in items.docs) {
      final itemData = doc.data();
      final quantity = itemQuantities[doc.id] ?? 0;
      if (quantity > 0) {
        archiveData['items'].add({
          'itemId': doc.id,
          'title': itemData['title'],
          'quantity': quantity,
          'image': itemData['image'],
          'label': itemData['label'],
          'title2': itemData['title2'],
        });
      }
    }

    // 1. Save to archive management
    await archiveRef.set(archiveData);

    // 2. Transfer quantities to input_quantities
    await _firestore.collection('input_quantities').doc('current').set(
      currentQuantities.map((key, value) => MapEntry(key, value)),
      SetOptions(merge: true),
    );

    // 3. Only clear quantities, not items
    setState(() {
      // Clear only quantities from the map
      itemQuantities.clear();
      
      // Reset quantity text fields to '0'
      _controllers.forEach((key, controller) {
        controller.text = '0';
      });
    });
    
    // Update Firestore to remove only quantities
    await _firestore.collection('remaining_quantities').doc('current').set({});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quantities have been archived, transferred, and cleared'),
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to process data'),
        duration: Duration(seconds: 2),
      ),
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
      itemQuantities[documentId] = newQuantity;
      _saveQuantities();
    }
  }

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
                'Remaining Stock',
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
                          child: data['label']?.isEmpty == true &&
                                  data['title2']?.isEmpty == true
                              ? Align(
                                  alignment: Alignment.centerLeft,
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
                                  if (value.isEmpty) {
                                    return;
                                  }
                                  if (int.tryParse(value) == null) {
                                    return;
                                  }
                                },
                                style: blackTextStyle.copyWith(
                                    fontSize: 16, fontWeight: bold),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _increaseQuantity(document.id),
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
