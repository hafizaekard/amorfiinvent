import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/skeleton/skeleton_input_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InputIngredientPage extends StatefulWidget {
  const InputIngredientPage({super.key});

  @override
  State<InputIngredientPage> createState() => _InputIngredientPageState();
}

class _InputIngredientPageState extends State<InputIngredientPage> {
  final Map<String, TextEditingController> _controllers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, int> itemQuantities = {};
  String _searchQuery = '';

  Stream<QuerySnapshot> get items {
    return _firestore
        .collection('ingredients_management')
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
    _scrollController.dispose();
    _searchController.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
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
      final title = (data['title'] as String? ?? '').toLowerCase();
      final values = data['values'] as List<dynamic>? ?? [];

      if (title.contains(_searchQuery)) {
        return true;
      }

      for (var value in values) {
        if (value.toString().toLowerCase().contains(_searchQuery)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  Future<void> _loadQuantities() async {
    var quantitiesDoc = await _firestore
        .collection('ingredient_quantities')
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

  Future<void> _saveQuantities() async {
    await _firestore.collection('ingredient_quantities').doc('current').set(
          itemQuantities.map((key, value) => MapEntry(key, value)),
          SetOptions(merge: true),
        );
  }

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
        actions: [const Padding(padding: EdgeInsets.only(right: 30))],
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
                'Input Ingredient',
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
                    itemBuilder: (context, index) {
                      return const SkeletonItemPage();
                    },
                  ),
                ),
              ],
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
                        hintText: 'Search for ingredient...',
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
                                  'No ingredients match your search',
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
                            controller: _scrollController,
                            children:
                                filteredDocs.map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              List<dynamic> values = data['values'] ?? [];

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
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 50,
                                            color: greyColor.withOpacity(0.3),
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: greyColor,
                                              size: 24,
                                            ),
                                          );
                                        },
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
                                          if (values.isNotEmpty) ...[
                                            const SizedBox(height: 5),
                                            Wrap(
                                              spacing: 8,
                                              children: values
                                                  .map((value) => Text(
                                                        value.toString(),
                                                        style: blueTextStyle
                                                            .copyWith(
                                                          fontSize: 14,
                                                          fontWeight: normal,
                                                        ),
                                                      ))
                                                  .toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () =>
                                              _decreaseQuantity(document.id),
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
                                            controller:
                                                _getController(document.id),
                                            textAlign: TextAlign.center,
                                            onSubmitted: (value) {
                                              _updateQuantityFromInput(
                                                  document.id, value);
                                            },
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 8),
                                              isDense: true,
                                            ),
                                            keyboardType: TextInputType.number,
                                            onChanged: (value) {
                                              if (value.isEmpty) return;
                                              if (int.tryParse(value) == null)
                                                return;
                                            },
                                            style: blackTextStyle.copyWith(
                                              fontSize: 16,
                                              fontWeight: bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () =>
                                              _increaseQuantity(document.id),
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
