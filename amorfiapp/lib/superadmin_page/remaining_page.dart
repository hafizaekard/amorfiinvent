import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/print_button.dart';
import 'package:amorfiapp/widgets/skeleton/skeleton_input_item.dart';
import 'package:amorfiapp/widgets/update_data_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RemainingPage extends StatefulWidget {
  const RemainingPage({super.key});

  @override
  State<RemainingPage> createState() => _RemainingPageState();
}

class _RemainingPageState extends State<RemainingPage> {
  final Map<String, int> itemQuantities = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    _listenToQuantities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _listenToQuantities() {
    _firestore
        .collection('remaining_stock')
        .doc('quantity')
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          itemQuantities.clear();
          for (var entry in data.entries) {
            itemQuantities[entry.key] = entry.value as int;
          }
        });
      }
    });
  }

  int _getQuantity(String id) {
    return itemQuantities[id] ?? 0;
  }

  TextEditingController _getController(String id) {
    return TextEditingController(text: _getQuantity(id).toString());
  }

  Color getStockColor(int stock) {
    if (stock <= 1) {
      return redColor;
    } else if (stock <= 100) {
      return greenColor;
    } else {
      return greenColor;
    }
  }

  String getStockStatus(int stock) {
    if (stock <= 1) {
      return 'Low Stock';
    } else if (stock <= 50) {
      return 'Normal Stock';
    } else {
      return 'High Stock';
    }
  }

  Future<void> refreshData() async {
    try {
      final timestamp = DateTime.now();
      final archiveRef = _firestore.collection('archive_management').doc();

      final items = await _firestore.collection('input_item').get();

      final archiveData = <String, dynamic>{
        'timestamp': timestamp,
        'source': 'remaining_stock',
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

      final Map<String, int> resetQuantities = {};
      for (var doc in items.docs) {
        resetQuantities[doc.id] = 0;
      }
      await _firestore
          .collection('remaining_stock')
          .doc('quantity')
          .set(resetQuantities);

      setState(() {
        itemQuantities.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Remaining stock data was successfully refreshed and archived')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to refresh remaining stock data')),
      );
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
                              final itemId = doc.id;
                              final quantity = _getQuantity(itemId);
                              final stockColor = getStockColor(quantity);

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: stockColor,
                                    width: 2,
                                  ),
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              if (data['label']?.isNotEmpty ==
                                                  true)
                                                Text(
                                                  data['label'],
                                                  style: blueTextStyle.copyWith(
                                                      fontSize: 15),
                                                ),
                                              if (data['label']?.isNotEmpty ==
                                                      true &&
                                                  data['title2']?.isNotEmpty ==
                                                      true)
                                                const SizedBox(width: 3),
                                              if (data['title2']?.isNotEmpty ==
                                                  true)
                                                Text(
                                                  data['title2'],
                                                  style: blueTextStyle.copyWith(
                                                      fontSize: 14),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: stockColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                      color: stockColor,
                                                      width: 1),
                                                ),
                                                child: Text(
                                                  getStockStatus(quantity),
                                                  style: TextStyle(
                                                    color: stockColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          width: 50,
                                          decoration: BoxDecoration(
                                            color: stockColor.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: stockColor, width: 1),
                                          ),
                                          child: TextField(
                                            controller: _getController(itemId),
                                            textAlign: TextAlign.center,
                                            readOnly: true,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 8),
                                              isDense: true,
                                            ),
                                            style: TextStyle(
                                              color: stockColor,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
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