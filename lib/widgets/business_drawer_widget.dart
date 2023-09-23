import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import '../models/app_text_to_speech.dart';
import '../providers/authentication_provider.dart';
import '../screens/business_orders_screen.dart';
import '../screens/business_screen.dart';
import '../screens/manage_menu_screen.dart';
import '../screens/business_details_screen.dart';

//drawer for business side for navigation to different screens
class BusinessDrawerWidget extends StatefulWidget {
  const BusinessDrawerWidget({Key? key}) : super(key: key);

  @override
  State<BusinessDrawerWidget> createState() => _BusinessDrawerWidgetState();
}

class _BusinessDrawerWidgetState extends State<BusinessDrawerWidget> {
  late SpeechToTextProvider speechProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    speechProvider = Provider.of<SpeechToTextProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    //Creates a Material Design drawer
    return Drawer(
      //creates a box in which a single widget can be scrolled
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              title: const Text('Business'),
              //back button is not needed so removing it
              automaticallyImplyLeading: false,
            ),
            //horizontal line
            const Divider(),
            //home button
            //Creates a list tile
            ListTile(
              //A widget to display before the title
              leading: const Icon(Icons.restaurant_menu),
              //The primary content of the list tile
              title: const Text('Home'),
              //Called when the user taps this list tile
              onTap: () {
                setState(() {
                  AppTextToSpeech.replyText = '';
                  AppTextToSpeech.stop();
                  speechProvider.cancel();
                });
                Navigator.of(context)
                    .pushReplacementNamed(BusinessScreen.routeName);
              },
            ),
            const Divider(),
            //orders button
            //Creates a list tile
            ListTile(
              //A widget to display before the title
              leading: const Icon(Icons.shopping_bag),
              //The primary content of the list tile
              title: const Text('Orders'),
              //Called when the user taps this list tile
              onTap: () {
                setState(() {
                  AppTextToSpeech.replyText = '';
                  AppTextToSpeech.stop();
                  speechProvider.cancel();
                });
                Navigator.of(context)
                    .pushReplacementNamed(BusinessOrdersScreen.routeName);
              },
            ),
            const Divider(),
            //manage button
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Manage'),
              //Called when the user taps this list tile
              onTap: () {
                setState(() {
                  AppTextToSpeech.replyText = '';
                  AppTextToSpeech.stop();
                  speechProvider.cancel();
                });
                Navigator.of(context)
                    .pushReplacementNamed(ManageMenuScreen.routeName);
              },
            ),
            const Divider(),
            //profile button
            ListTile(
              leading: const Icon(Icons.verified_user),
              title: const Text('Profile'),
              onTap: () {
                setState(() {
                  AppTextToSpeech.replyText = '';
                  AppTextToSpeech.stop();
                  speechProvider.cancel();
                });
                Navigator.of(context)
                    .pushReplacementNamed(BusinessDetailsScreen.routeName);
              },
            ),
            const Divider(),
            //logout button tile
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                setState(() {
                  AppTextToSpeech.replyText = '';
                  AppTextToSpeech.stop();
                  speechProvider.cancel();
                });
                //clear all credentials
                //remove stored data, if user just wanted to sign out
                final sharedPreferences = await SharedPreferences.getInstance();
                sharedPreferences.remove('email');
                sharedPreferences.remove('password');
                sharedPreferences.remove('role');
                //properly logout
                Future.delayed(const Duration(seconds: 1),(){
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacementNamed('/');
                  Provider.of<Authentication>(context, listen: false).userLogout();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
