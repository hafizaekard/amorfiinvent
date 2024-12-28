import 'dart:developer';

import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/pages/input_item.dart';
import 'package:amorfiapp/pages/item_management.dart';
import 'package:amorfiapp/pages/order_data.dart';
import 'package:amorfiapp/pages/production_archive_management.dart';
import 'package:amorfiapp/pages/remaining_stock.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/production_app_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  State<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToInputItemPage() {
    _navigateToPage(const InputItemPage());
  }

  void _navigateToOrderDataPage() {
    _navigateToPage(const OrderDataPage());
  }

  void _navigateToRemainingStockPage() {
    _navigateToPage(const RemainingStockPage());
  }

  // Updated to pass the currentPage parameter
  void _navigateToProductionArchiveManagementPage(String currentPage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductionArchiveManagementPage(currentPage: currentPage),
      ),
    );
  }

  void _navigateToItemManagementPage() {
    _navigateToPage(const ItemManagementPage());
  }

  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('input_item').snapshots();

  Stream<QuerySnapshot> get topProductsStream => FirebaseFirestore.instance
      .collection("input_item")
      .orderBy('quantity', descending: true)
      .limit(6)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: newBlueColor,
        automaticallyImplyLeading: false,
        titleSpacing: 35,
        title: Row(
          children: [
            Builder(
              builder: (BuildContext context) {
                return InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: blueColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu_rounded,
                        color: whiteColor,
                        size: 25,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 15),
            Text(
              'Ámorfi Invent',
              style: headerTextStyle.copyWith(
                fontSize: 30,
                fontWeight: semiBold,
              ),
            ),
          ],
        ),
      ),
      drawer: const ProductionAppDrawer(),
      backgroundColor: lightGreyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      ...List.generate(5, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              width: 230,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: blackColor.withOpacity(0.2),
                                    blurRadius: 3,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Determine which page to navigate to
                                  if (index == 0) {
                                    _navigateToInputItemPage();
                                  } else if (index == 1) {
                                    _navigateToOrderDataPage();
                                  } else if (index == 2) {
                                    _navigateToRemainingStockPage();
                                  } else if (index == 3) {
                                    _navigateToItemManagementPage();
                                  } else if (index == 4) {
                                    // Pass 'Production Archive' as the current page
                                    _navigateToProductionArchiveManagementPage(
                                        'Production Archive');
                                  }
                                },
                                highlightColor: transparentColor,
                                splashColor: transparentColor,
                                child: FutureBuilder<String>(
                                  future: FirestoreHelper().getImage(
                                    index == 0
                                        ? 'input_item'
                                        : index == 1
                                            ? 'order_data'
                                            : index == 2
                                                ? 'remaining_stock'
                                                : index == 3
                                                    ? 'item_management'
                                                    : 'archive_management',
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    }
                                    if (!snapshot.hasData) {
                                      return const Center(
                                          child: Text('No image'));
                                    }
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, bottom: 20),
                    width: 250,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Menyelaraskan teks statis di kiri
                        children: [
                          // Tambahkan teks statis di sini
                          Text('The top produced product today',
                              textAlign: TextAlign.center,
                              style: blackTextStyle.copyWith(
                                  fontSize: 18, fontWeight: semiBold)),
                          const SizedBox(height: 10),
                          StreamBuilder<QuerySnapshot>(
                            stream: topProductsStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }
                      
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                      
                              return Column(
                                children: snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data()! as Map<String, dynamic>;
                                  return ListTile(
                                    title: Text(data['title'],
                                        style: blackTextStyle.copyWith(
                                            fontSize: 16)),
                                    subtitle: Text('${data['quantity']} produced',
                                        style: blackTextStyle.copyWith(
                                            fontSize: 16)),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: StreamBuilder(
                            stream: _usersStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Something went wrong');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Text("Loading");
                              }

                              return SizedBox(
                                width:
                                    800, // Atur lebar maksimum grafik di sini
                                child: SfCartesianChart(
                                  // Initialize category axis
                                  primaryXAxis: CategoryAxis(
                                    arrangeByIndex: true,
                                    axisLine: AxisLine(width: 0),
                                    name: 'Quantity',
                                  ),
                                  series: [
                                    LineSeries(
                                      // Bind data source
                                      dataSource: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        final data = document.data()!
                                            as Map<String, dynamic>;
                                        log(data['quantity']
                                            .runtimeType
                                            .toString());
                                        return {
                                          'quantity': data['quantity'],
                                          'title': data['title'],
                                        };
                                      }).toList(),
                                      xValueMapper: (sales, _) =>
                                          sales['title'],
                                      yValueMapper: (sales, _) =>
                                          sales['quantity'],
                                      // Enable data label
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        borderColor: orangeColor,
                                        borderWidth: 2,
                                        color: orangeColor,
                                      ),
                                      color: blueColor,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
