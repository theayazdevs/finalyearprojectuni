import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fyp/providers/food_category_provider.dart';

//Business Screen Commands
class BusinessScreenCommand {
  //list of commands
  static final commandsBusinessScreen = [
    manageMenu,
    manage,
    logout,
    signOut,
    repeat,
    myProfile,
    manageProfile,
    profile,
    myOrders,
    ordersReceived,
    orders,
    view,
    show,
    open,
    goSto,
    goTo,
  ];

  //commands based on the data received from the database will be stored in this variable
  static final commandsDynamicBusinessScreen = [];

  //commands are constant because there value will stay the same throughout the app
  static const manageMenu = 'manage menu',
      manage = 'manage',
      logout = 'logout',
      signOut = 'sign out',
      repeat = 'repeat',
      myProfile = 'my profile',
      manageProfile = 'manage profile',
      profile = 'profile',
      myOrders = 'my orders',
      ordersReceived = 'orders received',
      orders = 'orders',
      view = 'view',
      show = 'show',
      open = 'open',
      goSto = 'go to',
      goTo = 'goto';

//method to create commands that can be recognized based on the data received from the database
  static void categoryCommands(List<FoodCategoryProvider> theCommands) {
    theCommands.forEach((element) {
      //add to the list that will be recognised on screen display
      commandsBusinessScreen.add(element.title.toLowerCase());
      //add to the dynamic list command to take action based on these commands
      commandsDynamicBusinessScreen.add(element.title.toLowerCase());
    });
  }
}

//process commands if detected any
class BusinessScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //debugPrint('spokenWords: $spokenWords');
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    String categoryReturn = '';
    //check if the spoken word asks to view a category and which one
    BusinessScreenCommand.commandsDynamicBusinessScreen.forEach((element) {
      //log('current element in command loop: $element');
      if (element == text) {
        categoryReturn = element;
      } else if ('view $element' == text) {
        categoryReturn = element;
      } else if ('show $element' == text) {
        categoryReturn = element;
      } else if ('open $element' == text) {
        categoryReturn = element;
      }
    });
    //if any dynamic command detected, return action phrase
    if (categoryReturn != '') {
      //log('returning in command: $categoryReturn');
      return categoryReturn;
    }
    if (text == BusinessScreenCommand.manage ||
        text == BusinessScreenCommand.manageMenu ||
        text == 'goto ${BusinessScreenCommand.manage}' ||
        text == 'go to ${BusinessScreenCommand.manage}' ||
        text == 'goto ${BusinessScreenCommand.manageMenu}' ||
        text == 'go to ${BusinessScreenCommand.manageMenu}') {
      return 'manage';
    } else if (text == BusinessScreenCommand.orders ||
        text == BusinessScreenCommand.myOrders ||
        text == BusinessScreenCommand.ordersReceived ||
        text == 'goto ${BusinessScreenCommand.orders}' ||
        text == 'go to ${BusinessScreenCommand.orders}' ||
        text == 'goto ${BusinessScreenCommand.myOrders}' ||
        text == 'go to ${BusinessScreenCommand.myOrders}' ||
        text == 'goto ${BusinessScreenCommand.ordersReceived}' ||
        text == 'go to ${BusinessScreenCommand.ordersReceived}') {
      return 'orders';
    } else if (text == BusinessScreenCommand.logout ||
        text == BusinessScreenCommand.signOut) {
      return 'logout';
    } else if (text == BusinessScreenCommand.repeat) {
      return 'repeat';
    } else if (text == BusinessScreenCommand.profile ||
        text == BusinessScreenCommand.myProfile ||
        text == BusinessScreenCommand.manageProfile ||
        text == 'goto ${BusinessScreenCommand.profile}' ||
        text == 'go to ${BusinessScreenCommand.profile}' ||
        text == 'goto ${BusinessScreenCommand.myProfile}' ||
        text == 'go to ${BusinessScreenCommand.myProfile}' ||
        text == 'goto ${BusinessScreenCommand.manageProfile}' ||
        text == 'go to ${BusinessScreenCommand.manageProfile}') {
      return 'profile';
    }
    return 'nothing';
  }
}
