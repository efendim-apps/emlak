import 'package:eRealState_App/helpers/api_helper.dart';
import 'package:eRealState_App/helpers/app_config.dart';
import 'package:eRealState_App/helpers/current_user.dart';
import 'package:eRealState_App/providers/languages.dart';
import 'package:eRealState_App/screens/auth_screen.dart';
import 'package:eRealState_App/screens/expire_ads_screen.dart';
import 'package:eRealState_App/screens/select_language_screen.dart';
import 'package:eRealState_App/screens/start_screen.dart';
import 'package:eRealState_App/screens/tabs_screen.dart';
import 'package:eRealState_App/screens/transactions_screen.dart';
import 'package:eRealState_App/widgets/account_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;


import 'color_helper.dart';
import 'membership_plan_screen.dart';


class DrawerWidget extends StatefulWidget {

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {

  //Map<String, String> langPack;

  Widget cancelButton(BuildContext ctx, Map<String, String> langPack) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.grey[800]),
      ),
      child: Text(
        langPack['Cancel'],
        textDirection: CurrentUser.textDirection,
      ),
      onPressed: () {
        Navigator.of(ctx).pop();
      },
    );
  }

  Widget continueButton(BuildContext ctx, Map<String, String> langPack) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.grey[800]),
      ),
      child: Text(
        langPack['Log out'],
        textDirection: CurrentUser.textDirection,
      ),
      onPressed: () async {
        await Provider.of<APIHelper>(ctx, listen: false).logout();
        final logoutResponse = await FacebookAuth.instance.logOut();
        Phoenix.rebirth(context);
        Navigator.pushNamedAndRemoveUntil(
            ctx, TabsScreen.routeName, (Route<dynamic> route) => false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    final langPack = Provider.of<Languages>(context).selected;


    return  Drawer(
      child: ListView(
        children: <Widget>[
          Container(
              child: CurrentUser.isLoggedIn
                  ? UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                    color: HexColor()
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(CurrentUser.picture),
                ),
                accountName: Text(
                  CurrentUser.name != "" ? CurrentUser.name : "",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                accountEmail: Text(
                  CurrentUser.email != "" ? CurrentUser.email : "",
                  style: TextStyle(
                    color:Colors.white,
                  ),
                ),
              )
                  : UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                    color: HexColor()
                ),
                currentAccountPicture: CircleAvatar(
                  child: Icon(
                    Icons.account_circle_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                accountName: GestureDetector(
                  onTap: () {
                    if (CurrentUser.isLoggedIn) {
                    } else if (!CurrentUser.isLoggedIn) {
                      Navigator.of(context)
                          .pushNamed(StartScreen.routeName);
                    }
                  },
                  child: Text(
                    langPack['Log in or sign up to continue'],
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              )),
          if (CurrentUser.isLoggedIn)
            AccountListTile(
              title: langPack['Upgrade To Premium'],
              icon: Icons.star,
              onTapFunc: () {
                Navigator.of(context)
                    .pushNamed(MembershipPlanScreen.routeName);
              },
              trailing: Icon(
                CurrentUser.language == 'Arabic'
                    ? Icons.arrow_left
                    : Icons.arrow_right,
                color: Colors.grey[800],
              ),
            ),

          if (CurrentUser.isLoggedIn)
            AccountListTile(
              icon: Icons.timer,
              title: 'Expire Ads',
              onTapFunc: () {
                Navigator.of(context).pushNamed(ExpireAdsScreen.routeName);
              },
              trailing: Icon(
                CurrentUser.language == 'Arabic'
                    ? Icons.arrow_left
                    : Icons.arrow_right,
                color: Colors.grey[800],
              ),
            ),
          if (CurrentUser.isLoggedIn)
            AccountListTile(
              title: 'Transaction',
              icon: Icons.credit_card_outlined,
              onTapFunc: () {
                Navigator.of(context)
                    .pushNamed(TransactionsScreen.routeName);
              },
              trailing: Icon(
                CurrentUser.language == 'Arabic'
                    ? Icons.arrow_left
                    : Icons.arrow_right,
                color: Colors.grey[800],
              ),
            ),
          AccountListTile(
            title: langPack['Choose your language'],
            subtitle: CurrentUser.language,
            icon: Icons.language_outlined,
            onTapFunc: () {
              Navigator.of(context)
                  .pushNamed(SelectLanguageScreen.routeName)
                  .then((value) {
                setState(() {});
              });
            },
            trailing: Icon(
              CurrentUser.language == 'Arabic'
                  ? Icons.arrow_left
                  : Icons.arrow_right,
              color: Colors.grey[800],
            ),
          ),
          AccountListTile(
            title: 'Rate Us',
            icon: Icons.favorite_outline,
            onTapFunc: () async {
              await LaunchReview.launch();
            },

          ),
          AccountListTile(
            title: 'Share',
            icon: Icons.share,
            onTapFunc: () async {
              await Share.share(
                  'Check out this application: example-app.com');
            },

          ),
          AccountListTile(
            title: langPack['Support'],
            icon: Icons.phone,
            onTapFunc: () async {
              final Uri _emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'example@gmail.com',
                queryParameters: {'subject': 'Support'},
              );
              await urlLauncher.canLaunch(_emailLaunchUri.toString())
                  ? await urlLauncher.launch(_emailLaunchUri.toString())
                  : throw 'Could not launch ${_emailLaunchUri.toString()}';
            },

          ),
          AccountListTile(
            title: langPack['Terms & Condition'],
            icon: Icons.check_box_outlined,
            onTapFunc: () async {
              await urlLauncher.canLaunch(AppConfig.termsPageLink)
                  ? await urlLauncher.launch(AppConfig.termsPageLink)
                  : throw 'Could not launch ${AppConfig.termsPageLink}';
            },

          ),
          if (CurrentUser.isLoggedIn)
            AccountListTile(
              title: langPack['Log out'],
              icon: Icons.logout,
              onTapFunc: () {
                showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text(langPack['Log out']),
                      content: Text(
                        langPack['Are you sure you want to log out'],
                        textDirection: CurrentUser.textDirection,
                      ),
                      actions: [
                        cancelButton(ctx, langPack),
                        continueButton(ctx, langPack),
                      ],
                    );
                  },
                );
              },

            ),
          SizedBox(
            height: 15,
          ),
          if (!CurrentUser.isLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(AuthScreen.routeName, arguments: true);
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all<Size>(Size(0, 50)),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(HexColor()),
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: Text(
                  langPack['Log in or sign up to continue'],
                  textDirection: CurrentUser.textDirection,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
