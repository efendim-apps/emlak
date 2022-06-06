import 'package:flutter/material.dart';
import 'package:eRealState_App/models/sub_category.dart';

import '../screens/sub_categories_screen.dart';
import '../models/category.dart';

class CategoryTile extends StatelessWidget {

  final Category category;
  Widget catIcon;

  CategoryTile({
    this.category,

  });

  Widget catImageBuilder(String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.network(
        category.picture,
        fit: BoxFit.fill,
        height: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (category.id) {
      case '4':
        catIcon = catImageBuilder('assets/images/house.png',);
        break;
      case '1':
        catIcon = catImageBuilder('assets/images/suv.png');
        break;
      case '9':
        catIcon = catImageBuilder('assets/images/bycicle.png');
        break;
      case '14':
        catIcon = catImageBuilder('assets/images/sofa.png');
        break;
      case '2':
        catIcon = catImageBuilder('assets/images/phone-camera.png');
        break;
      case '3':
        catIcon = catImageBuilder('assets/images/tv.png');
        break;
      case '11':
        catIcon = catImageBuilder('assets/images/football.png');
        break;
      case '6':
        catIcon = catImageBuilder('assets/images/agreement.png');
        break;
      case '10':
        catIcon = catImageBuilder('assets/images/dog.png');
        break;
      case '7':
        catIcon = catImageBuilder('assets/images/consult.png');
        break;
      case '12':
        catIcon = catImageBuilder('assets/images/book.png');
        break;
      case '5':
        catIcon = catImageBuilder('assets/images/dress.png');
        break;
      default:
        catIcon = catImageBuilder('assets/images/category.png');
    }
    return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            SubCategoriesScreen.routeName,
            arguments: {
              'chosenCat': category,
              'newAd': false,
              'editAd': false,
            },
          );
        },
        child: Container(
          height: 20,
          child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [

                  catIcon,
                  FittedBox(
                    child: Text(
                      category.name.toUpperCase(),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }
}
