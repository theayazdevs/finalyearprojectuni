import 'dart:developer';

//Customer Details/Profile Screen Commands
class CustomerDetailsScreenCommand {
  //list of commands
  static final commandsCustomerDetailsScreen = [
    orders,
    myOrders,
    logout,
    signOut,
    home,
    repeat,
    editProfile,
    manageProfile,
    updateProfile,
    changeProfile, goSto, goto,
  ];

  //commands are constant because there value will stay the same throughout the app
  static const orders = 'orders',
      myOrders = 'my orders',
      logout = 'logout',
      signOut = 'sign out',
      home = 'home',
      repeat = 'repeat',
      editProfile = 'edit profile',
      updateProfile = 'update profile',
      changeProfile = 'change profile',
      manageProfile = 'manage profile', goSto='go to', goto='goto';
}

//process commands if detected any
class CustomerDetailsScreenCommandProcess {
  //returns a string when a command is detected
  static String handleSpokenWords(String spokenWords) {
    //print(spokenWords);
    final text = spokenWords.toLowerCase();
    //debugPrint(text);
    if (text == CustomerDetailsScreenCommand.orders ||
        text == CustomerDetailsScreenCommand.myOrders ||
        text == 'goto ${CustomerDetailsScreenCommand.orders}' ||
        text == 'go to ${CustomerDetailsScreenCommand.orders}' ||
        text == 'goto ${CustomerDetailsScreenCommand.myOrders}' ||
        text == 'go to ${CustomerDetailsScreenCommand.myOrders}') {
      return 'orders';
    } else if (text == CustomerDetailsScreenCommand.logout ||
        text == CustomerDetailsScreenCommand.signOut) {
      return 'logout';
    } else if (text == CustomerDetailsScreenCommand.home ||
        text == 'goto ${CustomerDetailsScreenCommand.home}' ||
        text == 'go to ${CustomerDetailsScreenCommand.home}') {
      return 'home';
    } else if (text == CustomerDetailsScreenCommand.repeat) {
      return 'repeat';
    } else if (text == CustomerDetailsScreenCommand.editProfile ||
        text == CustomerDetailsScreenCommand.manageProfile ||
        text == CustomerDetailsScreenCommand.updateProfile ||
        text == CustomerDetailsScreenCommand.changeProfile) {
      return 'edit profile';
    }
    //no command found
    return 'nothing';
  }
}
