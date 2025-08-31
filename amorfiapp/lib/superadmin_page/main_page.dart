import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/superadmin_page/app_drawer.dart';
import 'package:amorfiapp/superadmin_page/ingredient_archive.dart';
import 'package:amorfiapp/superadmin_page/ingredient_item.dart';
import 'package:amorfiapp/superadmin_page/ingredient_item_management.dart';
import 'package:amorfiapp/superadmin_page/monitoring_stock.dart';
import 'package:amorfiapp/superadmin_page/order_data_superadmin.dart';
import 'package:amorfiapp/superadmin_page/output_stock.dart';
import 'package:amorfiapp/superadmin_page/produced_page.dart';
import 'package:amorfiapp/superadmin_page/production_archive.dart';
import 'package:amorfiapp/superadmin_page/production_item_management.dart';
import 'package:amorfiapp/superadmin_page/remaining_page.dart';
import 'package:flutter/material.dart';

class MainPageSuperadmin extends StatelessWidget {
  const MainPageSuperadmin({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Produced Item',
        'icon': Icons.inventory_2_outlined,
        'page': const ProducedPage(),
      },
      {
        'title': 'Remaining Stock',
        'icon': Icons.store_outlined,
        'page': const RemainingPage(),
      },
      {
        'title': 'Order Data',
        'icon': Icons.receipt_long_outlined,
        'page': const OrderDataSuperadmin(),
      },
      {
        'title': 'Production Item Management',
        'icon': Icons.settings_outlined,
        'page': const ProductionManagement(),
      },
      {
        'title': 'Ingredient Item',
        'icon': Icons.category_outlined,
        'page': const IngredeientItemPage(),
      },
      {
        'title': 'Ingredient Output Stock',
        'icon': Icons.output_outlined,
        'page': const OutputStockPage(),
      },
      {
        'title': 'Ingredient Monitoring Stock',
        'icon': Icons.monitor_rounded,
        'page': const MonitoringStockPage(),
      },
      {
        'title': 'Ingredient Item Management',
        'icon': Icons.settings_outlined,
        'page': const IngredientItemManagement(),
      },
      {
        'title': 'Production Archive Management',
        'icon': Icons.folder_outlined,
        'page': const ProductionArchive(currentPage: 'superadmin'),
      },
      {
        'title': 'Ingredient Archive Management',
        'icon': Icons.folder_outlined,
        'page': const IngredientArchive(currentPage: 'superadmin'),
      },
    ];

    return Scaffold(
      backgroundColor: whiteColor,
      drawer: const SuperadminAppDrawer(),
      appBar: AppBar(
        backgroundColor: newBlueColor,
        automaticallyImplyLeading: false,
        titleSpacing: 35,
        elevation: 0,
        title: Row(
          children: [
            Builder(
              builder: (BuildContext context) {
                return InkWell(
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: blueColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu_rounded,
                        color: whiteColor,
                        size: 20,
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
                fontSize: 28,
                fontWeight: semiBold,
                color: blackColor,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              whiteColor,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...menuItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          CustomPageRoute(page: item['page']),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: newBlueColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  item['icon'],
                                  size: 24,
                                  color: blueColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'],
                                      style: blackTextStyle.copyWith(
                                          fontWeight: bold, fontSize: 15)),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: blueColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // Footer spacing
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
