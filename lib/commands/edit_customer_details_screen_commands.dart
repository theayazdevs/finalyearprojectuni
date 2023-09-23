import 'dart:developer';
import 'package:fyp/models/app_text_to_speech.dart';

//Edit Business Details/Profile Commands
class EditCustomerDetailsScreenCommand {
  //list of commands
  static final commandsEditCustomerDetailsScreen = [
    saveDetails,
    save,
    done,
    back,
    goBack,
    firstName, lastName, clearFirstName, clearLastName, phoneNumber, clearPNumber, clearPhone,
    clearDoorNo,
    doorNo,
    clearDoor,
    door,
    clearPostCode,
    postcode,
    businessPost,
  ];

  //commands are constant because there value will stay the same throughout the app
  static const save = 'save',
      saveDetails = 'save details',
      done = 'done',
      back = 'back',
      goBack = 'go back',
      firstName = 'first name',
      lastName = 'last name',
      clearFirstName = 'clear first name',
      clearLastName = 'clear last name',
      door = 'door',
      doorNo = 'door number',
      clearDoor = 'clear door',
      clearDoorNo = 'clear door number',
      postcode = 'postcode',
      businessPost = 'business post code',
      clearPostCode = 'clear post code',
      phoneNumber = 'phone number',
      clearPNumber = 'clear phone number',
      clearPhone = 'clear phone', cancel='cancel';
}

//process commands if detected any
class EditCustomerDetailsScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);

    if (text == EditCustomerDetailsScreenCommand.save ||
        text == EditCustomerDetailsScreenCommand.saveDetails ||
        text == EditCustomerDetailsScreenCommand.done) {
      return 'save';
    } else if (text == EditCustomerDetailsScreenCommand.back ||
        text == EditCustomerDetailsScreenCommand.goBack||
        text == EditCustomerDetailsScreenCommand.cancel) {
      return 'back';
    } else if (text == EditCustomerDetailsScreenCommand.firstName) {
      AppTextToSpeech.replyText = 'Please say your first name!';
      return 'firstName';
    } else if (text == EditCustomerDetailsScreenCommand.clearFirstName) {
      return 'clear firstName';
    } else if (text == EditCustomerDetailsScreenCommand.lastName) {
      AppTextToSpeech.replyText = 'Please say your last name!';
      return 'lastName';
    } else if (text == EditCustomerDetailsScreenCommand.clearLastName) {
      return 'clear lastName';
    } else if (text == EditCustomerDetailsScreenCommand.door ||
        text == EditCustomerDetailsScreenCommand.doorNo) {
      AppTextToSpeech.replyText = 'Please say your new door number!';
      return 'door';
    } else if (text == EditCustomerDetailsScreenCommand.clearDoor ||
        text == EditCustomerDetailsScreenCommand.clearDoorNo) {
      return 'clear door';
    } else if (text == EditCustomerDetailsScreenCommand.postcode ||
        text == EditCustomerDetailsScreenCommand.businessPost) {
      AppTextToSpeech.replyText = 'Please say your new business post code!';
      return 'post code';
    } else if (text == EditCustomerDetailsScreenCommand.clearPostCode) {
      return 'clear postcode';
    } else if (text == EditCustomerDetailsScreenCommand.phoneNumber) {
      AppTextToSpeech.replyText = 'Please say your new phone number!';
      return 'phone number';
    } else if (text == EditCustomerDetailsScreenCommand.clearPNumber || text == EditCustomerDetailsScreenCommand.clearPhone) {
      return 'clear phone number';
    }
    //no commands found
    return 'nothing';
  }
}
