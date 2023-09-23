import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import '../models/app_text_to_speech.dart';
import '../screens/view_category_items_screen.dart';

//to show a category to be viewed
class ViewCategoryWidget extends StatefulWidget {
  const ViewCategoryWidget({Key? key, required this.theTitle, required this.id})
      : super(key: key);
  final String theTitle;
  final String id;

  @override
  State<ViewCategoryWidget> createState() => _ViewCategoryWidgetState();
}

class _ViewCategoryWidgetState extends State<ViewCategoryWidget> {
  late SpeechToTextProvider speechProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    speechProvider = Provider.of<SpeechToTextProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //Creates a Material Design card
    return Card(
      //This controls the size of the shadow below the card
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
      child: Container(
        //The decoration to paint behind the child
        decoration: const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
        //Creates a list tile
        child: ListTile(
          title: ElevatedButton(
            onPressed: () {
              setState(() {
                AppTextToSpeech.replyText = '';
                AppTextToSpeech.stop();
                speechProvider.cancel();
              });
              Navigator.pushReplacementNamed(
                  context, ViewCategoryItemScreen.routeName,
                  arguments: widget.id);
            },
            //Create the ButtonStyle
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromRGBO(64, 75, 96, .9))),
            //creates a horizontal array of children
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Creates a text widget
                Text(
                  widget.theTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                //fills the available space
                const Expanded(
                  child: Text(''),
                ),
                const Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white,
                  size: 30.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
