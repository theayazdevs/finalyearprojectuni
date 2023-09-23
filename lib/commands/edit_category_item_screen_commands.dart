import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fyp/models/app_text_to_speech.dart';

//Edit Category Items Screen Commands
class EditCategoryItemsScreenCommand {
  //list of commands
  static final commandsEditCategoryItems = [
    saveItem,
    save, done,
    back, goBack,
    title,
    itemTitle,
    clearTitle,
    description,
    itemDescription,
    clearDescription,
    price,
    itemPrice,
    clearPrice,
    name,
    itemName,
    clearName,
    clearItemName, cancel,
  ];

  //commands are constant because there value will stay the same throughout the app
  static const
      saveItem='save item',save = 'save', done='done',
      back = 'back', goBack='go back', cancel='cancel',
      title = 'title',
      itemTitle='item title',
      clearTitle = 'clear title',
      description = 'description',
      itemDescription = 'item description',
      clearDescription = 'clear description',
      price = 'price',
      itemPrice = 'item price',
      clearPrice = 'clear price',
      name = 'name',
      itemName = 'item name',
      clearName = 'clear name',
      clearItemName = 'clear item name';
}

//process commands if detected any
class EditCategoryItemsCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    if (text == EditCategoryItemsScreenCommand.save || text == EditCategoryItemsScreenCommand.saveItem || text == EditCategoryItemsScreenCommand.done) {
      return 'save';
    } else if (text == EditCategoryItemsScreenCommand.back || text == EditCategoryItemsScreenCommand.goBack || text == EditCategoryItemsScreenCommand.cancel) {
      return 'back';
    } else if (text == EditCategoryItemsScreenCommand.title ||
        text == EditCategoryItemsScreenCommand.name ||
        text == EditCategoryItemsScreenCommand.itemName||
        text == EditCategoryItemsScreenCommand.itemTitle) {
      AppTextToSpeech.replyText = 'Please say your new title!';
      return 'title';
    } else if (text == EditCategoryItemsScreenCommand.clearTitle ||
        text == EditCategoryItemsScreenCommand.clearName ||
        text == EditCategoryItemsScreenCommand.clearItemName) {
      return 'clear title';
    } else if (text == EditCategoryItemsScreenCommand.description||text == EditCategoryItemsScreenCommand.itemDescription) {
      AppTextToSpeech.replyText = 'Please say your new description!';
      return 'description';
    } else if (text == EditCategoryItemsScreenCommand.clearDescription) {
      return 'clear description';
    } else if (text == EditCategoryItemsScreenCommand.price||text == EditCategoryItemsScreenCommand.itemPrice) {
      AppTextToSpeech.replyText = 'Please say your new price!';
      return 'price';
    } else if (text == EditCategoryItemsScreenCommand.clearPrice) {
      return 'clear price';
    }
    //no commands found
    return 'nothing';
  }
}
