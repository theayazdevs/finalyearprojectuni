import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/providers/category_item_provider.dart';
import 'package:fyp/providers/food_category_provider.dart';
import 'package:fyp/providers/foods_menu_provider.dart';
import 'package:mockito/mockito.dart';

//unit testing
void main() {
  late FoodsMenu systemUnderTest;
  setUp(() {
    systemUnderTest = MockFoodsMenu();
  });
  //grouping unit tests
  group('Manage Categories', () {
    test('Adding a category', () async {
      //should return exactly 2 categories from the list
      expect(systemUnderTest.getCategoryItems.length, 2);
      FoodCategoryProvider addCategory =
          FoodCategoryProvider(id: 'p3', title: 'Drinks', itemsInCategory: []);
      await systemUnderTest.addFoodCategory(addCategory);
      //should return exactly 3 categories as 1 new should be added
      expect(systemUnderTest.getCategoryItems.length, 3);
      //Making sure that category is added correctly
      expect(systemUnderTest.findCategoryById('p3').title, 'Drinks');
    });
    test('Updating a category', () async {
      //should return exactly 2 categories from the list
      expect(systemUnderTest.getCategoryItems.length, 2);
      FoodCategoryProvider updateCategory =
      FoodCategoryProvider(id: 'p1', title: 'Milkshakes', itemsInCategory: []);
      await systemUnderTest.updateFoodCategory('p1', updateCategory);
      //should return exactly 2 categories because just edited, not added or removed
      expect(systemUnderTest.getCategoryItems.length, 2);
      //Making sure that category is updated correctly
      expect(systemUnderTest.findCategoryById('p1').title, 'Milkshakes');
    });
    test('Removing a Category', () async {
      //delete the category
      systemUnderTest.deleteFoodCategory('p1');
      //check if it is successfully deleted
      expect(systemUnderTest.getCategoryItems.length, 1);
      //making sure that the only one category is left
      expect(systemUnderTest.getCategoryItems[0].title, 'Burgers');
    });
  });
  //managing items in a category
  group('Manage Items in Category', () {
    test('Adding an item in category', () async {
      //should return exactly 3 items in category
      expect(systemUnderTest.getCategoryItems[0].itemsInCategory.length, 3);
      CategoryItemProvider addItem = CategoryItemProvider(id: 'pizza4', categoryItemTitle: 'Vegetarian', categoryItemDescription: 'pizza with vegetables', categoryItemPrice: 4.00);
      await systemUnderTest.addFoodItemCategory('p1', addItem);
      //should return exactly 4 items in category as 1 new should be added
      expect(systemUnderTest.getCategoryItems[0].itemsInCategory.length, 4);
      //Making sure that category is added correctly
      expect(systemUnderTest.findCategoryById('p1').itemsInCategory[3].categoryItemTitle, 'Vegetarian');
    });
    test('Updating an item in category', () async {
      //should return exactly 3 items in category
      expect(systemUnderTest.getCategoryItems[0].itemsInCategory.length, 3);
      CategoryItemProvider updateItem = CategoryItemProvider(id: 'pizza2', categoryItemTitle: 'Vegan', categoryItemDescription: 'purely vegan pizza', categoryItemPrice: 6.00);
      await systemUnderTest.updateFoodCategoryItem('p1', 'pizza2', updateItem);
      //should return exactly 3 items in category because just edited, not added or removed
      expect(systemUnderTest.getCategoryItems[0].itemsInCategory.length, 3);
      //Making sure that category is updated correctly
      expect(systemUnderTest.findCategoryById('p1').itemsInCategory[1].categoryItemTitle, 'Vegan');
    });
    test('Removing an item in Category', () async {
      //delete the item from category
      systemUnderTest.deleteCategoryItem('p1', 'pizza1');
      //check if it is successfully deleted
      expect(systemUnderTest.getCategoryItems[0].itemsInCategory.length, 2);
      //making sure that the only two items are left
      expect(systemUnderTest.getCategoryItems[0].itemsInCategory[0].categoryItemTitle, 'BBQ Chicken');
      expect(systemUnderTest.getCategoryItems[0].itemsInCategory[1].categoryItemTitle, 'Pepperoni');
    });
  });
}

//using Mockito to Mock the FoodsMenu class
class MockFoodsMenu extends Mock implements FoodsMenu {
  final List<FoodCategoryProvider> _items = [
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
  Future<void> addFoodCategory(FoodCategoryProvider itemCategory) async {
    _items.add(itemCategory);
  }

  @override
  Future<void> updateFoodCategory(String foodID, FoodCategoryProvider newCategoryItem) async {
    final catIndex = _items.indexWhere((category) => category.id == foodID);
    //check if a category with that index is found
    if (catIndex >= 0) {
      //overwrite that category
      _items[catIndex] = newCategoryItem;
    }
  }

  @override
  Future<void> deleteFoodCategory(String foodID) async {
    _items.removeWhere((theCategory) => theCategory.id == foodID);
  }

  @override
  Future<void> addFoodItemCategory(String categoryID, CategoryItemProvider categoryItem) async {
    findCategoryById(categoryID).itemsInCategory.add(categoryItem);
  }

  @override
  Future<void> updateFoodCategoryItem(String categoryID, String foodItemID, CategoryItemProvider newItem) async {
    final catIndex = findCategoryById(categoryID)
        .itemsInCategory
        .indexWhere((category) => category.id == foodItemID);
    //check if a category with that index is found
    if (catIndex >= 0) {
      //overwrite that category
      findCategoryById(categoryID).itemsInCategory[catIndex] = newItem;
    }
  }

  @override
  void deleteCategoryItem(String categoryID, String itemID) {
    FoodCategoryProvider inCategory = findCategoryById(categoryID);
    inCategory.itemsInCategory.removeWhere((theItem) => theItem.id == itemID);
  }

}
