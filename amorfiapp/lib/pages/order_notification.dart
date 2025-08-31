import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/print_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationOrderPage extends StatefulWidget {
  const NotificationOrderPage({super.key});

  @override
  State<NotificationOrderPage> createState() => _NotificationOrderPageState();
}

class _NotificationOrderPageState extends State<NotificationOrderPage> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String selectedFilter =
      'today'; // today, this_week, this_month, last_month, custom

  @override
  void initState() {
    super.initState();
    _setInitialDateFilter();
  }

  void _setInitialDateFilter() {
    final now = DateTime.now();
    switch (selectedFilter) {
      case 'today':
        selectedStartDate = DateTime(now.year, now.month, now.day);
        selectedEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'this_week':
        selectedStartDate = now.subtract(Duration(days: now.weekday - 1));
        selectedStartDate = DateTime(selectedStartDate!.year,
            selectedStartDate!.month, selectedStartDate!.day);
        selectedEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'this_month':
        selectedStartDate = DateTime(now.year, now.month, 1);
        selectedEndDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'last_month':
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        selectedStartDate = lastMonth;
        selectedEndDate = DateTime(now.year, now.month, 0, 23, 59, 59);
        break;
    }
  }

  Stream<QuerySnapshot> _getFilteredStream() {
    Query query = FirebaseFirestore.instance.collection('order_notifications');

    if (selectedStartDate != null && selectedEndDate != null) {
      query = query
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(selectedStartDate!))
          .where('timestamp',
              isLessThanOrEqualTo: Timestamp.fromDate(selectedEndDate!));
    }

    return query.orderBy('timestamp', descending: true).snapshots();
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
          const SizedBox(width: 10),
          PrintButton(borderRadius: BorderRadius.circular(8)),
          const SizedBox(width: 10),
          const Padding(padding: EdgeInsets.only(right: 30)),
        ],
        title: Row(
          children: [
            BackButtonCustom(onPressed: () => Navigator.pop(context)),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Notification Order',
                style:
                    blueTextStyle.copyWith(fontSize: 25, fontWeight: semiBold),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              right: 16,
              top: 16,
              left: 16,
              bottom: 0,
            ),
            decoration: BoxDecoration(
              color: whiteColor,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter By Date:',
                  style: blackTextStyle.copyWith(
                      fontWeight: semiBold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip('Today', 'today'),
                    _buildFilterChip('This week', 'this_week'),
                    _buildFilterChip('This Month', 'this_month'),
                    _buildFilterChip('Last Month', 'last_month'),
                    _buildFilterChip('Custom', 'custom'),
                  ],
                ),
                if (selectedFilter == 'custom') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectStartDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  selectedStartDate != null
                                      ? DateFormat('dd/MM/yyyy')
                                          .format(selectedStartDate!)
                                      : 'Tanggal Mulai',
                                  style: selectedStartDate != null
                                      ? blackTextStyle
                                      : TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(' - '),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectEndDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  selectedEndDate != null
                                      ? DateFormat('dd/MM/yyyy')
                                          .format(selectedEndDate!)
                                      : 'Tanggal Akhir',
                                  style: selectedEndDate != null
                                      ? blackTextStyle
                                      : TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (selectedStartDate != null && selectedEndDate != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: newBlueColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: newBlueColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Menampilkan data dari ${DateFormat('dd/MM/yyyy').format(selectedStartDate!)} hingga ${DateFormat('dd/MM/yyyy').format(selectedEndDate!)}',
                            style: TextStyle(color: newBlueColor, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No order notifications for the selected period',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;

                    final customerName = data['customerName'] ?? '-';
                    final customerAddress = data['customerAddress'] ?? '-';
                    final customerNumber = data['customerNumber'] ?? '-';
                    final pickupDate = data['pickupDate'] ?? '-';
                    final totalPrice = data['totalPrice'] ?? 0;
                    final orderItems = List<Map<String, dynamic>>.from(
                        data['orderItems'] ?? []);
                    final proofImageUrl = data['proofImageUrl'];
                    final status = data['status'] ?? '';
                    final note = data['note'] ?? '';
                    final timestamp = data['timestamp'] as Timestamp?;

                    return Stack(
                      children: [
                        Card(
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (timestamp != null) ...[
                                  const SizedBox(height: 8),
                                ],
                                Text('Nama: $customerName',
                                    style: blackTextStyle.copyWith(
                                        fontWeight: semiBold)),
                                Text('Alamat: $customerAddress'),
                                Text('No HP: $customerNumber'),
                                Text('Tanggal Pengambilan: $pickupDate'),
                                Text('Total Harga: Rp$totalPrice'),
                                if (note.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text('Catatan: $note',
                                      style: redTextStyle.copyWith()),
                                ],
                                const Divider(),
                                const SizedBox(height: 6),
                                Text('Daftar Pesanan:',
                                    style: blackTextStyle.copyWith(
                                        fontWeight: semiBold)),
                                const SizedBox(height: 8),
                                ...orderItems.map((item) {
                                  final title =
                                      item['title'] ?? 'Tidak diketahui';
                                  final quantity = item['quantity'] ?? 0;
                                  final price = item['price'] ?? 0;
                                  final image = item['image'] ?? '';

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (image.isNotEmpty)
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              image,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        else
                                          const Icon(Icons.image_not_supported,
                                              size: 60),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(title,
                                                  style: blueTextStyle.copyWith(
                                                      fontWeight: semiBold)),
                                              Text('Jumlah: $quantity'),
                                              Text('Harga: Rp$price'),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }),
                                if (proofImageUrl != null &&
                                    proofImageUrl.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text('Bukti Transfer:',
                                      style: blackTextStyle.copyWith(
                                          fontWeight: semiBold)),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: InteractiveViewer(
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.network(
                                                proofImageUrl,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        proofImageUrl,
                                        fit: BoxFit.cover,
                                        width: 200,
                                        height: 150,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                if (status == '')
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => _updateStatus(
                                            context,
                                            docId,
                                            'rejected',
                                            orderItems,
                                            pickupDate),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: redColor,
                                        ),
                                        child: Text('Reject',
                                            style: whiteTextStyle),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () => _updateStatus(
                                            context,
                                            docId,
                                            'approved',
                                            orderItems,
                                            pickupDate),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: greenColor,
                                        ),
                                        child: Text('Approve',
                                            style: blackTextStyle),
                                      ),
                                    ],
                                  )
                                else
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          status == 'approved'
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: status == 'approved'
                                              ? greenColor
                                              : redColor,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          status == 'approved'
                                              ? 'Approved'
                                              : 'Rejected',
                                          style: TextStyle(
                                            color: status == 'approved'
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final confirm = await showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title:
                                              const Text("Delete Order data?"),
                                          content: const Text(
                                              "Are you sure you want to delete this order data?"),
                                          actions: [
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text("Cancel")),
                                            TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text("Delete")),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        await FirebaseFirestore.instance
                                            .collection('order_notifications')
                                            .doc(docId)
                                            .delete();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (status == 'approved' || status == 'rejected')
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  status == 'approved' ? greenColor : redColor,
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue) {
    final isSelected = selectedFilter == filterValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            selectedFilter = filterValue;
            _setInitialDateFilter();
          });
        }
      },
      selectedColor: whiteColor,
      checkmarkColor: greenColor,
      labelStyle: TextStyle(
        color: isSelected ? blackColor : blackColor,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedStartDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedEndDate ?? DateTime.now(),
      firstDate: selectedStartDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        selectedEndDate =
            DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  bool _isPickupDateToday(String pickupDateString) {
    try {
      final parts = pickupDateString.split('/');
      if (parts.length == 3) {
        final pickupDate = DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
        final today = DateTime.now();
        return pickupDate.year == today.year &&
            pickupDate.month == today.month &&
            pickupDate.day == today.day;
      }
    } catch (e) {
      print('Error parsing pickup date: $e');
    }
    return false;
  }

  void _updateStatus(BuildContext context, String docId, String newStatus,
      List<Map<String, dynamic>> orderItems, String pickupDate) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await FirebaseFirestore.instance
          .collection('order_notifications')
          .doc(docId)
          .update({'status': newStatus});

      if (newStatus == 'approved') {
        if (_isPickupDateToday(pickupDate)) {
          await _reduceRemainingStock(orderItems);
          print('Stock reduced because pickup date is today: $pickupDate');
        } else {
          print(
              'Stock NOT reduced because pickup date is not today: $pickupDate');
        }
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to update order status', style: whiteTextStyle),
            backgroundColor: blackColor,
          ),
        );
      }
    }
  }

  Future<void> _reduceRemainingStock(
      List<Map<String, dynamic>> orderItems) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      print('=== DEBUG ORDER ITEMS ===');
      for (int i = 0; i < orderItems.length; i++) {
        print('Item $i: ${orderItems[i]}');
      }
      print('========================');

      final remainingStockDoc =
          await firestore.collection('remaining_stock').doc('quantity').get();

      Map<String, dynamic> currentStock = {};
      if (remainingStockDoc.exists) {
        currentStock = remainingStockDoc.data() ?? {};
        print('Current stock before update: $currentStock');
      } else {
        print('Remaining stock document does not exist! Creating new one...');

        await firestore.collection('remaining_stock').doc('quantity').set({});
      }

      Map<String, dynamic> updatedStock = Map.from(currentStock);

      for (var item in orderItems) {
        final itemId = item['itemId'] ??
            item['id'] ??
            item['productId'] ??
            item['item_id'];
        final orderedQuantity = item['quantity'] ?? 0;
        final title = item['title'] ?? 'Unknown';

        print('Processing item: $title');
        print('ItemId found: $itemId');
        print('Ordered quantity: $orderedQuantity');

        if (itemId != null && orderedQuantity > 0) {
          final currentQuantity = updatedStock[itemId] ?? 0;

          final newQuantity = (currentQuantity - orderedQuantity)
              .clamp(0, double.infinity)
              .toInt();

          updatedStock[itemId] = newQuantity;

          print(
              'Item $itemId ($title): $currentQuantity -> $newQuantity (dikurangi $orderedQuantity)');
        } else {
          print('SKIPPED - ItemId is null or quantity is 0 for item: $title');
        }
      }

      print('Updated stock to be saved: $updatedStock');

      await firestore
          .collection('remaining_stock')
          .doc('quantity')
          .set(updatedStock, SetOptions(merge: true));

      print('Stock update completed successfully');
    } catch (e) {
      print('Error reducing remaining stock: $e');
      rethrow;
    }
  }

  Future<void> _restoreRemainingStock(
      List<Map<String, dynamic>> orderItems) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      final remainingStockDoc =
          await firestore.collection('remaining_stock').doc('quantity').get();

      Map<String, dynamic> currentStock = {};
      if (remainingStockDoc.exists) {
        currentStock = remainingStockDoc.data() ?? {};
      }

      Map<String, dynamic> updatedStock = Map.from(currentStock);

      for (var item in orderItems) {
        final itemId = item['itemId'];
        final orderedQuantity = item['quantity'] ?? 0;

        if (itemId != null && orderedQuantity > 0) {
          final currentQuantity = updatedStock[itemId] ?? 0;

          final newQuantity = currentQuantity + orderedQuantity;

          updatedStock[itemId] = newQuantity;

          print(
              'Item $itemId: $currentQuantity -> $newQuantity (ditambah kembali $orderedQuantity)');
        }
      }

      await firestore
          .collection('remaining_stock')
          .doc('quantity')
          .set(updatedStock);
    } catch (e) {
      print('Error restoring remaining stock: $e');
      rethrow;
    }
  }
}
