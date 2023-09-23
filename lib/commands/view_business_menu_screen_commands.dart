import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fyp/providers/food_category_provider.dart';

class ViewBusinessMenuScreenCommand {
  //list of commands
  static final commandsViewBusinessMenuScreen = [
    manageProfile,
    profile,
    myProfile,
    logout,
    signOut,
    repeat,
    cart,
    myCart,
    basket,
    myBasket,
    checkout,
    trolley,
    back,
    goBack,
    orders,
    myOrders,
    goSto,
    goTo,
  ];

  //commands based on the data received from the database will be stored in this variable
  static final commandsDynamicViewBusinessMenuScreen = [];

  //commands are constant because there value will stay the same throughout the app
  static const manageProfile = 'manage profile',
      logout = 'logout',
      signOut = 'sign out',
      repeat = 'repeat',
      profile = 'profile',
      myProfile = 'my profile',
      cart = 'cart',
      myCart = 'my cart',
      back = 'back',
      goBack = 'go back',
      orders = 'orders',
      myOrders = 'my orders',
      basket = 'basket',
      myBasket = 'my basket',
      trolley = 'trolley',
      checkout = 'check out',
      goSto = 'go to',
      goTo = 'goto';

  //method to create commands that can be recognized based on the data received from the database
  static void categoryCommands(List<FoodCategoryProvider> theCommands) {
    theCommands.forEach((element) {
      //add to the list that will be recognised on screen display
      commandsViewBusinessMenuScreen.add(element.title.toLowerCase());
      //add to the dynamic list command to take action based on these commands
      commandsDynamicViewBusinessMenuScreen.add(element.title.toLowerCase());
    });
  }
}

//process commands if detected any
class ViewBusinessMenuScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //debugPrint('spokenWords: $spokenWords');
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    String categoryReturn = '';
    ViewBusinessMenuScreenCommand.commandsDynamicViewBusinessMenuScreen
        .forEach((element) {
      //log('current element in command loop: $element');
      if (element == text) {
        categoryReturn = element;
      }
    });
    if (categoryReturn != '') {
      //log('returning in command: $categoryReturn');
      return categoryReturn;
    }
    if (text == ViewBusinessMenuScreenCommand.logout ||
        text == ViewBusinessMenuScreenCommand.signOut) {
      return 'logout';
    } else if (text == ViewBusinessMenuScreenCommand.repeat) {
      return 'repeat';
    } else if (text == ViewBusinessMenuScreenCommand.profile ||
        text == ViewBusinessMenuScreenCommand.myProfile ||
        text == ViewBusinessMenuScreenCommand.manageProfile ||
        text == 'goto ${ViewBusinessMenuScreenCommand.profile}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.profile}' ||
        text == 'goto ${ViewBusinessMenuScreenCommand.myProfile}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.myProfile}' ||
        text == 'goto ${ViewBusinessMenuScreenCommand.manageProfile}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.manageProfile}') {
      return 'profile';
    } else if (text == ViewBusinessMenuScreenCommand.cart ||
        text == ViewBusinessMenuScreenCommand.myCart ||
        text == ViewBusinessMenuScreenCommand.basket ||
        text == ViewBusinessMenuScreenCommand.myBasket ||
        text == ViewBusinessMenuScreenCommand.trolley ||
        text == ViewBusinessMenuScreenCommand.checkout ||
        text == 'goto ${ViewBusinessMenuScreenCommand.cart}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.cart}' ||
        text == 'goto ${ViewBusinessMenuScreenCommand.myCart}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.myCart}' ||
        text == 'goto ${ViewBusinessMenuScreenCommand.basket}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.basket}' ||
        text == 'goto ${ViewBusinessMenuScreenCommand.myBasket}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.myBasket}' ||
        text == 'goto ${ViewBusinessMenuScreenCommand.trolley}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.trolley}' ||
        text == 'goto ${ViewBusinessMenuScreenCommand.checkout}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.checkout}') {
      return 'cart';
    } else if (text == ViewBusinessMenuScreenCommand.back ||
        text == ViewBusinessMenuScreenCommand.goBack) {
      return 'back';
    } else if (text == ViewBusinessMenuScreenCommand.orders ||
        text == ViewBusinessMenuScreenCommand.myOrders ||
        text == 'goto ${ViewBusinessMenuScreenCommand.orders}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.orders}' ||
        text == 'goto ${ViewBusinessMenuScreenCommand.myOrders}' ||
        text == 'go to ${ViewBusinessMenuScreenCommand.myOrders}') {
      return 'orders';
    }
    //no command match found
    return 'nothing';
  }
}
