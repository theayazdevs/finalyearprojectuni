import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import '../models/app_text_to_speech.dart';
import '../providers/authentication_provider.dart';
import '../screens/customer_orders_screen.dart';
import '../screens/customer_details_screen.dart';
import '../screens/customer_screen.dart';

//drawer for customer side, for navigation to other screens
class CustomerDrawerWidget extends StatefulWidget {
  const CustomerDrawerWidget({Key? key}) : super(key: key);

  @override
  State<CustomerDrawerWidget> createState() => _CustomerDrawerWidgetState();
}

class _CustomerDrawerWidgetState extends State<CustomerDrawerWidget> {
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
      child: Column(
        children: [
          AppBar(
            title: const Text('Customer'),
            //back button removed
            automaticallyImplyLeading: false,
          ),
          //horizontal line
          const Divider(),
          //Creates a list tile
          ListTile(
            //key: const Key('home_btn_drawer'),
            //A widget to display before the title
            leading: const Icon(Icons.restaurant_menu),
            title: const Text('Home'),
            //Called when the user taps this list tile
            onTap: () {
              setState(() {
                AppTextToSpeech.replyText = '';
                AppTextToSpeech.stop();
                speechProvider.cancel();
              });
              Navigator.of(context)
                  .pushReplacementNamed(CustomerScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('My Orders'),
            //Called when the user taps this list tile
            onTap: () {
              setState(() {
                AppTextToSpeech.replyText = '';
                AppTextToSpeech.stop();
                speechProvider.cancel();
              });
              Navigator.of(context)
                  .pushReplacementNamed(CustomerOrdersScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile'),
            //Called when the user taps this list tile
            onTap: () {
              setState(() {
                AppTextToSpeech.replyText = '';
                AppTextToSpeech.stop();
                speechProvider.cancel();
              });
              Navigator.of(context)
                  .pushReplacementNamed(CustomerDetailsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            //Called when the user taps this list tile
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
              Future.delayed(const Duration(seconds: 1), () {
                //properly logout
                Navigator.pop(context);
                Navigator.of(context).pushReplacementNamed('/');
                Provider.of<Authentication>(context, listen: false).userLogout();
              });
            },
          ),
        ],
      ),
    );
  }
}
