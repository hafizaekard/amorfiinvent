import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/print_button.dart';
import 'package:amorfiapp/widgets/skeleton/skeleton_input_item.dart';
import 'package:amorfiapp/widgets/update_data_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockMonitoringPage extends StatefulWidget {
  const StockMonitoringPage({super.key});

  @override
  State<StockMonitoringPage> createState() => _StockMonitoringPageState();
}

class _StockMonitoringPageState extends State<StockMonitoringPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Stream<QuerySnapshot> get items {
    return _firestore
        .collection('ingredients_management')
        .orderBy('title', descending: false)
        .snapshots();
  }


  Stream<DocumentSnapshot> get inputQuantitiesStream {
    return _firestore
        .collection('ingredient_quantities')
        .doc('current')
        .snapshots();
  }


  Stream<DocumentSnapshot> get outputQuantitiesStream {
    return _firestore
        .collection('output_ingredient_quantities')
        .doc('current')
        .snapshots();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }


  Future<void> _saveToArchive() async {
    try {

      final itemsSnapshot = await _firestore
          .collection('ingredients_management')
          .orderBy('title', descending: false)
          .get();

      final inputSnapshot = await _firestore
          .collection('ingredient_quantities')
          .doc('current')
          .get();

      final outputSnapshot = await _firestore
          .collection('output_ingredient_quantities')
          .doc('current')
          .get();


      Map<String, dynamic> inputData = {};
      Map<String, dynamic> outputData = {};

      if (inputSnapshot.exists) {
        inputData = inputSnapshot.data() as Map<String, dynamic>;
      }

      if (outputSnapshot.exists) {
        outputData = outputSnapshot.data() as Map<String, dynamic>;
      }


      List<Map<String, dynamic>> archiveItems = [];

      for (var doc in itemsSnapshot.docs) {
        Map<String, dynamic> data = doc.data();
        

        int monitoringStock = calculateMonitoringStock(
          doc.id, 
          inputData, 
          outputData
        );


        Map<String, dynamic> archiveItem = {
          'id': doc.id,
          'title': data['title'] ?? 'Unknown Item',
          'image': data['image'] ?? '',
          'values': data['values'] ?? [],
          'input_quantity': inputData[doc.id] ?? 0,
          'output_quantity': outputData[doc.id] ?? 0,
          'monitoring_stock': monitoringStock,
          'quantity': monitoringStock, // untuk konsistensi dengan format archive
        };

        archiveItems.add(archiveItem);
      }


      await _firestore.collection('archive_ingredients').add({
        'source': 'stock_monitoring',
        'timestamp': FieldValue.serverTimestamp(),
        'items': archiveItems,
        'total_items': archiveItems.length,
      });


      await _firestore
          .collection('ingredient_quantities')
          .doc('current')
          .set({});

      await _firestore
          .collection('output_ingredient_quantities')
          .doc('current')
          .set({});

    } catch (e) {
      throw Exception('Failed to save archive data: $e');
    }
  }


  Future<void> refreshData() async {
    try {
     
      await _saveToArchive();
      

      await Future.delayed(const Duration(milliseconds: 500));
      

      if (mounted) {
        setState(() {});
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Stock data was successfully refreshed and archived'),
            backgroundColor: blackColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refresh data: $e'),
            backgroundColor: redColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  int calculateMonitoringStock(String ingredientId, 
      Map<String, dynamic> inputData, 
      Map<String, dynamic> outputData) {
    
    int inputQuantity = 0;
    int outputQuantity = 0;

    if (inputData.containsKey(ingredientId)) {
      inputQuantity = inputData[ingredientId] is int ? 
          inputData[ingredientId] as int : 0;
    }

    
    if (outputData.containsKey(ingredientId)) {
      outputQuantity = outputData[ingredientId] is int ? 
          outputData[ingredientId] as int : 0;
    }

    int monitoringStock = inputQuantity - outputQuantity;
    
    return monitoringStock < 0 ? 0 : monitoringStock;
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


  TextEditingController _getController(int monitoringStock) {
    return TextEditingController(text: monitoringStock.toString());
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
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
                'Stock Monitoring',
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
              child: StreamBuilder<DocumentSnapshot>(
                stream: inputQuantitiesStream,
                builder: (context, inputSnapshot) {
                  return StreamBuilder<DocumentSnapshot>(
                    stream: outputQuantitiesStream,
                    builder: (context, outputSnapshot) {
                      Map<String, dynamic> inputData = {};
                      Map<String, dynamic> outputData = {};

                      if (inputSnapshot.hasData && inputSnapshot.data!.exists) {
                        inputData = inputSnapshot.data!.data() as Map<String, dynamic>;
                      }

                      if (outputSnapshot.hasData && outputSnapshot.data!.exists) {
                        outputData = outputSnapshot.data!.data() as Map<String, dynamic>;
                      }

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
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                                    children: filteredDocs.map((DocumentSnapshot document) {
                                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                                      List<dynamic> values = data['values'] ?? [];
                                      

                                      int monitoringStock = calculateMonitoringStock(
                                        document.id, 
                                        inputData, 
                                        outputData
                                      );
                                      
                                      final stockColor = getStockColor(monitoringStock);

                                      return Container(
                                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                                                errorBuilder: (context, error, stackTrace) {
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
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data['title'] ?? 'Unknown Item',
                                                    style: blackTextStyle.copyWith(
                                                      fontSize: 16,
                                                      fontWeight: bold,
                                                    ),
                                                  ),
                                                  if (values.isNotEmpty) ...[
                                                    const SizedBox(height: 5),
                                                    Wrap(
                                                      spacing: 8,
                                                      children: values.map((value) => Text(
                                                        value.toString(),
                                                        style: blueTextStyle.copyWith(
                                                          fontSize: 14,
                                                          fontWeight: normal,
                                                        ),
                                                      )).toList(),
                                                    ),
                                                  ],
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Input: ${inputData[document.id] ?? 0}',
                                                        style: blackTextStyle.copyWith(
                                                          fontSize: 12,
                                                          fontWeight: normal,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      Text(
                                                        'Output: ${outputData[document.id] ?? 0}',
                                                        style: blackTextStyle.copyWith(
                                                          fontSize: 12,
                                                          fontWeight: normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),

                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: stockColor.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: stockColor, width: 1),
                                                    ),
                                                    child: Text(
                                                      getStockStatus(monitoringStock),
                                                      style: TextStyle(
                                                        color: stockColor,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Container(
                                              width: 50,
                                              decoration: BoxDecoration(
                                                color: stockColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: stockColor, width: 1),
                                              ),
                                              child: TextField(
                                                controller: _getController(monitoringStock),
                                                textAlign: TextAlign.center,
                                                readOnly: true,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                                  isDense: true,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 16, 
                                                  fontWeight: FontWeight.bold,
                                                  color: stockColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}