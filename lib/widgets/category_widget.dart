import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import '../models/app_text_to_speech.dart';
import '../providers/foods_menu_provider.dart';
import '../screens/edit_category_screen.dart';
import '../screens/manage_category_item_screen.dart';

//to show the category widget
class CategoryWidget extends StatefulWidget {
  const CategoryWidget({Key? key, required this.title, required this.id})
      : super(key: key);
  final String title;
  final String id;

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
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
      //Create an ElevatedButton
      title: ElevatedButton(
          onPressed: () {
            setState(() {
              AppTextToSpeech.replyText = '';
              AppTextToSpeech.stop();
              speechProvider.cancel();
            });
            Navigator.pushReplacementNamed(
                context, ManageCategoryItemScreen.routeName,
                arguments: widget.id);
          },
          child: Text(widget.title)),
      //A widget to display after the title
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              //The callback that is called when the button is tapped
                onPressed: () {
                  setState(() {
                    AppTextToSpeech.replyText = '';
                    AppTextToSpeech.stop();
                    speechProvider.cancel();
                  });
                  //which item to edit
                  Navigator.pushReplacementNamed(
                      context, EditCategoryScreen.routeName,
                      arguments: widget.id);
                },
                icon: const Icon(Icons.edit)),
            //Creates an icon button
            IconButton(
              //The callback that is called when the button is tapped
                onPressed: () async {
                  try {
                    await Provider.of<FoodsMenu>(context, listen: false)
                        .deleteFoodCategory(widget.id);
                  } catch (error) {
                    //can show feedback to user here
                    debugPrint('error while deleting');
                  }
                },
                icon: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }
}
