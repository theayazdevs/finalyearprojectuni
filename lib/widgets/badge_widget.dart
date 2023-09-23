import 'package:flutter/material.dart';

//badge to be shown with the cart icon
class MyBadge extends StatelessWidget {
  const MyBadge({
    required Key? key,
    required this.theValue,
    required this.theChild,
  }) : super(key: key);
  //value to be showed in the badge will be stored in this variable
  final String theValue;
  //to store the child widget
  final Widget theChild;
  //to strore the color if any

  @override
  Widget build(BuildContext context) {
    //stack layout widget
    return Stack(
      alignment: Alignment.center,
      children: [
        theChild,
        //Creates a widget that controls where a child of a Stack is positioned
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            //The decoration to paint behind the child
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.deepOrange,
            ),
            //Creates a text widget
            child: Text(
              theValue,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
              ),
            ),

          ),
        )
      ],
    );
  }
}
