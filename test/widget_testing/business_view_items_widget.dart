import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/providers/category_item_provider.dart';
import 'package:fyp/providers/food_category_provider.dart';
import 'package:fyp/providers/foods_menu_provider.dart';
import 'package:fyp/widgets/view_category_items_widget.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

//widget testing
void main() {
  late Widget systemUnderTest;
  final sttProvider = SpeechToTextProvider(SpeechToText());
  Widget widgetUnderTest() {
    final foodsMenu = MockFoodsMenu();
    //testing with pizza category
    FoodCategoryProvider categoryPizza = foodsMenu.findById('p1');
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sttProvider),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: Text(categoryPizza.title),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: categoryPizza.itemsInCategory.isEmpty ||
                      categoryPizza.itemsInCategory[0].categoryItemTitle == 'title'
                  ? const Center(child: Text('No items added yet!'))
                  : ListView.builder(
                      itemBuilder: (_, i) => Column(
                        children: [
                          ViewCategoryItemsWidget(
                            theTitle: categoryPizza.itemsInCategory[i].categoryItemTitle,
                            theDescription:
                                categoryPizza.itemsInCategory[i].categoryItemDescription,
                            thePrice: categoryPizza.itemsInCategory[i].categoryItemPrice
                                .toString(),
                          ),
                        ],
                      ),
                      itemCount: categoryPizza.itemsInCategory.length,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  setUp(() {
    systemUnderTest = widgetUnderTest();
  });

  //business views a category
  group('Business Home Screen View Items In A Category', () {
    testWidgets('Check Category Name Present On Screen',
        (widgetTester) async {
      //set up view category screen
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if business view items in a category screen displaying correctly
      expect(find.text('Pizzas'), findsOneWidget);
    });
    testWidgets('Check if All items present on screen',
            (widgetTester) async {
          //set up the screen
          await widgetTester.pumpWidget(systemUnderTest);
          await widgetTester.pump(const Duration(seconds: 2));
          await widgetTester.pumpAndSettle();
          //check if all items widgets are on screen
          expect(find.text('Margherita'), findsOneWidget);
          expect(find.text('BBQ Chicken'), findsOneWidget);
          expect(find.text('Pepperoni'), findsOneWidget);
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
  Future<void> fetchAndSetMenu() async {
    if (_items.isNotEmpty) {
      _items = _items;
    } else {
      _items = [];
    }
  }
}
