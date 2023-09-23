import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'customer_data_provider.dart';
import 'item_in_cart_provider.dart';

//BusinessOrderItem class
class BusinessOrderItem {
  final String id;
  final double theAmount;
  final List<CustomerCartItem> theItems;
  final DateTime orderDateTime;
  final String customerName;
  final String customerAddress;
  final String customerPhone;
  final String service;
  //constructor
  BusinessOrderItem({
    required this.id,
    required this.theAmount,
    required this.theItems,
    required this.orderDateTime,
    required this.customerName,
    required this.customerAddress,
    required this.customerPhone,
    required this.service,
  });
}
//CustomerOrderItem class
class CustomerOrderItem {
  final String id;
  final double theAmount;
  final List<CustomerCartItem> theItems;
  final DateTime orderDateTime;
  final String businessName;
  final String service;
  //constructor
  CustomerOrderItem({
    required this.id,
    required this.theAmount,
    required this.theItems,
    required this.orderDateTime,
    required this.businessName,
    required this.service,
  });
}
//Orders class, using Change Notifier to notify listeners of any changes made
class AllOrders with ChangeNotifier {
  //store a list of BusinessOrderItem
  List<BusinessOrderItem> _ordersBusiness = [];
  //store a list of CustomerOrderItem
  List<CustomerOrderItem> _ordersCustomer = [];
  //store the user token
  final String _userToken;
  //store the user ID
  final String _userID;
  //constructor
  AllOrders(this._userToken, this._userID, this._ordersBusiness, this._ordersCustomer);
  //return a list of BusinessOrderItem
  List<BusinessOrderItem> get getBusinessOrders {
    return [..._ordersBusiness];
  }
  //return a list of CustomerOrderItem
  List<CustomerOrderItem> get getCustomerOrders {
    return [..._ordersCustomer];
  }
  //fetch and set orders for the customer
  Future<void> fetchAndSetCustomerOrders() async {
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    const String charactersPath = '/orders.json';
    final Map<String, String> queryParameters = <String, String>{
      'auth': _userToken,
      'orderBy': '"userID"',
      'equalTo': '"$_userID"',
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    final response = await http.get(url);
    final List<CustomerOrderItem> loadedCustomerOrders = [];
    final dataReceived = json.decode(response.body) as Map<String, dynamic>;
    if (dataReceived == null) {
      return;
    }
    dataReceived.forEach((theOrderId, theOrderData) {
      loadedCustomerOrders.add(
        CustomerOrderItem(
          id: theOrderId,
          theAmount: theOrderData['theAmount'],
          orderDateTime: DateTime.parse(theOrderData['theDateTime']),
          theItems: (theOrderData['theItems'] as List<dynamic>)
              .map(
                (cartItem) => CustomerCartItem(
                  id: cartItem['id'],
                  thePrice: cartItem['thePrice'],
                  theQuantity: cartItem['theQuantity'],
                  theTitle: cartItem['theTitle'],
                ),
              )
              .toList(),
          businessName: theOrderData['nameBusiness'],
          service: theOrderData['service'],
        ),
      );
    });
    //_ordersCustomer = loadedOrders.reversed.toList();
    //sorting by recent to old orders
    loadedCustomerOrders.sort((a, b) => b.orderDateTime.compareTo(a.orderDateTime));
    _ordersCustomer = loadedCustomerOrders.toList();
    notifyListeners();
  }
  //add a new order to the database
  Future<void> addNewOrder(
    List<CustomerCartItem> cartItemsAll,
    double total,
    String ownerID,
    String theBusinessName,
      String service,
  ) async {
    CustomerData customerData = await findUserByID();
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    const String charactersPath = '/orders.json';
    final Map<String, String> queryParameters = <String, String>{
      'auth': _userToken,
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    final currentTime = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'customerName':'${customerData.customerFirstName} ${customerData.customerLastName}',
        'customerAddress':'${customerData.customerDoorNo} - ${customerData.customerPostCode}',
        'customerPhone':customerData.phoneNumber,
        'service':service,
        'theAmount': total,
        'theDateTime': currentTime.toIso8601String(),
        'theItems': cartItemsAll
            .map((currentProduct) => {
                  'id': currentProduct.id,
                  'theTitle': currentProduct.theTitle,
                  'theQuantity': currentProduct.theQuantity,
                  'thePrice': currentProduct.thePrice,
                })
            .toList(),
        'nameBusiness':theBusinessName,
        'ownerID': ownerID,
        'userID': _userID,
      }),
    );
    _ordersCustomer.insert(
      0,
      CustomerOrderItem(
        id: json.decode(response.body)['name'],
        theAmount: total,
        orderDateTime: currentTime,
        theItems: cartItemsAll,
        businessName: theBusinessName,
        service: service,
      ),
    );
    notifyListeners();
  }
  //fetch orders made to the specific owner/business
  Future<void> fetchAndSetOrdersOwner() async {
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    const String charactersPath = '/orders.json';
    final Map<String, String> queryParameters = <String, String>{
      'auth': _userToken,
      'orderBy': '"ownerID"',
      'equalTo': '"$_userID"',
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    final response = await http.get(url);
    final List<BusinessOrderItem> loadedBusinessOrders = [];
    final dataReceived = json.decode(response.body) as Map<String, dynamic>;
    if (dataReceived == null) {
      return;
    }
    dataReceived.forEach((theOrderId, theOrderData) {
      loadedBusinessOrders.add(
        BusinessOrderItem(
          id: theOrderId,
          customerName: theOrderData['customerName'],
          customerAddress: theOrderData['customerAddress'],
          customerPhone: theOrderData['customerPhone'],
          service: theOrderData['service'],
          theAmount: theOrderData['theAmount'],
          orderDateTime: DateTime.parse(theOrderData['theDateTime']),
          theItems: (theOrderData['theItems'] as List<dynamic>)
              .map(
                (cartItem) => CustomerCartItem(
                  id: cartItem['id'],
                  thePrice: cartItem['thePrice'],
                  theQuantity: cartItem['theQuantity'],
                  theTitle: cartItem['theTitle'],
                ),
              )
              .toList(),
        ),
      );
    });
    //sorting data by recent orders first
    loadedBusinessOrders.sort((a, b) => b.orderDateTime.compareTo(a.orderDateTime));
    _ordersBusiness = loadedBusinessOrders.toList();
    notifyListeners();
  }

  Future<CustomerData> findUserByID() async {
    CustomerData customerData = CustomerData(id: 'id', customerFirstName: 'customerFirstName', customerLastName: 'customerLastName', customerDoorNo: 'customerDoorNo', customerPostCode: 'customerPostCode', phoneNumber: 'phoneNumber', userID: 'userID');
    //getting user by ID from database
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
      //debugPrint('customerData data: ${response.body.toString()}');
      final dataReceived =
          json.decode(response.body.toString()) as Map<String, dynamic>?;
      //debugPrint('customerData data extracted data: ${extractedData.toString()}');
      if (dataReceived != null && dataReceived.isNotEmpty) {
        dataReceived.forEach((customerDetailsID, customerDetailsData) {
          //debugPrint('customerData: loop ran');
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
      notifyListeners();
    } catch (error) {
      //throw error to handle it
      rethrow;
    }
    return customerData;
  }

}
