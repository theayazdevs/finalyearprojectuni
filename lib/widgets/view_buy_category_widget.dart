import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import '../models/app_text_to_speech.dart';
import '../screens/buy_items_screen.dart';

//to show category from which items can be bought
class ViewBuyCategoryWidget extends StatefulWidget {
  const ViewBuyCategoryWidget({Key? key, required this.title, required this.id, required this.ownerID, required this.businessName})
      : super(key: key);
  final String title;
  final String id;
  final String ownerID;
  final String businessName;

  @override
  State<ViewBuyCategoryWidget> createState() => _ViewBuyCategoryWidgetState();
}

class _ViewBuyCategoryWidgetState extends State<ViewBuyCategoryWidget> {
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
    //Creates a list tile
    return ListTile(
      title: ElevatedButton(
          onPressed: () {
            setState(() {
              AppTextToSpeech.replyText = '';
              AppTextToSpeech.stop();
              speechProvider.cancel();
            });
            Navigator.pushReplacementNamed(
                context, BuyItemsScreen.routeName,
                arguments: {
                  'categoryID': widget.id,
                  'ownerID': widget.ownerID,
                  'businessName':widget.businessName,
                });
          },
          //Creates a text widget for the button
          child: Text(widget.title)),
    );
  }
}
