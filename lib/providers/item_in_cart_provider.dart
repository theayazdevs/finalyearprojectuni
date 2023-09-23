import 'package:flutter/foundation.dart';

//Cart item class
class CustomerCartItem {
  final String id;
  final String theTitle;
  final double thePrice;
  final int theQuantity;
//constructor
  CustomerCartItem({
    required this.id,
    required this.theTitle,
    required this.thePrice,
    required this.theQuantity,
  });
}
//Cart class, using Change Notifier to notify listeners of any changes made
class CustomerCart with ChangeNotifier {
  //to store cart items
  Map<String, CustomerCartItem> _theItems = {};
  //to return cart items
  Map<String, CustomerCartItem> get allCartItems {
    return {..._theItems};
  }
  //return the count of the items in the cart
  int get getCartItemCount {
    return _theItems.length;
  }
  //return total amount of the items in the cart added up
  double get getTotalAmount {
    var theTotal = 0.0;
    _theItems.forEach((theKey, theCartItem) {
      theTotal += theCartItem.thePrice * theCartItem.theQuantity;
    });
    //debugPrint(total);
    return theTotal;
  }
  //add an item to the cart
  void addItemToCart(
      String theItemID,
      double theItemPrice,
      String theItemTitle,
      String ownerID
      ) {
    //debugPrint('${'$itemID/$price'}/$title/$ownerID');
    if (_theItems.containsKey(theItemID)) {
      //change quantity...
      _theItems.update(
        theItemID,
            (existingCartItem) => CustomerCartItem(
          id: existingCartItem.id,
              theTitle: existingCartItem.theTitle,
              thePrice: existingCartItem.thePrice,
              theQuantity: existingCartItem.theQuantity + 1,
        ),
      );
    } else {
      _theItems.putIfAbsent(
        theItemID,
            () => CustomerCartItem(
          id: DateTime.now().toString(),
              theTitle: theItemTitle,
              thePrice: theItemPrice,
              theQuantity: 1,
        ),
      );
    }
    notifyListeners();
  }
  //remove an item form the cart by given ID
  void removeCartItemByID(String removeItemID) {
    _theItems.remove(removeItemID);
    notifyListeners();
  }
  //remove just one item from the cart
  void removeSingleCartItem(String removeItemID) {
    //debugPrint(itemID);
    if (!_theItems.containsKey(removeItemID)) {
      return;
    }
    if (_theItems[removeItemID]!.theQuantity > 1) {
      _theItems.update(
          removeItemID,
              (presentCartItem) => CustomerCartItem(
            id: presentCartItem.id,
                theTitle: presentCartItem.theTitle,
                thePrice: presentCartItem.thePrice,
                theQuantity: presentCartItem.theQuantity - 1,
          ));
    } else {
      _theItems.remove(removeItemID);
    }
    notifyListeners();
  }
  //add one item to the cart
  void addSingleItemToCart(String itemID) {
    //debugPrint(itemID);
    if (!_theItems.containsKey(itemID)) {
      return;
    }
    _theItems.update(
          itemID,
              (presentCartItem) => CustomerCartItem(
            id: presentCartItem.id,
                theTitle: presentCartItem.theTitle,
                thePrice: presentCartItem.thePrice,
                theQuantity: presentCartItem.theQuantity + 1,
          ));
    notifyListeners();
  }
//clear the entire cart
  void clearCart() {
    _theItems = {};
    notifyListeners();
  }
}
