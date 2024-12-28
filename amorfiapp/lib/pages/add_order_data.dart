import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/back_button_custom.dart';
import 'package:amorfiapp/widgets/button_custom.dart';
import 'package:flutter/material.dart';

class AddOrderDataPage extends StatefulWidget {
  final Function onSave; // Callback function to notify parent

  const AddOrderDataPage(
      {super.key, required this.onSave}); // Pass callback in constructor

  @override
  State<AddOrderDataPage> createState() => _AddOrderDataPageState();
}

class _AddOrderDataPageState extends State<AddOrderDataPage> {
  final FirestoreHelper firestoreHelper = FirestoreHelper();

  // Controllers for customer details
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController customerNumberController =
      TextEditingController();
  final TextEditingController customerAddressController =
      TextEditingController();

  // List to hold controllers for order items
  final List<TextEditingController> orderItemControllers = [
    TextEditingController()
  ]; // Start with one item

  // Variable to store selected date
  DateTime? selectedDate;

  String? selectedOption;

  // Function to show date picker
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
      });
    }
  }

  // Function to build Order Item TextFields
  Widget buildOrderItemFields() {
    return Column(
      children: [
        for (int i = 0; i < orderItemControllers.length; i++)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: orderItemControllers[i],
                  decoration: InputDecoration(
                    hintText: 'Item ${i + 1}',
                    hintStyle: greyTextStyle.copyWith(fontSize: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(
                  width: 8), // Space between TextField and delete button
              if (i > 0) // Show delete button only for items after the first
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      orderItemControllers.removeAt(i); // Remove the item
                    });
                  },
                ),
            ],
          ),
        const SizedBox(height: 10), // Space before the add item button
        // Button to add more order items
        TextButton(
          onPressed: () {
            setState(() {
              orderItemControllers
                  .add(TextEditingController()); // Add new controller
            });
          },
          child: const Text('Add Item'),
        ),
      ],
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
                'Add Order Data',
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Container for Customer Data
                  Container(
                    width: 500, // Set the width for customer container
                    margin: const EdgeInsets.only(
                        bottom: 20), // Margin below customer container
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
                        const SizedBox(height: 10), // Space between TextFields
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
                        const SizedBox(height: 10), // Space between TextFields
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

                  // Container for Order Items
                  Container(
                    width: 500, // Set the width for order items container
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
                        buildOrderItemFields(), // Use the buildOrderItemFields function
                        const SizedBox(
                            height: 10), // Space before the date picker
                        // Date Picker
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: greyColor), // Optional border
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedDate == null
                                      ? 'Select Date'
                                      : '${selectedDate!.toLocal()}'
                                          .split(' ')[0], // Format the date
                                  style: greyTextStyle.copyWith(fontSize: 14),
                                ),
                                Icon(Icons.calendar_today, color: blackColor),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20), // Space before the save button
                  // Save Button outside of the container
                  // Save Button outside of the container
                  Container(
                    width: 500, // Set the width for order items container
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detailed Payment',
                            style: blackTextStyle.copyWith(fontSize: 16)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Radio(
                                      value: "Belum Bayar",
                                      groupValue: selectedOption,
                                      onChanged: (index) {
                                        selectedOption = index;
                                        setState(() {
                                          
                                        });
                                      }),
                                  Expanded(
                                    child: Text('Belum Bayar'),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Radio(
                                      value: "Sudah DP",
                                      groupValue: selectedOption,
                                      onChanged: (index) {
                                        selectedOption = index;
                                        setState(() {
                                          
                                        });
                                      }),
                                  Expanded(child: Text('Sudah DP'))
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Radio(
                                      value: "Lunas",
                                      groupValue: selectedOption,
                                      onChanged: (index) {
                                        selectedOption = index;
                                        setState(() {
                                          
                                        });
                                      }),
                                  Expanded(child: Text('Lunas'))
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
                        final customerName = customerNameController.text;
                        final customerNumber = customerNumberController.text;
                        final customerAddress = customerAddressController.text;

                        // Validation
                        if (customerName.isEmpty ||
                            customerNumber.isEmpty ||
                            customerAddress.isEmpty ||
                            orderItemControllers.every(
                                (controller) => controller.text.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please fill all fields and add at least one order item.'),
                            ),
                          );
                          return;
                        }

                        // Show loading indicator

                        // Save data to Firestore, including the selected date
                        try {
                          await firestoreHelper.addOrderData({
                            'customerName': customerName,
                            'customerNumber': customerNumber,
                            'customerAddress': customerAddress,
                            'pickupDate': selectedDate
                                ?.toIso8601String(), // Save as ISO string
                            'orderItems': orderItemControllers
                                .map((controller) => controller.text)
                                .toList(),
                                "payment" : selectedOption
                          });

                          // Show success message after saving
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Data saved successfully'), // Success message
                            ),
                          );

                          // Call the onSave callback to refresh the order data list
                          widget.onSave();

                          // Close the page after saving
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving order: $e'),
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
