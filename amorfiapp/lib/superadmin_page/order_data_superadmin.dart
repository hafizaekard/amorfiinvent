import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/print_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDataSuperadmin extends StatefulWidget {
  const OrderDataSuperadmin({super.key});

  @override
  State<OrderDataSuperadmin> createState() => _OrderDataSuperadminState();
}

class _OrderDataSuperadminState extends State<OrderDataSuperadmin> {
  final FirestoreHelper firestoreHelper = FirestoreHelper();

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
      return 'Tanggal Tidak Valid';
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
      return 'Tanggal Tidak Valid';
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
      return const Text('Tidak ada pesanan',
          style: TextStyle(fontStyle: FontStyle.italic));
    }

    List<Widget> itemWidgets = [];

    for (int i = 0; i < orderItems.length; i++) {
      String item = orderItems[i]?.toString() ?? 'Item tidak valid';
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
            const SizedBox(width: 10),
            PrintButton(borderRadius: BorderRadius.circular(8)),
            const SizedBox(width: 10),
            const Padding(padding: EdgeInsets.only(right: 20)),
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
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
