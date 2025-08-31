import 'dart:developer';

import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/button_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditOrderDataPage extends StatefulWidget {
  final Map<String, dynamic> itemData;
  final String itemId;
  const EditOrderDataPage(
      {super.key, required this.itemId, required this.itemData});

  @override
  State<EditOrderDataPage> createState() => _EditOrderDataPageState();
}

class _EditOrderDataPageState extends State<EditOrderDataPage> {
  final FirestoreHelper firestoreHelper = FirestoreHelper();

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerNumberController =
      TextEditingController();
  final TextEditingController customerAddressController =
      TextEditingController();
  final TextEditingController orderItemControllers = TextEditingController();
  final TextEditingController orderNoteController = TextEditingController();
  final TextEditingController orderTotalController = TextEditingController();

  DateTime? selectedDate;
  String? selectedOption;

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();

    if (date is Timestamp) {
      return date.toDate();
    }

    if (date is DateTime) {
      return date;
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
          'EEEE, dd MMMM yyyy', 
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        log(selectedDate.toString());
      });
    }
  }

  Widget buildOrderItemFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: orderItemControllers,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Order Items (separate with commas)',
                  hintStyle: greyTextStyle.copyWith(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatOrderItemsToString(dynamic orderItems) {
    if (orderItems == null) return '';

    if (orderItems is List) {
      return orderItems.map((item) => item.toString()).join(', ');
    }

    return orderItems.toString();
  }

  String _formatOrderTotal(dynamic orderTotal) {
    if (orderTotal == null) return '';

    if (orderTotal is num) {
      return orderTotal.toString();
    }

    if (orderTotal is String) {
      return orderTotal.replaceAll(RegExp(r'[^\d]'), '');
    }

    return orderTotal.toString();
  }

  @override
  void initState() {
    super.initState();

    try {
      customerNameController.text =
          widget.itemData['customerName']?.toString() ?? '';
      customerNumberController.text =
          widget.itemData['customerNumber']?.toString() ?? '';
      customerAddressController.text =
          widget.itemData['customerAddress']?.toString() ?? '';

      orderItemControllers.text =
          _formatOrderItemsToString(widget.itemData['orderItems']);

      orderNoteController.text = widget.itemData['orderNote']?.toString() ?? '';

      orderTotalController.text =
          _formatOrderTotal(widget.itemData['orderTotal']);

      selectedDate = _parseDate(widget.itemData['pickupDate']);

      selectedOption = widget.itemData['payment']?.toString();
    } catch (e) {
      print('Error initializing edit form: $e');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
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
            BackButtonCustom(onPressed: () {
              Navigator.pop(context);
            }),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                'Edit Order Data',
                style: blueTextStyle.copyWith(
                  fontSize: 25,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 500,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Customer Data',
                            style: blackTextStyle.copyWith(fontSize: 16)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: customerNameController,
                          decoration: InputDecoration(
                            fillColor: whiteColor,
                            filled: true,
                            hintText: 'Customer Name',
                            hintStyle: greyTextStyle.copyWith(fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: customerNumberController,
                          decoration: InputDecoration(
                            fillColor: whiteColor,
                            filled: true,
                            hintText: 'Customer Number',
                            hintStyle: greyTextStyle.copyWith(fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: customerAddressController,
                          decoration: InputDecoration(
                            fillColor: whiteColor,
                            filled: true,
                            hintText: 'Customer Address',
                            hintStyle: greyTextStyle.copyWith(fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 500,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detailed Order Data',
                            style: blackTextStyle.copyWith(fontSize: 16)),
                        const SizedBox(height: 10),
                        buildOrderItemFields(),
                        const SizedBox(height: 10),
                        TextField(
                          controller: orderNoteController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            fillColor: whiteColor,
                            filled: true,
                            hintText: 'Order Note (optional)',
                            hintStyle: greyTextStyle.copyWith(fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: orderTotalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: whiteColor,
                            filled: true,
                            hintText: 'Order Total',
                            hintStyle: greyTextStyle.copyWith(fontSize: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: greyColor),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate == null
                                      ? 'Select Date'
                                      : DateFormat('EEEE, dd MMMM yyyy')
                                          .format(selectedDate!),
                                  style: selectedDate == null
                                      ? greyTextStyle.copyWith(fontSize: 14)
                                      : blackTextStyle.copyWith(fontSize: 14),
                                ),
                                Icon(Icons.calendar_today, color: blackColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 500,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Status',
                            style: blackTextStyle.copyWith(fontSize: 16)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Radio(
                                    value: "Pay at the cashier",
                                    groupValue: selectedOption,
                                    onChanged: (value) => setState(() =>
                                        selectedOption = value.toString()),
                                  ),
                                  const Text('Pay at the cashier'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Radio(
                                    value: "Transfer Payment",
                                    groupValue: selectedOption,
                                    onChanged: (value) => setState(() =>
                                        selectedOption = value.toString()),
                                  ),
                                  const Text('Transfer payment'),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 90,
                    child: ButtonCustom(
                      label: 'Save',
                      onPressed: () async {
                        final customerName = customerNameController.text.trim();
                        final customerNumber =
                            customerNumberController.text.trim();
                        final customerAddress =
                            customerAddressController.text.trim();
                        final orderItems = orderItemControllers.text.trim();
                        final orderNote = orderNoteController.text.trim();
                        final orderTotal = orderTotalController.text.trim();

                        if (customerName.isEmpty ||
                            customerNumber.isEmpty ||
                            customerAddress.isEmpty ||
                            orderItems.isEmpty ||
                            selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please fill all required fields and select a date.'),
                            ),
                          );
                          return;
                        }

                        try {
                          List<String> orderItemsList = orderItems
                              .split(',')
                              .map((item) => item.trim())
                              .where((item) => item.isNotEmpty)
                              .toList();

                          Map<String, dynamic> updateData = {
                            'customerName': customerName,
                            'customerNumber': customerNumber,
                            'customerAddress': customerAddress,
                            'pickupDate': selectedDate!.toIso8601String(),
                            'orderItems': orderItemsList,
                            'payment': selectedOption ?? 'Belum Bayar',
                          };

                          if (orderNote.isNotEmpty) {
                            updateData['orderNote'] = orderNote;
                          }

                          if (orderTotal.isNotEmpty) {
                            updateData['orderTotal'] =
                                int.tryParse(orderTotal) ?? 0;
                          }

                          await firestoreHelper.editOrderData(
                              updateData, widget.itemId);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data updated successfully'),
                            ),
                          );

                          Navigator.pop(context);
                        } catch (e) {
                          print('Error updating order: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error updating order: $e'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
