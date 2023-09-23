import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fyp/models/app_text_to_speech.dart';

//Business Orders Screen Commands
class BusinessOrdersScreenCommand {
  //list of commands
  static final commandsBusinessOrdersScreen = [
    home,
    myMenu,
    viewMenu,
    viewMyMenu,
    manage,
    manageMenu,
    orders,
    ordersReceived,
    profile,
    myProfile,
    logout,
    signout,
    repeat,
    scrollDown,
    goDown,
    scrollUp,
    goUp,
    stopScrolling,
    pauseScrolling,
    manageProfile,
    goSto,
    goTo,
  ];

  //commands are constant because there value will stay the same throughout the app
  static const logout = 'logout',
      signout='sign out',
      home = 'home',
      myMenu = 'my menu',
      viewMenu = 'view menu',
      viewMyMenu = 'view my menu',
      manage = 'manage',
      manageMenu = 'manage menu',
      orders = 'orders',
      ordersReceived = 'orders received',
      profile = 'profile',
      myProfile = 'my profile',
      repeat = 'repeat',
      scrollDown = 'scroll down',
      goDown = 'go down',
      scrollUp = 'scroll up',
      goUp = 'go up',
      stopScrolling = 'stop scrolling',
      pauseScrolling = 'pause scrolling',
      manageProfile = 'manage profile',
      goSto = 'go to',
      goTo = 'goto';
}

//process commands if detected any
class BusinessOrdersScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    if (text == BusinessOrdersScreenCommand.home ||
        text == BusinessOrdersScreenCommand.myMenu ||
        text == BusinessOrdersScreenCommand.viewMenu ||
        text == BusinessOrdersScreenCommand.viewMyMenu) {
      return 'home';
    } else if (text == BusinessOrdersScreenCommand.manageMenu ||
        text == BusinessOrdersScreenCommand.manage||
        text == 'goto ${BusinessOrdersScreenCommand.manage}' ||
        text == 'go to ${BusinessOrdersScreenCommand.manage}' ||
        text == 'goto ${BusinessOrdersScreenCommand.manageMenu}' ||
        text == 'go to ${BusinessOrdersScreenCommand.manageMenu}') {
      return 'manage';
    } else if (text == BusinessOrdersScreenCommand.orders ||
        text == BusinessOrdersScreenCommand.ordersReceived||
        text == 'goto ${BusinessOrdersScreenCommand.orders}' ||
        text == 'go to ${BusinessOrdersScreenCommand.orders}' ||
        text == 'goto ${BusinessOrdersScreenCommand.ordersReceived}' ||
        text == 'go to ${BusinessOrdersScreenCommand.ordersReceived}') {
      return 'orders';
    } else if (text == BusinessOrdersScreenCommand.profile ||
        text == BusinessOrdersScreenCommand.myProfile ||
        text == 'goto ${BusinessOrdersScreenCommand.profile}' ||
        text == 'go to ${BusinessOrdersScreenCommand.profile}' ||
        text == 'goto ${BusinessOrdersScreenCommand.myProfile}' ||
        text == 'go to ${BusinessOrdersScreenCommand.myProfile}' ||
        text == 'goto ${BusinessOrdersScreenCommand.manageProfile}' ||
        text == 'go to ${BusinessOrdersScreenCommand.manageProfile}') {
      return 'profile';
    } else if (text == BusinessOrdersScreenCommand.logout || text == BusinessOrdersScreenCommand.signout) {
      return 'logout';
    } else if (text == BusinessOrdersScreenCommand.repeat) {
      return 'repeat';
    } else if (text == BusinessOrdersScreenCommand.scrollDown ||
        text == BusinessOrdersScreenCommand.goDown) {
      return 'scroll down';
    } else if (text == BusinessOrdersScreenCommand.scrollUp ||
        text == BusinessOrdersScreenCommand.goUp) {
      return 'scroll up';
    } else if (text == BusinessOrdersScreenCommand.stopScrolling ||
        text == BusinessOrdersScreenCommand.pauseScrolling) {
      return 'scroll stop';
    }
    return 'nothing';
  }
}
