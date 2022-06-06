import 'package:eRealState_App/helpers/app_config.dart';
import 'package:eRealState_App/models/membership_plan.dart';
import 'package:flutter/material.dart';
import 'package:eRealState_App/screens/color_helper.dart';
import 'package:provider/provider.dart';
import 'package:launch_review/launch_review.dart';

import '../fab_with_icons.dart';
import '../fab_bottom_app_bar.dart';
import '../layout.dart';
import './all_categories_screen.dart';
import './start_screen.dart';
import '../tabs/account_tab.dart';
import '../tabs/home_tab.dart';
import '../tabs/messages_tab.dart';
import '../tabs/my_ads_tab.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';
import '../models/location.dart';

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs';
  TabsScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TabsScreenState createState() => new _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> with TickerProviderStateMixin {
  int _lastSelected = 1;
  Map<String, String> langPack;
  List<MembershipPlan> membershipPlans = [];
  var membershipPlanUser;

  List<Widget> _tabs = [
    AllCategoriesScreen(),
    HomeTab(),
    MessagesTab(),
    NotificationsTab(),
  ];

  Future<void> _selectedTab(int index,) async {
    if(index == 0) {
      if (!CurrentUser.isLoggedIn ) {
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text(
                langPack['Login'],
                textDirection: CurrentUser.textDirection,
              ),
              content: Text(
                langPack['You must be logged in to use this feature'],
                textDirection: CurrentUser.textDirection,
              ),
              actions: [
                cancelButton(ctx),
                continueButton(ctx),
              ],
            );
          },
        );
      } else if (CurrentUser.isLoggedIn) {
        /*fetchMembershipPlans(apiHelper);
      fetchUserMembershipById(apiHelper, CurrentUser.id);*/

        /* await Navigator.of(context)
                .pushNamed(AllCategoriesScreen.routeName, arguments: {
              'newAd': true,
              'editAd': false,
            });
            CurrentUser.prodLocation = Location();*/
      }
    }

    setState(() {
      _lastSelected = index;
    });
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = index;
    });
  }

  Widget cancelButton(BuildContext ctx) {
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

  Widget continueButton(BuildContext ctx) {
    return TextButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.grey[800]),
      ),
      child: Text(
        langPack['Login'],
        textDirection: CurrentUser.textDirection,
      ),
      onPressed: () async {
        Navigator.of(context).pushNamed(StartScreen.routeName);
      },
    );
  }

  void _updateAlert(BuildContext ctx) {
    showDialog(
        context: ctx,
        builder: (ctx) {
          return AlertDialog(
            title: Text('New Version Available'),
            content: Text(
                'A new version of the application is available now for download. We have fixed few bugs and enhanced user experience. Please click on Upgrade Now button to update the application. It will not change any of your existing information.'),
            actions: [
              TextButton(
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.grey[800]),
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () async {
                  await LaunchReview.launch();
                },
                child: Text('Update Now'),
              ),
            ],
          );
        });
  }


  Future<void> fetchMembershipPlans(APIHelper apiHelper) async{
    apiHelper.fetchMembershipPlan().then((value) {
      print(value);
      setState(() {
        membershipPlans = value;
      });
    });
  }

  Future<void> fetchUserMembershipById(APIHelper apiHelper, String userId) async {
    membershipPlanUser = await apiHelper.fetchCurrentUserMembershipPlan(userId: userId);
    apiHelper.fetchCurrentUserMembershipPlan(userId: userId).then((value) {
      print(value);
      setState(() {
        membershipPlanUser = value;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    if (CurrentUser.showUpdateAlert) {
      Future.delayed(Duration.zero, () {
        print("server version ${AppConfig.appVersion}");
        if (AppConfig.appVersion != AppConfig.APP_VERION) _updateAlert(context);
      });
      CurrentUser.showUpdateAlert = false;
    }
    langPack = Provider.of<Languages>(context).selected;
    print(
        'Current user info: ${CurrentUser.id}, ${CurrentUser.name}, ${CurrentUser.email}, ${CurrentUser.username}, ${CurrentUser.picture}, ${CurrentUser.isLoggedIn}, ');
    final apiHelper = Provider.of<APIHelper>(context);
    return Scaffold(
      body: _tabs[_lastSelected],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            backgroundColor: HexColor(),
            label: 'SELLE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'CHAT',
          ),   BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'MY ADS',
          ),

        ],
        currentIndex: _lastSelected,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _selectedTab,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }


}
