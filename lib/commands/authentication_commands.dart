import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fyp/models/app_text_to_speech.dart';

//Commands for the Authentication Screen
class AuthenticationCommand {
  //list of commands recognized on Authentication screen
  static final commandsAuthentication = [
    email,
    password,
    customer,
    business,
    login,
    loginT,
    signUp,
    signupInstead,
    loginInstead,
    cnfrmPass,
    atSymbol,
    atName,
    dotSymbol,
    dotName,
    hello,
    hi,
    help,
    clearEmail,
    clearPass,
    clearCnfrmPass,
    loginT,
    signIn,
    signInT,
  ];

  //commands are constant because there value will stay the same throughout the app
  static const email = 'email',
      password = 'password',
      customer = 'customer',
      business = 'business',
      login = 'log in',
      loginT = 'login',
      signIn = 'sign in',
      signInT = 'signin',
      signUp = 'sign up',
      signupInstead = 'register instead',
      loginInstead = 'sign in instead',
      cnfrmPass = 'confirm password',
      atSymbol = '@',
      atName = 'at',
      dotSymbol = '.',
      dotName = 'dot',
      hello = 'hello',
      hi = 'hi',
      help = 'help',
      clearEmail = 'clear email',
      clearPass = 'clear password',
      clearCnfrmPass = 'clear confirm password';
}

//process commands if any match is detected and return action to the authentication screen
class AuthenticationCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    final text = spokenWords.toLowerCase();
    if (text == AuthenticationCommand.clearEmail) {
      AppTextToSpeech.replyText = 'Email field cleared!';
      return 'clearEmail';
    } else if (text == AuthenticationCommand.clearPass) {
      AppTextToSpeech.replyText = 'Password field cleared!';
      return 'clearPass';
    } else if (text == AuthenticationCommand.clearCnfrmPass) {
      AppTextToSpeech.replyText = 'Confirm Password field cleared!';
      return 'clearCnfrmPass';
    }
    //else if (text.contains(AuthenticationCommand.email)) {
    else if (text == AuthenticationCommand.email) {
      AppTextToSpeech.replyText = 'Please say your complete email address';
      return '_emailFocus';
    } else if (text == AuthenticationCommand.password) {
      AppTextToSpeech.replyText = 'Please say your password';
      return '_passFocus';
    } else if (text == AuthenticationCommand.cnfrmPass) {
      AppTextToSpeech.replyText = 'Please say your password again';
      return '_cnfrmPassFocus';
    } else if (text.contains(AuthenticationCommand.customer)) {
      AppTextToSpeech.replyText = 'Customer mode selected';
      return 'customer';
    } else if (text.contains(AuthenticationCommand.business)) {
      AppTextToSpeech.replyText = 'Business mode selected';
      return 'business';
    } else if (text.contains(AuthenticationCommand.login) ||
        text.contains(AuthenticationCommand.signUp) ||
        text.contains(AuthenticationCommand.loginT) ||
        text.contains(AuthenticationCommand.signIn) ||
        text.contains(AuthenticationCommand.signInT)) {
      AppTextToSpeech.replyText = 'Submitting data';
      return 'submitBtn';
    } else if (text.contains(AuthenticationCommand.loginInstead)) {
      AppTextToSpeech.replyText = 'Login Page';
      return 'loginPage';
    } else if (text.contains(AuthenticationCommand.signupInstead)) {
      AppTextToSpeech.replyText = 'Registration Page';
      return 'signUpPage';
    } else if ((text.contains(AuthenticationCommand.atName) ||
            text.contains(AuthenticationCommand.atSymbol)) &&
        (text.contains(AuthenticationCommand.dotSymbol) ||
            text.contains(AuthenticationCommand.dotName))) {
      String converToEmail =
          text.replaceAll('at', '@').replaceAll('dot', '.').trim();
      //emailCorrection.replaceAll(RegExp(r'\s+'), '');
      String emailCorrection = '';
      // Iterate over the characters in the original string
      for (int i = 0; i < converToEmail.length; i++) {
        //eliminating spaces
        if (converToEmail[i] != ' ') {
          emailCorrection += converToEmail[i];
        }
      }
      //log("from Commands: $emailCorrection");
      AppTextToSpeech.replyText = 'Email $emailCorrection , successful';
      return emailCorrection;
    } else if (text == AuthenticationCommand.hello ||
        text == AuthenticationCommand.hi) {
      AppTextToSpeech.replyText = 'Hello and welcome to the FOOD ORDERING APP';
    } else if (text.contains(AuthenticationCommand.help)) {
      AppTextToSpeech.replyText =
          'You can login or register using your email, password and your user role, such as business or customer';
    } else {
      debugPrint('No command match');
    }
    //no command detected
    return 'nothing';
  }
}
