import 'package:amorfiapp/helper/firestore_helper.dart';
import 'package:amorfiapp/pages/ingredients_archive_management.dart';
import 'package:amorfiapp/pages/input_ingredient.dart';
import 'package:amorfiapp/routes/custom_page_route.dart';
import 'package:amorfiapp/shared/shared_values.dart';
import 'package:amorfiapp/widgets/ingredient_app_drawer.dart';
import 'package:flutter/material.dart';

class IngredientsPage extends StatefulWidget {
  const IngredientsPage({super.key});

  @override
  State<IngredientsPage> createState() => _IngredientsPageState();
}

class _IngredientsPageState extends State<IngredientsPage> {
  void _navigateToPage(Widget page) {
    Navigator.of(context).push(CustomPageRoute(page: page));
  }

  void _navigateToInputIngredientPage() {
    _navigateToPage(const InputIngredientPage());
  }

  void _navigateToIngredientsArchiveManagementPage() {
    _navigateToPage(const IngredientsArchiveManagementPage());
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
              ),
            ),
          ],
        ),
      ),
      drawer: const IngredientAppDrawer(),
      backgroundColor: lightGreyColor,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionContainer(0),
                  const SizedBox(width: 30),
                  _buildOptionContainer(1),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionContainer(int index) {
    return FutureBuilder<String>(
      future: FirestoreHelper().getImage(
        index == 0 ? 'input_ingredient' : 'archive_management',
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 120,
            width: 150,
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
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 120,
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
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return Container(
            height: 150,
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
            child: const Center(child: Text('No image')),
          );
        }

        // Mengembalikan widget ketika snapshot memiliki data
        return Container(
          height: 150,
          width: 230,
          decoration: BoxDecoration(
            color: whiteColor,
            image: DecorationImage(
              image: NetworkImage(snapshot.data!), // Menampilkan gambar dari data
              fit: BoxFit.cover,
            ),
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
          onTap: () {
            // Logika navigasi berdasarkan index
            if (index == 0) {
              _navigateToInputIngredientPage();
            } else {
              _navigateToIngredientsArchiveManagementPage();
            }
          },
        ),
        );
      },
    );
  }
}
