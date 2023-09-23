import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/item_in_cart_provider.dart';

//to show items in the cart
class CartItemWidget extends StatelessWidget {
  final String id;
  final String cartItemID;
  final double cartItemPrice;
  final int cartItemQuantity;
  final String cartItemTitle;

  const CartItemWidget(
    this.id,
    this.cartItemID,
    this.cartItemPrice,
    this.cartItemQuantity,
    this.cartItemTitle,
  );

  @override
  Widget build(BuildContext context) {
    //Creates a widget that can be dismissed
    return Dismissible(
      key: ValueKey(id),
      //A widget that is stacked behind the child
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        //Align the child within the container
        alignment: Alignment.centerRight,
        color: Colors.deepOrange,
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: const Icon(
          Icons.delete_forever,
          color: Colors.white,
          size: 40,
        ),
      ),
      //Called when the widget has been dismissed
      onDismissed: (theDirection) {
        Provider.of<CustomerCart>(context, listen: false)
            .removeCartItemByID(cartItemID);
      },
      //Gives the app an opportunity to confirm a pending dismissal
      confirmDismiss: (theDirection) {
        //Displays a Material dialog above the current contents of the app
        return showDialog(
          context: context,
          //Creates an alert dialog
          builder: (theContext) => AlertDialog(
            actions: [
              //Create a TextButton
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(theContext).pop(false);
                },
              ),
              //Create a TextButton
              TextButton(
                child: const Text('Remove'),
                onPressed: () {
                  Navigator.of(theContext).pop(true);
                },
              ),
            ],
            //The title of the dialog is displayed at the top of the dialog
            title: const Text('Removing Item:'),
            //The content is displayed in the center of the dialog
            content: const Text(
              'Do you completely want to remove this item from the Cart?',
            ),
          ),
        );
      },
      //The direction in which the widget can be dismissed
      direction: DismissDirection.endToStart,
      //Creates a Material Design card
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          //Creates a list tile
          child: ListTile(
            //A widget to display before the title
            //Creates a circle that represents its child widget
              leading: CircleAvatar(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: FittedBox(
                    child: Text('£$cartItemPrice'),
                  ),
                ),
              ),
              //the primary content of the list tile
              title: Row(
                children: [
                  Text(cartItemTitle),
                  //fills the available space
                  const Expanded(child: Text('')),
                  Text(' x $cartItemQuantity'),
                ],
              ),
              //Additional content displayed below the title
              subtitle: Text('Total: £${(cartItemPrice * cartItemQuantity)}'),
              trailing: SizedBox(
                height: 100,
                width: 100,
                child: Row(
                  children: [
                    //Creates an icon button
                    IconButton(
                      //The callback that is called when the button is tapped
                        onPressed: () {
                          //remove single item
                          Provider.of<CustomerCart>(context, listen: false)
                              .removeSingleCartItem(cartItemID);
                        },
                        //The icon to display inside the button
                        icon: const CircleAvatar(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            child:
                                Center(child: Icon(Icons.exposure_minus_1)))),
                    IconButton(
                      //The callback that is called when the button is tapped
                        onPressed: () {
                          //remove single item
                          Provider.of<CustomerCart>(context, listen: false)
                              .addSingleItemToCart(cartItemID);
                        },
                        //The icon to display inside the button.
                        icon: const CircleAvatar(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green,
                            child: Center(child: Icon(Icons.plus_one)))),
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
