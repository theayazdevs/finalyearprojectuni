import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/providers/business_data_provider.dart';
import 'package:fyp/providers/category_item_provider.dart';
import 'package:fyp/providers/customer_food_provider.dart';
import 'package:fyp/providers/food_category_provider.dart';
import 'package:mockito/mockito.dart';

//unit testing
void main() {
  late CustomerFoodProvider systemUnderTest;
  setUp(() {
    systemUnderTest = MockViewBusiness();
  });
  //grouping unit tests
  group('Customer Screen', () {
    test('Fetch current available food places', () async {
      //fetch business data for customer screen
      await systemUnderTest.fetchAndSetBusiness();
      //should return exactly 2 businesses from the list
      expect(systemUnderTest.businessItems.length, 2);
      //checking accuracy
      expect(systemUnderTest.businessItems[0].businessName, 'theKFC');
      expect(systemUnderTest.businessItems[1].businessName, 'theMcDonald');
    });
    test('Fetch current menu from first business', () async {
      await systemUnderTest.fetchAndSetMenu('theOwner-1');
      //should return exactly 2 categories
      expect(systemUnderTest.getCategoryItems.length,2);
      //should return exactly 1 item in category
      expect(systemUnderTest.getCategoryItems[0].itemsInCategory.length, 1);
    });
    test('Fetch current menu from second business', () async {
      await systemUnderTest.fetchAndSetMenu('theOwner-2');
      //should return exactly 1 categories
      expect(systemUnderTest.getCategoryItems.length,1);
      //should return exactly 1 item in category
      expect(systemUnderTest.getCategoryItems[0].itemsInCategory.length, 1);
    });
  });
}

//using Mockito to Mock the CustomerFoodProvider class
class MockViewBusiness extends Mock implements CustomerFoodProvider {
  List<BusinessData> _businessItems = [
    BusinessData(
        id: 'b1',
        businessName: 'theKFC',
        businessType: 'restaurant',
        businessDoorNo: '1',
        businessPostCode: 'ABC123',
        deliveryOrCollection: 'delivery and collection',
        openTimes: 'mon to fri, 6 to 10',
        ownerID: 'theOwner-1'),
    BusinessData(
        id: 'b2',
        businessName: 'theMcDonald',
        businessType: 'takeaway',
        businessDoorNo: '2',
        businessPostCode: 'DEF456',
        deliveryOrCollection: 'delivery and collection',
        openTimes: 'mon to fri, 4 to 11',
        ownerID: 'theOwner-2'),
  ];
  //to store the list of FoodCategoryProvider items
  List<FoodCategoryProvider> _items = [];
  //return list of BusinessData items
  @override
  List<BusinessData> get businessItems {
    //return a copy of items
    return [..._businessItems];
  }
  //return list of FoodCategoryProvider items
  @override
  List<FoodCategoryProvider> get items {
    //return a copy of items
    return [..._items];
  }
  @override
  Future<void> fetchAndSetBusiness() async {
    if (_businessItems.isNotEmpty) {
      _businessItems = _businessItems;
    } else {
      _businessItems = [];
    }
  }

  @override
  Future<void> fetchAndSetMenu(String ownerID) async {
    if(ownerID=='theOwner-1'){
      _items = [
        FoodCategoryProvider(id: 'c1', title: 'Pizza', itemsInCategory: [CategoryItemProvider(id: 'p1', categoryItemTitle: 'Margherita', categoryItemDescription: 'simple pizza', categoryItemPrice: 4.00)]),
        FoodCategoryProvider(id: 'c2', title: 'Burger', itemsInCategory: [CategoryItemProvider(id: 'b1', categoryItemTitle: 'Chicken', categoryItemDescription: 'simple chicken fillet burger', categoryItemPrice: 4.00)]),
      ];
    }
    else if(ownerID=='theOwner-2'){
      _items = [
        FoodCategoryProvider(id: 'c3', title: 'Pizza', itemsInCategory: [CategoryItemProvider(id: 'p1', categoryItemTitle: 'Chicken', categoryItemDescription: 'simple chicken pizza', categoryItemPrice: 5.00)]),
      ];
    }

  }
}
