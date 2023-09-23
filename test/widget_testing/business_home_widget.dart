import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/providers/category_item_provider.dart';
import 'package:fyp/providers/food_category_provider.dart';
import 'package:fyp/providers/foods_menu_provider.dart';
import 'package:fyp/widgets/view_category_widget.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sttProvider),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          //BUSINESS HOME SCREEN
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Your Menu'),
            ),
            body: foodsMenu.items.isEmpty
                  ? const Center(child: Text('No categories added yet!'))
                  : ListView.builder(
                      itemBuilder: (_, i) => Column(
                        children: [
                          ViewCategoryWidget(
                            theTitle: foodsMenu.items[i].title,
                            id: foodsMenu.items[i].id.toString(),
                          ),
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

  //Business
  group('Business Home Screen', () {
    testWidgets('Check All Categories are present at home screen', (widgetTester) async {
      //set up the login screen
      //await widgetTester.pumpWidget(const MyApp());
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if business home screen displaying correctly
      expect(find.text('Your Menu'), findsOneWidget);
      //check if category widget is present
      expect(find.text('Pizzas'), findsOneWidget);
      expect(find.text('Burgers'), findsOneWidget);
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
