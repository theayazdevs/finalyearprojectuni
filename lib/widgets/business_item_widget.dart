import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';

import '../models/app_text_to_speech.dart';
import '../screens/view_business_menu_screen.dart';

//to show the available food places to the customers
class BusinessItemWidget extends StatefulWidget {
  const BusinessItemWidget({Key? key, required this.businessName, required this.ownerID, required this.businessType, required this.businessDoorNo, required this.businessPostCode, required this.businessService, required this.businessOpenTimes})
      : super(key: key);
  final String businessName;
  final String businessType;
  final String businessDoorNo;
  final String businessPostCode;
  final String businessService;
  final String businessOpenTimes;
  final String ownerID;

  @override
  State<BusinessItemWidget> createState() => _BusinessItemWidgetState();
}

class _BusinessItemWidgetState extends State<BusinessItemWidget> {
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
      //This controls the size of the shadow below the card, so elevation effect
      elevation: 8.0,
      //The empty space that surrounds the card
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3.0),
      child: Container(
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
                  context, ViewBusinessMenuScreen.routeName, arguments: {
                'ownerID': widget.ownerID,
                'businessName': widget.businessName,
              });
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromRGBO(64, 75, 96, .9))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.businessName.toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          const Text('------------------------------')
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.restaurant_menu), const Text(' Type:  '),
                    Text(
                      widget.businessType,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20),
                    ),
                  ],
                ),
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_outlined), const Text(' Address:  '),
                    Text(
                      widget.businessDoorNo,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20),
                    ),
                    const Text(" - "),
                    Text(
                      widget.businessPostCode,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20),
                    ),
                  ],
                ),
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag), const Text(' Services:  '),
                    Text(
                      widget.businessService,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20),
                    ),
                  ],
                ),
                Row(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time), const Text(' Timing:  '),
                     Expanded(
                       child: Text( widget.businessOpenTimes,
                         style: const TextStyle(
                             color: Colors.white,
                             fontSize: 20),
                       ),
                     ),
                  ],
                ),
                const Divider(),
                const Icon(Icons.arrow_circle_right, color: Colors.white, size: 30.0,),
                const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
