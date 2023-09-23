import 'package:flutter/material.dart';

//to show items in a category for viewing
class ViewCategoryItemsWidget extends StatelessWidget {
  const ViewCategoryItemsWidget({
    Key? key,
    required this.theTitle,
    required this.theDescription,
    required this.thePrice,
  }) : super(key: key);
  final String theTitle;
  final String theDescription;
  final String thePrice;

  @override
  Widget build(BuildContext context) {
    //Creates a Material Design card
    return Card(
      //This controls the size of the shadow below the card
      elevation: 8.0,
      //The empty space that surrounds the card
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
      child: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
        //Creates a list tile
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          //The primary content of the list tile
          title: Text(
            theTitle,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          //Additional content displayed below the title
          subtitle: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(theDescription,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          //A widget to display after the title
          trailing: Text('£$thePrice',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
