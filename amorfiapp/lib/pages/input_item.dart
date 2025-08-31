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
  final Map<String, int> itemQuantities = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuantities() async {
    final items = await _firestore.collection('input_item').get();
    setState(() {
      for (var doc in items.docs) {
        final data = doc.data();
        if (data.containsKey('quantity')) {
          itemQuantities[doc.id] = data['quantity'] ?? 0;
        }
      }
    });
  }

  Future<void> _saveQuantities() async {
    for (var entry in itemQuantities.entries) {
      await _firestore
          .collection('input_item')
          .doc(entry.key)
          .update({'quantity': entry.value});
    }
  }

  Future<void> _updateRemainingStockIncrementally(
      String itemId, int changeAmount) async {
    try {
      final remainingStockDoc =
          await _firestore.collection('remaining_stock').doc('quantity').get();

      Map<String, int> currentRemainingStock = {};
      if (remainingStockDoc.exists) {
        final data = remainingStockDoc.data() as Map<String, dynamic>;
        currentRemainingStock = Map<String, int>.from(data);
      }

      final currentRemainingQuantity = currentRemainingStock[itemId] ?? 0;
      final newRemainingQuantity = currentRemainingQuantity + changeAmount;

      currentRemainingStock[itemId] =
          newRemainingQuantity < 0 ? 0 : newRemainingQuantity;

      await _firestore
          .collection('remaining_stock')
          .doc('quantity')
          .set(currentRemainingStock, SetOptions(merge: true));
    } catch (e) {
      print('Error updating remaining stock incrementally: $e');
    }
  }

  void _increaseQuantity(String documentId) {
    setState(() {
      itemQuantities[documentId] = (itemQuantities[documentId] ?? 0) + 1;
      _getController(documentId).text = itemQuantities[documentId].toString();
    });
    _saveQuantities();

    _updateRemainingStockIncrementally(documentId, 1);
  }

  void _decreaseQuantity(String documentId) {
    if ((itemQuantities[documentId] ?? 0) > 0) {
      setState(() {
        itemQuantities[documentId] = (itemQuantities[documentId] ?? 0) - 1;
        _getController(documentId).text = itemQuantities[documentId].toString();
      });
      _saveQuantities();

      _updateRemainingStockIncrementally(documentId, -1);
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
      final oldQuantity = itemQuantities[documentId] ?? 0;
      final difference = newQuantity - oldQuantity;

      setState(() {
        itemQuantities[documentId] = newQuantity;
      });
      _saveQuantities();

      if (difference != 0) {
        _updateRemainingStockIncrementally(documentId, difference);
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<DocumentSnapshot> _filterItems(List<DocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) {
      return docs;
    }

    return docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final title = (data['title'] as String).toLowerCase();
      final label = (data['label'] as String? ?? '').toLowerCase();
      final title2 = (data['title2'] as String? ?? '').toLowerCase();

      return title.contains(_searchQuery) ||
          label.contains(_searchQuery) ||
          title2.contains(_searchQuery);
    }).toList();
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
            'label': itemData['label'],
            'title2': itemData['title2'],
          });
        }
      }

      if (archiveData['items'].isNotEmpty) {
        await archiveRef.set(archiveData);
      }

      WriteBatch batch = _firestore.batch();
      for (var doc in items.docs) {
        final docRef = _firestore.collection('input_item').doc(doc.id);
        batch.update(docRef, {'quantity': 0});
      }
      await batch.commit();

      setState(() {
        itemQuantities.clear();
        _controllers.forEach((key, controller) {
          controller.text = '0';
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Input item data was successfully refreshed and archived')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to refresh input item data')),
      );
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
            BackButtonCustom(onPressed: () => Navigator.pop(context)),
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
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: greyColor.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      hintText: 'Loading...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 15,
                    itemBuilder: (context, index) => const SkeletonItemPage(),
                  ),
                ),
              ],
            );
          }

          final sortedDocs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final titleA =
                  (a.data() as Map<String, dynamic>)['title'] as String;
              final titleB =
                  (b.data() as Map<String, dynamic>)['title'] as String;
              return titleA.toLowerCase().compareTo(titleB.toLowerCase());
            });

          final filteredDocs = _filterItems(sortedDocs);

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: greyColor.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search for item...',
                        hintStyle: greyTextStyle.copyWith(fontSize: 16),
                        prefixIcon: Icon(Icons.search, color: greyColor),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: greyColor),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: blackTextStyle.copyWith(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: filteredDocs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: greyColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No items match your search',
                                  style: greyTextStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: medium,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try different keywords',
                                  style: greyTextStyle.copyWith(fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            children: filteredDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
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
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                data['title'],
                                                style: blackTextStyle.copyWith(
                                                    fontSize: 16,
                                                    fontWeight: bold),
                                              ),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['title'],
                                                  style:
                                                      blackTextStyle.copyWith(
                                                          fontSize: 16,
                                                          fontWeight: bold),
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    if (data['label']
                                                            ?.isNotEmpty ==
                                                        true)
                                                      Text(
                                                        data['label'],
                                                        style: blueTextStyle
                                                            .copyWith(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    normal),
                                                      ),
                                                    if (data['label']
                                                                ?.isNotEmpty ==
                                                            true &&
                                                        data['title2']
                                                                ?.isNotEmpty ==
                                                            true)
                                                      const SizedBox(width: 3),
                                                    if (data['title2']
                                                            ?.isNotEmpty ==
                                                        true)
                                                      Text(
                                                        data['title2'],
                                                        style: blueTextStyle
                                                            .copyWith(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    normal),
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
                                          onPressed: () =>
                                              _decreaseQuantity(doc.id),
                                          icon: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: blueColor,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Icon(Icons.remove,
                                                color: whiteColor, size: 18),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 50,
                                          child: TextField(
                                            controller: _getController(doc.id),
                                            textAlign: TextAlign.center,
                                            onSubmitted: (value) =>
                                                _updateQuantityFromInput(
                                                    doc.id, value),
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 8),
                                              isDense: true,
                                            ),
                                            keyboardType: TextInputType.number,
                                            style: blackTextStyle.copyWith(
                                                fontSize: 16, fontWeight: bold),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () =>
                                              _increaseQuantity(doc.id),
                                          icon: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: blueColor,
                                              borderRadius:
                                                  BorderRadius.circular(4),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
