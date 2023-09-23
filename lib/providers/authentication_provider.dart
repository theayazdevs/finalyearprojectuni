import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_exceptions.dart';
import '../models/encrypt_data.dart';

//Authentication class, using Change Notifier to notify listeners of any changes made
class Authentication with ChangeNotifier {
  //to store user token provided by FireBase
  late String _userToken = '';

  //time that the provided token will expire
  late DateTime _tokenExpiry = DateTime.now();

  //storing the unique user ID
  late String _userID = '';

  //storing the user role
  late int _theUserRole = 3;

  //timer used in auto logout feature when the token expires
  Timer? tokenTimer = Timer(const Duration(seconds: 0), () {});

  //check if the user is authenticated, return true if null, false if not null
  bool get userAuthenticated {
    //if there is a token and it did'nt expire then the user is authenticated
    return theToken != null;
  }

  //check if the user with that role exists or not and return it
  int get userRoleVerified {
    return _theUserRole;
  }

  //get the token if it is not empty else returns null
  String? get theToken {
    if (_userToken != '') {
      return _userToken;
    }
    return null;
  }

  //get the current user's ID
  String? get theUserID {
    return _userID;
  }

  Future<void> _authenticateUser(
      String gotEmail, String gotPassword, String urlSignInOrUp, int role) async {
    //role selected by the user
    _theUserRole = role;
    //url to google authentication api
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSignInOrUp?key=AIzaSyCwpLm6dwo2G1iU3Rzwn9CySPUqBneun4g');
        //'https://identitytoolkit.googleapis.com/v1/accounts:$urlSignInOrUp?key=AIzaSyC56W_6DRmecLGCI9DtlyWjhsUpP50BIMs');
    try {
      //posting email, password for a check, and storing the response
      final response = await http.post(
        url,
        body: json.encode(
          {'email': gotEmail, 'password': gotPassword, 'returnSecureToken': true},
        ),
      );
      //decoding response from the firebase authentication
      final authenticationResponse = json.decode(response.body);
      //throw exception when an error occurs
      if (authenticationResponse['error'] != null) {
        throw AppExceptions(authenticationResponse['error']['message']);
      }
      //if successful then store the user token, user ID and token expiry
      _userToken = authenticationResponse['idToken'];
      _userID = authenticationResponse['localId'];
      _tokenExpiry = DateTime.now().add(
        Duration(
          seconds: int.parse(authenticationResponse['expiresIn']),
        ),
      );
      //log('login successful');
      //theUserRole = role;
      //postUserDatabase(_userID, role);
      //if signing up store user data on database
      if (urlSignInOrUp == 'signUp') {
        await postUserDatabase(_userID, role, gotEmail);
        //print('ran the method post to database');
      }
      //if signing in, check and verify user role from database
      if (urlSignInOrUp == 'signInWithPassword') {
        //print(await verifyUser(email, role));
        bool verResult = await verifyUser(gotEmail, role);
        if (verResult) {
          _theUserRole = role;
        } else {
          _theUserRole = 3;
          //log("The role in user authenticate now is: $_theUserRole");
          //throw role error exception
          throw AppExceptions('role error');
        }
      }
      //debugPrint(_userToken);
      //setting the logout timer based on the token expiry when logged in
      _automaticallyLogout();
      //to trigger the consumer in main dart file, when changes occur
      notifyListeners();
      //storing user details in the device, for the auto login next time
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('email', gotEmail);
      //encrypting
      await AesEncryption.encryptAES(gotPassword);
      sharedPreferences.setString(
          'password', AesEncryption.encrypted!.base64.toString());
      sharedPreferences.setInt('role', _theUserRole);
      //log('credentials stored in device');
    } catch (error) {
      log("authenticate user:$error");
      rethrow;
    }
  }

  //signup new users
  Future<void> signup(String gotEmail, String gotPassword, int role) async {
    if (role == 1 || role == 0) {
      return _authenticateUser(gotEmail, gotPassword, 'signUp', role);
    } else {
      //log("The role in sign up now is: $role");
      //theUserRole = 3;
      throw AppExceptions('role error');
    }
  }

  //sign in existing users
  Future<void> login(String gotEmail, String gotPassword, int role) async {
    if (role == 1 || role == 0) {
      return _authenticateUser(gotEmail, gotPassword, 'signInWithPassword', role);
    } else {
      //log("The role in login now is: $role");
      //theUserRole = 3;
      throw AppExceptions('role error');
    }
  }

  //logout the current user
  Future<void> userLogout() async {
    //log('logout method called');
    //reset authentication variables
    _userToken = '';
    _userID = '';
    _tokenExpiry = DateTime.now();
    //reset auto logout timer if it exists
    if (tokenTimer != null) {
      tokenTimer!.cancel();
      tokenTimer = null;
    }
    //notify the objects listening about changes
    notifyListeners();
  }

  //auto logout when the token expires
  void _automaticallyLogout() {
    //log('auto-logout called');
    //check if a timer already exists
    if (tokenTimer != null) {
      //log('cancelling auto-logout timer');
      //cancel existing timer
      tokenTimer!.cancel();
    }
    final timeToExpiry = _tokenExpiry.difference(DateTime.now()).inSeconds;
    //log('time to expiry in auto-logout now: $timeToExpiry');
    //logout when token expires
    tokenTimer = Timer(Duration(seconds: timeToExpiry), userLogout);
    //testing
    //tokenTimer = Timer(Duration(seconds: 15),logout);
  }

  //posting new user data on sign up to the database
  Future<void> postUserDatabase(
      String userID, int role, String theEmail) async {
    String roleText = '';
    //print("Role is : ---->  $role");
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    const String charactersPath = '/users.json';
    final Map<String, String> queryParameters = <String, String>{
      'auth': _userToken,
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    try {
      //converting integer to the relevant role text
      if (role == 0) {
        roleText = 'customer';
      } else if (role == 1) {
        roleText = 'business';
      }
      //send data to database
      await http.post(
        url,
        body: json.encode({
          'userID': userID,
          'role': roleText,
          'email': theEmail,
        }),
      );
    } catch (error) {
      log(error.toString());
      log('error with the post user to database method');
      //throw error;
      rethrow;
    }
  }

  //verify the role selected by the user based on email
  Future<bool> verifyUser(String gotEmail, int gotRole) async {
    String roleText = '';
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    const String charactersPath = '/users.json';
    final Map<String, String> queryParameters = <String, String>{
      'auth': _userToken,
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    //print(url);
    try {
      final response = await http.get(url);
      final extractedData =
          json.decode(response.body.toString()) as Map<String, dynamic>;
      if (extractedData == null) {
        return false;
      }
      //debugging
      //log(extractedData.toString());
      var matchFound = false;
      if (gotRole == 0) {
        roleText = 'customer';
      } else {
        roleText = 'business';
      }
      //log("user tried email: $gotEmail and role: $roleText");
      for (var key in extractedData.keys) {
        var item = extractedData[key];
        if (item['email'] == gotEmail && item['role'] == roleText) {
          //print('Email Match found: ${item['email']}');
          //print('with role match found as: ${item['role']}');
          matchFound = true;
        }
      }
      //return true if verified and false if not
      return matchFound;
    } catch (error) {
      //throw (error);
      rethrow;
    }
  }
}
