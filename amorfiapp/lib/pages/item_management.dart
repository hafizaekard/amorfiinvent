import 'package:amorfiapp/pages/add_item_page.dart';
import 'package:amorfiapp/pages/edit_item_page.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/edit_button.dart';
import 'package:amorfiapp/widgets/select_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemManagementPage extends StatefulWidget {
  const ItemManagementPage({super.key});

  @override
  State<ItemManagementPage> createState() => _ItemManagementPageState();
}

class _ItemManagementPageState extends State<ItemManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isSelectMode = false;
  String? selectedItemId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Stream<QuerySnapshot> get items {
    return _firestore
        .collection('input_item')
        .orderBy('title', descending: false)
        .snapshots();
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToAddItemPage() {
    _navigateToPage(const AddItemPage());
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await _firestore.collection('input_item').doc(itemId).delete();
      print("Deleted from input_item: $itemId");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item successfully deleted')),
      );
    } catch (e) {
      print("Error deleting item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete item: $e")),
      );
    }
  }

  void _showEditDeleteDialog(String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit or Delete'),
          content: const Text('Choose an action for this item.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                DocumentSnapshot doc =
                    await _firestore.collection('input_item').doc(itemId).get();

                if (mounted && doc.exists) {
                  Map<String, dynamic> itemData =
                      doc.data() as Map<String, dynamic>;
                  _navigateToPage(EditItemPage(
                    itemId: itemId,
                    itemData: itemData,
                  ));
                }
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(itemId);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isSelectMode = false;
                  selectedItemId = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ).then((_) {
      if (isSelectMode) {
        setState(() {
          isSelectMode = false;
          selectedItemId = null;
        });
      }
    });
  }

  void _handleCircleAvatarTap(String itemId) {
    setState(() {
      selectedItemId = selectedItemId == itemId ? null : itemId;
    });
    _showEditDeleteDialog(itemId);
  }

  List<DocumentSnapshot> _filterItems(List<DocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) {
      return docs;
    }

    return docs.where((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String title = data['title']?.toString().toLowerCase() ?? '';
      String label = data['label']?.toString().toLowerCase() ?? '';
      String title2 = data['title2']?.toString().toLowerCase() ?? '';

      String searchLower = _searchQuery.toLowerCase();

      return title.contains(searchLower) ||
          label.contains(searchLower) ||
          title2.contains(searchLower);
    }).toList();
  }

  Widget _buildSearchBar() {
    return Container(
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
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search for item...',
          hintStyle: TextStyle(color: greyColor, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: greyColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: greyColor),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: blackTextStyle.copyWith(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItemId = null;
          isSelectMode = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: newBlueColor,
          shape: Border(bottom: BorderSide(color: blueColor.withOpacity(0.2))),
          automaticallyImplyLeading: false,
          titleSpacing: 15,
          actions: [
            EditButton(
              onPressed: _navigateToAddItemPage,
              label: 'Add Item',
              width: 90,
            ),
            const SizedBox(width: 10),
            SelectButton(
              label: isSelectMode ? 'Done' : 'Select',
              isSelected: isSelectMode,
              onPressed: () {
                setState(() {
                  isSelectMode = !isSelectMode;
                  selectedItemId = null;
                });
              },
              width: 70,
            ),
            const Padding(padding: EdgeInsets.only(right: 30)),
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
                  'Item Management',
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
              return const Center(child: CircularProgressIndicator());
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
                    _buildSearchBar(),
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
                              children:
                                  filteredDocs.map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                String itemId = document.id;

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
                                                    data['label'] == '-'
                                                        ? ''
                                                        : data['label'],
                                                    style:
                                                        blueTextStyle.copyWith(
                                                      fontSize: 15,
                                                      fontWeight: normal,
                                                    ),
                                                  ),
                                                if (data['label']?.isNotEmpty ==
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
                                                    style:
                                                        blueTextStyle.copyWith(
                                                      fontSize: 14,
                                                      fontWeight: normal,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            if (data['price'] != null)
                                              Text(
                                                'Rp${NumberFormat.decimalPattern('id').format(data['price'])}',
                                                style: orangeTextStyle.copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (isSelectMode)
                                        GestureDetector(
                                          onTap: () {
                                            _handleCircleAvatarTap(itemId);
                                          },
                                          child: CircleAvatar(
                                            backgroundColor:
                                                selectedItemId == itemId
                                                    ? blueColor
                                                    : beigeColor,
                                            radius: 10,
                                            child: selectedItemId == itemId
                                                ? const Icon(Icons.check,
                                                    color: Colors.white,
                                                    size: 15)
                                                : null,
                                          ),
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
      ),
    );
  }
}
