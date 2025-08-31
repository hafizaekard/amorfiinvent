import 'dart:async';

import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductionArchive extends StatefulWidget {
  final String currentPage;

  const ProductionArchive({super.key, required this.currentPage});

  @override
  State<ProductionArchive> createState() =>
      _ProductionArchiveState();
}

class _ProductionArchiveState
    extends State<ProductionArchive> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _cleanupTimer;

  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String selectedFilter = 'today';

  @override
  void initState() {
    super.initState();
    _setInitialDateFilter();

    FirestoreHelper.deleteOldArchives(collectionName: 'archive_management');

    _cleanupTimer = Timer.periodic(const Duration(days: 7), (timer) {
      FirestoreHelper.deleteOldArchives(collectionName: 'archive_management');
    });
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
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
    Query query = _firestore.collection('archive_management');

    if (selectedStartDate != null && selectedEndDate != null) {
      query = query
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(selectedStartDate!))
          .where('timestamp',
              isLessThanOrEqualTo: Timestamp.fromDate(selectedEndDate!));
    }

    return query.orderBy('timestamp', descending: true).snapshots();
  }

  Color _getContainerColor(String source) {
    if (source == 'input_item') {
      return lightBlueColor;
    } else if (source == 'remaining_stock') {
      return lightYellowColor;
    }
    return whiteColor;
  }

  Color _getStatusColor(String source) {
    if (source == 'input_item') {
      return blueColor;
    } else if (source == 'remaining_stock') {
      return orangeColor;
    }
    return greyColor;
  }

  String _formatTimestamp(String timestamp) {
    try {
      DateTime dateTime = DateTime.parse(timestamp);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}.${dateTime.millisecond.toString().padLeft(3, '0')}';
    } catch (e) {
      return timestamp;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: newBlueColor,
        shape: Border(bottom: BorderSide(color: blueColor.withOpacity(0.2))),
        automaticallyImplyLeading: false,
        titleSpacing: 15,
        title: Row(
          children: [
            BackButtonCustom(
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                'Archive Management',
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
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final archivedDocs = snapshot.data!.docs;

                if (archivedDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No archive data for the selected period',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: archivedDocs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        archivedDocs[index].data() as Map<String, dynamic>;
                    final String source = data['source'] ?? '';
                    final List<dynamic> items = data['items'] ?? [];
                    final timestamp = data['timestamp'] is Timestamp
                        ? _formatTimestamp(
                            data['timestamp'].toDate().toString())
                        : 'No timestamp';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: _getContainerColor(source),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Data entry time: $timestamp',
                                    style: blackTextStyle.copyWith(
                                        fontSize: 14, fontWeight: semiBold),
                                  ),
                                ),
                                Text(
                                  source == 'input_item'
                                      ? 'Input Item'
                                      : 'Remaining Stock',
                                  style: blackTextStyle.copyWith(
                                    color: _getStatusColor(source),
                                    fontSize: 16,
                                    fontWeight: semiBold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Items:',
                                style: blackTextStyle.copyWith(
                                    fontSize: 14, fontWeight: semiBold)),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: items.length,
                            itemBuilder: (context, itemIndex) {
                              final itemMap =
                                  items[itemIndex] as Map<String, dynamic>;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: itemMap['image'] != null
                                          ? Image.network(
                                              itemMap['image'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 50,
                                              height: 50,
                                              color: greyColor,
                                              child: Icon(
                                                  Icons.image_not_supported),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(itemMap['title'] ?? 'No title',
                                              style: blackTextStyle.copyWith(
                                                  fontSize: 14,
                                                  fontWeight: semiBold)),
                                          if (itemMap['label'] != null &&
                                              itemMap['label'].isNotEmpty)
                                            Text('Label: ${itemMap['label']}',
                                                style: burnSiennaTextStyle
                                                    .copyWith(
                                                        fontSize: 13,
                                                        fontWeight: semiBold)),
                                          if (itemMap['title2'] != null &&
                                              itemMap['title2'].isNotEmpty)
                                            Text(
                                                'Additional: ${itemMap['title2']}',
                                                style: burnSiennaTextStyle
                                                    .copyWith(
                                                        fontSize: 13,
                                                        fontWeight: semiBold)),
                                          const SizedBox(height: 4),
                                          Text(
                                              'Quantity: ${itemMap['quantity'] ?? 'No quantity'}',
                                              style: blackTextStyle.copyWith(
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
}