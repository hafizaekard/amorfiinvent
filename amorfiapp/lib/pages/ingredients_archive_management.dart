import 'dart:async';

import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IngredientsArchiveManagementPage extends StatefulWidget {
  final String currentPage;

  const IngredientsArchiveManagementPage({super.key, required this.currentPage});

  @override
  State<IngredientsArchiveManagementPage> createState() =>
      _IngredientsArchiveManagementPageState();
}

class _IngredientsArchiveManagementPageState
    extends State<IngredientsArchiveManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Timer? _cleanupTimer;

  @override
  void initState() {
    super.initState();
    FirestoreHelper.deleteOldArchives();
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      FirestoreHelper.deleteOldArchives();
    });
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }

  Stream<QuerySnapshot> get archivedItems {
    return _firestore
        .collection('archive_ingredients')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Color _getContainerColor(String source) {
    if (source == 'ingredient_quantities') {
      return lightBlueColor;
    }
    return whiteColor;
  }

  Color _getStatusColor(String source) {
    if (source == 'ingredient_quantities') {
      return blueColor;
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
            const SizedBox(width: 8),
            Text(
              'Archive Management',
              style: TextStyle(
                color: blueColor,
                fontSize: 25,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: lightGreyColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: archivedItems,
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
              child: Text(
                'No archive data available',
                style: blackTextStyle.copyWith(fontSize: 16),
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
                  ? _formatTimestamp(data['timestamp'].toDate().toString())
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
                              'Timestamp: $timestamp',
                              style: blackTextStyle.copyWith(
                                  fontSize: 14, fontWeight: semiBold),
                            ),
                          ),
                          Text(
                            'Input Ingredient',
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
  physics: const NeverScrollableScrollPhysics(),
  itemCount: items.length,
  itemBuilder: (context, itemIndex) {
    final itemMap = items[itemIndex] as Map<String, dynamic>;
    final value = itemMap['value'] ?? 'No value';
    final valueString = value is num ? value.toStringAsFixed(2) : value.toString();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemMap['title'] ?? 'No title',
                  style: blackTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quantity: ${itemMap['quantity'] ?? 'No quantity'}',
                  style: blackTextStyle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Value: $valueString',
                  style: blackTextStyle.copyWith(fontSize: 14),
                ),
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
    );
  }
}