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
  
   Stream<QuerySnapshot> get items {
    return _firestore
        .collection('order_data')
        .orderBy('title', descending: false)
        .snapshots();
  }

  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  
  void _navigateToAddOrderDataPage() {
    // Navigate to AddOrderDataPage
    Navigator.of(context).push(
      CustomPageRoute(
        page: AddOrderDataPage(
          onSave: () {
            _fetchOrderData(); // Refresh order data after saving
          },
        ),
      ),
    );
  }

  
  Future<void> _deleteItem(String orderId) async {
    try {
      // Gunakan FirestoreHelper untuk menghapus
      await firestoreHelper.deleteOrderData(orderId);

      // Refresh data setelah menghapus
      _fetchOrderData();

      // Tampilkan pesan sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item berhasil dihapus')),
        );
      }
    } catch (e) {
      // Tampilkan pesan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus item: $e')),
        );
      }
      print("Error deleting item: $e");
    }
  }

  void _showEditDeleteDialog(String orderData) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Edit or Delete'),
        content: const Text('Choose an action for this item.'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              
              // Get the item data from Firestore
              DocumentSnapshot doc = await _firestore
                  .collection('order_data')
                  .doc(orderData)
                  .get();
              
              if (mounted && doc.exists) {
                Map<String, dynamic> itemData = doc.data() as Map<String, dynamic>;
                _navigateToPage(EditOrderDataPage(
                  itemId: orderData,
                  itemData: itemData,
                ));
              }
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              _deleteItem(orderData);
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
    // Jika item yang di-tap sudah terpilih, hilangkan seleksi
    if (selectedItemId == orderId) {
      selectedItemId = null;
    } else {
      // Jika item yang di-tap belum terpilih, pilih item tersebut
      selectedItemId = orderId;
    }
  });
  _showEditDeleteDialog(orderId);
}

  @override
  void initState() {
    super.initState();
    _fetchOrderData(); // Fetch order data when page loads
  }

  void _fetchOrderData() async {
    final fetchedOrders = await firestoreHelper.getOrderData(); // Fetch data from Firestore

    // Sort by pickupDate, then by customerName with uppercase before lowercase
    fetchedOrders.sort((a, b) {
      // Convert pickupDate to DateTime for accurate comparison
      DateTime dateA = DateTime.tryParse(a['pickupDate'] ?? '') ?? DateTime(0);
      DateTime dateB = DateTime.tryParse(b['pickupDate'] ?? '') ?? DateTime(0);

      // Compare by pickupDate first
      int dateComparison = dateA.compareTo(dateB);

      // If dates are the same, compare by customerName alphabetically (uppercase before lowercase)
      if (dateComparison == 0) {
        String nameA = a['customerName'] ?? '';
        String nameB = b['customerName'] ?? '';
        
        // Sort uppercase names before lowercase by adjusting the comparison
        return nameA.toLowerCase() == nameB.toLowerCase()
            ? nameA.compareTo(nameB)
            : nameA.toLowerCase().compareTo(nameB.toLowerCase());
      }

      return dateComparison;
    });

    setState(() {
      orderData = fetchedOrders; // Update state with sorted data
    });
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Reset the selected item when tapping outside the CircleAvatar
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
              onPressed: _navigateToAddOrderDataPage, // Navigate to AddOrderDataPage on press
              label: 'Add Order Data',
              width: 140,
            ),
            const SizedBox(width: 10),
            PrintButton(
              borderRadius: BorderRadius.circular(8), // Adjust border radius here
            ),
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
              BackButtonCustom(
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Order Data',
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
        body: orderData.isEmpty
            ? const Center(child: CircularProgressIndicator()) // Show loading indicator if data is empty
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
                          title: Text(order['customerName'] ?? 'N/A'), // Display customer name
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Number: ${order['customerNumber'] ?? 'N/A'}'), // Display customer number
                              Text('Address: ${order['customerAddress'] ?? 'N/A'}'), // Display customer address
                              Text(
                                'Pickup Date: ${order['pickupDate'] != null ? DateTime.parse(order['pickupDate']).toLocal().toString().split(' ')[0] : 'N/A'}', // Display pickup date
                              ),
                              const SizedBox(height: 5),
                              Text('Order Items: ${order['orderItems'].join(', ') ?? 'N/A'}'), // Display order items
                            ],
                          ),
                          isThreeLine: true,
                        ),
                        ),
                         if (isSelectMode)
                          Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: GestureDetector(
                              onTap: () {
                                _handleCircleAvatarTap(order['id'] ?? '');
                              },
                              child: CircleAvatar(
                                backgroundColor: selectedItemId == order['id']
                                    ? beigeColor
                                    : blueColor,
                                radius: 10,
                                child: selectedItemId == order['id']
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
