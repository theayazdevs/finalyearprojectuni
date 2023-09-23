
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders_provider.dart';

//customer order history item widget
class CustomerOrderItemWidget extends StatefulWidget {
  final CustomerOrderItem customerOrder;

  CustomerOrderItemWidget(this.customerOrder);

  @override
  _CustomerOrderItemWidgetState createState() =>
      _CustomerOrderItemWidgetState();
}

class _CustomerOrderItemWidgetState extends State<CustomerOrderItemWidget> {
  @override
  Widget build(BuildContext context) {
    //Creates a Material Design card
    return Card(
      //The color to paint the shadow below the card
      shadowColor: Colors.green,
      margin: const EdgeInsets.all(10),
      ////The shape of the card's Material
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.green, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            'Amount Spent: £${widget.customerOrder.theAmount.toStringAsFixed(2)} at ${widget.customerOrder.businessName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            'Order Date and Time: ${DateFormat('dd/MM/yyyy (H:mm)').format(widget.customerOrder.orderDateTime)}',
          ),
          Text(
            'Service Requested: ${widget.customerOrder.service}',
          ),
          const Divider(color: Colors.black),
          //Creates a scrollable, linear array of widgets from an explicit List
          ListView(
                //scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: widget.customerOrder.theItems
                    .map(
                  //Creates a horizontal array of children
                      (theItem) => Row(
                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            theItem.theTitle,
                          ),
                          const Text('  ---  '),
                          Text(
                            '${theItem.theQuantity}x £${theItem.thePrice}',
                          )
                        ],
                      ),
                    )
                    .toList(),
              ),
          const Divider(color: Colors.black),
        ],
      ),
    );
  }
}
