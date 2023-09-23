import 'package:flutter/cupertino.dart';

//BusinessData class, using Change Notifier to notify listeners of any changes made
class BusinessData with ChangeNotifier {
  final String id;
  final String businessName;
  final String businessType;
  final String businessDoorNo;
  final String businessPostCode;
  final String deliveryOrCollection;
  final String openTimes;
  final String ownerID;

  //constructor
  BusinessData({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.businessDoorNo,
    required this.businessPostCode,
    required this.deliveryOrCollection,
    required this.openTimes,
    required this.ownerID,
  });
}
