//import 'dart:developer';
//import 'package:flutter/material.dart';
import '../providers/food_category_provider.dart';

//Manage Menu Screen Commands
class ManageMenuCommand {
  //list of commands
  static final commandsManageMenu = [
    home,
    myMenu,
    show,
    view,
    open,
    addCategory,
    addANewCategory,
    addNewCategory,
    newCategory,
    add,
    repeat,
    edit,
    modify,
    update,
    change,
    delete,
    remove,
    myProfile,
    profile,
    manageProfile,
    myOrders,
    ordersReceived,
    orders,
    goSto,
    goTo,
    logout,
    signout,
  ];

  //commands based on the data received from the database will be stored in this variable
  static final commandsDynamicManageMenu = [];

  //commands are constant because there value will stay the same throughout the app
  static const home = 'home',
      myMenu = 'my menu',
      show = 'show',
      view = 'view',
      open = 'open',
      add = 'add',
      addCategory = 'add category',
      addANewCategory = 'add a new category',
      addNewCategory = 'add new category',
      newCategory = 'new category',
      logout = 'logout',
      signout = 'sign out',
      repeat = 'repeat',
      edit = 'edit',
      update = 'update',
      modify = 'modify',
      change = 'change',
      delete = 'delete',
      remove = 'remove',
      orders = 'orders',
      myOrders = 'my orders',
      ordersReceived = 'orders received',
      profile = 'profile',
      myProfile = 'my profile',
      manageProfile = 'manage profile',
      goSto = 'go to',
      goTo = 'goto';

  //method to create commands that can be recognized based on the data received from the database
  static void categoryCommands(List<FoodCategoryProvider> theCommands) {
    theCommands.forEach((element) {
      //add to the list that will be recognised on screen display
      commandsManageMenu.add(element.title.toLowerCase());
      //add to the dynamic list command to take action based on these commands
      commandsDynamicManageMenu.add(element.title.toLowerCase());
    });
  }
}

//process commands if detected any
class ManageMenuCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    String categoryReturn = '';
    String editCategory = '';
    String deleteCategory = '';
    //check for dynamic commands
    ManageMenuCommand.commandsDynamicManageMenu.forEach((element) {
      //log('current element in command loop: $element');
      if (element == text) {
        categoryReturn = element;
      } else if ('view $element' == text ||
          'show $element' == text ||
          'open $element' == text) {
        categoryReturn = element;
      } else if ('edit $element' == text ||
          'update $element' == text ||
          'modify $element' == text ||
          'change $element' == text) {
        editCategory = element;
      } else if ('delete $element' == text || 'remove $element' == text) {
        deleteCategory = element;
      }
    });
    if (categoryReturn != '') {
      //log('returning in command: $categoryReturn');
      return categoryReturn;
    }
    if (editCategory != '') {
      //log('returning in editCategory command: $editCategory');
      return 'edit $editCategory';
    }
    if (deleteCategory != '') {
      //log('returning in deleteCategory command: $deleteCategory');
      return 'delete $deleteCategory';
    }

    if (text == ManageMenuCommand.home || text == ManageMenuCommand.myMenu) {
      return 'home';
    } else if (text == ManageMenuCommand.repeat) {
      return 'repeat';
    } else if (text == ManageMenuCommand.add ||
        text == ManageMenuCommand.addCategory ||
        text == ManageMenuCommand.addNewCategory ||
        text == ManageMenuCommand.newCategory ||
        text == ManageMenuCommand.addANewCategory) {
      return 'add';
    } else if (text == ManageMenuCommand.logout ||
        text == ManageMenuCommand.signout) {
      return 'logout';
    } else if (text == ManageMenuCommand.profile ||
        text == ManageMenuCommand.myProfile ||
        text == 'goto ${ManageMenuCommand.profile}' ||
        text == 'go to ${ManageMenuCommand.profile}' ||
        text == 'goto ${ManageMenuCommand.myProfile}' ||
        text == 'go to ${ManageMenuCommand.myProfile}' ||
        text == 'goto ${ManageMenuCommand.manageProfile}' ||
        text == 'go to ${ManageMenuCommand.manageProfile}') {
      return 'profile';
    } else if (text == ManageMenuCommand.orders ||
        text == ManageMenuCommand.myOrders ||
        text == ManageMenuCommand.ordersReceived ||
        text == 'goto ${ManageMenuCommand.orders}' ||
        text == 'go to ${ManageMenuCommand.orders}' ||
        text == 'goto ${ManageMenuCommand.myOrders}' ||
        text == 'go to ${ManageMenuCommand.myOrders}' ||
        text == 'goto ${ManageMenuCommand.ordersReceived}' ||
        text == 'go to ${ManageMenuCommand.ordersReceived}') {
      return 'orders';
    }
    //no commands found
    return 'nothing';
  }
}
