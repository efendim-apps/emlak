import 'package:flutter/material.dart';
import 'package:eRealState_App/screens/color_helper.dart';
import 'package:provider/provider.dart';

import './new_ad_screen.dart';
import '../models/sub_category.dart';
import '../providers/languages.dart';
import './products_by_category_screen.dart';
import './edit_ad_screen.dart';
import '../helpers/current_user.dart';

class SubCategoriesScreen extends StatelessWidget {
  static const routeName = '/subcategories';

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    Map pushedArguments = ModalRoute.of(context).settings.arguments;
    //print(pushedArguments);
    //print(subCategories);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          langPack['Select sub category'],
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
      body: ListView(
        children: [
          if (!pushedArguments['newAd'])
            ListTile(
              title: Text(
                langPack['Show'] + ' ' + langPack['All'],
                textDirection: CurrentUser.textDirection,
              ),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(ProductsByCategoryScreen.routeName, arguments: {
                  'chosenCat': pushedArguments['chosenCat'],
                  'chosenSubCat': '',
                });
              },
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              // gridDelegate:
              // SliverGridDelegateWithFixedCrossAxisCount(
              //   crossAxisCount: 2,
              //   crossAxisSpacing: 20,
              //   mainAxisSpacing: 20,
              //   childAspectRatio: 1.5,
              // ),
              itemCount: pushedArguments['chosenCat'].subCategory.length,
              itemBuilder: (ctx, i) {
                return Card(
                    elevation: 6.0,
                    child: InkWell(
                      onTap: () {
                        if (pushedArguments['newAd']) {
                          Navigator.of(context)
                              .pushNamed(NewAdScreen.routeName, arguments: {
                            'chosenCat': pushedArguments['chosenCat'],
                            'chosenSubCat':
                            pushedArguments['chosenCat'].subCategory[i],
                          });
                        } else if (pushedArguments['editAd']) {
                          Navigator.of(context)
                              .pushNamed(EditAdScreen.routeName, arguments: {
                            'chosenCat': pushedArguments['chosenCat'],
                            'chosenSubCat':
                            pushedArguments['chosenCat'].subCategory[i],
                          });
                        } else {
                          Navigator.of(context).pushNamed(
                              ProductsByCategoryScreen.routeName,
                              arguments: {
                                'chosenCat': pushedArguments['chosenCat'],
                                'chosenSubCat':
                                pushedArguments['chosenCat'].subCategory[i],
                              });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: [
                            if(pushedArguments['chosenCat'].subCategory[i].picture != null)
                              Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Image.network(
                                pushedArguments['chosenCat'].subCategory[i].picture,
                                width: 64,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.warning_amber_rounded,
                                  size: 64,
                                ),
                              ),
                            ),
                            Expanded(child: Text(pushedArguments['chosenCat'].subCategory[i].name)),
                          ],
                        ),
                      ),
                    )
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
