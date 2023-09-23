import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/providers/category_item_provider.dart';
import 'package:fyp/providers/food_category_provider.dart';
import 'package:fyp/providers/foods_menu_provider.dart';
import 'package:mockito/mockito.dart';

//unit testing
void main() {
  late FoodsMenu systemUnderTest;
  setUp( (){
    systemUnderTest = MockFoodsMenu();
  });
  //grouping unit tests
  group('Current Menu Business', () {
    test('Successful Current Menu Fetch', () async {
      await systemUnderTest.fetchAndSetMenu();
      //should return exactly 2 categories from the list
      expect(systemUnderTest.getCategoryItems.length, 2);
      //should return exactly 3 items from the category by ID
      expect(systemUnderTest.findCategoryById('p1').itemsInCategory.length, 3);
      //should return exactly 2 items from the category by ID
      expect(systemUnderTest.findCategoryById('p2').itemsInCategory.length, 2);
    });
    test('Accuracy of fetched menu', () async {
      await systemUnderTest.fetchAndSetMenu();
      //should return exactly same category title
      expect(systemUnderTest.getCategoryItems[0].title, 'Pizzas');
      expect(systemUnderTest.getCategoryItems[1].title, 'Burgers');
      //should return exactly same item title from within a category
      expect(systemUnderTest.getCategoryItems[0].itemsInCategory[0].categoryItemTitle, 'Margherita');
      expect(systemUnderTest.getCategoryItems[1].itemsInCategory[1].categoryItemTitle, 'Cheese Burger');
    });
  });
}

//using Mockito to Mock the FoodsMenu class
class MockFoodsMenu extends Mock implements FoodsMenu {
   List<FoodCategoryProvider> _items = [
    FoodCategoryProvider(id: 'p1', title: 'Pizzas', itemsInCategory: [
      CategoryItemProvider(
          id: 'pizza1',
          categoryItemTitle: 'Margherita',
          categoryItemDescription: 'cheese, tomato, puree',
          categoryItemPrice: 5.00),
      CategoryItemProvider(
          id: 'pizza2',
          categoryItemTitle: 'BBQ Chicken',
          categoryItemDescription: 'chicken, cheese, tomato puree',
          categoryItemPrice: 7.00),
      CategoryItemProvider(
          id: 'pizza3',
          categoryItemTitle: 'Pepperoni',
          categoryItemDescription: 'pepperoni, cheese, tomato puree',
          categoryItemPrice: 8.00),
    ]),
    FoodCategoryProvider(id: 'p2', title: 'Burgers', itemsInCategory: [
      CategoryItemProvider(
          id: 'burger1',
          categoryItemTitle: 'Chicken',
          categoryItemDescription: 'chicken, lettuce, mayo',
          categoryItemPrice: 4.00),
      CategoryItemProvider(
          id: 'burger2',
          categoryItemTitle: 'Cheese Burger',
          categoryItemDescription: 'beef, cheese slice, lettuce, mayo',
          categoryItemPrice: 4.00),
    ]),
  ];
   @override
  List<FoodCategoryProvider> get getCategoryItems {
     //return a copy of items
     return [..._items];
   }
   //find food category by ID
   @override
  FoodCategoryProvider findCategoryById(String id) {
     return _items.firstWhere((theFood) => theFood.id == id);
   }
  @override
  Future<void> fetchAndSetMenu() async {
    if(_items.isNotEmpty ){
        _items = _items;
      }
      else{
        _items = [];
    }
  }
}
