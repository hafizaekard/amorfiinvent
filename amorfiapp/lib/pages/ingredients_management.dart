import 'package:amorfiapp/pages/add_ingredient_page.dart';
import 'package:amorfiapp/pages/edit_ingredient_page.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/edit_button.dart';
import 'package:amorfiapp/widgets/select_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IngredientsManagementPage extends StatefulWidget {
  const IngredientsManagementPage({super.key});

  @override
  State<IngredientsManagementPage> createState() => _IngredientsManagementPageState();
}

class _IngredientsManagementPageState extends State<IngredientsManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isSelectMode = false;
  String? selectedIngredientId;

  Stream<QuerySnapshot> get items {
    return _firestore
        .collection('ingredients_management')
        .orderBy('title', descending: false)
        .snapshots();
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToAddIngredientPage() {
    _navigateToPage(const AddIngredientPage());
  }

  Future<void> _deleteItem(String ingredientId) async {
    try {
      // Hapus item dari "input_item"
      await _firestore.collection('ingredients_management').doc(ingredientId).delete();
      print("Deleted from ingredients_management: $ingredientId"); // Debug print

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item successfully deleted')),
      );
    } catch (e) {
      // Tampilkan pesan kesalahan
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
              Navigator.pop(context); // Close the dialog
              
              // Get the item data from Firestore
              DocumentSnapshot doc = await _firestore
                  .collection('ingredients_management')
                  .doc(ingredientId)
                  .get();
              
              if (mounted && doc.exists) {
                Map<String, dynamic> ingredientData = doc.data() as Map<String, dynamic>;
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
      selectedIngredientId = selectedIngredientId == ingredientId ? null : ingredientId;
    });
    _showEditDeleteDialog(ingredientId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Reset the selected item when tapping outside the CircleAvatar
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

            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                child: ListView(
                  children: sortedDocs.map((DocumentSnapshot document) {
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
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                              style: blueTextStyle.copyWith(
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
                                _handleCircleAvatarTap(ingredientId);
                              },
                              child: CircleAvatar(
                                backgroundColor: selectedIngredientId == ingredientId
                                    ? blueColor
                                    : beigeColor,
                                radius: 10,
                                child: selectedIngredientId == ingredientId
                                    ? const Icon(Icons.check,
                                        color: Colors.white, size: 15)
                                    : null,
                              ),
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
      ),
    );
  }
}
