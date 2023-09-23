import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:fyp/providers/business_data_provider.dart';

//as http to avoid any name clashes
import 'package:http/http.dart' as http;

import '../providers/category_item_provider.dart';
import '../providers/food_category_provider.dart';

//CustomerFoodProvider class, using Change Notifier to notify listeners of any changes made
//mixin is like merging classes (keyword is WITH)
class CustomerFoodProvider with ChangeNotifier {
  //to store the user token
  final String _userToken;
  //to store the user ID
  final String _userID;
  //to store the list of FoodCategoryProvider items
  List<FoodCategoryProvider> _foodCategoryItems = [];
  //to store the list of BusinessData items
  List<BusinessData> _businessItems = [];
  //constructor
  CustomerFoodProvider(
      this._userToken, this._userID, this._businessItems, this._foodCategoryItems);

  //return list of FoodCategoryProvider items
  List<FoodCategoryProvider> get getCategoryItems {
    //return a copy of items
    // the ... makes sure a copy of the data is sent, so the original data stays unchanged
    return [..._foodCategoryItems];
  }
  //return list of BusinessData items
  List<BusinessData> get businessItems {
    //return a copy of items
    return [..._businessItems];
  }
  //find food category by ID
  FoodCategoryProvider findCategoryById(String id) {
    return _foodCategoryItems.firstWhere((theFood) => theFood.id == id);
  }
  //find item in food category by ID
  CategoryItemProvider findItemById(String categoryId, String categoryItemID) {
    return findCategoryById(categoryId)
        .itemsInCategory
        .firstWhere((element) => element.id == categoryItemID);
  }
  //get business details from the database
  Future<void> fetchAndSetBusiness() async {
    //debugPrint('fetchAndSetBusiness');
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    const String charactersPath = '/businessDetails.json';
    final Map<String, String> queryParameters = <String, String>{
      //'auth': currentUserToken,
      'auth': _userToken,
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    try {
      //store data in response
      final response = await http.get(url);
      final receivedData = json.decode(response.body.toString()) as Map<String, dynamic>?;
      if(receivedData==null){
        return;
      }
      //temporary list holder, to tell which kind of data
      final List<BusinessData> loadedBusinessData = [];
      //key is the food category ID, value is data
      //extractedData.forEach((key, value) {
      receivedData.forEach((businessDataID, businessDataGot) {
        //debugPrint(businessDataGot['businessName'].toString());
        /*itemsList.forEach((element) {
          debugPrint('ELEMENT START ------------------------------------------');
          debugPrint(element.id);
          debugPrint(element.title);
          debugPrint(element.description);
          debugPrint(element.price.toString());
          debugPrint('ELEMENT END --------------------------------------');
        });*/
        //get each item in list and add to a list of type needed, then finally returning that list as a single variable
        loadedBusinessData.add(BusinessData(
            id: businessDataID,
            businessName: businessDataGot['businessName'],
            businessType: businessDataGot['businessType'],
            businessDoorNo: businessDataGot['businessDoorNo'],
            businessPostCode: businessDataGot['businessPostCode'],
            deliveryOrCollection: businessDataGot['deliveryOrCollection'],
            openTimes: businessDataGot['openTimes'],
            ownerID: businessDataGot['ownerID']));
      });
      _businessItems = loadedBusinessData;
      //debugPrint(_businessItems.toString());
      Future.delayed(const Duration(milliseconds: 500), () {
        //notify listeners of any changes made
        notifyListeners();
      });
      //notifyListeners();
    } catch (error) {
      //log('try again');
      //throw error to handle it
      rethrow;
    }
  }
  //fetch the menu by owner ID from the database
  Future<void> fetchAndSetMenu(String ownerID) async {
    //debugPrint('fetchAndSetMenu');
    //getting menu by owner ID
    const String baseUrl =
        'finalyearproject-6b240-default-rtdb.europe-west1.firebasedatabase.app';
        //'testing-dccdf-default-rtdb.europe-west1.firebasedatabase.app';
    const String charactersPath = '/foods.json';
    final Map<String, String> queryParameters = <String, String>{
      //'auth': currentUserToken,
      'auth': _userToken,
      'orderBy': '"ownerID"',
      'equalTo': '"$ownerID"',
    };
    final url = Uri.https(baseUrl, charactersPath, queryParameters);
    try {
      //store data in response
      final response = await http.get(url);
      //debugPrint('getting data from database');
      final receivedData =
          json.decode(response.body.toString()) as Map<String, dynamic>;
      //temporary list holder, to tell which kind of data
      final List<FoodCategoryProvider> loadedCategories = [];
      //key is the food category ID, value is data
      receivedData.forEach((categoryID, categoryData) {
        //get each item in list and add to a list of type needed, then finally returning that list as a single variable
        //debugPrint(categoryData['itemsInCategory'].toString());
        List<CategoryItemProvider> itemsList = [];
        final itemsInCategoryList =
            categoryData['itemsInCategory'] as Map<String, dynamic>?;
        if(itemsInCategoryList==null){
          return;
        }
        if (itemsInCategoryList != null) {
          itemsInCategoryList.forEach((itemID, itemData) {
            CategoryItemProvider itemsListItem = CategoryItemProvider(
                id: itemID,
                categoryItemTitle: itemData['title'],
                categoryItemDescription: itemData['description'],
                categoryItemPrice: itemData['price']);
            itemsList.add(itemsListItem);
            //debugPrint(itemsList[0].title.toString());
          });
        } else {
          itemsList.add(CategoryItemProvider(
              id: 'null',
              categoryItemTitle: 'title',
              categoryItemDescription: 'description',
              categoryItemPrice: 0));
          //debugPrint('no items in this category ID: $categoryID');
        }
        loadedCategories.add(FoodCategoryProvider(
          id: categoryID,
          title: categoryData['title'],
          itemsInCategory: itemsList,
        ));
      });
      _foodCategoryItems = loadedCategories;

      //debugPrint(_items.toString());
      Future.delayed(const Duration(milliseconds: 500), () {
        //notify listeners about the changes made
        notifyListeners();
      });
      //notifyListeners();
    } catch (error) {
      //throw error to handle it
      rethrow;
    }
  }
}
