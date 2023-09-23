import 'dart:developer';

import '../providers/category_item_provider.dart';

//Buy Items Screen Commands
class BuyItemsScreenCommand {
  //list of commands
  static final commandsBuyItemsScreen = [
    add,
    buy,
    goBack,
    repeat,
    back,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
    ten,
    wOne,
    wTwo,
    wThree,
    wFour,
    wFive,
    wSix,
    wSeven,
    wEight,
    wNine,
    wTen,
  ];

  //commands based on the data received from the database will be stored in this variable
  static final commandsDynamicBuyItemsScreen = [];

  //commands are constant because there value will stay the same throughout the app
  static const add = 'add',
      buy = 'buy',
      back = 'back',
      goBack = 'go back',
      repeat = 'repeat',
      one = '1',
      two = '2',
      three = '3',
      four = '4',
      five = '5',
      six = '6',
      seven = '7',
      eight = '8',
      nine = '9',
      ten = '10',
      wOne = 'one',
      wTwo = 'two',
      wThree = 'three',
      wFour = 'four',
      wFive = 'five',
      wSix = 'six',
      wSeven = 'seven',
      wEight = 'eight',
      wNine = 'nine',
      wTen = 'ten';

//method to create commands that can be recognized based on the data received from the database
  static void categoryItemsCommands(List<CategoryItemProvider> theCommands) {
    theCommands.forEach((element) {
      //add to the list that will be recognised on screen display
      commandsBuyItemsScreen.add(element.categoryItemTitle.toLowerCase().trim());
      //add to the dynamic list command to take action based on these commands
      commandsDynamicBuyItemsScreen.add(element.categoryItemTitle.toLowerCase().trim());
    });
  }
}

//process commands if detected any
class BuyItemsScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    String addCategoryItem = '';
    //check and add item to the cart, also recognize quantity upto ten items and which specific items
    BuyItemsScreenCommand.commandsDynamicBuyItemsScreen.forEach((element) {
      //log('current element in command loop: $element');
      if ('add $element' == text ||
          'buy $element' == text ||
          'add 1 $element' == text ||
          'buy 1 $element' == text ||
          '1 $element' == text ||
          'one $element' == text) {
        addCategoryItem = element;
      } else if ('add 2 $element' == text ||
          'buy 2 $element' == text ||
          'add two $element' == text ||
          'buy two $element' == text ||
          '2 $element' == text ||
          'two $element' == text) {
        addCategoryItem = '2 $element';
      } else if ('add 3 $element' == text ||
          'buy 3 $element' == text ||
          'add three $element' == text ||
          'buy three $element' == text ||
          '3 $element' == text ||
          'three $element' == text) {
        addCategoryItem = '3 $element';
      } else if ('add 4 $element' == text ||
          'buy 4 $element' == text ||
          'add four $element' == text ||
          'buy four $element' == text ||
          '4 $element' == text ||
          'four $element' == text) {
        addCategoryItem = '4 $element';
      } else if ('add 5 $element' == text ||
          'buy 5 $element' == text ||
          'add five $element' == text ||
          'buy five $element' == text ||
          'five $element' == text ||
          '5 $element' == text) {
        addCategoryItem = '5 $element';
      } else if ('add 6 $element' == text ||
          'buy 6 $element' == text ||
          'add six $element' == text ||
          'buy six $element' == text ||
          'six $element' == text ||
          '6 $element' == text) {
        addCategoryItem = '6 $element';
      } else if ('add 7 $element' == text ||
          'buy 7 $element' == text ||
          'add seven $element' == text ||
          'buy seven $element' == text ||
          'seven $element' == text ||
          '7 $element' == text) {
        addCategoryItem = '7 $element';
      } else if ('add 8 $element' == text ||
          'buy 8 $element' == text ||
          'add eight $element' == text ||
          'buy eight $element' == text ||
          'eight $element' == text ||
          '8 $element' == text) {
        addCategoryItem = '8 $element';
      } else if ('add 9 $element' == text ||
          'buy 9 $element' == text ||
          'add nine $element' == text ||
          'buy nine $element' == text ||
          'nine $element' == text ||
          '9 $element' == text) {
        addCategoryItem = '9 $element';
      } else if ('add 10 $element' == text ||
          'buy 10 $element' == text ||
          'add ten $element' == text ||
          'buy ten $element' == text ||
          'ten $element' == text ||
          '10 $element' == text) {
        addCategoryItem = '10 $element';
      }
    });
    //return if any dynamic command detected
    if (addCategoryItem != '') {
      //log('returning in add item command: $addCategoryItem');
      //AppTextToSpeech.replyText='$addCategoryItem added';
      //AppTextToSpeech.speak();
      return 'buy $addCategoryItem';
    }
    if (text == BuyItemsScreenCommand.back ||
        text == BuyItemsScreenCommand.goBack) {
      return 'back';
    } else if (text == BuyItemsScreenCommand.repeat) {
      return 'repeat';
    }
    return 'nothing';
  }
}
