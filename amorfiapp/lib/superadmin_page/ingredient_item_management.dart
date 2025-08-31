import 'package:amorfiapp/pages/add_ingredient_page.dart';
import 'package:amorfiapp/pages/edit_ingredient_page.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/edit_button.dart';
import 'package:amorfiapp/widgets/select_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IngredientItemManagement extends StatefulWidget {
  const IngredientItemManagement({super.key});

  @override
  State<IngredientItemManagement> createState() =>
      _IngredientItemManagementState();
}

class _IngredientItemManagementState extends State<IngredientItemManagement> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  bool isSelectMode = false;
  String? selectedIngredientId;
  String _searchQuery = '';

  Stream<QuerySnapshot> get items {
    return _firestore
        .collection('ingredients_management')
        .orderBy('title', descending: false)
        .snapshots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToAddIngredientPage() {
    _navigateToPage(const AddIngredientPage());
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

  Future<void> _deleteItem(String ingredientId) async {
    try {
      await _firestore
          .collection('ingredients_management')
          .doc(ingredientId)
          .delete();
      print("Deleted from ingredients_management: $ingredientId");

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

  void _showEditDeleteDialog(String ingredientId) {
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

                DocumentSnapshot doc = await _firestore
                    .collection('ingredients_management')
                    .doc(ingredientId)
                    .get();

                if (mounted && doc.exists) {
                  Map<String, dynamic> ingredientData =
                      doc.data() as Map<String, dynamic>;
                  _navigateToPage(EditIngredientPage(
                    ingredientId: ingredientId,
                    ingredientData: ingredientData,
                  ));
                }
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(ingredientId);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  isSelectMode = false;
                  selectedIngredientId = null;
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
          selectedIngredientId = null;
        });
      }
    });
  }

  void _handleCircleAvatarTap(String ingredientId) {
    setState(() {
      selectedIngredientId =
          selectedIngredientId == ingredientId ? null : ingredientId;
    });
    _showEditDeleteDialog(ingredientId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIngredientId = null;
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
              onPressed: _navigateToAddIngredientPage,
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
                  selectedIngredientId = null;
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
                  'Ingredient Item Management',
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
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
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
                              children:
                                  filteredDocs.map((DocumentSnapshot document) {
                                String ingredientId = document.id;
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
                                      if (isSelectMode)
                                        GestureDetector(
                                          onTap: () {
                                            _handleCircleAvatarTap(
                                                ingredientId);
                                          },
                                          child: CircleAvatar(
                                            backgroundColor:
                                                selectedIngredientId ==
                                                        ingredientId
                                                    ? blueColor
                                                    : beigeColor,
                                            radius: 10,
                                            child: selectedIngredientId ==
                                                    ingredientId
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
