import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/pages/input_item.dart';
import 'package:amorfiapp/pages/order_data.dart';
import 'package:amorfiapp/pages/production_archive_management.dart';
import 'package:amorfiapp/pages/remaining_stock.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/production_app_drawer.dart';
import 'package:flutter/material.dart';

class ProductionPage extends StatefulWidget {
  const ProductionPage({super.key});

  @override
  State<ProductionPage> createState() => _ProductionPageState();
}

class _ProductionPageState extends State<ProductionPage> {
  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToInputItemPage() {
    _navigateToPage(const InputItemPage());
  }
  
  void _navigateToOrderDataPage() {
    _navigateToPage(const OrderDataPage());
  }

  void _navigateToRemainingStockPage() {
    _navigateToPage(const RemainingStockPage());
  }

  void _navigateToProductionArchiveManagementPage() {
    _navigateToPage(const ProductionArchiveManagementPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: newBlueColor,
        automaticallyImplyLeading: false,
        titleSpacing: 35,
        title: Row(
          children: [
            Builder(
              builder: (BuildContext context) {
                return InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: blueColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu_rounded,
                        color: whiteColor,
                        size: 25,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 15),
            Text(
              'Ámorfi Invent',
              style: headerTextStyle.copyWith(
                fontSize: 30,
                fontWeight: semiBold,
              )
            ),
          ],
        ),
      ),
      drawer: const ProductionAppDrawer(),
      backgroundColor: lightGreyColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Column(
                    children: [
                      ...List.generate(4, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              width: 230,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: blackColor.withOpacity(0.2),
                                    blurRadius: 3,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: InkWell(
                                onTap: index == 0
                                  ? _navigateToInputItemPage
                                  : index == 1
                                  ? _navigateToOrderDataPage
                                  : index == 2
                                  ? _navigateToRemainingStockPage
                                  : index == 3
                                  ? _navigateToProductionArchiveManagementPage
                                  : null,
                                highlightColor: transparentColor,
                                splashColor: transparentColor,
                                child:
                                  FutureBuilder<String>(
                                      future: FirestoreHelper().getImage(
                                        index == 0 ? 'input_item' 
                                        : index == 1 ? 'order_data' 
                                        : index == 2 ? 'remaining_stock' : 'archive_management'),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator());
                                        }
                                        if (snapshot.hasError) {
                                          return Center(child: Text('Error: ${snapshot.error}'));
                                        }
                                        if (!snapshot.hasData) {
                                          return const Center(child: Text('No image'));
                                        }
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(30),
                                          child: Image.network(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        );
                                      },
                                    ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}