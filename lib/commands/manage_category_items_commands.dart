import 'dart:developer';
import 'package:flutter/material.dart';
import '../providers/category_item_provider.dart';

//Manage Category Items Commands
class ManageCategoryItemsCommand {
  //list of commands
  static final commandsManageCategoryItems = [
    addANewItem,
    addNewItem,
    addItem,
    add,
    edit,
    modify,
    update,
    change,
    delete,
    remove,
    goBack,
    back,
    repeat,
  ];

  //commands based on the data received from the database will be stored in this variable
  static final commandsDynamicManageCategoryItems = [];

  //commands are constant because there value will stay the same throughout the app
  static const addANewItem = 'add a new item',
      addNewItem = 'add new item',
      addItem = 'add item',
      add = 'add',
      logout = 'logout',
      edit = 'edit',
      modify = 'modify',
      delete = 'delete',
      update = 'update',
      change = 'change',
      remove = 'remove',
      goBack = 'go back',
      back = 'back',
      repeat = 'repeat';

  //method to create commands that can be recognized based on the data received from the database
  static void categoryItemsCommands(List<CategoryItemProvider> theCommands) {
    theCommands.forEach((element) {
      //add to the list that will be recognised on screen display
      commandsManageCategoryItems.add(element.categoryItemTitle.toLowerCase().trim());
      //add to the dynamic list command to take action based on these commands
      commandsDynamicManageCategoryItems
          .add(element.categoryItemTitle.toLowerCase().trim());
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
    String editItemCategory = '';
    String deleteItemCategory = '';
    //check if any dynamic command is detected
    ManageCategoryItemsCommand.commandsDynamicManageCategoryItems
        .forEach((element) {
      //log('current element in command loop: $element');
      if ('edit $element' == text || 'update $element' == text) {
        editItemCategory = element;
      } else if ('modify $element' == text || 'change $element' == text) {
        editItemCategory = element;
      } else if ('delete $element' == text) {
        deleteItemCategory = element;
      } else if ('remove $element' == text) {
        deleteItemCategory = element;
      }
    });
    if (editItemCategory != '') {
      //log('returning in editCategoryItem command: $editItemCategory');
      return 'edit $editItemCategory';
    }
    if (deleteItemCategory != '') {
      //log('returning in deleteCategoryItem command: $deleteItemCategory');
      return 'delete $deleteItemCategory';
    }
    if (text == ManageCategoryItemsCommand.add ||
        text == ManageCategoryItemsCommand.addNewItem ||
        text == ManageCategoryItemsCommand.addItem ||
        text == ManageCategoryItemsCommand.addANewItem) {
      return 'add';
    } else if (text == ManageCategoryItemsCommand.logout) {
      return 'logout';
    } else if (text == ManageCategoryItemsCommand.back ||
        text == ManageCategoryItemsCommand.goBack) {
      return 'back';
    } else if (text == ManageCategoryItemsCommand.repeat) {
      return 'repeat';
    }
    //no command found
    return 'nothing';
  }
}
