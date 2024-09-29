import 'package:amorfiapp/pages/input_item.dart';
import 'package:amorfiapp/pages/order_data.dart';
import 'package:amorfiapp/pages/production_archive_management.dart';
import 'package:amorfiapp/pages/remaining_stock.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/auto_image_slider.dart';
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

  void _navigateToArchiveManagementPage() {
    _navigateToPage(const ProductionArchiveManagementPage());
  }

 void _showDrawer() {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: whiteColor,
  shadowColor: blackColor.withOpacity(1),
  elevation: 0.5,
  automaticallyImplyLeading: false,
  titleSpacing: 35,
  title: Row(
    children: [
      Builder(
        builder: (BuildContext context) {
          return InkWell(
            onTap: () {
              Scaffold.of(context).openDrawer(); // Membuka drawer menggunakan context yang tepat
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: newpurpleColor,
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
      backgroundColor: whiteColor,
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
                                    spreadRadius: 0.1,
                                    blurRadius: 5,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: InkWell(
                                onTap: index == 0
                                ? _navigateToInputItemPage
                                : index == 1
                                ? _navigateToOrderDataPage
                                : index == 2
                                ?_navigateToRemainingStockPage
                                : index == 3
                                ?_navigateToArchiveManagementPage
                                : null,
                  
                                highlightColor: transparentColor,
                                splashColor: transparentColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      index == 0 ? Icons.system_update_alt_rounded :
                                      index == 1 ? Icons.receipt_rounded :
                                      index == 2 ? Icons.shelves : Icons.archive_rounded,
                                      color: newpurpleColor,
                                      size: 50,
                                    ),
                                    Text(
                                      index == 0 ? 'Input Item' :
                                      index == 1 ? 'Order Data' :
                                      index == 2 ? 'Remaining Stock' : 'Archive Management',
                                      style: newpurpleTextStyle.copyWith(
                                        fontSize: 20,
                                        fontWeight: normal,
                                      ),
                                    )
                                  ],
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
                      padding : const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          boxShadow: [
                            BoxShadow(
                              color: blackColor.withOpacity(0.2),
                              spreadRadius: 0.1,
                              blurRadius: 5,
                              offset: const Offset(0, 1),
                              ),
                              ],
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
                              ),
                        ),
                    )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: AutoImageSlider())),
                ],
              ),
            ),
          ],
          
        ),
        
        
      ),
      
    );
  }
}

