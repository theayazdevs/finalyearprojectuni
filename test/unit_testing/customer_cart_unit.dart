import 'package:flutter_test/flutter_test.dart';
import 'package:fyp/providers/item_in_cart_provider.dart';
import 'package:mockito/mockito.dart';

//unit testing
void main() {
  late CustomerCart systemUnderTest;
  setUp(() {
    systemUnderTest = MockCustomerCart();
  });
  //grouping unit tests
  group('Customer Cart Tests', () {
    test('Add items to cart', () async {
      //checking initial length
      expect(systemUnderTest.allCartItems.length, 2);
      //adding a new item
      systemUnderTest.addItemToCart('3', 4.00, 'chicken burger', 'theOwner-1');
      //checking if one new one was added
      expect(systemUnderTest.allCartItems.length, 3);
      //making sure correct item was added
      expect(systemUnderTest.allCartItems['3']?.theTitle.toString(), 'chicken burger');
    });
    test('Removing item completely from cart', () async {
      //checking initial length
      expect(systemUnderTest.allCartItems.length, 2);
      //removing an item completely
      systemUnderTest.removeCartItemByID('2');
      //making sure if item was removed
      expect(systemUnderTest.allCartItems.length, 1);
    });
    test('Removing single item from cart', () async {
      //checking initial length
      expect(systemUnderTest.allCartItems.length, 2);
      //just remove one from quantity of an item
      systemUnderTest.removeSingleCartItem('1');
      //making sure that item was not removed completely but just 1 as total are 2
      expect(systemUnderTest.allCartItems.length, 2);
      //checking quantity
      expect(systemUnderTest.allCartItems['1']?.theQuantity, 1);
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
  Map<String, CustomerCartItem> get allCartItems {
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
