import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/providers/category_item_provider.dart';
import 'package:fyp/providers/food_category_provider.dart';
import 'package:fyp/providers/foods_menu_provider.dart';
import 'package:fyp/widgets/category_item_widget.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

//widget testing
void main() {
  late Widget systemUnderTest;
  final sttProvider = SpeechToTextProvider(SpeechToText());
  final mockFoodsMenu = MockFoodsMenu();
  final foodsMenu = mockFoodsMenu.findById('p1');
  Widget widgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sttProvider),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          //BUSINESS MANAGE CATEGORY ITEMS SCREEN
          home: Scaffold(
            appBar: AppBar(
              title: Text(foodsMenu.title),
            ),
            body: foodsMenu.itemsInCategory.isEmpty || foodsMenu.itemsInCategory[0].categoryItemTitle=='title' ? const Center(child: Text('No items added yet!')) :  ListView.builder(
                itemBuilder: (_, i) => Column(
                  children: [
                    CategoryItemWidget(
                      title: foodsMenu.itemsInCategory[i].categoryItemTitle,
                      categoryID: foodsMenu.id,
                      categoryItemID: foodsMenu.itemsInCategory[i].id,
                    ),
                  ],
                ),
                itemCount: foodsMenu.itemsInCategory.length,
              ),
          ),
        ),
      ),
    );
  }

  setUp(() {
    systemUnderTest = widgetUnderTest();
  });

  //Manage
  group('Manage Items - Manage Items of a category', () {
    testWidgets('Check All items are present in a category', (widgetTester) async {
      //set up the Manage Category Items Screen
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if manage category items screen displaying correctly
      expect(find.text('Pizzas'), findsOneWidget);
      //check if category item widgets are present
      expect(find.text('Margherita'), findsOneWidget);
      expect(find.text('BBQ Chicken'), findsOneWidget);
      expect(find.text('Pepperoni'), findsOneWidget);
    });
    testWidgets('Add a new item', (widgetTester) async {
      CategoryItemProvider newItem = CategoryItemProvider(id: 'pizza4', categoryItemTitle: 'Vegetarian', categoryItemDescription: 'with vegetables', categoryItemPrice: 5.00);
      mockFoodsMenu.addFoodItemCategory('p1', newItem);
      //set up the Manage Category Items Screen
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if manage category items screen displaying correctly
      expect(find.text('Pizzas'), findsOneWidget);
      //check if category item widgets are present
      expect(find.text('Margherita'), findsOneWidget);
      expect(find.text('BBQ Chicken'), findsOneWidget);
      expect(find.text('Pepperoni'), findsOneWidget);
      expect(find.text('Vegetarian'), findsOneWidget);
    });
    testWidgets('Edit an item', (widgetTester) async {
      CategoryItemProvider updatedItem = CategoryItemProvider(id: 'pizza1', categoryItemTitle: 'Vegan', categoryItemDescription: 'purely vegan', categoryItemPrice: 6.00);
      mockFoodsMenu.updateFoodCategoryItem('p1', 'pizza1', updatedItem);
      //set up the Manage Category Items Screen
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if manage category items screen displaying correctly
      expect(find.text('Pizzas'), findsOneWidget);
      //check if category item widget is updated
      expect(find.text('Vegan'), findsOneWidget);
      //this item is updated
      expect(find.text('Margherita'), findsNothing);
    });
    testWidgets('Delete an item', (widgetTester) async {
      mockFoodsMenu.deleteCategoryItem('p1', 'pizza2');
      //set up the Manage Category Items Screen
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if manage category items screen displaying correctly
      expect(find.text('Pizzas'), findsOneWidget);
      //check if category item widget is deleted
      expect(find.text('BBQ Chicken'), findsNothing);
    });
  });
}

//using Mockito to Mock the FoodsMenu class
class MockFoodsMenu extends Mock implements FoodsMenu {

  //providing dummy data for testing
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
  List<FoodCategoryProvider> get items {
    //return a copy of items
    return [..._items];
  }

  //find food category by ID
  @override
  FoodCategoryProvider findById(String id) {
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
    findById(categoryID).itemsInCategory.add(categoryItem);
  }

  @override
  Future<void> updateFoodCategoryItem(String categoryID, String foodItemID, CategoryItemProvider newItem) async {
    final catIndex = findById(categoryID)
        .itemsInCategory
        .indexWhere((category) => category.id == foodItemID);
    //check if a category with that index is found
    if (catIndex >= 0) {
      //overwrite that category
      findById(categoryID).itemsInCategory[catIndex] = newItem;
    }
  }

  @override
  void deleteCategoryItem(String categoryID, String itemID) {
    FoodCategoryProvider inCategory = findById(categoryID);
    inCategory.itemsInCategory.removeWhere((theItem) => theItem.id == itemID);
  }

}
