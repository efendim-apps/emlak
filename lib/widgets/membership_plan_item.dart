import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/app_config.dart';
import '../providers/languages.dart';
import '../screens/payment_methods_screen.dart';
import '../helpers/current_user.dart';

class MembershipPlanWidget extends StatelessWidget {
  final String id;
  final String title;
  final String price;
  final String term;
  final String postLimit;
  final String adDuration;
  final String featuredFee;
  final String urgentFee;
  final String highlightFee;
  final String featuredDuration;
  final String urgentDuration;
  final String highlightDuration;
  final bool topInSearchAndCategory;
  final bool showOnHome;
  final bool showInHomeSearch;

  MembershipPlanWidget({
    @required this.id,
    @required this.title,
    @required this.price,
    @required this.term,
    @required this.postLimit,
    @required this.adDuration,
    @required this.featuredFee,
    @required this.urgentFee,
    @required this.highlightFee,
    @required this.featuredDuration,
    @required this.urgentDuration,
    @required this.highlightDuration,
    @required this.topInSearchAndCategory,
    @required this.showOnHome,
    @required this.showInHomeSearch,
  });

  Widget _customListTileBuilder({
    BuildContext ctx,
    String simpleText = '',
    String boldText = '',
    double fontSize = 16.0,
    Icon icon = const Icon(
      Icons.check_circle,
      color: Colors.green,
    ),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        Container(
          margin: EdgeInsets.symmetric(vertical: 7),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(ctx).size.width - 70,
          ),
          child: RichText(
            maxLines: null,
            softWrap: true,
            textDirection: CurrentUser.textDirection,
            text: TextSpan(
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.grey[800],
              ),
              children: [
                TextSpan(
                  text: simpleText,
                ),
                TextSpan(
                  text: boldText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    return Container(
      margin: EdgeInsets.only(
        top: 0,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      width: MediaQuery.of(context).size.width - 40,
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 8,
        child: Container(
          padding: EdgeInsets.only(bottom: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                  color: Colors.grey[800],
                ),
              ),
              _customListTileBuilder(
                ctx: context,
                simpleText: '',
                boldText: '${AppConfig.currencySign}$price / $term',
                fontSize: 20,
              ),
              _customListTileBuilder(
                ctx: context,
                simpleText: langPack['Ad Post Limit'],
                boldText: postLimit,
              ),
              _customListTileBuilder(
                ctx: context,
                simpleText: langPack['Ad Expiry in'],
                boldText: ' $postLimit ${langPack['days']}',
              ),
              _customListTileBuilder(
                ctx: context,
                simpleText: langPack['Featured Ad fee'],
                boldText:
                ' $featuredFee ${langPack['for']} $featuredDuration ${langPack['days']}',
              ),
              _customListTileBuilder(
                ctx: context,
                simpleText: langPack['Urgent Ad fee'],
                boldText:
                ' $urgentFee ${langPack['for']} $urgentDuration ${langPack['days']}',
              ),
              _customListTileBuilder(
                ctx: context,
                simpleText: langPack['Highlight Ad fee'],
                boldText:
                ' $highlightFee ${langPack['for']} $highlightDuration ${langPack['days']}',
              ),
              _customListTileBuilder(
                ctx: context,
                simpleText: langPack['Top in search results and category'],
                boldText: '',
                icon: topInSearchAndCategory
                    ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
                    : Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
              ),
              _customListTileBuilder(
                ctx: context,
                simpleText: langPack['Show ad on home page premium ad section'],
                boldText: '',
                icon: showOnHome
                    ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
                    : Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
              ),
              _customListTileBuilder(
                ctx: context,
                simpleText: langPack['Show ad on home page search result'],
                boldText: '',
                icon: showInHomeSearch
                    ? Icon(
                  Icons.check_circle,
                  color: Colors.green,
                )
                    : Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                ),
              ),
              Spacer(),
              Center(
                child: TextButton(
                  child: Text(
                    langPack['Upgrade To Premium'],
                    textDirection: CurrentUser.textDirection,
                  ),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        )),
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.grey[800]),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(PaymentMethodsScreen.routeName, arguments: {
                      'id': id,
                      'title': title,
                      'price': price,
                      'isFeatured': false,
                      'isUrgent': false,
                      'isHighlighted': false,
                      'isSubscription': true,
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
