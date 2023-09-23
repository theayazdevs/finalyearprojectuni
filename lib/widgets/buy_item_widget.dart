import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import '../models/app_text_to_speech.dart';
import '../providers/item_in_cart_provider.dart';

//to show items that can be bought/ added to cart
class BuyItemWidget extends StatefulWidget {
  const BuyItemWidget({
    Key? key,
    required this.theTitle,
    required this.theDescription,
    required this.thePrice,
    required this.categoryID,
    required this.categoryItemID,
    required this.ownerID,
  }) : super(key: key);
  final String theTitle;
  final String theDescription;
  final String thePrice;
  final String categoryID;
  final String categoryItemID;
  final String ownerID;

  @override
  State<BuyItemWidget> createState() => _BuyItemWidgetState();
}

class _BuyItemWidgetState extends State<BuyItemWidget> {
  late SpeechToTextProvider speechProvider;
  late CustomerCart cart;
  @override
  void initState() {
    super.initState();
    cart  = CustomerCart();
  }

  @override
  void didChangeDependencies() {
    speechProvider = Provider.of<SpeechToTextProvider>(context);
    cart = Provider.of<CustomerCart>(context, listen: false);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    //Creates a Material Design card
    return Card(
      elevation: 8.0,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
      child: Container(
        decoration: const BoxDecoration(color: Color.fromRGBO(64, 75, 96, .9)),
        //Creates a list tile
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          title: Row(
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
              const Expanded(child: Text('')),
              //Creates a text widget
              Text(
                '£${widget.thePrice}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          //Additional content displayed below the title
          subtitle: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(widget.theDescription,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          //A widget to display after the title
          trailing: IconButton(
            icon: const CircleAvatar(
                backgroundColor: Colors.white,
                //Creates a widget that centers its child
                child: Center(
                    child: Icon(
                  Icons.add_shopping_cart,
                  color: Color.fromRGBO(64, 75, 96, .9),
                ))),
            onPressed: () {
              cart.addItemToCart(widget.categoryItemID, double.parse(widget.thePrice), widget.theTitle, widget.ownerID);
              AppTextToSpeech.replyText='Added to Cart';
              AppTextToSpeech.speak();
              //Removes the current SnackBar by running its normal exit animation
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              //Shows a SnackBar across the registered Scaffold
              ScaffoldMessenger.of(context).showSnackBar(
                //Creates a snack bar
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Center(
                    child: Text(
                      'Item added to cart !', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
