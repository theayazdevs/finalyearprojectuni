import 'package:flutter/cupertino.dart';
//CustomerData class, using Change Notifier to notify listeners of any changes made
class CustomerData with ChangeNotifier {
  final String id;
  final String customerFirstName;
  final String customerLastName;
  final String customerDoorNo;
  final String customerPostCode;
  final String phoneNumber;
  final String userID;
  //constructor
  CustomerData({
    required this.id,
    required this.customerFirstName,
    required this.customerLastName,
    required this.customerDoorNo,
    required this.customerPostCode,
    required this.phoneNumber,
    required this.userID,
  });
}
