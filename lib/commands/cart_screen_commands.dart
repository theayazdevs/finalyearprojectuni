import 'dart:developer';
import 'package:fyp/providers/item_in_cart_provider.dart';

//Cart Screen Commands
class CartScreenCommand {
  //list of commands
  static final commandsCartScreen = [
    delete,
    goBack,
    back,
    removeAll,
    deleteAll,
    remove,
    order,
    chooseDelivery,
    selectDelivery,
    delivery,
    deliver,
    chooseCollection,
    selectCollection,
    collection,
    collect,
    buy,
    orderNow,
    menu,
    scrollDown,
    goDown,
    scrollUp,
    goUp,
    stopScrolling,
    pauseScrolling,
    addOne,
    addA,
    add,
    oneMore,
    placeOrder,
    repeat,
    one,
    clearCart,
    removeAllCart,
    emptyCart,
    removeBasket,
    emptyBasket,
  ];

  //commands based on the data received from the database will be stored in this variable
  static final commandsDynamicCartScreen = [];

  //commands are constant because there value will stay the same throughout the app
  static const delete = 'delete',
      goBack = 'go back',
      back = 'back',
      removeAll = 'remove all',
      deleteAll = 'delete all',
      remove = 'remove',
      order = 'order',
      chooseDelivery = 'choose delivery',
      selectDelivery = 'select delivery',
      delivery = 'delivery',
      deliver = 'deliver',
      chooseCollection = 'choose collection',
      selectCollection = 'select collection',
      collection = 'collection',
      collect = 'collect',
      buy = 'buy',
      orderNow = 'order now',
      menu = 'menu',
      scrollDown = 'scroll down',
      goDown = 'go down',
      scrollUp = 'scroll up',
      goUp = 'go up',
      stopScrolling = 'stop scrolling',
      pauseScrolling = 'pause scrolling',
      addOne = 'add one',
      one = 'one',
      addA = 'add a',
      add = 'add',
      oneMore = 'one more',
      placeOrder = 'place order',
      repeat = 'repeat',
      clearCart = 'clear cart',
      removeAllCart = 'remove all',
      emptyCart = 'empty cart',
      removeBasket = 'remove basket',
      emptyBasket = 'empty basket';

  //method to create commands that can be recognized based on the data received from the database
  static void cartCommands(Map<String, CustomerCartItem> theCommands) {
    theCommands.forEach((key, cartItem) {
      //add to the list that will be recognised on screen display
      commandsCartScreen.add(cartItem.theTitle.toLowerCase());
      //add to the dynamic list command to take action based on these commands
      commandsDynamicCartScreen.add(cartItem.theTitle.toLowerCase());
    });
  }
}

//process commands if detected any
class CartScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    String deleteItem = '';
    String deleteAllItems = '';
    String addItem = '';
    //check and add item to the cart, also recognize quantity upto ten items and which specific items
    CartScreenCommand.commandsDynamicCartScreen.forEach((element) {
      //log('current element in command loop: $element');
      if ('delete $element' == text ||
          'remove $element' == text ||
          'delete one $element' == text ||
          'remove one $element' == text) {
        deleteItem = element;
      } else if ('delete all $element' == text ||
          'remove all $element' == text) {
        deleteAllItems = element;
      } else if ('add one $element' == text ||
          'add a $element' == text ||
          'add $element' == text ||
          'one more $element' == text) {
        addItem = element;
      }
    });
    //return which item to delete
    if (deleteItem != '') {
      //log('returning in deleteItem command: $deleteItem');
      return 'delete $deleteItem';
    }
    //return which item to delete completely
    if (deleteAllItems != '') {
      //log('returning in deleteAllItems command: $deleteAllItems');
      return 'delete all $deleteAllItems';
    }
    //return to add one item
    if (addItem != '') {
      //log('returning in addItem command: $addItem');
      return 'add $addItem';
    }
    if (text == CartScreenCommand.back ||
        text == CartScreenCommand.menu ||
        text == CartScreenCommand.goBack) {
      return 'back';
    } else if (text == CartScreenCommand.deliver ||
        text == CartScreenCommand.delivery ||
        text == CartScreenCommand.chooseDelivery ||
        text == CartScreenCommand.selectDelivery) {
      return 'deliver';
    } else if (text == CartScreenCommand.collect ||
        text == CartScreenCommand.collection ||
        text == CartScreenCommand.chooseCollection ||
        text == CartScreenCommand.selectCollection) {
      return 'collect';
    } else if (text == CartScreenCommand.order ||
        text == CartScreenCommand.orderNow ||
        text == CartScreenCommand.buy ||
        text == CartScreenCommand.placeOrder) {
      return 'order';
    } else if (text == CartScreenCommand.scrollDown ||
        text == CartScreenCommand.goDown) {
      return 'scroll down';
    } else if (text == CartScreenCommand.scrollUp ||
        text == CartScreenCommand.goUp) {
      return 'scroll up';
    } else if (text == CartScreenCommand.stopScrolling ||
        text == CartScreenCommand.pauseScrolling) {
      return 'scroll stop';
    } else if (text == CartScreenCommand.clearCart ||
        text == CartScreenCommand.removeAllCart||
        text == CartScreenCommand.emptyBasket||
        text == CartScreenCommand.emptyCart||
        text == CartScreenCommand.removeBasket) {
      return 'clear cart';
    }else if (text == CartScreenCommand.repeat) {
      return 'repeat';
    }
    //no command match detected
    return 'nothing';
  }
}
