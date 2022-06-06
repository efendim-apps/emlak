import 'package:eRealState_App/helpers/ad_manager.dart';
import 'package:eRealState_App/helpers/app_config.dart';
// import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:eRealState_App/helpers/db_helper.dart';
import 'package:eRealState_App/screens/color_helper.dart';
// import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:provider/provider.dart';

import '../widgets/grid_products.dart';
import '../widgets/my_product_item.dart';
import '../helpers/api_helper.dart';
import '../helpers/current_user.dart';
import '../providers/languages.dart';
import '../screens/membership_plan_screen.dart';
import '../providers/products.dart';

class NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context, listen: false).selected;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          shape: AppBarBottomShape(),
          iconTheme: IconThemeData(
            color: Colors.grey[800],
          ),
          elevation: 2,
          backgroundColor: Colors.grey.shade200,
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 4,
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            tabs: [
              Tab(
                text: 'ADS',
              ),
              Tab(
                text: 'FAVOURITES',
              ),
            ],
          ),
          title: Text(
            langPack['My Ads'],
            textDirection: CurrentUser.textDirection,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            MyAds(),
            FavoriteAds(),
          ],


        ),
      ),
    );
  }
}

class MyAds extends StatefulWidget {
  @override
  _MyAdsState createState() => _MyAdsState();
}

class _MyAdsState extends State<MyAds> {
  List myProducts = [];
  final _pageSize = 8;
  var _scrollController = ScrollController();
  int _listLength = 1;
  int productLimit = 8;
  bool firstBuild = true;
  bool isOnBottom = false;
  bool allPagesAreFetched = false;
  bool loadingNewPage = false;
  int page = 1;
  AppConfig appConfig = AppConfig();
  // final controller = NativeAdController();
  bool isFacebookAdsShow = false;


  // void printAdDetails(NativeAdController controller) async {
  //   /// Just for showcasing the ability to access
  //   /// NativeAd's details via its controller.
  //   print("------- NATIVE AD DETAILS: -------");
  //   print(controller.headline);
  //   print(controller.body);
  //   print(controller.price);
  //   print(controller.store);
  //   print(controller.callToAction);
  //   print(controller.advertiser);
  //   print(controller.iconUri);
  //   print(controller.imagesUri);
  //   print("----END----");
  // }


  @override
  void initState() {
    super.initState();
    if (AppConfig.googleBannerOn) {
      // controller.load(keywords: ['valorant', 'games', 'fortnite']);
      // controller.onEvent.listen((event) {
      //   if (event.keys.first == NativeAdEvent.loaded) {
      //     printAdDetails(controller);
      //     setState(() {
      //       //adLoaded = true;
      //     });
      //   }
      // });
    }
    _scrollController.addListener(() async {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
        } else {
          print('Congrats... you reached the bottom....');
          if (!allPagesAreFetched && !loadingNewPage) {
            page++;
            List newProducts = [];
            setState(() {
              loadingNewPage = true;
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: 300),
                curve: Curves.fastOutSlowIn,
              );
            });
            newProducts = await Provider.of<APIHelper>(context, listen: false)
                .fetchProductsForUser(
              userId: CurrentUser.id,
              limit: productLimit,
              page: page,
            );
            setState(() {
              loadingNewPage = false;
            });
            if (newProducts.length > 0) {
              for (int i = 0; i < newProducts.length; i++) {
                myProducts.add(newProducts[i]);
              }
              setState(() {
                _listLength++;
              });
            } else {
              allPagesAreFetched = true;
            }
          }
        }
      }
    });
    if (!AppConfig.googleBannerOn) {
      // FacebookAudienceNetwork.init(
      //   testingId: "745FD4A0981807548C46C1EDCBF8696B",
      // ); //optional,

      AdManager.loadInterstitialAd();
      isFacebookAdsShow = true;
      //}
    }
  }

  Widget _getAdContainer() {
    return AppConfig.googleBannerOn
        ? Container(
      // child: controller.isLoaded
      //     ? AdManager.nativeAdsView()
      //     : Container(
      //   child: Text("Banner"),
      // ),
    )
        : Container(
      alignment: Alignment(0.5, 1),
      // child: FacebookNativeAd(
      //   //need a new placement id for advanced native ads
      //   placementId: AdManager.fbNativePlacementId,
      //   adType: NativeAdType.NATIVE_AD,
      //   listener: (result, value) {
      //     print("Native Banner Ad: $result --> $value");
      //   },
      // ),
    );
  }

  void dispose() {
    // if (AppConfig.googleBannerOn) controller.dispose();
    super.dispose();

  }
  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context, listen: false).selected;
    final apiHelper = Provider.of<APIHelper>(context, listen: false);
    final productsProvider = Provider.of<Products>(context);

    if (myProducts.length == 0) {
      myProducts = productsProvider.myProductsItems;
      firstBuild = myProducts.length == 0 ? true : false;
    }

    if (loadingNewPage) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }
    if (CurrentUser.isLoggedIn) {
      return RefreshIndicator(
        onRefresh: () {
          setState(() {
            productsProvider.myProducts = [];
            myProducts = [];
            _listLength = 1;
            firstBuild = true;
            page = 1;
            allPagesAreFetched = false;
          });
          return Future.delayed(Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!firstBuild)
                ListView.builder(
                  itemCount: myProducts.length,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemBuilder: (ctx, i) {
                    List<String> locations = [
                      myProducts[i]['city'],
                      myProducts[i]['state']
                    ];
                    locations.removeWhere(
                            (element) => element == null || element == '');
                    locations.join(',');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i == 0)
                          Container(
                            margin: EdgeInsets.only(
                              top: 10,
                              left: 10,
                              right: 10,
                            ),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.blueAccent,
                            ),
                            child: Row(
                              textDirection: CurrentUser.textDirection,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Heavy discount on Packages',
                                    softWrap: true,
                                    maxLines: null,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                TextButton(
                                  child: Text(
                                    'View Packages',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                        MembershipPlanScreen.routeName);
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        side: BorderSide(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        MyProductItem(
                          parent: this,
                          stateId: myProducts[i]['stateid'].toString(),
                          cityId: myProducts[i]['cityid'].toString(),
                          picture: myProducts[i]['picture'].toString(),
                          currencySign: myProducts[i]['currency'] ?? "₹",
                          location: locations.join(", "),
                          id: myProducts[i]['id'].toString(),
                          name: myProducts[i]['product_name'].toString(),
                          createdAt: myProducts[i]['created_at'].toString(),
                          expireAt: myProducts[i]['expire_date'].toString(),
                          price: myProducts[i]['price'].toString(),
                          status: myProducts[i]['status'].toString(),
                        ),
                        if (i == myProducts.length - 1)
                          SizedBox(
                            height: 20,
                          ),
                      ],
                    );
                  },
                ),
              if (firstBuild)
                FutureBuilder(
                  future: apiHelper.fetchProductsForUser(
                      userId: CurrentUser.id, limit: productLimit, page: page),
                  builder: (ctx, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                            width: 100,
                            margin: EdgeInsets.only(top: 10),
                            child: LinearProgressIndicator(
                              backgroundColor: Colors.grey,
                            ),
                          ),
                        );
                        break;
                      default:
                        firstBuild = false;
                        if (snapshot.hasError) {
                          return Container(
                            child: Text(snapshot.error.toString()),
                          );
                        }
                        if (snapshot.data.length < productLimit) {
                          allPagesAreFetched = true;
                        }
                        if (snapshot.data.length > 0) {
                          myProducts.addAll(snapshot.data);
                          productsProvider.myProducts = myProducts;


                          return ListView.builder(
                            itemCount: snapshot.data.length,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemBuilder: (ctx, i) {
                              print('${snapshot.data[i]}');
                              List<String> locations = [
                                snapshot.data[i]['city'],
                                snapshot.data[i]['state']
                              ];
                              locations.removeWhere((element) =>
                              element == null || element == '');
                              locations.join(',');
                              print("Le produit personnel");
                              print(snapshot.data[i]);
                              return Column(
                                children: [
                                  if (i == 0)
                                    Container(
                                      margin: EdgeInsets.only(
                                        top: 10,
                                        left: 10,
                                        right: 10,
                                      ),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.blueAccent,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Heavy discount on Packages',
                                              softWrap: true,
                                              maxLines: null,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            child: Text(
                                              'View Packages',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  MembershipPlanScreen
                                                      .routeName);
                                            },
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(5),
                                                  side: BorderSide(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  MyProductItem(
                                    parent: this,
                                    stateId:
                                    myProducts[i]['stateid'].toString(),
                                    cityId: myProducts[i]['cityid'].toString(),
                                    picture:
                                    myProducts[i]['picture'].toString(),
                                    currencySign:
                                    myProducts[i]['currency'] ?? "₹",
                                    location: locations.join(", "),
                                    id: myProducts[i]['id'].toString(),
                                    name: myProducts[i]['product_name']
                                        .toString(),
                                    createdAt:
                                    myProducts[i]['created_at'].toString(),
                                    expireAt:
                                    myProducts[i]['expire_date'].toString(),
                                    price: myProducts[i]['price'].toString(),
                                    status: myProducts[i]['status'].toString(),
                                  ),
                                  if (i == snapshot.data.length - 1)
                                    SizedBox(
                                      height: 20,
                                    ),
                                ],
                              );
                            },
                          );
                        }
                    }
                    return Center(
                        child: Text(
                          langPack['No products found, please refine your search'],
                          textDirection: CurrentUser.textDirection,
                        ));
                  },
                ),
              _getAdContainer(),
              if (loadingNewPage)
                Center(
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(bottom: 30),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return Center(
          child: Text(
            langPack['You must be logged in to use this feature'],
            textDirection: CurrentUser.textDirection,
          ));
    }
  }
}

class FavoriteAds extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context, listen: false).selected;
    final apiHelper = Provider.of<APIHelper>(context, listen: false);
    Future getProducts() async {
      List<Map<String, dynamic>> productIdList =
      await DBHelper.queryFavProduct(DBHelper.favTableName, "NOT NULL");
      List<dynamic> result = [];
      for (int i = 0; i < productIdList.length; i++) {
        result.add(
          await apiHelper.fetchProductsDetails(
            itemId: productIdList[i]["prodId"],
          ),
        );
      }
      return result;
    }

    return FutureBuilder(
      future: getProducts(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
              width: 100,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey,
              ),
            ),
          );
        }
        if (snapshot.data.length > 0) {
          return GridProducts(
            productsList: snapshot.data,
            isMyAds: false,
          );
        }
        return Center(
            child: Text(
              langPack['No products found, please refine your search'],
              textDirection: CurrentUser.textDirection,
            ));
      },
    );
  }
}
