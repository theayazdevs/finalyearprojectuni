import 'package:shared_preferences/shared_preferences.dart';

//class to store user preferences in the device storage
class GlobalPreferences {
  //stores the current auto listener value
  static bool autoListener = false;

  //update the auto-listener preferences in the device storage
  static Future<void> storeAutoListener() async {
    //instance of shared preferences
    final sharedPreferences = await SharedPreferences.getInstance();
    //store using the key specified as a boolean
    sharedPreferences.setBool('autoListener', autoListener);
  }
}
