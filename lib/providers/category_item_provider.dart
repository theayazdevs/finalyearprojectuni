import 'package:flutter/cupertino.dart';

//CategoryItemProvider class, using Change Notifier to notify listeners of any changes made
class CategoryItemProvider with ChangeNotifier {
  final String id;
  final String categoryItemTitle;
  final String categoryItemDescription;
  final double categoryItemPrice;
  //constructor
  CategoryItemProvider({
    required this.id,
    required this.categoryItemTitle,
    required this.categoryItemDescription,
    required this.categoryItemPrice,
  });
}
