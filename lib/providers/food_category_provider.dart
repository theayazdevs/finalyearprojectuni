import 'package:flutter/cupertino.dart';
import 'category_item_provider.dart';
//FoodCategoryProvider class, using Change Notifier to notify listeners of any changes made
class FoodCategoryProvider with ChangeNotifier {
  final String id;
  final String title;
  final List<CategoryItemProvider> itemsInCategory;
  //constructor
  FoodCategoryProvider({
    required this.id,
    required this.title,
    required this.itemsInCategory,
  });
}
