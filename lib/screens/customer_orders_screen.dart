import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../models/app_text_to_speech.dart';
import '../models/global_preferences.dart';
import '../providers/authentication_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/customer_order_item_widget.dart';
import '../commands/customer_orders_screen_commands.dart';
import '../screens/customer_details_screen.dart';
import '../screens/customer_screen.dart';
import '../widgets/customer_drawer_widget.dart';

//customer order history screen user interface
class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});
  //for navigation reference between screens
  static const routeName = '/customerOrdersScreen';

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
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
  //to be used in to show the count down timer
  int _startingIn = 0;
  //the countdown timer that will be shown on the screen before listening
  late Timer _timerNew;
  //to control the slider value
  double _sliderVal = 7.0;
  //to store the instance of orders class
  late List<CustomerOrderItem> orders;
  //to control the scroll on list
  final ScrollController _listController = ScrollController();
  //initializing...
  @override
  void initState() {
    super.initState();
    //AppTextToSpeech.replyText='';
    //AppTextToSpeech.stop();
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        //speaking text
        AppTextToSpeech.replyText = "Your Orders";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing orders
    orders=[];
    //initializing timers
    timer = RestartableTimer(const Duration(seconds: 0), () => {});
    timerCont = Timer(const Duration(seconds: 0), () => {});
    _timerNew = Timer(const Duration(seconds: 1), () => {});
    Future.delayed(const Duration(seconds: 2), () {
      speakCurrentScreen();
    });
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
        Provider.of<AllOrders>(context, listen: false).fetchAndSetCustomerOrders().then((_) {
          if (mounted) {
            //update UI using set state
            setState(() {
              _isItLoading = false;
              orders = Provider.of<AllOrders>(context, listen: false).getCustomerOrders;
              //debugPrint('foodCategories: '+foodCategories.toString());
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
    //log('disposing the CustomerOrdersScreen screen');
    //also stop listening and speaking when leaving the screen
    AppTextToSpeech.replyText = '';
    AppTextToSpeech.stop();
    //stopping the auto mic listener after leaving this screen
    //cancelling all the timers running on this screen
    timer.cancel();
    timerCont.cancel();
    _timerNew.cancel();
  }
  //get the user preferences stored on the device and set respectively
  Future<void> setUserPreferences() async {
    final sharedPreferences =  await SharedPreferences.getInstance();
    //sharedPreferences.setBool('autoListener', autoListener);
    bool? userAutoListener = sharedPreferences.getBool('autoListener');
    setState(() {
      if(userAutoListener!=null){
        autoRecord=userAutoListener;
      }
    });
  }
  //listen for user input via microphone
  void speechListen() {
    //make sure TTS is not speaking before listening
    AppTextToSpeech.replyText='';
    AppTextToSpeech.speak();
    AppTextToSpeech.stop();
    //log('speechListen() in CustomerOrdersScreen screen screen RAN');
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
    //log('checkAuto() in CustomerOrdersScreen screen RAN');
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
    String actionCommand = CustomerOrdersScreenCommandProcess.handleSpokenWords(text);
    //_recognizedText = '';
    //log('received back command: $actionCommand');
    if (actionCommand == 'home') {
      speechProvider.cancel();
      Navigator.pushReplacementNamed(context, CustomerScreen.routeName);
    } else if (actionCommand == 'logout') {
      //log('signing out');
      speechProvider.cancel();
      //remove stored data, if user just wanted to sign out
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.remove('email');
      sharedPreferences.remove('password');
      sharedPreferences.remove('role');
      //properly logout
      Future.delayed(const Duration(seconds: 1),() {
        Provider.of<Authentication>(context, listen: false).userLogout();
        Navigator.of(context).pushReplacementNamed('/');
      });
    } else if (actionCommand == 'repeat') {
      Navigator.of(context).pushReplacementNamed(CustomerOrdersScreen.routeName);
    } else if (actionCommand == 'profile') {
      Navigator.of(context)
          .pushReplacementNamed(CustomerDetailsScreen.routeName);
    }
    else if (actionCommand == 'scroll up') {
      _scrollUp();
      AppTextToSpeech.replyText='Scrolling Up';
    }
    else if (actionCommand == 'scroll down') {
      _scrollDown();
      AppTextToSpeech.replyText='Scrolling Down';
    }
    else if (actionCommand == 'scroll stop') {
      _scrollStop();
      AppTextToSpeech.replyText='Stopped';
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
    AppTextToSpeech.replyText = 'Orders History';
    AppTextToSpeech.speak();
    List<String> toSpeak = [];
    orders.forEach((element) {
      String currentElement = ',amount spent: £${element.theAmount} at ${element.businessName}, date and time: ${DateFormat('dd-MM-yyyy').format(element.orderDateTime)} at ${DateFormat.Hm().format(element.orderDateTime)},items,';
      String addToCurrentElement='';
      element.theItems.forEach((cartItem) {
        addToCurrentElement += ',${cartItem.theQuantity},${cartItem.theTitle},';
      });
      toSpeak.add(currentElement+addToCurrentElement);
      //totalSecondsWait+=10;
    });
    int speakLength = (toSpeak.length*12)+20;
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
        await AppTextToSpeech.flutterTts.speak('You have not made any orders yet, now, you can ask me to repeat or goto home, or profile screen');
      } else {
        AppTextToSpeech.replyText = speakAll;
        await AppTextToSpeech.flutterTts.speak(' :$speakAll, now, you can ask me to repeat or goto home, or profile screen');
      }
      //AppTextToSpeech.flutterTts.awaitSpeakCompletion(true);

      //AppTextToSpeech.replyText = '';
      //log('');
    });
    //}).then((value) =>
    Future.delayed(Duration(seconds: speakLength), () {
      //debugPrint('finished speaking');
      if(autoRecord==true) {
        if (mounted) {
          setState(() {
            //if user wants the auto listener then run it after speaking current screen
            if (autoRecord) {
              AppTextToSpeech.replyText = '';
              //to show the count down on screen
              _startingIn = 7;
              _sliderVal = 7;
              countDownListener();
              //starting timer related to the auto listener feature
              timer =
                  RestartableTimer(const Duration(seconds: 7), () => speechListen());
              timerCont =
                  Timer.periodic(
                      const Duration(seconds: 13), (Timer t) => checkAuto());
            }
            else {
              log('auto record OFF');
            }
          });
        }
      }
    });
  }

//Scroll Down
  void _scrollDown() {
    _listController.animateTo(
      _listController.position.maxScrollExtent,
      duration: const Duration(seconds: 10),
      curve: Curves.fastOutSlowIn,
    );
  }
  //Scroll Up
  void _scrollUp() {
    _listController.animateTo(
      _listController.position.minScrollExtent,
      duration: const Duration(seconds: 10),
      curve: Curves.fastOutSlowIn,
    );
  }
  //stop scrolling
  void _scrollStop() {
    _listController.animateTo(_listController.offset, duration: const Duration(milliseconds: 1), curve: Curves.fastOutSlowIn);
  }

    //Build UI
  @override
  Widget build(BuildContext context) {
    //get current window size
    final deviceSize = MediaQuery.of(context).size;
    final customerOrderData = Provider.of<AllOrders>(context);
    Future<void> refreshCurrentOrders() async {
      //can change this to listen: false
      await Provider.of<AllOrders>(context).fetchAndSetCustomerOrders();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const CustomerDrawerWidget(),
      body:
      _isItLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: refreshCurrentOrders,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: deviceSize.height*0.78,
            child: ListView.builder(
              controller: _listController,
              //to solve vertical height issues
              //scrollDirection: Axis.vertical,
              //shrinkWrap: true,
              itemBuilder: (_, i) => Column(
                children: [
                  CustomerOrderItemWidget(customerOrderData.getCustomerOrders[i]),
                  const Divider(),
                ],
              ),
              itemCount: customerOrderData.getCustomerOrders.length,
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
                      terms: CustomerOrdersScreenCommand.commandsCustomerOrdersScreen,
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
                  heroTag: "btnAutoCOrders",
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
                  heroTag: "btnMicCOrders",
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
