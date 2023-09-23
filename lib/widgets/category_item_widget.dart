import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import '../models/app_text_to_speech.dart';
import '../providers/foods_menu_provider.dart';
import '../screens/edit_category_item_screen.dart';

//to show category item
class CategoryItemWidget extends StatefulWidget {
  const CategoryItemWidget({
    Key? key,
    required this.title,
    required this.categoryID,
    required this.categoryItemID,
  }) : super(key: key);
  final String title;
  final String categoryID;
  final String categoryItemID;

  @override
  State<CategoryItemWidget> createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends State<CategoryItemWidget> {
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
      //The primary content of the list tile
      title: Text(widget.title),
      //A widget to display after the title
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            //Creates an icon button
            IconButton(
              //The callback that is called when the button is tapped
                onPressed: () {
                  setState(() {
                    AppTextToSpeech.replyText = '';
                    AppTextToSpeech.stop();
                    speechProvider.cancel();
                  });
                  Navigator.pushReplacementNamed(
                      context, EditCategoryItemScreen.routeName, arguments: {
                    'categoryID': widget.categoryID,
                    'categoryItemID': widget.categoryItemID
                  });
                },
                icon: const Icon(Icons.edit)),
            //Creates an icon button
            IconButton(
              //The callback that is called when the button is tapped
                onPressed: () {
                  Provider.of<FoodsMenu>(context, listen: false)
                      .deleteCategoryItem(
                          widget.categoryID, widget.categoryItemID);
                },
                icon: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }
}
