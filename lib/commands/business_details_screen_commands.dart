import 'dart:developer';
import 'package:flutter/material.dart';

//Business Details/Profile Screen Commands
class BusinessDetailsScreenCommand {
  //list of commands
  static final commandsBusinessDetailsScreen = [
    manageMenu,
    manage,
    logout,
    signOut,
    home,
    myMenu,
    repeat,
    editProfile,
    manageProfile,
    myOrders,
    ordersReceived,
    orders,
    goSto,
    goTo,
  ];
  //commands are constant because there value will stay the same throughout the app
  static const manageMenu = 'manage menu',
      manage = 'manage',
      logout = 'logout',
      signOut = 'sign out',
      home = 'home',
      myMenu = 'my menu',
      repeat = 'repeat',
      myOrders = 'my orders',
      ordersReceived = 'orders received',
      orders = 'orders',
      editProfile = 'edit profile',
      manageProfile = 'manage profile',
      goSto = 'go to',
      goTo = 'goto';
}
//process commands if detected any
class BusinessDetailsScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    if (text == BusinessDetailsScreenCommand.manage ||
        text == BusinessDetailsScreenCommand.manageMenu||
        text == 'goto ${BusinessDetailsScreenCommand.manage}' ||
        text == 'go to ${BusinessDetailsScreenCommand.manage}' ||
        text == 'goto ${BusinessDetailsScreenCommand.manageMenu}' ||
        text == 'go to ${BusinessDetailsScreenCommand.manageMenu}') {
      return 'manage';
    } else if (text == BusinessDetailsScreenCommand.logout ||
        text == BusinessDetailsScreenCommand.signOut) {
      return 'logout';
    } else if (text == BusinessDetailsScreenCommand.home ||
        text == BusinessDetailsScreenCommand.myMenu||
        text == 'goto ${BusinessDetailsScreenCommand.home}' ||
        text == 'go to ${BusinessDetailsScreenCommand.home}' ||
        text == 'goto ${BusinessDetailsScreenCommand.myMenu}' ||
        text == 'go to ${BusinessDetailsScreenCommand.myMenu}') {
      return 'home';
    } else if (text == BusinessDetailsScreenCommand.repeat) {
      return 'repeat';
    } else if (text == BusinessDetailsScreenCommand.editProfile ||
        text == BusinessDetailsScreenCommand.manageProfile) {
      return 'edit profile';
    } else if (text == BusinessDetailsScreenCommand.ordersReceived ||
        text == BusinessDetailsScreenCommand.myOrders ||
        text == BusinessDetailsScreenCommand.orders||
        text == 'goto ${BusinessDetailsScreenCommand.orders}' ||
        text == 'go to ${BusinessDetailsScreenCommand.orders}' ||
        text == 'goto ${BusinessDetailsScreenCommand.myOrders}' ||
        text == 'go to ${BusinessDetailsScreenCommand.myOrders}' ||
        text == 'goto ${BusinessDetailsScreenCommand.ordersReceived}' ||
        text == 'go to ${BusinessDetailsScreenCommand.ordersReceived}') {
      return 'orders';
    }
    return 'nothing';
  }
}
