import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../commands/business_orders_screen_commands.dart';
import '../models/app_text_to_speech.dart';
import '../models/global_preferences.dart';
import '../providers/food_category_provider.dart';
import '../providers/authentication_provider.dart';
import '../providers/orders_provider.dart';
import '../screens/manage_menu_screen.dart';
import '../screens/business_details_screen.dart';
import '../screens/business_screen.dart';
import '../widgets/business_drawer_widget.dart';
import '../widgets/business_order_item_widget.dart';

//business orders received screen user interface
class BusinessOrdersScreen extends StatefulWidget {
  const BusinessOrdersScreen({super.key});

  //for navigation reference between screens
  static const routeName = '/businessOrdersScreen';

  @override
  State<BusinessOrdersScreen> createState() => _BusinessOrdersScreenState();
}

class _BusinessOrdersScreenState extends State<BusinessOrdersScreen> {
  //to store the timer that check for the auto listener feature
  late Timer timerCont;
  //timer that runs the method to listen to user speech
  late RestartableTimer timer;
  //for auto listener feature which is set to true or false based on the user choice
  late bool autoRecord;
  //to store text recognized by the speech to text
  String _recognizedText = '';
  //speech to text provider to control the speech recognition
  late SpeechToTextProvider speechProvider;
  //to check if its initialized
  var _isInit = true;
  //to show loading on screen
  var _isItLoading = false;
  //the dynamic voice commands based on data from the database
  Map<String, String> voiceCommandData = {};
  //to store food categories
  late List<FoodCategoryProvider> foodCategories;
  //to be used in to show the count down timer
  int _startingIn = 0;
  //the countdown timer that will be shown on the screen before listening
  late Timer _timerNew;
  //to control the slider value
  double _sliderVal = 7.0;
  //to store the order items
  late List<BusinessOrderItem> orders;
  //for scrolling list
  final ScrollController _listController = ScrollController();
  //initializing...
  @override
  void initState() {
    super.initState();
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        //speaking text
        AppTextToSpeech.replyText = "Orders Received";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing food categories
    foodCategories = [];
    //initializing timers
    timer = RestartableTimer(const Duration(seconds: 0), () => {});
    timerCont = Timer(const Duration(seconds: 0), () => {});
    _timerNew = Timer(const Duration(seconds: 1), () => {});
    //default auto record
    autoRecord = true;
    //check for any stored user preferences
    setUserPreferences();
  }
  //Called when a dependency of this State object changes, called after initState
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //storing the speech to text provider to be used on this screen
    speechProvider = Provider.of<SpeechToTextProvider>(context);
    //if not already loaded data then load data now from database
    if (_isInit) {
      //update UI using set state
      setState(() {
        _isItLoading = true;
      });
      //debugPrint('showing data from database');
      if (mounted) {
        Provider.of<AllOrders>(context, listen: false)
            .fetchAndSetOrdersOwner()
            .then((_) {
          if (mounted) {
            //update UI using set state
            setState(() {
              _isItLoading = false;
              orders =
                  Provider.of<AllOrders>(context, listen: false).getBusinessOrders;
              Future.delayed(const Duration(seconds: 2), () {
                speakCurrentScreen();
              });
            });
          }
        });
      }
    }
    _isInit = false;
  }
  //after leaving the screen, disposes of any active elements on the screen
  @override
  void dispose() {
    super.dispose();
    //log('disposing the business screen');
    AppTextToSpeech.replyText = '';
    AppTextToSpeech.stop();
    timer.cancel();
    timerCont.cancel();
    _timerNew.cancel();
  }
  //get the user preferences stored on the device and set respectively
  Future<void> setUserPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    //sharedPreferences.setBool('autoListener', autoListener);
    bool? userAutoListener = sharedPreferences.getBool('autoListener');
    setState(() {
      if (userAutoListener != null) {
        autoRecord = userAutoListener;
      }
    });
  }
  //listen for user input via microphone
  void speechListen() {
    //make sure TTS is not speaking before listening
    AppTextToSpeech.replyText='';
    AppTextToSpeech.speak();
    AppTextToSpeech.stop();
    //log('speechListen() in business screen screen RAN');
    if (!speechProvider.isAvailable || speechProvider.isListening) {
      log('not available: NULL');
    } else {
      //speechProvider.listen(partialResults: true);
      //speechProvider.stop();
      speechProvider.listen();
    }
    //show the listened text on screen
    Future.delayed(const Duration(seconds: 5), () {
      //_recognizedText = speechProvider.lastResult?.recognizedWords ?? '';
      if (mounted) {
        setState(() {
          _recognizedText = speechProvider.lastResult?.recognizedWords ?? '';
        });
      }
    });
    //check for for commands in the recognized text
    Future.delayed(const Duration(seconds: 6), () {
      //_recognizedText = speechProvider.lastResult?.recognizedWords ?? '';
      if (mounted) {
        setState(() {
          //log(_recognizedText);
          handleCommand(_recognizedText);
        });
      }
    });
    //could also stop listening instead of null if button is pressed again
    //!speechProvider.isAvailable || speechProvider.isListening ? null : () => speechProvider.listen(partialResults: true);
  }
  //check if the auto listener feature was disabled or still enabled
  void checkAuto() {
    //log('checkAuto() in business screen RAN');
    try {
      if (autoRecord) {
        if (!speechProvider.isListening) {
          setState(() {
            _startingIn = 7;
            _sliderVal = 7;
          });
          countDownListener();
          timer.reset();
        }
        //log('resetted');
      } else if (!autoRecord) {
        log('Stopped');
      }
    } catch (error) {
      log('handled error');
    }
  }
  //auto listening functionality controlled by the button on screen
  void autoListenerSwitch() {
    setState(() {
      //reversing auto record, so if ON then OFF and vice-versa
      autoRecord = !autoRecord;
      //storing user preferences about auto listener
      GlobalPreferences.autoListener = autoRecord;
      GlobalPreferences.storeAutoListener();
      //if enabled then show countdown animation and enable the auto listener
      if (autoRecord) {
        setState(() {
          _startingIn = 7;
          _sliderVal = 7;
        });
        countDownListener();
        timer = RestartableTimer(const Duration(seconds: 7), () => speechListen());
        timerCont =
            Timer.periodic(const Duration(seconds: 13), (Timer t) => checkAuto());
      } else {
        _startingIn = 0;
        timer = RestartableTimer(const Duration(seconds: 0), () => {});
        timerCont = Timer(const Duration(seconds: 0), () => {});
      }
    });
    //debugPrint('AUTO LISTENER: $autoRecord');
  }
  //to control the countdown animation on screen
  void countDownListener() {
    //_startingIn = 13;
    const oneSec = Duration(seconds: 1);
    _timerNew = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_startingIn == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _startingIn--;
            _sliderVal--;
          });
        }
      },
    );
  }
  //process the text recognized by the speech to text
  Future<void> handleCommand(String text) async {
    //send to command process class to see if text spoke is a command or not
    String actionCommand =
        BusinessOrdersScreenCommandProcess.handleSpokenWords(text);
    //_recognizedText = '';
    //log('received back command: $actionCommand');
    if (actionCommand == 'home') {
      speechProvider.cancel();
      Navigator.pushReplacementNamed(context, BusinessScreen.routeName);
      //} else if (actionCommand == 'logout' || actionCommand == 'sign out') {
    } else if (actionCommand == 'logout') {
      //log('signing out');
      speechProvider.cancel();
      //remove stored data, if user just wanted to sign out
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.remove('email');
      sharedPreferences.remove('password');
      sharedPreferences.remove('role');
      //properly logout
      Future.delayed(const Duration(seconds: 1), () {
        Provider.of<Authentication>(context, listen: false).userLogout();
        Navigator.of(context).pushReplacementNamed('/');
      });
    } else if (actionCommand == 'repeat') {
      Navigator.of(context)
          .pushReplacementNamed(BusinessOrdersScreen.routeName);
      //} else if (actionCommand == 'profile' || actionCommand == 'my profile') {
    } else if (actionCommand == 'profile') {
      Navigator.of(context)
          .pushReplacementNamed(BusinessDetailsScreen.routeName);
    } else if (actionCommand == 'orders') {
      Navigator.of(context)
          .pushReplacementNamed(BusinessOrdersScreen.routeName);
    } else if (actionCommand == 'manage') {
      Navigator.of(context).pushReplacementNamed(ManageMenuScreen.routeName);
    } else if (actionCommand == 'scroll up') {
      _scrollUp();
      AppTextToSpeech.replyText = 'Scrolling Up';
    } else if (actionCommand == 'scroll down') {
      _scrollDown();
      AppTextToSpeech.replyText = 'Scrolling Down';
    } else if (actionCommand == 'scroll stop') {
      _scrollStop();
      AppTextToSpeech.replyText = 'Stopped';
    } else if (actionCommand=='nothing') {
      AppTextToSpeech.replyText='';
    }
    Future.delayed(const Duration(milliseconds: 2000), () {
      //debugPrint("Now Speaking this: ${AppTextToSpeech.replyText}");
      //speak text on event
      if(AppTextToSpeech.replyText != ''){
        AppTextToSpeech.speak();
      }
    });
  }
  //speak the current screen elements
  void speakCurrentScreen() {
    //log('speakCurrentScreen() RAN in CustomerOrdersScreen ');
    AppTextToSpeech.replyText = 'Orders Screen';
    AppTextToSpeech.speak();
    List<String> toSpeak = [];
    orders.forEach((element) {
      //log(element.amount.toString());
      //String currentElement = ',order amount spent: £${element.amount}, order date and time: ${element.dateTime}, order items, ${element.products},';
      String currentElement =
          'order received on ${DateFormat('dd-MM-yyyy').format(element.orderDateTime)} at ${DateFormat.Hm().format(element.orderDateTime)},service requested, ${element.service}, order items';
      String addToCurrentElement = '';
      element.theItems.forEach((cartItem) {
        addToCurrentElement += ',${cartItem.theQuantity} ${cartItem.theTitle},';
      });
      toSpeak.add(currentElement + addToCurrentElement);
      //totalSecondsWait+=10;
    });
    int speakLength = (toSpeak.length * 10) + 20;
    //log('toSpeak List: $toSpeak');
    //log('orders : ${toSpeak.length}');
    String speakAll = '';
    toSpeak.forEach((element) {
      speakAll += '$element ';
    });
    //log('speakAll: $speakAll');
    Future.delayed(const Duration(seconds: 2), () async {
      if (toSpeak.isEmpty) {
        //log('nothing to speak yet');
        await AppTextToSpeech.flutterTts.speak('No orders yet, you can now ask me to repeat or goto home, manage, or profile screen');
      } else {
        AppTextToSpeech.replyText = speakAll;
        await AppTextToSpeech.flutterTts.speak('speaking orders :$speakAll, you can now ask me to repeat or goto home, manage, or profile screen');
      }
      //AppTextToSpeech.flutterTts.awaitSpeakCompletion(true);

      //AppTextToSpeech.replyText = '';
      //log('');
    });
    //}).then((value) =>
    Future.delayed(Duration(seconds: speakLength), () {
      //debugPrint('finished speaking');
      //if user wants the auto listener then run it after speaking current screen
      if (autoRecord == true) {
        if (mounted) {
          setState(() {
            if (autoRecord) {
              AppTextToSpeech.replyText = '';
              //to show the count down on screen
              _startingIn = 7;
              _sliderVal = 7;
              countDownListener();
              //starting timer related to the auto listener feature
              timer =
                  RestartableTimer(const Duration(seconds: 7), () => speechListen());
              timerCont = Timer.periodic(
                  const Duration(seconds: 13), (Timer t) => checkAuto());
            } else {
              log('auto record OFF');
            }
          });
        }
      }
    });
  }


// Down
  void _scrollDown() {
    _listController.animateTo(
      _listController.position.maxScrollExtent,
      duration: const Duration(seconds: 10),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Up
  void _scrollUp() {
    _listController.animateTo(
      _listController.position.minScrollExtent,
      duration: const Duration(seconds: 10),
      curve: Curves.fastOutSlowIn,
    );
  }

  //stop scrolling
  void _scrollStop() {
    _listController.animateTo(_listController.offset,
        duration: const Duration(milliseconds: 1), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    //get current window size
    final deviceSize = MediaQuery.of(context).size;
    //log('getting the business orders');
    final businessOrderData = Provider.of<AllOrders>(context);
    Future<void> refreshCurrentOrders() async {
      await Provider.of<AllOrders>(context, listen: false).fetchAndSetOrdersOwner();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Received'),
      ),
      drawer: const BusinessDrawerWidget(),
      body: _isItLoading
      //Creates a widget that centers its child
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: refreshCurrentOrders,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: businessOrderData.getBusinessOrders.isEmpty ? const Center(child: Text('No Orders Yet')) :
                SizedBox(
                  height: deviceSize.height*0.78,
                  //Creates a scrollable, linear array of widgets that are created on demand
                  child: ListView.builder(
                    controller: _listController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    //to solve vertical height issues
                    //scrollDirection: Axis.vertical,
                    //shrinkWrap: true,
                    //The itemBuilder callback will be called only with indices greater than or equal to zero and less than itemCount
                    itemBuilder: (_, i) => Column(
                      children: [
                        BusinessOrderItemWidget(
                            businessOrderData.getBusinessOrders[i]
                        ),
                        const Divider(),
                      ],
                    ),
                    itemCount: businessOrderData.getBusinessOrders.length,
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          //alignment: Alignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //dynamically sized with expanded
                Expanded(
                  child: Center(
                    child: SubstringHighlight(
                      text: _recognizedText,
                      terms: BusinessOrdersScreenCommand
                          .commandsBusinessOrdersScreen,
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        backgroundColor: Colors.white,
                      ),
                      textStyleHighlight: const TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                //),
              ],
            ),
            Row(
              children: [
                if (_startingIn == 0)
                  const Text('')
                else
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        //Text("$_startingIn", style: TextStyle(fontSize: 16, backgroundColor: Colors.deepOrange, color: Colors.white),),
                        CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          child: Center(
                            child: Text(
                              "$_startingIn",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Slider(
                            value: _sliderVal,
                            onChanged: (newVl) {},
                            min: 0,
                            max: 7,
                            activeColor: Colors.green,
                            label: _startingIn.toString()),
                      ],
                    ),
                  ),
              ],
            ),
            //const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "btnAutoOrders",
                  onPressed: () {
                    timer.cancel();
                    timerCont.cancel();
                    speechProvider.cancel();
                    //start recording for speech to text
                    autoListenerSwitch();
                  },
                  //onPressed: () => {debugPrint('pressed <-------------------------------')} ,
                  child: Icon(
                    autoRecord ? Icons.autorenew_outlined : Icons.sync_disabled,
                    size: 50,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                  heroTag: "btnMicOrders",
                  onPressed: speechListen,
                  //onPressed: () => {debugPrint('pressed <-------------------------------')} ,
                  child: Icon(
                    speechProvider.isListening
                        ? Icons.record_voice_over
                        : Icons.mic,
                    size: 50,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
