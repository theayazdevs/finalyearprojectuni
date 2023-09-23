import 'dart:developer';

//Customer Orders Screen Commands
class CustomerOrdersScreenCommand {
  //list of commands
  static final commandsCustomerOrdersScreen = [
    home,
    homePage,
    profile,
    myProfile,
    logout,
    signOut,
    repeat,
    scrollDown,
    goDown,
    scrollUp,
    goUp,
    stopScrolling,
    pauseScrolling,
    goSto,
    goto,
  ];

  //commands are constant because there value will stay the same throughout the app
  static const logout = 'logout',
      signOut = 'sign out',
      home = 'home',
      homePage = 'homepage',
      profile = 'profile',
      myProfile = 'my profile',
      repeat = 'repeat',
      scrollDown = 'scroll down',
      goDown = 'go down',
      scrollUp = 'scroll up',
      goUp = 'go up',
      stopScrolling = 'stop scrolling',
      pauseScrolling = 'pause scrolling',
      goSto = 'go to',
      goto = 'goto';
}

//process commands if detected any
class CustomerOrdersScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    if (text == CustomerOrdersScreenCommand.home ||
        text == CustomerOrdersScreenCommand.homePage ||
        text == 'goto ${CustomerOrdersScreenCommand.home}' ||
        text == 'go to ${CustomerOrdersScreenCommand.home}' ||
        text == 'goto ${CustomerOrdersScreenCommand.homePage}' ||
        text == 'go to ${CustomerOrdersScreenCommand.homePage}') {
      return 'home';
    } else if (text == CustomerOrdersScreenCommand.profile ||
        text == CustomerOrdersScreenCommand.myProfile ||
        text == 'goto ${CustomerOrdersScreenCommand.profile}' ||
        text == 'go to ${CustomerOrdersScreenCommand.profile}' ||
        text == 'goto ${CustomerOrdersScreenCommand.myProfile}' ||
        text == 'go to ${CustomerOrdersScreenCommand.myProfile}') {
      return 'profile';
    } else if (text == CustomerOrdersScreenCommand.logout ||
        text == CustomerOrdersScreenCommand.signOut) {
      return 'logout';
    } else if (text == CustomerOrdersScreenCommand.repeat) {
      return 'repeat';
    } else if (text == CustomerOrdersScreenCommand.scrollDown ||
        text == CustomerOrdersScreenCommand.goDown) {
      return 'scroll down';
    } else if (text == CustomerOrdersScreenCommand.scrollUp ||
        text == CustomerOrdersScreenCommand.goUp) {
      return 'scroll up';
    } else if (text == CustomerOrdersScreenCommand.stopScrolling ||
        text == CustomerOrdersScreenCommand.pauseScrolling) {
      return 'scroll stop';
    }
    //no commands detected
    return 'nothing';
  }
}
