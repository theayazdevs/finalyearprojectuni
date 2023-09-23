
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders_provider.dart';

//widget to show order to business
class BusinessOrderItemWidget extends StatefulWidget {
  final BusinessOrderItem businessOrder;

  BusinessOrderItemWidget(this.businessOrder);

  @override
  _BusinessOrderItemWidgetState createState() => _BusinessOrderItemWidgetState();
}

class _BusinessOrderItemWidgetState extends State<BusinessOrderItemWidget> {
  @override
  Widget build(BuildContext context) {
    //Creates a Material Design card
    return Card(
      //The color to paint the shadow below the card
      shadowColor: Colors.green,
      margin: const EdgeInsets.all(10),
      //The shape of the card
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.green, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            'Service requested: ${widget.businessOrder.service}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            ' Customer Name: ${widget.businessOrder.customerName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            ' Customer address: ${widget.businessOrder.customerAddress}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            ' Customer phone: ${widget.businessOrder.customerPhone}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const Divider(color: Colors.black),
          Text(
            'Order Date and Time: ${DateFormat('dd/MM/yyyy (H:mm)').format(widget.businessOrder.orderDateTime)}',
          ),
          Text(
            'Order worth: £${widget.businessOrder.theAmount.toStringAsFixed(2)}',
          ),
          const Divider(color: Colors.black),
          ListView(
            //scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: widget.businessOrder.theItems
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
