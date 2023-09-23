import 'dart:convert';
import 'package:flutter/cupertino.dart';

//as http to avoid any name clashes
import 'package:http/http.dart' as http;

import '../providers/business_data_provider.dart';

//BusinessDetails class, using Change Notifier to notify listeners of any changes made
//mixin is like merging classes (keyword is WITH)
class BusinessDetails with ChangeNotifier {
  //to store the user token
  final String _userToken;
  //to store the user ID
  final String _userID;
  //to store the instance of business data class
  BusinessData businessData = BusinessData(
    id: '',
    businessName: '',
    businessType: '',
    businessDoorNo: '',
    businessPostCode: '',
    deliveryOrCollection: '',
    openTimes: '',
    ownerID: '',
  );
  //constructor
  BusinessDetails(this._userToken, this._userID, this.businessData);
  //returns the current data stored in the business data variable
  BusinessData get getBusinessDetails {
    return businessData;
  }
  //add new business details to the database
  Future<void> addBusinessDetails(BusinessData theBusinessData) async {
    //database URL
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    var charactersPath = '/businessDetails.json';
    final Map<String, String> queryParameters = <String, String>{
      'auth': _userToken,
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    try {
      //post data as JSON encoded
      final response = await http.post(
        url,
        body: json.encode({
          'ownerID': _userID,
          'businessName': theBusinessData.businessName,
          'businessType': theBusinessData.businessType,
          'businessDoorNo': theBusinessData.businessDoorNo,
          'businessPostCode': theBusinessData.businessPostCode,
          'deliveryOrCollection': theBusinessData.deliveryOrCollection,
          'openTimes': theBusinessData.openTimes,
        }),
      );
      final newBusinessData = BusinessData(
        id: json.decode(response.body)['name'],
        businessName: theBusinessData.businessName,
        businessType: theBusinessData.businessType,
        businessDoorNo: theBusinessData.businessDoorNo,
        businessPostCode: theBusinessData.businessPostCode,
        deliveryOrCollection: theBusinessData.deliveryOrCollection,
        openTimes: theBusinessData.openTimes,
        ownerID: theBusinessData.ownerID,
      );
      businessData = newBusinessData;
      //used by the providers package, establishes a communication channel between interested widgets and this class
      //let certain widgets know about the updates made, so only widgets listening to this class will get rebuilt
      notifyListeners();
    } catch (error) {
      //error handling
      debugPrint("error in addBusinessDetails method : $error");
      //creating error to be handled by the other screen
      rethrow;
    }
  }
  //update current details stored on the database based on the new values provided by the user
  Future<void> updateBusinessDetails(
      String businessDataID, BusinessData newBusinessData) async {
    //updating data on the database
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    var charactersPath = '/businessDetails/$businessDataID.json';
    final Map<String, String> queryParameters = <String, String>{
      'auth': _userToken,
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    try {
      //merge data with patch in firebase
      await http.patch(url,
          body: json.encode({
            'businessName': newBusinessData.businessName,
            'businessType': newBusinessData.businessType,
            'businessDoorNo': newBusinessData.businessDoorNo,
            'businessPostCode': newBusinessData.businessPostCode,
            'deliveryOrCollection': newBusinessData.deliveryOrCollection,
            'openTimes': newBusinessData.openTimes,
          }));
      //notify about changes to the listeners
      notifyListeners();
    } catch (error) {
      //error handling
      debugPrint("error in updateBusinessDetails method : $error");
      //creating error to be handled by the other screen
      rethrow;
    }
  }
  //fetch details of the business stored on the database
  Future<void> fetchBusinessDetails(String byID) async {
    if(byID=='' || byID.isEmpty){
      //current user is owner
      byID=_userID;
    }
    //debugPrint('fetchAndSetMenu');
    //getting menu by owner ID
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    const String charactersPath = '/businessDetails.json';
    final Map<String, String> queryParameters = <String, String>{
      //'auth': currentUserToken,
      'auth': _userToken,
      'orderBy': '"ownerID"',
      //'equalTo': '"$_userID"',
      'equalTo': '"$byID"',
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    try {
      final response = await http.get(url);
      //debugPrint('getting data from database');
      //debugPrint('business data: ${response.body.toString()}');
      final extractedData =
          json.decode(response.body.toString()) as Map<String, dynamic>?;
      //debugPrint('business data extracted data: ${extractedData.toString()}');
      if (extractedData != null && extractedData.isNotEmpty) {
        extractedData.forEach((businessDetailsID, businessDetailsData) {
          //debugPrint('businessData: loop ran');
          businessData = BusinessData(
            id: businessDetailsID,
            businessName: businessDetailsData['businessName'],
            businessType: businessDetailsData['businessType'],
            businessDoorNo: businessDetailsData['businessDoorNo'],
            businessPostCode: businessDetailsData['businessPostCode'],
            deliveryOrCollection: businessDetailsData['deliveryOrCollection'],
            openTimes: businessDetailsData['openTimes'],
            ownerID: businessDetailsData['ownerID'],
          );
        });
        /*debugPrint('businessData: ${businessData.id}');
        debugPrint('businessData: ${businessData.businessName}');
        debugPrint('businessData: ${businessData.businessType}');
        debugPrint('businessData: ${businessData.businessDoorNo}');
        debugPrint('businessData: ${businessData.businessPostCode}');
        debugPrint('businessData: ${businessData.deliveryOrCollection}');
        debugPrint('businessData: ${businessData.openTimes}');
        debugPrint('businessData: ${businessData.ownerID}');*/
      } else {
        //debugPrint('no business data: $extractedData');
        //default values
        businessData = BusinessData(
          id: '',
          businessName: '',
          businessType: '',
          businessDoorNo: '',
          businessPostCode: '',
          deliveryOrCollection: '',
          openTimes: '',
          ownerID: '',
        );
      }
      //debugPrint(businessData.toString());
      //notify listeners about the changes
      notifyListeners();
    } catch (error) {
      //throw error to handle it
      rethrow;
    }
  }
}
