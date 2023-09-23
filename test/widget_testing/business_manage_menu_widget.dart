import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/providers/category_item_provider.dart';
import 'package:fyp/providers/food_category_provider.dart';
import 'package:fyp/providers/foods_menu_provider.dart';
import 'package:fyp/widgets/category_widget.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

//widget testing
void main() {
  late Widget systemUnderTest;
  final sttProvider = SpeechToTextProvider(SpeechToText());
  final foodsMenu = MockFoodsMenu();
  Widget widgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sttProvider),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          //BUSINESS MANAGE MENU SCREEN
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Manage Your Menu'),
            ),
            body: foodsMenu.items.isEmpty ? const Center(child: Text('No categories added yet!')) : ListView.builder(
                // code after => tells how should the category look like
                itemBuilder: (_, i) => Column(
                  children: [
                    CategoryWidget(
                      title: foodsMenu.items[i].title,
                      id: foodsMenu.items[i].id.toString(),
                    ),
                    const Divider(),
                  ],
                ),
                itemCount: foodsMenu.items.length,
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
  group('Business Manage Menu Screen - Manage Categories', () {
    testWidgets('Check All Categories are present at Manage screen', (widgetTester) async {
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if business manage menu screen displaying correctly
      expect(find.text('Manage Your Menu'), findsOneWidget);
      //category quantity should be 2
      expect(foodsMenu.items.length, 2);
      //check if category widgets are present
      expect(find.text('Pizzas'), findsOneWidget);
      expect(find.text('Burgers'), findsOneWidget);
    });
    testWidgets('Adding a category widget', (widgetTester) async {
      FoodCategoryProvider addCategoryWidget = FoodCategoryProvider(id: 'p3', title: 'Drinks', itemsInCategory: []);
      await foodsMenu.addFoodCategory(addCategoryWidget);
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if business manage menu screen displaying correctly
      expect(find.text('Manage Your Menu'), findsOneWidget);
      //making sure new category widget is added
      expect(find.text('Drinks'), findsOneWidget);
    });
    testWidgets('Editing a category widget', (widgetTester) async {
      FoodCategoryProvider updatedCategoryWidget = FoodCategoryProvider(id: 'p1', title: 'Milkshakes', itemsInCategory: []);
      await foodsMenu.updateFoodCategory('p1', updatedCategoryWidget);
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if business manage menu screen displaying correctly
      expect(find.text('Manage Your Menu'), findsOneWidget);
      //making sure category widget is updated
      expect(find.text('Milkshakes'), findsOneWidget);
    });
    testWidgets('Deleting a category widget', (widgetTester) async {
      await foodsMenu.deleteFoodCategory('p1');
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if business manage menu screen displaying correctly
      expect(find.text('Manage Your Menu'), findsOneWidget);
      //making sure category widget is deleted
      expect(find.text('Milkshakes'), findsNothing);
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
