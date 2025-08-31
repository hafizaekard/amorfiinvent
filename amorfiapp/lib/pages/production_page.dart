import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/helper/notification_helper.dart';
import 'package:amorfiapp/pages/input_item.dart';
import 'package:amorfiapp/pages/item_management.dart';
import 'package:amorfiapp/pages/order_data.dart';
import 'package:amorfiapp/pages/order_notification.dart';
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
  StreamSubscription<DocumentSnapshot>? _notificationSubscription;
  
  // Filter variables
  String _selectedPeriod = 'Today';
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _setupNotificationListener() {
    _notificationSubscription = FirebaseFirestore.instance
        .collection("notification")
        .doc("notification")
        .snapshots()
        .listen((event) async {
      final data = event.data();

      if (data != null &&
          data['title'] != null &&
          data['body'] != null &&
          data['title'] != '' &&
          data['body'] != '') {
        final status = data['status'] ?? '';

        if (status == '' || status == 'pending') {
          NotificationHelper.instance.showNotification(
            id: Random().nextInt(1000),
            title: data['title'],
            body: data['body'],
            payload: 'notification_order_page',
          );

          _showInAppNotificationDialog(data['title'], data['body']);

          await FirebaseFirestore.instance
              .collection("notification")
              .doc("notification")
              .delete();
        }
      }
    });

    NotificationHelper.instance.setNotificationTapHandler((payload) {
      if (payload == 'notification_order_page') {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const NotificationOrderPage(),
            ),
          );
        }
      }
    });
  }

  void _showInAppNotificationDialog(String title, String body) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notifications, color: orangeColor),
              const SizedBox(width: 8),
              const Text('Notifikasi Baru'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(body),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NotificationOrderPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
              ),
              child: Text('Lihat Pesanan', style: TextStyle(color: whiteColor)),
            ),
          ],
        );
      },
    );
  }

  // Method to get date range based on selected period
  Map<String, DateTime?> _getDateRange() {
    DateTime now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (_selectedPeriod) {
      case 'Today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'This Week':
        int weekday = now.weekday;
        startDate = now.subtract(Duration(days: weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'This Month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Custom':
        startDate = _customStartDate ?? DateTime(now.year, now.month, 1);
        endDate = _customEndDate ?? now;
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    }

    return {'start': startDate, 'end': endDate};
  }

  // Method to show custom date picker
  Future<void> _showCustomDatePicker() async {
    DateTime now = DateTime.now();
    
    // Show start date picker
    DateTime? startDate = await showDatePicker(
      context: context,
      initialDate: _customStartDate ?? now.subtract(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: now,
      helpText: 'Select Start Date',
    );

    if (startDate != null) {
      // Show end date picker
      DateTime? endDate = await showDatePicker(
        context: context,
        initialDate: _customEndDate ?? now,
        firstDate: startDate,
        lastDate: now,
        helpText: 'Select End Date',
      );

      if (endDate != null) {
        setState(() {
          _customStartDate = startDate;
          _customEndDate = endDate;
          _selectedPeriod = 'Custom';
        });
      }
    }
  }

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

  // Updated stream to include date filtering - using client-side filtering
  Stream<List<Map<String, dynamic>>> get filteredProductsStream {
    return FirebaseFirestore.instance
        .collection("input_item")
        .snapshots()
        .map((snapshot) {
      Map<String, DateTime?> dateRange = _getDateRange();
      DateTime startDate = dateRange['start']!;
      DateTime endDate = dateRange['end']!;

      return snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .where((data) {
            // Check if created_at exists and is within date range
            final createdAt = data['created_at'];
            if (createdAt != null && createdAt is Timestamp) {
              final docDate = createdAt.toDate();
              return docDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                     docDate.isBefore(endDate.add(const Duration(days: 1)));
            }
            // If no created_at field, include in "Today" filter only
            return _selectedPeriod == 'Today';
          })
          .toList();
    });
  }

  // Updated stream for top products with filtering
  Stream<List<Map<String, dynamic>>> get topProductsStream {
    return filteredProductsStream;
  }

  // Method to process and aggregate data by product title
  List<Map<String, dynamic>> _processProductData(List<Map<String, dynamic>> docs) {
    Map<String, int> productTotals = {};
    
    for (var data in docs) {
      String title = data['title'] ?? 'Unknown';
      int quantity = data['quantity'] ?? 0;
      
      productTotals[title] = (productTotals[title] ?? 0) + quantity;
    }
    
    // Convert to list and sort by quantity
    List<Map<String, dynamic>> products = productTotals.entries
        .map((entry) => {'title': entry.key, 'quantity': entry.value})
        .toList();
    
    products.sort((a, b) => b['quantity'].compareTo(a['quantity']));
    
    return products;
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: blueColor),
            iconSize: 25,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NotificationOrderPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 15),
        ],
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
                                  if (index == 0) {
                                    _navigateToInputItemPage();
                                  } else if (index == 1) {
                                    _navigateToOrderDataPage();
                                  } else if (index == 2) {
                                    _navigateToRemainingStockPage();
                                  } else if (index == 3) {
                                    _navigateToItemManagementPage();
                                  } else if (index == 4) {
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
                    margin: const EdgeInsets.only(left: 20, bottom: 20),
                    width: 280,
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Top Produced Products',
                            textAlign: TextAlign.center,
                            style: blackTextStyle.copyWith(
                              fontSize: 18, 
                              fontWeight: semiBold
                            )
                          ),
                          const SizedBox(height: 15),
                          
                          // Period Filter Dropdown
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPeriod,
                                isExpanded: true,
                                items: ['Today', 'This Week', 'This Month', 'Custom']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: blackTextStyle.copyWith(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) async {
                                  if (newValue == 'Custom') {
                                    await _showCustomDatePicker();
                                  } else {
                                    setState(() {
                                      _selectedPeriod = newValue!;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          
                          // Display custom date range if selected
                          if (_selectedPeriod == 'Custom' && _customStartDate != null && _customEndDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '${_customStartDate!.day}/${_customStartDate!.month}/${_customStartDate!.year} - ${_customEndDate!.day}/${_customEndDate!.month}/${_customEndDate!.year}',
                                style: blackTextStyle.copyWith(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ),
                          
                          const SizedBox(height: 15),
                          
                          StreamBuilder<List<Map<String, dynamic>>>(
                            stream: topProductsStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return const Text('Something went wrong');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }

                              List<Map<String, dynamic>> products = _processProductData(snapshot.data ?? []);
                              List<Map<String, dynamic>> topProducts = products.take(6).toList();

                              if (topProducts.isEmpty) {
                                return Text(
                                  'No data available for selected period',
                                  style: blackTextStyle.copyWith(fontSize: 14),
                                );
                              }

                              return Column(
                                children: topProducts.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  Map<String, dynamic> product = entry.value;
                                  
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: index == 0 ? const Color(0xFFFFD700) : 
                                                   index == 1 ? Colors.grey.shade400 : 
                                                   index == 2 ? const Color(0xFFCD7F32) : blueColor,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product['title'] ?? 'Unknown',
                                                style: blackTextStyle.copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${product['quantity'] ?? 0} produced',
                                                style: blackTextStyle.copyWith(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Production Chart - $_selectedPeriod',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 18,
                                    fontWeight: semiBold,
                                  ),
                                ),
                                if (_selectedPeriod == 'Custom' && _customStartDate != null && _customEndDate != null)
                                  Text(
                                    '${_customStartDate!.day}/${_customStartDate!.month} - ${_customEndDate!.day}/${_customEndDate!.month}',
                                    style: blackTextStyle.copyWith(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: StreamBuilder<List<Map<String, dynamic>>>(
                                  stream: filteredProductsStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return const Text('Something went wrong');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text("Loading");
                                    }

                                    List<Map<String, dynamic>> chartData = _processProductData(snapshot.data ?? []);

                                    if (chartData.isEmpty) {
                                      return Center(
                                        child: Text(
                                          'No data available for selected period',
                                          style: blackTextStyle.copyWith(fontSize: 16),
                                        ),
                                      );
                                    }

                                    return SizedBox(
                                      width: math.max(800, chartData.length * 80.0),
                                      child: SfCartesianChart(
                                        primaryXAxis: const CategoryAxis(
                                          arrangeByIndex: true,
                                          axisLine: AxisLine(width: 0),
                                          name: 'Products',
                                          labelRotation: -45,
                                        ),
                                        primaryYAxis: const NumericAxis(
                                          name: 'Quantity',
                                        ),
                                        tooltipBehavior: TooltipBehavior(enable: true),
                                        series: [
                                          LineSeries(
                                            dataSource: chartData,
                                            xValueMapper: (data, _) => data['title'],
                                            yValueMapper: (data, _) => data['quantity'],
                                            name: 'Production Quantity',
                                            markerSettings: MarkerSettings(
                                              isVisible: true,
                                              shape: DataMarkerType.circle,
                                              borderColor: orangeColor,
                                              borderWidth: 2,
                                              color: orangeColor,
                                            ),
                                            color: blueColor,
                                            width: 3,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
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