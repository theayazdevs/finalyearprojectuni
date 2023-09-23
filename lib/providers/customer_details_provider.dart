import 'dart:convert';
import 'package:flutter/cupertino.dart';

//as http to avoid any name clashes
import 'package:http/http.dart' as http;
import 'customer_data_provider.dart';

//CustomerDetails class, using Change Notifier to notify listeners of any changes made
//mixin is like merging classes (keyword is WITH)
class CustomerDetails with ChangeNotifier {
  //to store the user token
  final String _userToken;
  //to store the user ID
  final String _userID;
  //to store the instance of customer data class
  CustomerData customerData = CustomerData(
    id: '',
    customerFirstName: '',
    customerLastName: '',
    customerDoorNo: '',
    customerPostCode: '',
    phoneNumber: '',
    userID: '',
  );
  //constructor
  CustomerDetails(this._userToken, this._userID, this.customerData);
  //returns the current data stored in the customer data variable
  CustomerData get getCustomerDetails {
    return customerData;
  }
  //add new customer details to the database
  Future<void> addCustomerDetails(CustomerData theCustomerData) async {
    //database URL
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    var charactersPath = '/customerDetails.json';
    final Map<String, String> queryParameters = <String, String>{
      'auth': _userToken,
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    try {
      //post data
      final response = await http.post(
        url,
        body: json.encode({
          'fName': theCustomerData.customerFirstName,
          'lName': theCustomerData.customerLastName,
          'customerDoorNo': theCustomerData.customerDoorNo,
          'customerPostCode': theCustomerData.customerPostCode,
          'phoneNumber': theCustomerData.phoneNumber,
          'userID': _userID,
        }),
      );
      final newCustomerData = CustomerData(
        //time as of now to make it unique
        id: json.decode(response.body)['name'],
        customerFirstName: theCustomerData.customerFirstName,
        customerLastName: theCustomerData.customerLastName,
        customerDoorNo: theCustomerData.customerDoorNo,
        customerPostCode: theCustomerData.customerPostCode,
        phoneNumber: theCustomerData.phoneNumber,
        userID: _userID,
      );
      customerData = newCustomerData;
      //used by the providers package, establishes a communication channel between interested widgets and this class
      //let certain widgets know about the updates did, so only widgets listening to this class will get rebuilt
      notifyListeners();
    } catch (error) {
      //error handling
      debugPrint("error in add customer data method : $error");
      //creating error to be handled by the other screen
      rethrow;
    }
  }
  //update current details stored on the database based on the new values provided by the user
  Future<void> updateCustomerDetails(
      String customerDataID, CustomerData newCustomerData) async {
    //updating data on the database
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    var charactersPath = '/customerDetails/$customerDataID.json';
    final Map<String, String> queryParameters = <String, String>{
      'auth': _userToken,
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    try {
      //merge data with patch in firebase
      await http.patch(url,
          body: json.encode({
            'fName': newCustomerData.customerFirstName,
            'lName': newCustomerData.customerLastName,
            'customerDoorNo': newCustomerData.customerDoorNo,
            'customerPostCode': newCustomerData.customerPostCode,
            'phoneNumber': newCustomerData.phoneNumber,
            'userID': _userID,
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
  //fetch details of the customer stored on the database
  Future<void> fetchCustomerDetails() async {
    //debugPrint('fetchCustomerDetails');
    //getting details by customer ID
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    const String charactersPath = '/customerDetails.json';
    final Map<String, String> queryParameters = <String, String>{
      //'auth': currentUserToken,
      'auth': _userToken,
      'orderBy': '"userID"',
      'equalTo': '"$_userID"',
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
        extractedData.forEach((customerDetailsID, customerDetailsData) {
          //debugPrint('businessData: loop ran');
          customerData = CustomerData(
            id: customerDetailsID,
            customerFirstName: customerDetailsData['fName'],
            customerLastName: customerDetailsData['lName'],
            customerDoorNo: customerDetailsData['customerDoorNo'],
            customerPostCode: customerDetailsData['customerPostCode'],
            phoneNumber: customerDetailsData['phoneNumber'],
            userID: customerDetailsData['userID'],
          );
        });
        /*debugPrint('customerData: ${customerData.id}');
        debugPrint('customerData: ${customerData.customerFirstName}');
        debugPrint('customerData: ${customerData.customerLastName}');
        debugPrint('customerData: ${customerData.customerDoorNo}');
        debugPrint('customerData: ${customerData.customerPostCode}');
        debugPrint('customerData: ${customerData.phoneNumber}');
        debugPrint('customerData: ${customerData.userID}');*/
      } else {
        //debugPrint('no business data: $extractedData');
        customerData = CustomerData(
          id: '',
          customerFirstName: '',
          customerLastName: '',
          customerDoorNo: '',
          customerPostCode: '',
          phoneNumber: '',
          userID: '',
        );
      }
      //debugPrint(customerData.toString());
      //notify listeners about the changes
      notifyListeners();
    } catch (error) {
      //throw error to handle it
      rethrow;
    }
  }
}
