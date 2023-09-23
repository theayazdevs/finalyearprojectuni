import 'dart:developer';
import 'package:fyp/models/app_text_to_speech.dart';

//Edit Business Details/Profile Commands
class EditBusinessDetailsScreenCommand {
  //list of commands
  static final commandsEditBusinessDetailsScreen = [
    saveDetails,
    save,
    done,
    back,
    goBack,
    businessName,
    nameBusiness,
    clearBusinessName,
    clearName,
    businessType,
    typeBusiness,
    clearType,
    clearBusinessType,
    door,
    doorNo,
    clearDoor,
    clearDoorNo,
    postcode,
    businessPost,
    clearPostCode,
    service,
    clearService,
    times,
    openTimes,
    clearTimes,
    clearOpenTimes,
  ];

  //commands are constant because there value will stay the same throughout the app
  static const save = 'save',
      saveDetails = 'save details',
      done = 'done',
      back = 'back',
      goBack = 'go back',
      businessName = 'business name',
      nameBusiness = 'name',
      clearBusinessName = 'clear business name',
      clearName = 'clear name',
      businessType = 'type',
      typeBusiness = 'business type',
      clearType = 'clear type',
      clearBusinessType = 'clear business type',
      door = 'door',
      doorNo = 'door number',
      clearDoor = 'clear door',
      clearDoorNo = 'clear door number',
      postcode = 'postcode',
      businessPost = 'business post code',
      clearPostCode = 'clear post code',
      service = 'service',
      clearService = 'clear service',
      times = 'business times',
      openTimes = 'opening times',
      clearTimes = 'clear times',
      clearOpenTimes = 'clear opening times',cancel='cancel';
}

//process commands if detected any
class EditBusinessDetailsScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);

    if (text == EditBusinessDetailsScreenCommand.save ||
        text == EditBusinessDetailsScreenCommand.saveDetails ||
        text == EditBusinessDetailsScreenCommand.done) {
      return 'save';
    } else if (text == EditBusinessDetailsScreenCommand.back ||
        text == EditBusinessDetailsScreenCommand.goBack||
        text == EditBusinessDetailsScreenCommand.cancel) {
      return 'back';
    } else if (text == EditBusinessDetailsScreenCommand.businessName ||
        text == EditBusinessDetailsScreenCommand.nameBusiness) {
      AppTextToSpeech.replyText = 'Please say your new business name!';
      return 'business name';
    } else if (text == EditBusinessDetailsScreenCommand.clearBusinessName ||
        text == EditBusinessDetailsScreenCommand.clearName) {
      return 'clear name';
    } else if (text == EditBusinessDetailsScreenCommand.businessType ||
        text == EditBusinessDetailsScreenCommand.typeBusiness) {
      AppTextToSpeech.replyText = 'Please say your new business type!';
      return 'business type';
    } else if (text == EditBusinessDetailsScreenCommand.clearType ||
        text == EditBusinessDetailsScreenCommand.clearBusinessType) {
      return 'clear type';
    } else if (text == EditBusinessDetailsScreenCommand.door ||
        text == EditBusinessDetailsScreenCommand.doorNo) {
      AppTextToSpeech.replyText = 'Please say your new door number!';
      return 'door';
    } else if (text == EditBusinessDetailsScreenCommand.clearDoor ||
        text == EditBusinessDetailsScreenCommand.clearDoorNo) {
      return 'clear door';
    } else if (text == EditBusinessDetailsScreenCommand.postcode ||
        text == EditBusinessDetailsScreenCommand.businessPost) {
      AppTextToSpeech.replyText = 'Please say your new business post code!';
      return 'post code';
    } else if (text == EditBusinessDetailsScreenCommand.clearPostCode) {
      return 'clear postcode';
    } else if (text == EditBusinessDetailsScreenCommand.service) {
      AppTextToSpeech.replyText = 'Please say your new service!';
      return 'service';
    } else if (text == EditBusinessDetailsScreenCommand.clearService) {
      return 'clear service';
    } else if (text == EditBusinessDetailsScreenCommand.openTimes ||
        text == EditBusinessDetailsScreenCommand.times) {
      AppTextToSpeech.replyText = 'Please say your new times!';
      return 'times';
    } else if (text == EditBusinessDetailsScreenCommand.clearTimes ||
        text == EditBusinessDetailsScreenCommand.clearOpenTimes) {
      return 'clear times';
    }
    //no commands found
    return 'nothing';
  }
}
