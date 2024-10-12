import 'package:amorfiapp/pages/ingredients_archive_management.dart';
import 'package:amorfiapp/pages/input_ingredients.dart';
import 'package:amorfiapp/pages/input_recipe.dart';
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

  void _navigateToInputRecipePage() {
    _navigateToPage(const InputRecipePage());
  }

  void _navigateToIngredientsArchiveManagementPage() {
    _navigateToPage(const IngredientsArchiveManagementPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: creamColor,
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
                      color: burnSiennaColor,
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
      backgroundColor: creamColor,
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
                      ...List.generate(3, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              width: 230,
                              decoration: BoxDecoration(
                                color: beigeColor,
                                
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: InkWell(
                                onTap: index == 0
                                    ? _navigateToInputIngredientPage
                                    : index == 1
                                        ? _navigateToInputRecipePage
                                        : _navigateToIngredientsArchiveManagementPage,
                                highlightColor: transparentColor,
                                splashColor: transparentColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      index == 0
                                          ? Icons.system_update_alt_rounded
                                          : index == 1
                                              ? Icons.receipt_rounded
                                              : Icons.archive_rounded,
                                      color: whiteColor,
                                      size: 50,
                                    ),
                                    Text(
                                      index == 0
                                          ? 'Input Ingredient'
                                          : index == 1
                                              ? 'Input Recipe'
                                              : 'Archive Management',
                                      style: blackTextStyle.copyWith(
                                        fontSize: 20,
                                        fontWeight: normal,
                                      ),
                                    ),
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
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: creamColor,
                          border: Border.all(color: charcoalColor),
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
