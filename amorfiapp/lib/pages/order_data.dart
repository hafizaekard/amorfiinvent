import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/pages/add_order_data.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/edit_button.dart';
import 'package:amorfiapp/widgets/print_button.dart';
import 'package:flutter/material.dart';

class OrderDataPage extends StatefulWidget {
  const OrderDataPage({super.key});

  @override
  State<OrderDataPage> createState() => _OrderDataPageState();
}

class _OrderDataPageState extends State<OrderDataPage> {
  final FirestoreHelper firestoreHelper = FirestoreHelper();
  List<Map<String, dynamic>> orders = []; // To store order data

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
      orders = fetchedOrders; // Update state with sorted data
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: orders.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator if data is empty
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(10),
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
                );
              },
            ),
    );
  }
}
