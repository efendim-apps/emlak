import 'package:flutter/material.dart';
import 'package:eRealState_App/screens/color_helper.dart';
import 'package:eRealState_App/screens/search_ad_screen.dart';
import 'package:provider/provider.dart';

import '../providers/languages.dart';
import '../helpers/current_user.dart';
import '../helpers/db_helper.dart';
import '../screens/tabs_screen.dart';
import '../helpers/api_helper.dart';
import '../providers/products.dart';

class LocationSearchScreenFirst extends StatefulWidget {
  static const routeName = '/location-search';
  @override
  _LocationSearchScreenFirstState createState() =>
      _LocationSearchScreenFirstState();
}

class _LocationSearchScreenFirstState extends State<LocationSearchScreenFirst> {
  bool _isState = false;
  bool _isCountry = true;
  String _keyword = '';
  String _keywordForSearch = '';
  String _chosenStateCode = '';
  String _chosenStateName = '';
  String _chosenCountryName = '';
  String _chosenCountryCode = '';
  String _chosenCityName = '';
  String _chosenCityCode = '';

  @override
  Widget build(BuildContext context) {
    final langPack = Provider.of<Languages>(context).selected;
    final productsProvider = Provider.of<Products>(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: SafeArea(
          child: AppBar(
            shape: AppBarBottomShape(),

            flexibleSpace: Container(
              padding: EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 10,
                right: 10,
              ),
              child: TextField(
                cursorColor: Colors.grey[800],
                textDirection: CurrentUser.textDirection,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintTextDirection: CurrentUser.textDirection,
                  labelText: langPack[_isCountry
                      ? 'Country'
                      : _isState
                      ? 'State'
                      : 'City'],
                  suffixIcon: Icon(Icons.search, color: Colors.grey),
                ),
                onChanged: (value) {
                  setState(() {
                    _keyword = value;
                    _keywordForSearch = value;
                  });

                },
              ),
            ),
            //title: Text('Home Tab'),
            backgroundColor: HexColor(),
            elevation: 2,
          ),
        ),
      ),
      body: _isCountry
          ? FutureBuilder(
          future: Provider.of<APIHelper>(context, listen: false)
              .fetchCountryDetails(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(top: 20),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,

                    ),
                  ),
                );

                break;
              default:
                if (snapshot.hasError) {
                  return Container(
                    child: Text(snapshot.error.toString()),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (content, i) => ListTile(
                    trailing: CurrentUser.language == 'Arabic'
                        ? null
                        : Icon(Icons.arrow_right),
                    leading: CurrentUser.language == 'Arabic'
                        ? Icon(Icons.arrow_left)
                        : null,

                    title: Text(
                      snapshot.data[i]['name'],
                      textAlign: CurrentUser.language == 'Arabic'
                          ? TextAlign.end
                          : TextAlign.start,
                    ),
                    onTap: () async {
                      _keywordForSearch = '';
                      _chosenCountryName = snapshot.data[i]['name'];
                      _chosenCountryCode = snapshot.data[i]['code'];
                      CurrentUser.location.countryCode = _chosenCountryCode;
                      print("data out here $_chosenCountryName");
                      if (!CurrentUser.uploadingAd) {
                        //CurrentUser.location.name = '$_chosenCountryName';
                        //CurrentUser.location.countryCode = _chosenCountryCode;
                        print(CurrentUser.location.countryCode);
                        print(
                            "data in here ${CurrentUser.location.name} | ${_chosenCountryCode}");
                        await DBHelper.update('user_info', {
                          'id': CurrentUser.id,
                          'locationName': '',
                          'locationCityId': '',
                          'locationCityName': '',
                          'locationStateId': '',
                          'locationStateName':
                          _chosenCountryName,
                          'locationCityState':
                          '',
                          'countryCode': CurrentUser.location.countryCode
                        });






                        productsProvider.clearProductsCache();
                        setState(() {
                          _isCountry = false;
                          _isState = true;
                        });
                      } else {


                        Provider.of<CurrentUser>(context, listen: false)
                            .setProductLocation(
                          prodCityId: '',
                          prodCityName: '',
                          prodCityState: '',
                          prodCountryCode: _chosenCountryCode,
                          prodCountryName: _chosenCountryName,
                          prodLatitude: '',
                          prodLocationName: _chosenCountryName,
                          prodLongitude: '',
                          prodStateId: _chosenStateCode,
                          prodStateName: _chosenStateName,



                        );
                        setState(() {
                          _isCountry = false;
                          _isState = true;
                        });
                      }
                    },
                  ),
                );
            }
          })
          : _isState
          ? FutureBuilder(
          future: Provider.of<APIHelper>(context, listen: false)
              .fetchStateDetailsByCountry(
              countryCode: _chosenCountryCode),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                print('State Waiting !');
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
                if (snapshot.hasError) {
                  return Container(
                    child: Text(snapshot.error.toString()),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (content, i) {
                    print('Fetched State ::::>>>> ${snapshot.data[i]}');
                    if (snapshot.data[i].name
                        .toLowerCase()
                        .contains(_keywordForSearch.toLowerCase())) {
                      return ListTile(
                        trailing: CurrentUser.language == 'Arabic'
                            ? null
                            : Icon(Icons.arrow_right),
                        leading: CurrentUser.language == 'Arabic'
                            ? Icon(Icons.arrow_left)
                            : null,
                        title: Text(
                          snapshot.data[i].name,
                          textAlign: CurrentUser.language == 'Arabic'
                              ? TextAlign.end
                              : TextAlign.start,
                        ),
                        onTap: () async {
                          _keywordForSearch = '';
                          _chosenStateCode = snapshot.data[i].code;
                          _chosenStateName = snapshot.data[i].name;

                          if (!CurrentUser.uploadingAd) {
                            CurrentUser.location.name =
                                _chosenStateName +
                                    ', ' +
                                    CurrentUser.location.countryName;
                            CurrentUser.location.cityId = '';
                            CurrentUser.location.cityName = '';
                            CurrentUser.location.stateId =
                                _chosenStateCode;
                            CurrentUser.location.stateName =
                                _chosenStateName;
                            CurrentUser.location.cityState = '';
                            CurrentUser.location.countryCode =
                                _chosenCountryCode;

                            await DBHelper.update('user_info', {
                              'id': CurrentUser.id,
                              'locationName': CurrentUser.location.name,
                              'locationCityId': '',
                              'locationCityName': '',
                              'locationStateId':
                              CurrentUser.location.stateId,
                              'locationStateName':
                              CurrentUser.location.stateName,
                              'locationCityState': '',
                              'countryCode': CurrentUser.location.countryCode

                            });
                            productsProvider.clearProductsCache();
                          } else {

                            Provider.of<CurrentUser>(context,
                                listen: false)
                                .setProductLocation(
                              prodCityId: '',
                              prodCityName: '',
                              prodCityState: '',
                              prodCountryCode: _chosenCountryCode,
                              prodCountryName: _chosenCountryName,
                              prodLatitude: '',
                              prodLocationName: _chosenStateName +
                                  ', ' +
                                  _chosenCountryName,
                              prodLongitude: '',
                              prodStateId: _chosenStateCode,
                              prodStateName: _chosenStateName,
                            );

                          }

                          setState(() {
                            _isState = false;
                          });

                        },
                      );
                    }
                    return Container();
                  },
                );
            }
          })
          : FutureBuilder(
          future:
          Provider.of<APIHelper>(context).fetchCityDetailsByState(
            stateCode: _chosenStateCode,
            keywords: _keywordForSearch,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Container(
                    width: 100,
                    margin: EdgeInsets.only(top: 20),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                );

                break;
              default:
                if (snapshot.hasError) {
                  return Container(
                    child: Text(snapshot.error.toString()),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (content, i) => ListTile(
                    trailing: CurrentUser.language == 'Arabic'
                        ? null
                        : Icon(Icons.arrow_right),
                    leading: CurrentUser.language == 'Arabic'
                        ? Icon(Icons.arrow_left)
                        : null,
                    title: Text(
                      snapshot.data[i]['name'],
                      textAlign: CurrentUser.language == 'Arabic'
                          ? TextAlign.end
                          : TextAlign.start,
                    ),
                    onTap: () async {
                      _keywordForSearch = '';
                      _chosenCityName = snapshot.data[i]['name'];
                      _chosenCityCode = snapshot.data[i]['id'];
                      if (!CurrentUser.uploadingAd) {
                        CurrentUser.location.name =
                        '$_chosenCityName, $_chosenStateName';
                        CurrentUser.location.cityId = _chosenCityCode;
                        CurrentUser.location.cityName = _chosenCityName;
                        CurrentUser.location.stateId = _chosenStateCode;
                        CurrentUser.location.stateName =
                            _chosenStateName;
                        CurrentUser.location.cityState =
                        '$_chosenCityName, $_chosenStateName';
                        CurrentUser.location.countryCode = _chosenCountryCode;

                        await DBHelper.update('user_info', {
                          'locationName': CurrentUser.location.name,
                          'locationCityId': CurrentUser.location.cityId,
                          'locationCityName':
                          CurrentUser.location.cityName,
                          'locationStateId':
                          CurrentUser.location.stateId,
                          'locationStateName':
                          CurrentUser.location.stateName,
                          'locationCityState':
                          CurrentUser.location.cityState,
                          'countryCode':
                          CurrentUser.location.countryCode
                        });
                        productsProvider.clearProductsCache();
                        FocusScope.of(context).requestFocus(FocusNode());
                        Navigator.pushNamedAndRemoveUntil(
                            context,
                            TabsScreen.routeName,
                                (Route<dynamic> route) => false);
                      } else {

                        Provider.of<CurrentUser>(context, listen: false)
                            .setProductLocation(
                          prodCityId: _chosenCityCode,
                          prodCityName: _chosenCityName,
                          prodCityState:
                          '$_chosenCityName, $_chosenStateName',
                          prodCountryCode: _chosenCountryCode,
                          prodCountryName: _chosenCountryName,
                          prodLatitude: snapshot.data[i]['latitude'],
                          prodLocationName:
                          '${snapshot.data[i]['name']}, $_chosenStateName',
                          prodLongitude: snapshot.data[i]['longitude'],
                          prodStateId: _chosenStateCode,
                          prodStateName: _chosenStateName,
                        );

                        CurrentUser.uploadingAd = false;
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                );
            }
          }),
    );
  }
}
