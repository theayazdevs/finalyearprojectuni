import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/providers/item_in_cart_provider.dart';
import 'package:fyp/widgets/cart_item_widget.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

//widget testing
void main() {
  late Widget systemUnderTest;
  final sttProvider = SpeechToTextProvider(SpeechToText());
  final cart = MockCustomerCart();
  Widget widgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sttProvider),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          //CUSTOMER CART SCREEN
          home: Scaffold(
            appBar: AppBar(
              title: const Center(child: Text('Your Cart')),
            ),
            body:
                 ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) => CartItemWidget(
                      cart.items.values.toList()[i].id,
                      cart.items.keys.toList()[i],
                      cart.items.values.toList()[i].thePrice,
                      cart.items.values.toList()[i].theQuantity,
                      cart.items.values.toList()[i].theTitle,
                    ),
                  ),
                )
          ),
        ),
      );
  }

  setUp(() async {
    systemUnderTest = widgetUnderTest();
  });

  //cart
  group('Customer Cart Screen', () {
    testWidgets('Check if current cart item widgets are present', (widgetTester) async {
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if cart screen displaying correctly
      expect(find.text('Your Cart'), findsOneWidget);
      //check if cart items widgets already added to cart are present
      expect(find.text('cheese burger'), findsOneWidget);
      expect(find.text('margherita'), findsOneWidget);
    });
    testWidgets('check if new cart item added widget is present', (widgetTester) async {
      //adding a new item
      cart.addItem('3', 4.00, 'chicken burger', 'theOwner-1');
      await widgetTester.pumpWidget(systemUnderTest);
      //print(widgetTester.allWidgets.toList());
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if cart screen displaying correctly
      expect(find.text('Your Cart'), findsOneWidget);
      //check if cart items widgets already added to cart are present
      expect(find.text('cheese burger'), findsOneWidget);
      expect(find.text('margherita'), findsOneWidget);
      //new cart item
      expect(find.text('chicken burger'), findsOneWidget);
    });
    testWidgets('Remove cart item widget check', (widgetTester) async {
      //adding a new item
      cart.removeItemByID('3');
      await widgetTester.pumpWidget(systemUnderTest);
      await widgetTester.pump(const Duration(seconds: 2));
      await widgetTester.pumpAndSettle();
      //check if cart screen displaying correctly
      expect(find.text('Your Cart'), findsOneWidget);
      //item removed
      expect(find.text('chicken burger'), findsNothing);
    });

  });
}

//using Mockito to Mock the CustomerCart class
class MockCustomerCart extends Mock implements CustomerCart {
  final Map<String, CustomerCartItem> _items = {
    '1': CustomerCartItem(id: 'one', theTitle: 'cheese burger', theQuantity: 2, thePrice: 4.00),
    '2': CustomerCartItem(id: 'two', theTitle: 'margherita', theQuantity: 1, thePrice: 4.50),
  };
  @override
  Map<String, CustomerCartItem> get items {
    return {..._items};
  }
  @override
  void removeItemByID(String itemID) {
    _items.remove(itemID);
  }
  @override
  void removeSingleItem(String itemID) {
    if (!_items.containsKey(itemID)) {
      return;
    }
    if (_items[itemID]!.theQuantity > 1) {
      _items.update(
          itemID,
              (existingCartItem) => CustomerCartItem(
            id: existingCartItem.id,
                theTitle: existingCartItem.theTitle,
                thePrice: existingCartItem.thePrice,
                theQuantity: existingCartItem.theQuantity - 1,
          ));
    } else {
      _items.remove(itemID);
    }
  }
  @override
  void addItem(String itemID, double price, String title, String ownerID) {
    if (_items.containsKey(itemID)) {
      // change quantity...
      _items.update(
        itemID,
            (existingCartItem) => CustomerCartItem(
          id: existingCartItem.id,
              theTitle: existingCartItem.theTitle,
              thePrice: existingCartItem.thePrice,
              theQuantity: existingCartItem.theQuantity + 1,
        ),
      );
    } else {
      //add new
      _items.putIfAbsent(
        itemID,
            () => CustomerCartItem(
          id: DateTime.now().toString(),
              theTitle: title,
              thePrice: price,
              theQuantity: 1,
        ),
      );
    }
  }
}
