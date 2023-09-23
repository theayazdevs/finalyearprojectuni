import 'dart:developer';

//Categories Items View Commands
class CategoryItemsViewCommand {
  //list of commands
  static final commandsCategoryItemsView = [
    back,
    goBack,
    repeat,
  ];

  //commands are constant because there value will stay the same throughout the app
  static const back = 'back', goBack = 'go back', repeat = 'repeat';
}

//process commands if detected any
class CategoryItemsViewCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    if (text == CategoryItemsViewCommand.back ||
        text == CategoryItemsViewCommand.goBack) {
      return 'back';
    } else if (text == CategoryItemsViewCommand.repeat) {
      return 'repeat';
    }
    //no command match found
    return 'nothing';
  }
}
