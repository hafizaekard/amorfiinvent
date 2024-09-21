import 'package:amorfiapp/pages/archivemanagement.dart';
import 'package:amorfiapp/pages/inputitem.dart';
import 'package:amorfiapp/pages/order_data.dart';
import 'package:amorfiapp/pages/remainingstock.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/auto_image_slider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void _navigateToInputItemPage(){
    Navigator.push(
      context,
       MaterialPageRoute(builder: (context) => const InputItemPage(),
       ),
    );
  }
  
  void _navigateToOrderDataPage(){
    Navigator.push(
      context,
       MaterialPageRoute(builder: (context) => const OrderDataPage(),
       ),
    );
  }

  void _navigateToRemainingStockPage(){
    Navigator.push(
      context,
       MaterialPageRoute(builder: (context) => const RemainingStockPage(),
       ),
    );
  }

  void _navigateToArchiveManagementPage(){
    Navigator.push(
      context,
       MaterialPageRoute(builder: (context) => const ArchiveManagementPage(),
       ),
    );
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
            Container(
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
                              width: 230, // Fixed width
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
                            borderRadius: BorderRadius.circular(30),
                            ),
                      )),
                      const SizedBox(width: 20),
                      Expanded(
                        child: AutoImageSlider())
                ],
              ),
            ),
          ],
          
        ),
        
        
      ),
      
    );
  }
}
