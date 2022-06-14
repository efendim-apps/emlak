import 'package:flutter/material.dart';
import 'package:eRealState_App/screens/color_helper.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/products.dart';
import './sub_categories_screen.dart';
import '../providers/languages.dart';
import '../helpers/current_user.dart';

class AllCategoriesScreen extends StatelessWidget {
  Widget catIcon;
  static const routeName = '/all-categories';
  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    final Map pushedArguments = ModalRoute.of(context).settings.arguments;

    List<Category> allCategories =
        Provider.of<Products>(context).categoriesItems;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          langPack['Categories'],
          textDirection: CurrentUser.textDirection,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: HexColor(),
        foregroundColor: Colors.grey[800],
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: ListView.builder(
          itemCount: allCategories.length,
          // gridDelegate:
          // SliverGridDelegateWithFixedCrossAxisCount(
          //   crossAxisCount: 1,
          //   crossAxisSpacing: 20,
          //   mainAxisSpacing: 20,
          //   childAspectRatio: 1.5,
          // ),
          itemBuilder: (ctx, i) {
            switch (allCategories[i].id) {
              case '4':
                catIcon = Image.asset('assets/images/house.png');
                break;
              case '1':
                catIcon = Image.asset('assets/images/suv.png');
                break;
              case '9':
                catIcon = Image.asset('assets/images/bycicle.png');
                break;
              case '14':
                catIcon = Image.asset('assets/images/sofa.png');
                break;
              case '2':
                catIcon = Image.asset('assets/images/phone-camera.png');
                break;
              case '3':
                catIcon = Image.asset('assets/images/tv.png');
                break;
              case '11':
                catIcon = Image.asset('assets/images/football.png');
                break;
              case '6':
                catIcon = Image.asset('assets/images/agreement.png');
                break;
              case '10':
                catIcon = Image.asset('assets/images/dog.png');
                break;
              case '7':
                catIcon = Image.asset('assets/images/consult.png');
                break;
              case '12':
                catIcon = Image.asset('assets/images/book.png');
                break;
              case '5':
                catIcon = Image.asset('assets/images/dress.png');
                break;
              default:
                catIcon = Image.asset('assets/images/category.png');
            }
            return Card(
              elevation: 6.0,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    SubCategoriesScreen.routeName,
                    arguments: {
                      'newAd':  true, //pushedArguments['newAd'],
                      'editAd': false, //pushedArguments['editAd'],
                      'chosenCat': allCategories[i]
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0)
                  ),
                  child: Row(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Image.network(allCategories[i].picture)),
                      Expanded(child: Text(allCategories[i].name)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
