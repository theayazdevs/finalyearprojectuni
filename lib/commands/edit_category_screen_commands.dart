import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fyp/models/app_text_to_speech.dart';

//Edit Category Screen Commands
class EditCategoryScreenCommand {
  //list of commands
  static final commandsEditCategory = [
    saveCategory,
    saveNewCategory,
    save,
    done,
    goBack,
    back,
    categoryName,
    categoryTitle,
    newName,
    newTitle,
    title,
    name,
    clearTitle,
    clearName, cancel,
  ];

  //commands are constant because there value will stay the same throughout the app
  static const saveCategory = 'save category',
      saveNewCategory = 'save new category',
      save = 'save',
      done = 'done',
      back = 'back',
      goBack = 'go back', cancel='cancel',
      categoryName = 'category name',
      categoryTitle = 'category title',
      newName = 'new name',
      newTitle = 'new title',
      title = 'title',
      name = 'name',
      clearTitle = 'clear title',
      clearName = 'clear name';
}

//process commands if detected any
class EditCategoryCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    if (text == EditCategoryScreenCommand.save ||
        text == EditCategoryScreenCommand.saveNewCategory ||
        text == EditCategoryScreenCommand.saveCategory ||
        text == EditCategoryScreenCommand.done) {
      return 'save';
    } else if (text == EditCategoryScreenCommand.back ||
        text == EditCategoryScreenCommand.goBack||
        text == EditCategoryScreenCommand.cancel) {
      return 'back';
    } else if (text == EditCategoryScreenCommand.title ||
        text == EditCategoryScreenCommand.categoryName ||
        text == EditCategoryScreenCommand.categoryTitle ||
        text == EditCategoryScreenCommand.newName ||
        text == EditCategoryScreenCommand.newTitle ||
        text == EditCategoryScreenCommand.name) {
      AppTextToSpeech.replyText = 'Please say your new title!';
      return 'title';
    } else if (text == EditCategoryScreenCommand.clearTitle ||
        text == EditCategoryScreenCommand.clearName) {
      return 'clear title';
    }
    return 'nothing';
  }
}
