import 'dart:async';

import 'package:eRealState_App/screens/drawer_screen.dart';
import 'package:eRealState_App/screens/expire_ads_screen.dart';
import 'package:eRealState_App/screens/membership_plan_screen.dart';
import 'package:eRealState_App/screens/start_screen.dart';
import 'package:eRealState_App/screens/transactions_screen.dart';
import 'package:eRealState_App/widgets/account_list_tile.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:eRealState_App/helpers/api_helper.dart';
import 'package:eRealState_App/screens/color_helper.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:facebook_audience_network/facebook_audience_network.dart';
// import 'package:advertising_id/advertising_id.dart';
// import 'package:native_admob_flutter/native_admob_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/product_item.dart';
import '../helpers/current_user.dart';
import '../models/product.dart';
import '../providers/products.dart';
import '../screens/all_categories_screen.dart';
import '../screens/search_ad_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/location_search_screen.dart';
import '../widgets/category_tile.dart';
import '../models/category.dart';
import '../models/location.dart';
import '../providers/languages.dart';
import '../helpers/ad_manager.dart';
import '../helpers/app_config.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Product> latestProducts = [];
  List<Product> featuredProducts = [];
  List<Category> categories = [];

//AdManager.adMobNativeAdUnit
//   final controller = NativeAdController();

  //var adLoaded = false;

  StreamSubscription _subscription;
  double _height = 0;
  final _adUnitId = 'ca-app-pub-9259101471660565/8555196884';
  //final _adUnitId = 'ca-app-pub-3940256099942544/8135179316';
  final _pageSize = 8;
  var _scrollController = ScrollController();
  int _listLength = 1;
  int productLimit = 8;
  bool firstBuild = true;
  bool isOnBottom = false;
  bool allPagesAreFetched = false;
  bool loadingNewPage = false;
  int page = 1;
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  bool isFacebookAdsShow = false;

  final PagingController<int, ProductItem> _pagingController =
  PagingController(firstPageKey: 1);

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
  void dispose() {
    // if (AppConfig.googleBannerOn) controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((value) => value.setBool("is_fresh_install", false));

    // AdvertisingId.id()
    //     .then((value) => print(" ${AppConfig.googleBannerOn} ididid $value"));

    // if (AppConfig.googleBannerOn) {
    //   controller.load(keywords: ['valorant', 'games', 'fortnite']);
    //   controller.onEvent.listen((event) {
    //     if (event.keys.first == NativeAdEvent.loaded) {
    //       printAdDetails(controller);
    //       setState(() {
    //         //adLoaded = true;
    //       });
    //     }
    //   });
    // }
    _scrollController.addListener(() async {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels == 0) {
        } else {
          print('Congrats... you reached the bottom....');
          if (!allPagesAreFetched && !loadingNewPage) {
            page++;
            List<Product> newProducts = [];
            setState(() {
              loadingNewPage = true;
              Timer(
                  Duration(milliseconds: 1),
                      () => _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.fastOutSlowIn,
                  ));
            });
            newProducts = await Provider.of<Products>(context, listen: false)
                .fetchHomeLatestProducts(
              userLocation: CurrentUser.location,
              limit: productLimit,
              page: page,
            );
            setState(() {
              loadingNewPage = false;
            });
            print('The LEEEEEEEEENGTH ${newProducts.length}');
            if (newProducts.length > 0) {
              latestProducts.addAll(newProducts);
              setState(() {
                _listLength++;
              });
              if (newProducts.length < productLimit) {
                allPagesAreFetched = true;
              }
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

    if (AppConfig.FCM_COUNT % 10 == 0) _handleFirebaseToken();

    AppConfig.FCM_COUNT++;
    _handleFirebaseTokenRefresh();
  }

  _handleFirebaseToken() async {
    // AdvertisingId.id().then((deviceID) {
    //   final apiHelper = Provider.of<APIHelper>(context, listen: false);
    //   apiHelper
    //       .addFirebaseDeviceToken(
    //       userId: CurrentUser.id,
    //       deviceId: deviceID,
    //       name: CurrentUser.name,
    //       token: AppConfig.FCM_ID)
    //       .then((result) {
    //     if (result != null) {
    //       if (!result) _handleFirebaseToken();
    //     }
    //   });
    // });
  }

  _handleFirebaseTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      AppConfig.FCM_ID = newToken;
      var pref = SharedPreferences.getInstance();
      pref.then((sharePref) {
        sharePref.setString("token_id", AppConfig.FCM_ID);
      });

      _handleFirebaseToken();
    });
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

  //this function is used to reformate the location in case it doesn't exist
  //using the product's country, state, and cityId
  String getProductLocation(Product product) {
    //creating a local variable so it would be easy to manibulate
    String location = "";
    if (product.location.isEmpty || product.location == null) {
      //the location doesn't exist
      //I am treing to combinate a new one
      location += product.cityId + ", " + product.state;
    } else {
      //the location exist
      //so I will only use it
      location = product.location;
    }
    //returning back the location
    return location;
  }


  @override
  Widget build(BuildContext context) {




    final langPack = Provider.of<Languages>(context).selected;

    final productsProvider = Provider.of<Products>(context);

    if (featuredProducts.length == 0 && latestProducts.length == 0) {
      categories = productsProvider.categoriesItems;
      featuredProducts = productsProvider.featuredAndUrgentItems;
      latestProducts = productsProvider.items;

      firstBuild = categories.length == 0 ? true : false;
    }

    if (loadingNewPage) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }
    return Scaffold(
      key: _key,
      //backgroundColor: Colors.white,
      drawer: DrawerWidget(),

      body: Container(
        color: Colors.white,
        child: RefreshIndicator(
          onRefresh: () {
            setState(() {
              productsProvider.clearProductsCache();
              categories = <Category>[];
              latestProducts = <Product>[];
              featuredProducts = <Product>[];
              _listLength = 1;
              firstBuild = true;
              page = 1;
              allPagesAreFetched = false;
            });
            return Future.delayed(Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            //padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: double.infinity,
                        child: Image.asset("assets/images/home_bg_house.png", fit: BoxFit.cover,),
                      ),
                      Positioned(
                        top: 10,
                        child: IconButton(
                          icon: Icon(Icons.menu, color: Colors.white, size: 30,),
                          onPressed: () {
                            _key.currentState.openDrawer();
                          },
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child:  IconButton(
                          icon: Icon(
                            Icons.notifications_active_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(NotificationsScreen.routeName);
                          },
                        ),
                      ),
                      Container(
                        height: 50,
                        width: double.infinity,
                        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height *0.25),
                        child: Row(
                          textDirection: CurrentUser.textDirection,
                          children: [
                            IconButton(
                              icon:  Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                CurrentUser.fromSearchScreen = false;
                                Navigator.of(context).pushNamed(LocationSearchScreen.routeName);
                              },
                            ),

                            Text(
                              CurrentUser.location.name ??
                                  CurrentUser.location.cityName,
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          CurrentUser.prodLocation = Location();
                          CurrentUser.fromSearchScreen = false;
                          print("Home Click::");
                          Navigator.of(context).pushNamed(SearchAdScreen.routeName);
                        },
                        child: Container(
                          height: 70,
                          margin: EdgeInsets.only(left: 10, right: 10, top: MediaQuery.of(context).size.height *0.35),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                width: 3,
                                color: Colors.grey[200],
                              )),
                          child: Row(
                            textDirection: CurrentUser.textDirection,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Container(
                                  child: Text(langPack['What are you looking for?'],
                                      textDirection: CurrentUser.textDirection,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      )),
                                ),
                              ),
                              Icon(
                                Icons.search,
                                color: Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 0,
                    bottom: 0,
                    left: 15,
                    right: 0,
                  ),
                  child: Row(
                    textDirection: CurrentUser.textDirection,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        langPack['Categories'],
                        textDirection: CurrentUser.textDirection,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: TextButton(
                          child: Text(
                            langPack['All'],
                            textDirection: CurrentUser.textDirection,
                            style: TextStyle(
                              color: Colors.grey[800],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                AllCategoriesScreen.routeName,
                                arguments: {
                                  'newAd': false,
                                  'editAd': false,
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (firstBuild)
                  Container(
                    height: 50,
                    child: FutureBuilder(
                        future: Provider.of<Products>(context, listen: false)
                            .fetchCategories(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return Center(
                                child: Container(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              );
                              break;
                            default:
                              if (snapshot.hasError)
                                return Container(
                                    child: Text(snapshot.error.toString()));
                              for (int j = 0; j < snapshot.data.length; j++) {
                                categories.add(snapshot.data[j]);
                              }
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,

                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 9,
                                  itemBuilder: (ctx, i) => CategoryTile(
                                    category: categories[i],
                                  ),
                                ),
                              );
                          }
                        }),
                  ),
                if (!firstBuild)
                  Container(
                    height: 50,
                    child: FutureBuilder(
                        future: Provider.of<Products>(context, listen: false)
                            .fetchCategories(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return Center(
                                child: Container(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              );
                              break;
                            default:
                              if (snapshot.hasError)
                                return Container(
                                    child: Text(snapshot.error.toString()));
                              for (int j = 0; j < snapshot.data.length; j++) {
                                categories.add(snapshot.data[j]);
                              }
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: 0,
                                  bottom: 0,

                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 9,
                                  itemBuilder: (ctx, i) => CategoryTile(
                                    category: categories[i],
                                  ),
                                ),
                              );
                          }
                        }),
                  ),

                if (AppConfig.isPremium)
                  Column(
                    children: [
                      Divider(
                        height: 30,
                      ),
                      Text(
                        langPack['Featured and Urgent Ads'],
                        textDirection: CurrentUser.textDirection,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      if (firstBuild)
                        FutureBuilder(
                          future: Provider.of<Products>(context, listen: false)
                              .fetchFeaturedProducts(CurrentUser.location),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Container(
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    backgroundColor: Colors.grey,
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasData && snapshot.data != null ) {
                              for (int i = 0; i < snapshot.data.length; i++) {
                                print(snapshot.data[i]);
                                featuredProducts.add(snapshot.data[i]);
                              }
                              return Container(
                                padding: const EdgeInsets.only(
                                  top: 0,
                                  bottom: 15,
                                  left: 15,
                                  right: 0,
                                ),
                                height:
                                MediaQuery.of(context).size.width * 3.3 / 5,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data.length,
                                  itemBuilder: (ctx, i) {
                                    return Row(
                                      children: [
                                        ProductItem(
                                          id: snapshot.data[i].id,
                                          isHighlighted: snapshot.data[i].isHighlighted,
                                          isFeatured:
                                          snapshot.data[i].isFeatured,
                                          isUrgent: snapshot.data[i].isUrgent,
                                          name: snapshot.data[i].name,
                                          imageUrl: snapshot.data[i].picture,
                                          price: snapshot.data[i].price,
                                          location: getProductLocation(
                                              snapshot.data[i]),
                                          currency: snapshot.data[i].currency,
                                        ),
                                        SizedBox(width: 20),
                                      ],
                                    );
                                  },
                                ),
                              );
                            }
                            return Text('No ads available in this location');
                          },
                        ),
                      if (!firstBuild && featuredProducts.length > 0)
                        Container(
                          padding: const EdgeInsets.only(
                            top: 0,
                            bottom: 15,
                            left: 15,
                            right: 0,
                          ),
                          height: MediaQuery.of(context).size.width * 3.3 / 5,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: featuredProducts.length,
                            itemBuilder: (ctx, i) {
                              if (true) {
                                return Row(
                                  children: [
                                    ProductItem(
                                      id: featuredProducts[i].id,
                                      isHighlighted: featuredProducts[i].isHighlighted ,
                                      isFeatured:
                                      featuredProducts[i].isFeatured,
                                      isUrgent: featuredProducts[i].isUrgent,
                                      name: featuredProducts[i].name,
                                      imageUrl: featuredProducts[i].picture,
                                      price: featuredProducts[i].price,
                                      location: getProductLocation(
                                          featuredProducts[i]),
                                      currency: featuredProducts[i].currency,
                                    ),
                                    SizedBox(width: 20),
                                  ],
                                );
                              }
                            },
                          ),
                        ),
                      if (!firstBuild && featuredProducts.length == 0)
                        Center(
                            child: Text('No ads available in this location')),
                    ],
                  ),
                Divider(
                ),
                Text(
                  langPack['Top Picks in Classifieds'],
                  textDirection: CurrentUser.textDirection,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: _listLength,
                  itemBuilder: (ctx, i) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!firstBuild && latestProducts.length > 0)
                        //building products grig
                          GridView.builder(
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              childAspectRatio: 3 / 5,
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),

                            itemCount: latestProducts.length % productLimit == 0
                                ? productLimit
                                : latestProducts.length < productLimit
                                ? latestProducts.length
                                : i == _listLength - 1
                                ? latestProducts.length -
                                i * productLimit
                                : productLimit,
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemBuilder: (ctx, index) {
                              return ProductItem(
                                isHighlighted: latestProducts[i * productLimit + index].isHighlighted,
                                id: latestProducts[i * productLimit + index].id,
                                name: latestProducts[i * productLimit + index]
                                    .name,
                                imageUrl:
                                latestProducts[i * productLimit + index]
                                    .picture,
                                price: latestProducts[i * productLimit + index]
                                    .price,
                                location: getProductLocation(
                                    latestProducts[i * productLimit + index]),
                                isFeatured:
                                latestProducts[i * productLimit + index]
                                    .isFeatured,
                                isUrgent:
                                latestProducts[i * productLimit + index]
                                    .isUrgent,
                                currency:
                                latestProducts[i * productLimit + index]
                                    .currency,
                              );

                            },
                          ),
                        if (!firstBuild && latestProducts.length == 0)
                          Center(
                            child: Text('No ads available in this location'),
                          ),
                        if (firstBuild)
                          FutureBuilder(
                            future: Provider.of<Products>(
                              context,
                              listen: false,
                            ).fetchHomeLatestProducts(
                              page: page,
                              limit: productLimit,
                              userLocation: CurrentUser.location,
                            ),
                            builder: (ctx, snapshot) {
                              firstBuild = false;
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                  break;
                                default:
                                  if (snapshot.hasError) {
                                    return Container(
                                        child: Text(snapshot.error.toString()));
                                  }
                                  if (snapshot.data.length < productLimit) {
                                    allPagesAreFetched = true;
                                  }
                                  if (snapshot.data.length > 0) {
                                    for (int j = 0;
                                    j < snapshot.data.length;
                                    j++) {
                                      latestProducts.add(snapshot.data[j]);
                                    }
                                    return GridView.builder(
                                      gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 20,
                                        mainAxisSpacing: 20,
                                        childAspectRatio: 3 / 5,
                                      ),
                                      padding: EdgeInsets.all(10),
                                      itemCount: snapshot.data.length,
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      itemBuilder: (ctx, index) {
                                        return ProductItem(
                                          isHighlighted: snapshot
                                              .data[i * productLimit + index].isHighlighted,
                                          id: snapshot
                                              .data[i * productLimit + index]
                                              .id,
                                          name: snapshot
                                              .data[i * productLimit + index]
                                              .name,
                                          imageUrl: snapshot
                                              .data[i * productLimit + index]
                                              .picture,
                                          price: snapshot
                                              .data[i * productLimit + index]
                                              .price,
                                          location: getProductLocation(snapshot
                                              .data[i * productLimit + index]),
                                          isFeatured: snapshot
                                              .data[i * productLimit + index]
                                              .isFeatured,
                                          isUrgent: snapshot
                                              .data[i * productLimit + index]
                                              .isUrgent,
                                          currency: snapshot
                                              .data[i * productLimit + index]
                                              .currency,
                                        );
                                      },
                                    );
                                  }
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Text(
                                        'No ads available in this location'),
                                  );
                              }
                            },
                          ),
                        //adLoaded ? _getAdContainer() : Container(),
                        _getAdContainer(),
                        if (loadingNewPage)
                          Center(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              width: 100,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}