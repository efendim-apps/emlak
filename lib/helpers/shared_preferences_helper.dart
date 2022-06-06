import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefencesHelper {


  static Future<void> setDefaultLanguage(String language) async {
    if (language != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', language);
    }
  }

  static Future<String> getDefaultLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String defaultLanguage;
    if (prefs.containsKey('language')) {
      defaultLanguage = await prefs.get('language');
    } else {
      defaultLanguage = "English";
    }
    return defaultLanguage;
  }

}