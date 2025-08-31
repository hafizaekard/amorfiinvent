import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/pages/add_order_data.dart';
import 'package:amorfiapp/pages/edit_order_data.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/edit_button.dart';
import 'package:amorfiapp/widgets/print_button.dart';
import 'package:amorfiapp/widgets/select_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDataPage extends StatefulWidget {
  const OrderDataPage({super.key});

  @override
  State<OrderDataPage> createState() => _OrderDataPageState();
}

class _OrderDataPageState extends State<OrderDataPage> {
  final FirestoreHelper firestoreHelper = FirestoreHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> orderData = [];
  bool isSelectMode = false;
  String? selectedItemId;

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  void _fetchOrderData() async {
    final fetchedOrders = await firestoreHelper.getOrderData();

    fetchedOrders.sort((a, b) {
      DateTime dateA = _parseDate(a['pickupDate']);
      DateTime dateB = _parseDate(b['pickupDate']);
      return dateA.compareTo(dateB);
    });

    setState(() {
      orderData = fetchedOrders;
    });
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();

    if (date is Timestamp) {
      return date.toDate();
    }

    if (date is String) {
      if (date.isEmpty) return DateTime.now();

      try {
        List<String> formats = [
          'yyyy-MM-dd HH:mm:ss',
          'yyyy-MM-dd',
          'dd/MM/yyyy',
          'dd-MM-yyyy',
          'yyyy/MM/dd',
          'MM/dd/yyyy',
          'dd MMM yyyy',
          'dd MMMM yyyy',
        ];

        for (String format in formats) {
          try {
            return DateFormat(format).parse(date);
          } catch (_) {
            continue;
          }
        }

        return DateTime.parse(date);
      } catch (e) {
        print('Error parsing date string: $date, Error: $e');
        return DateTime.now();
      }
    }

    if (date is DateTime) {
      return date;
    }

    if (date is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(date);
      } catch (e) {
        print('Error parsing timestamp: $date, Error: $e');
        return DateTime.now();
      }
    }

    print('Unknown date type: ${date.runtimeType}, Value: $date');
    return DateTime.now();
  }

  String formatPickupDate(dynamic date) {
    try {
      final parsed = _parseDate(date);

      final formatter = DateFormat('EEEE, dd MMMM yyyy');

      return formatter.format(parsed);
    } catch (e) {
      print('Error formatting date: $date, Error: $e');
      return 'Date is not valid';
    }
  }

  String formatPickupDateIndonesian(dynamic date) {
    try {
      final parsed = _parseDate(date);

      const dayNames = [
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu'
      ];

      const monthNames = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];

      String dayName = dayNames[parsed.weekday - 1];
      String monthName = monthNames[parsed.month - 1];

      return '$dayName, ${parsed.day} $monthName ${parsed.year}';
    } catch (e) {
      print('Error formatting Indonesian date: $date, Error: $e');
      return 'Date is not valid';
    }
  }

  String formatRupiah(dynamic amount) {
    try {
      if (amount == null) return 'Rp0';

      int value = 0;
      if (amount is int) {
        value = amount;
      } else if (amount is double) {
        value = amount.toInt();
      } else if (amount is String) {
        value = int.tryParse(amount.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      }

      final formatter = NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
      return formatter.format(value);
    } catch (e) {
      print('Error formatting currency: $amount, Error: $e');
      return 'Rp0';
    }
  }

  Widget _buildOrderItemsList(
      List<dynamic> orderItems, List<dynamic>? quantities) {
    if (orderItems.isEmpty) {
      return const Text('No order',
          style: TextStyle(fontStyle: FontStyle.italic));
    }

    List<Widget> itemWidgets = [];

    for (int i = 0; i < orderItems.length; i++) {
      String item = orderItems[i]?.toString() ?? 'Item is not valid';
      String quantity = '';

      if (quantities != null &&
          i < quantities.length &&
          quantities[i] != null) {
        quantity = '${quantities[i]}x ';
      }

      itemWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            '• $quantity$item',
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: itemWidgets,
    );
  }

  Future<void> _navigateToPage(Widget page) async {
    await Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToAddOrderDataPage() {
    Navigator.of(context).push(
      CustomPageRoute(
        page: AddOrderDataPage(
          onSave: _fetchOrderData,
        ),
      ),
    );
  }

  Future<void> _deleteItem(String orderId) async {
    try {
      await firestoreHelper.deleteOrderData(orderId);
      _fetchOrderData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
      }
    } catch (e) {
      print('Error deleting item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item failed to delete: $e')),
        );
      }
    }
  }

  void _showEditDeleteDialog(String orderDataId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit or Delete'),
          content: const Text('Select an action for this data'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  DocumentSnapshot doc = await _firestore
                      .collection('order_data')
                      .doc(orderDataId)
                      .get();
                  if (mounted && doc.exists) {
                    Map<String, dynamic> itemData =
                        doc.data() as Map<String, dynamic>;
                    await _navigateToPage(EditOrderDataPage(
                      itemId: orderDataId,
                      itemData: itemData,
                    ));
                    _fetchOrderData();
                  }
                } catch (e) {
                  print('Error fetching document for edit: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                _deleteItem(orderDataId);
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

  void _handleCircleAvatarTap(String orderId) {
    setState(() {
      selectedItemId = selectedItemId == orderId ? null : orderId;
    });
    _showEditDeleteDialog(orderId);
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
              onPressed: _navigateToAddOrderDataPage,
              label: 'Add Order Data',
              width: 140,
            ),
            const SizedBox(width: 10),
            PrintButton(borderRadius: BorderRadius.circular(8)),
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
              BackButtonCustom(onPressed: () => Navigator.pop(context)),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Order Data',
                  style: blueTextStyle.copyWith(
                      fontSize: 25, fontWeight: semiBold),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: lightGreyColor,
        body: orderData.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: orderData.length,
                itemBuilder: (context, index) {
                  final order = orderData[index];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text(
                              order['customerName']?.toString() ?? 'N/A',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                    'Nomor: ${order['customerNumber']?.toString() ?? 'N/A'}'),
                                const SizedBox(height: 4),
                                Text(
                                    'Alamat: ${order['customerAddress']?.toString() ?? 'N/A'}'),
                                const SizedBox(height: 4),
                                Text(
                                    'Pickup Date: ${formatPickupDateIndonesian(order['pickupDate'])}'),
                                const SizedBox(height: 8),
                                const Text(
                                  'Pesanan:',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                _buildOrderItemsList(
                                  order['orderItems'] as List? ?? [],
                                  order['orderQuantities'] as List?,
                                ),
                                if (order['orderNote'] != null &&
                                    order['orderNote']
                                        .toString()
                                        .trim()
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Catatan:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: whiteColor,
                                      border: Border.all(color: blackColor),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      order['orderNote'].toString(),
                                      style: blackTextStyle,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                    'Pembayaran: ${order['payment']?.toString() ?? 'N/A'}'),
                                const SizedBox(height: 4),
                                Text(
                                  'Total: ${formatRupiah(order['orderTotal'])}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        ),
                        if (isSelectMode)
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: () => _handleCircleAvatarTap(
                                  order['id']?.toString() ?? ''),
                              child: CircleAvatar(
                                backgroundColor: selectedItemId != order['id']
                                    ? beigeColor
                                    : blueColor,
                                radius: 10,
                                child: selectedItemId != order['id']
                                    ? null
                                    : const Icon(Icons.check,
                                        color: Colors.white, size: 15),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
