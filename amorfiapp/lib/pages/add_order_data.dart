import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/button_custom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddOrderDataPage extends StatefulWidget {
  final Function onSave;

  const AddOrderDataPage({super.key, required this.onSave});

  @override
  State<AddOrderDataPage> createState() => _AddOrderDataPageState();
}

class _AddOrderDataPageState extends State<AddOrderDataPage> {
  final FirestoreHelper firestoreHelper = FirestoreHelper();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerNumberController =
      TextEditingController();
  final TextEditingController customerAddressController =
      TextEditingController();
  final TextEditingController orderNoteController = TextEditingController();

  final Map<String, int> _quantities = {};
  final Map<String, dynamic> _items = {};
  final Map<String, int> _remainingStock = {};
  final Map<String, TextEditingController> _textControllers = {};

  DateTime? selectedDate;
  String? selectedOption;
  int _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _loadItemsAndStock();
  }

  @override
  void dispose() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    customerNameController.dispose();
    customerNumberController.dispose();
    customerAddressController.dispose();
    orderNoteController.dispose();
    super.dispose();
  }

  bool _isPickupDateToday() {
    if (selectedDate == null) return false;
    final today = DateTime.now();
    return selectedDate!.year == today.year &&
        selectedDate!.month == today.month &&
        selectedDate!.day == today.day;
  }

  Future<void> _loadItemsAndStock() async {
    try {
      final stockDoc =
          await _firestore.collection('remaining_stock').doc('quantity').get();
      if (stockDoc.exists) {
        final stockData = stockDoc.data() as Map<String, dynamic>;
        _remainingStock.clear();
        for (var entry in stockData.entries) {
          _remainingStock[entry.key] = entry.value as int;
        }
      }

      final itemSnapshot = await _firestore.collection('input_item').get();

      setState(() {
        _items.clear();
        _quantities.clear();
        for (var controller in _textControllers.values) {
          controller.dispose();
        }
        _textControllers.clear();

        List<MapEntry<String, dynamic>> itemsWithStock = [];
        for (var doc in itemSnapshot.docs) {
          final data = doc.data();
          final id = doc.id;
          if (data.containsKey('title') && data.containsKey('image')) {
            itemsWithStock.add(MapEntry(id, data));
          }
        }

        if (_isPickupDateToday()) {
          itemsWithStock.sort((a, b) {
            final stockA = _remainingStock[a.key] ?? 0;
            final stockB = _remainingStock[b.key] ?? 0;
            return stockB.compareTo(stockA);
          });
        }

        for (var entry in itemsWithStock) {
          _items[entry.key] = entry.value;
          _quantities[entry.key] = 0;
          _textControllers[entry.key] = TextEditingController(text: '0');
        }
      });

      _calculateTotalAmount();
    } catch (e) {
      print('Error loading items and stock: $e');
      _showSnackBar('Error loading data: $e');
    }
  }

  int _getItemPrice(String id) {
    if (_items.containsKey(id) && _items[id]['price'] != null) {
      return (_items[id]['price'] as num).toInt();
    }
    return 0;
  }

  void _calculateTotalAmount() {
    int total = 0;
    for (var entry in _quantities.entries) {
      if (entry.value > 0) {
        final price = _getItemPrice(entry.key);
        total += price * entry.value;
      }
    }
    setState(() {
      _totalAmount = total;
    });
  }

  void _updateQuantityFromText(String id, String value) {
    if (selectedDate == null) {
      _showSnackBar("Harap pilih tanggal pengambilan terlebih dahulu");
      _textControllers[id]?.text = '0';
      return;
    }

    final cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.isEmpty) {
      _textControllers[id]?.text = '0';
      _textControllers[id]?.selection = TextSelection.fromPosition(
        TextPosition(offset: _textControllers[id]!.text.length),
      );
      setState(() {
        _quantities[id] = 0;
      });
      _calculateTotalAmount();
      return;
    }

    final int? newValue = int.tryParse(cleanValue);

    if (newValue != null) {
      if (newValue < 0) {
        _textControllers[id]?.text = '0';
        _textControllers[id]?.selection = TextSelection.fromPosition(
          TextPosition(offset: _textControllers[id]!.text.length),
        );
        _showSnackBar("Quantity cannot be less than 0");
        return;
      }

      if (_isPickupDateToday()) {
        final int maxStock = _remainingStock[id] ?? 0;
        if (newValue > maxStock) {
          _textControllers[id]?.text = maxStock.toString();
          _textControllers[id]?.selection = TextSelection.fromPosition(
            TextPosition(offset: _textControllers[id]!.text.length),
          );
          _showSnackBar("Quantity exceeds available stock. Maximum: $maxStock");
          setState(() {
            _quantities[id] = maxStock;
          });
          _calculateTotalAmount();
          return;
        }
      }

      setState(() {
        _quantities[id] = newValue;
      });
      _textControllers[id]?.text = newValue.toString();
      _textControllers[id]?.selection = TextSelection.fromPosition(
        TextPosition(offset: _textControllers[id]!.text.length),
      );
      _calculateTotalAmount();
    } else {
      _textControllers[id]?.text = _quantities[id].toString();
      _textControllers[id]?.selection = TextSelection.fromPosition(
        TextPosition(offset: _textControllers[id]!.text.length),
      );
      _showSnackBar("Enter only valid numbers");
    }
  }

  void _increaseQuantity(String id) {
    if (selectedDate == null) {
      _showSnackBar("Harap pilih tanggal pengambilan terlebih dahulu");
      return;
    }

    final currentQuantity = _quantities[id] ?? 0;

    if (_isPickupDateToday()) {
      final availableStock = _remainingStock[id] ?? 0;
      if (currentQuantity >= availableStock) {
        _showSnackBar("Stok tidak mencukupi. Stok tersedia: $availableStock");
        return;
      }
    }

    final newQuantity = currentQuantity + 1;
    setState(() {
      _quantities[id] = newQuantity;
      _textControllers[id]?.text = newQuantity.toString();
    });
    _calculateTotalAmount();
  }

  void _decreaseQuantity(String id) {
    if (selectedDate == null) {
      _showSnackBar("Harap pilih tanggal pengambilan terlebih dahulu");
      return;
    }

    final currentQuantity = _quantities[id] ?? 0;
    if (currentQuantity > 0) {
      final newQuantity = currentQuantity - 1;
      setState(() {
        _quantities[id] = newQuantity;
        _textControllers[id]?.text = newQuantity.toString();
      });
      _calculateTotalAmount();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;

        _loadItemsAndStock();
      });
    }
  }

  Future<void> _updateRemainingStock(Map<String, int> orderedQuantities) async {
    try {
      final stockDoc = _firestore.collection('remaining_stock').doc('quantity');

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(stockDoc);

        if (!snapshot.exists) {
          throw Exception('Stock document does not exist');
        }

        final currentStock =
            Map<String, dynamic>.from(snapshot.data() as Map<String, dynamic>);
        final updatedStock = <String, dynamic>{};

        for (var entry in orderedQuantities.entries) {
          final itemId = entry.key;
          final orderedQty = entry.value;
          final currentQty = currentStock[itemId] as int? ?? 0;

          if (currentQty < orderedQty) {
            throw Exception(
                'Insufficient stock for item: ${_items[itemId]['title']}');
          }

          updatedStock[itemId] = currentQty - orderedQty;
        }

        for (var entry in currentStock.entries) {
          if (!updatedStock.containsKey(entry.key)) {
            updatedStock[entry.key] = entry.value;
          }
        }

        transaction.update(stockDoc, updatedStock);
      });
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  bool _validateAllFields() {
    if (customerNameController.text.trim().isEmpty) {
      _showSnackBar("Nama customer tidak boleh kosong");
      return false;
    }
    if (customerNumberController.text.trim().isEmpty) {
      _showSnackBar("Nomor customer tidak boleh kosong");
      return false;
    }
    if (customerAddressController.text.trim().isEmpty) {
      _showSnackBar("Alamat customer tidak boleh kosong");
      return false;
    }
    if (selectedDate == null) {
      _showSnackBar("Harap pilih tanggal pengambilan");
      return false;
    }
    if (_totalAmount == 0) {
      _showSnackBar("Harap tambahkan pesanan terlebih dahulu");
      return false;
    }
    if (selectedOption == null) {
      _showSnackBar("Harap pilih jenis pembayaran");
      return false;
    }
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: blackColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dateNotSelected = selectedDate == null;
    final bool isPickupToday = _isPickupDateToday();

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
              child: Text('Add Order Data',
                  style: blueTextStyle.copyWith(
                    fontSize: 25,
                    fontWeight: semiBold,
                  )),
            ),
          ],
        ),
      ),
      backgroundColor: lightGreyColor,
      body: _items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                          Text(
                            'Customer Data',
                            style: blackTextStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: customerNameController,
                            decoration: const InputDecoration(
                              hintText: 'Customer Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: customerNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Customer Phone Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: customerAddressController,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText: 'Customer Address',
                              border: OutlineInputBorder(),
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
                          Text(
                            'Detailed Order Data',
                            style: blackTextStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Select a pickup date',
                            style: blackTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: greyColor),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: blackColor,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: blackColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Pilih Item',
                            style: blackTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._items.entries.map((entry) {
                            final id = entry.key;
                            final item = entry.value;
                            final price = _getItemPrice(id);
                            final stock = _remainingStock[id] ?? 0;
                            final isOutOfStock = isPickupToday && stock == 0;
                            final isDisabled = dateNotSelected || isOutOfStock;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDisabled
                                    ? greyColor.withOpacity(0.1)
                                    : whiteColor,
                                border: Border.all(
                                  color: isDisabled
                                      ? greyColor.withOpacity(0.3)
                                      : blackColor,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Opacity(
                                    opacity: isDisabled ? 0.5 : 1.0,
                                    child: Image.network(
                                      item['image'] ?? '',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                              Icons.image_not_supported,
                                              color: greyColor),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Opacity(
                                      opacity: isDisabled ? 0.5 : 1.0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'] ?? 'Tanpa Nama',
                                            style: blackTextStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isDisabled
                                                  ? greyColor
                                                  : blackColor,
                                            ),
                                          ),
                                          if ((item['label']?.isNotEmpty ==
                                                  true) ||
                                              (item['title2']?.isNotEmpty ==
                                                  true))
                                            Row(
                                              children: [
                                                if (item['label']?.isNotEmpty ==
                                                    true)
                                                  Text(
                                                    item['label'],
                                                    style: TextStyle(
                                                      color: isDisabled
                                                          ? greyColor
                                                          : Colors.blue,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                if ((item['label']
                                                            ?.isNotEmpty ==
                                                        true) &&
                                                    (item['title2']
                                                            ?.isNotEmpty ==
                                                        true))
                                                  const SizedBox(width: 5),
                                                if (item['title2']
                                                        ?.isNotEmpty ==
                                                    true)
                                                  Text(
                                                    item['title2'],
                                                    style: TextStyle(
                                                      color: isDisabled
                                                          ? greyColor
                                                          : Colors.blue,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          Text(
                                            'Harga: Rp $price',
                                            style: greyTextStyle,
                                          ),
                                          if (isPickupToday)
                                            Text(
                                              'Stock: $stock',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDisabled
                                                    ? greyColor
                                                    : (stock > 0
                                                        ? Colors.green
                                                        : Colors.red),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )
                                          else if (!dateNotSelected)
                                            const Text(
                                              'Tersedia',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: greyColor.withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: isDisabled
                                              ? null
                                              : () => _decreaseQuantity(id),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.remove,
                                              size: 18,
                                              color: isDisabled
                                                  ? greyColor
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Center(
                                            child: TextFormField(
                                              controller: _textControllers[id],
                                              enabled: !isDisabled,
                                              textAlign: TextAlign.center,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    3),
                                              ],
                                              onChanged: (value) =>
                                                  _updateQuantityFromText(
                                                      id, value),
                                              style: blackTextStyle.copyWith(
                                                fontSize: 13,
                                                color: isDisabled
                                                    ? greyColor
                                                    : blackColor,
                                              ),
                                              decoration: const InputDecoration
                                                  .collapsed(
                                                hintText: '',
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: isDisabled
                                              ? null
                                              : () => _increaseQuantity(id),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.add,
                                              size: 18,
                                              color: isDisabled
                                                  ? greyColor
                                                  : Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          Text(
                            'Add Note',
                            style: blackTextStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: orderNoteController,
                              enabled: !dateNotSelected,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: dateNotSelected
                                    ? 'Pilih tanggal pengambilan terlebih dahulu'
                                    : 'Add note for order if needed',
                                hintStyle: greyTextStyle.copyWith(fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              style: blackTextStyle.copyWith(
                                color: dateNotSelected ? greyColor : blackColor,
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
                          Text(
                            'Detailed Payment',
                            style: blackTextStyle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Amount',
                                  style: greyTextStyle.copyWith(fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Rp $_totalAmount',
                                  style: blackTextStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
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
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 90,
                      child: ButtonCustom(
                        label: 'Save',
                        onPressed: () async {
                          if (!_validateAllFields()) return;

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                                child: CircularProgressIndicator()),
                          );

                          try {
                            final customerName =
                                customerNameController.text.trim();
                            final customerNumber =
                                customerNumberController.text.trim();
                            final customerAddress =
                                customerAddressController.text.trim();

                            List<String> orderItems = [];
                            List<int> orderQuantities = [];
                            List<String> orderItemIds = [];
                            Map<String, int> orderedQuantitiesMap = {};

                            for (var entry in _quantities.entries) {
                              if (entry.value > 0) {
                                final id = entry.key;
                                final itemTitle =
                                    _items[id]['title'] ?? 'Unknown Item';
                                final quantity = entry.value;
                                orderItems.add(itemTitle);
                                orderQuantities.add(quantity);
                                orderItemIds.add(id);
                                orderedQuantitiesMap[id] = quantity;
                              }
                            }

                            final orderData = {
                              'customerName': customerName,
                              'customerNumber': customerNumber,
                              'customerAddress': customerAddress,
                              'pickupDate': selectedDate!.toIso8601String(),
                              'orderItems': orderItems,
                              'orderQuantities': orderQuantities,
                              'orderItemIds': orderItemIds,
                              'payment': selectedOption,
                              'orderTotal': _totalAmount.toString(),
                              'orderNote': orderNoteController.text.trim(),
                              'createdAt': FieldValue.serverTimestamp(),
                              'status': 'pending',
                              'isPickupToday': _isPickupDateToday(),
                            };

                            await firestoreHelper.addOrderData(orderData);

                            if (_isPickupDateToday() &&
                                orderedQuantitiesMap.isNotEmpty) {
                              await _updateRemainingStock(orderedQuantitiesMap);
                            }

                            Navigator.pop(context); // Close loading dialog
                            _showSnackBar('Order data saved successfully');
                            widget.onSave();
                            Navigator.pop(context); // Close current page
                          } catch (e) {
                            Navigator.pop(context); // Close loading dialog
                            _showSnackBar('Error saving order: $e');
                            print('Error saving order: $e');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
