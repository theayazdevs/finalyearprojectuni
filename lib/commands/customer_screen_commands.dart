import 'dart:developer';
import 'package:flutter/material.dart';
import '../providers/business_data_provider.dart';

//Customer Screen Commands
class CustomerScreenCommand {
  //list of commands
  static final commandsCustomerScreen = [
    manageProfile,
    logout,
    signOut,
    repeat,
    profile,
    myProfile,
    orders,
    myOrders,
    search,
    find,
    clearSearch,
    clearSearchBox,
    cancelSearch,
    cancel,
    scrollDown,
    goDown,
    scrollUp,
    goUp,
    stopScrolling,
    pauseScrolling,
    goSto,
    goto,
  ];

  //commands based on the data received from the database will be stored in this variable
  static final commandsDynamicCustomerScreen = [];

  //commands are constant because there value will stay the same throughout the app
  static const manageProfile = 'manage profile',
      logout = 'logout',
      signOut = 'sign out',
      repeat = 'repeat',
      profile = 'profile',
      myProfile = 'my profile',
      orders = 'orders',
      myOrders = 'my orders',
      search = 'search',
      find = 'find',
      clearSearch = 'clear search',
      clearSearchBox = 'clear search box',
      cancelSearch = 'cancel search',
      cancel = 'cancel',
      scrollDown = 'scroll down',
      goDown = 'go down',
      scrollUp = 'scroll up',
      goUp = 'go up',
      stopScrolling = 'stop scrolling',
      pauseScrolling = 'pause scrolling',
      goSto = 'go to',
      goto = 'goto';

  //method to create commands that can be recognized based on the data received from the database
  static void businessNameCommands(List<BusinessData> theCommands) {
    theCommands.forEach((element) {
      //log('businessNameCommands $element');
      //adding to recognize and show on screen
      commandsCustomerScreen.add(element.businessName.toLowerCase());
      //adding to carry out action based on command
      commandsDynamicCustomerScreen.add(element.businessName.toLowerCase());
    });
  }
}

//process commands if detected any
class CustomerScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //debugPrint('spokenWords: $spokenWords');
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    String categoryReturn = '';
    //CustomerScreenCommand.commandsCustomerScreen.forEach((element) {
    //check if text matched any item from the dynamic commands list
    CustomerScreenCommand.commandsDynamicCustomerScreen.forEach((element) {
      //log('current element in command loop: $element');
      if (element == text) {
        categoryReturn = element;
      } else if ('go to $element' == text) {
        categoryReturn = element;
      } else if ('view $element' == text) {
        categoryReturn = element;
      } else if ('see $element' == text) {
        categoryReturn = element;
      } else if ('open $element' == text) {
        categoryReturn = element;
      }
    });
    if (categoryReturn != '') {
      //log('returning in command: $categoryReturn');
      return categoryReturn;
    }
    if (text == CustomerScreenCommand.logout ||
        text == CustomerScreenCommand.signOut) {
      return 'logout';
    } else if (text == CustomerScreenCommand.repeat) {
      return 'repeat';
    } else if (text == CustomerScreenCommand.profile ||
        text == CustomerScreenCommand.myProfile ||
        text == CustomerScreenCommand.manageProfile ||
        text == 'goto ${CustomerScreenCommand.profile}' ||
        text == 'go to ${CustomerScreenCommand.profile}' ||
        text == 'goto ${CustomerScreenCommand.myProfile}' ||
        text == 'go to ${CustomerScreenCommand.myProfile}' ||
        text == 'goto ${CustomerScreenCommand.manageProfile}' ||
        text == 'go to ${CustomerScreenCommand.manageProfile}') {
      return 'profile';
    } else if (text == CustomerScreenCommand.orders ||
        text == CustomerScreenCommand.myOrders ||
        text == 'goto ${CustomerScreenCommand.orders}' ||
        text == 'go to ${CustomerScreenCommand.orders}' ||
        text == 'goto ${CustomerScreenCommand.myOrders}' ||
        text == 'go to ${CustomerScreenCommand.myOrders}') {
      return 'orders';
    } else if (text == CustomerScreenCommand.search ||
        text == CustomerScreenCommand.search) {
      return 'search';
    } else if (text == CustomerScreenCommand.clearSearch ||
        text == CustomerScreenCommand.clearSearchBox ||
        text == CustomerScreenCommand.cancelSearch) {
      return 'clear search';
    } else if (text == CustomerScreenCommand.cancelSearch ||
        text == CustomerScreenCommand.cancel) {
      return 'cancel search';
    } else if (text == CustomerScreenCommand.scrollDown ||
        text == CustomerScreenCommand.goDown) {
      return 'scroll down';
    } else if (text == CustomerScreenCommand.scrollUp ||
        text == CustomerScreenCommand.goUp) {
      return 'scroll up';
    } else if (text == CustomerScreenCommand.stopScrolling ||
        text == CustomerScreenCommand.pauseScrolling) {
      return 'scroll stop';
    }
    //no command found
    return 'nothing';
  }
}
