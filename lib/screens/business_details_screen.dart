import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../models/app_text_to_speech.dart';
import '../models/global_preferences.dart';
import '../providers/authentication_provider.dart';
import '../providers/business_data_provider.dart';
import '../providers/business_details_provider.dart';
import '../commands/business_details_screen_commands.dart';
import '../screens/business_screen.dart';
import '../screens/edit_business_details_screen.dart';
import '../screens/manage_menu_screen.dart';
import '../screens/business_orders_screen.dart';
import '../widgets/business_drawer_widget.dart';


//business profile screen user interface
class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({Key? key}) : super(key: key);

  //for navigation reference between screens
  static const routeName = '/businessDetailsScreen';

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
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

  //the dynamic voice commands based on data from the database
  Map<String, String> voiceCommandData = {};

  //to store current business data
  late BusinessData businessData;

  //to check if its initialized
  var _isInit = true;

  //to be used in to show the count down timer
  int _startingIn = 0;

  //to control the slider value
  double _sliderVal = 7.0;

  //the countdown timer that will be shown on the screen before listening
  late Timer _timerNew;

  //to show loading on screen
  var _isItLoading = false;

  //initializing...
  @override
  void initState() {
    super.initState();
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        //speaking text
        AppTextToSpeech.replyText = "Your Current Profile";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing business data
    businessData = BusinessData(
      id: '',
      businessName: '',
      businessType: '',
      businessDoorNo: '',
      businessPostCode: '',
      deliveryOrCollection: '',
      openTimes: '',
      ownerID: '',
    );
    //initializing timers
    timer = RestartableTimer(const Duration(seconds: 1), () => {});
    timerCont = Timer(const Duration(seconds: 1), () => {});
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
        //update UI using set state
        setState(() {
          Provider.of<BusinessDetails>(context, listen: false)
              .fetchBusinessDetails('')
              .then((_) {
            setState(() {
              _isItLoading = false;
              businessData =
                  Provider.of<BusinessDetails>(context, listen: false)
                      .getBusinessDetails;
              Future.delayed(const Duration(seconds: 2), () {
                speakCurrentScreen();
              });
            });
          });
        });
      }
    }
    _isInit = false;
  }

  //after leaving the screen, disposes of any active elements on the screen
  @override
  void dispose() {
    super.dispose();
    //log('disposing the manage business screen');
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
      speechProvider.listen();
    }
    //show the listened text on screen
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _recognizedText = speechProvider.lastResult?.recognizedWords ?? '';
        });
      }
    });
    //check for for commands in the recognized text
    Future.delayed(const Duration(seconds: 6), () {
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
    //send to command process class to see if text spoken is a command or not
    String actionCommand =
        BusinessDetailsScreenCommandProcess.handleSpokenWords(text);
    //log('received back command: $actionCommand');
    if (actionCommand == 'home') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, BusinessScreen.routeName);
    } else if (actionCommand == 'manage') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, ManageMenuScreen.routeName);
    } else if (actionCommand == 'repeat') {
      Navigator.pushReplacementNamed(context, BusinessDetailsScreen.routeName);
    } else if (actionCommand == 'edit profile') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(
          context, EditBusinessDetailsScreen.routeName);
    } else if (actionCommand == 'logout') {
      log('signing out');
      setState(() {
        //may already have been reset by dispose method
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
        speechProvider.cancel();
      });
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
    } else if (actionCommand == 'orders') {
      Navigator.of(context)
          .pushReplacementNamed(BusinessOrdersScreen.routeName);
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
    //log('speakCurrentScreen() RAN in business details screen');
    AppTextToSpeech.replyText = 'Your Business Profile';
    AppTextToSpeech.speak();
    String speakAll;
    if (businessData.businessName == 'newID' ||
        businessData.businessName.isEmpty ||
        businessData.businessName == '' ||
        businessData.businessName == 'null') {
      speakAll =
          'Please setup your profile by going to edit business details screen!, or, you can ask me to repeat or goto home, orders, or manage screen';
    } else {
      speakAll =
          'Your business name is, ${businessData.businessName}, of type, ${businessData.businessType}, door number is, ${businessData.businessDoorNo}, post-code is,${businessData.businessPostCode}, in services, you offer,${businessData.deliveryOrCollection},and, you are open, ${businessData.openTimes}, now, you can ask me to edit profile, repeat or goto home, orders, or manage screen';
      //log('speakAll: $speakAll');
    }

    Future.delayed(const Duration(seconds: 2), () async {
      await AppTextToSpeech.flutterTts.speak(speakAll);
    });
    Future.delayed(const Duration(seconds: 30), () {
      //debugPrint('finished speaking');
      //if user wants the auto listener then run it after speaking current screen
      if (autoRecord == true) {
        if (mounted) {
          setState(() {
            AppTextToSpeech.replyText = '';
            //to show the count down on screen
            _startingIn = 7;
            _sliderVal = 7;
            countDownListener();
            //starting timer related to the auto listener feature
            timer = RestartableTimer(
                const Duration(seconds: 7), () => speechListen());
            timerCont = Timer.periodic(
                const Duration(seconds: 13), (Timer t) => checkAuto());
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //get current window size
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Business Profile'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                AppTextToSpeech.replyText = '';
                AppTextToSpeech.stop();
                speechProvider.cancel();
              });
              //when edit button is clicked
              Navigator.pushReplacementNamed(
                  context, EditBusinessDetailsScreen.routeName);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      //Creates the drawer for the business side
      drawer: const BusinessDrawerWidget(),
      body: _isItLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SizedBox(
            height: deviceSize.height*0.78,
            child: SingleChildScrollView(
                //show business details with cards in a column
                child: Column(
                  children: [
                    Card(
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(64, 75, 96, .9)),
                        child: ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Business Name:',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Expanded(
                                child: Text(''),
                              ),
                              Icon(
                                Icons.text_fields,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ],
                          ),
                          subtitle: Center(
                              child: Text(
                            businessData.businessName,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(64, 75, 96, .9)),
                        child: ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Business Type:',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Expanded(
                                child: Text(''),
                              ),
                              Icon(
                                Icons.restaurant,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ],
                          ),
                          subtitle: Center(
                              child: Text(
                            businessData.businessType,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(64, 75, 96, .9)),
                        child: ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Building No. :',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Expanded(
                                child: Text(''),
                              ),
                              Icon(
                                Icons.numbers,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ],
                          ),
                          subtitle: Center(
                              child: Text(
                            businessData.businessDoorNo,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(64, 75, 96, .9)),
                        child: ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Post-Code:',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Expanded(
                                child: Text(''),
                              ),
                              Icon(
                                Icons.map,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ],
                          ),
                          subtitle: Center(
                              child: Text(
                            businessData.businessPostCode,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(64, 75, 96, .9)),
                        child: ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Service (Delivery, Collection):',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Expanded(
                                child: Text(''),
                              ),
                              Icon(
                                Icons.shopping_bag,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ],
                          ),
                          subtitle: Center(
                              child: Text(
                            businessData.deliveryOrCollection,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 8.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 5.0, vertical: 3.0),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color.fromRGBO(64, 75, 96, .9)),
                        child: ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Timing:',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Expanded(
                                child: Text(''),
                              ),
                              Icon(
                                Icons.timelapse,
                                color: Colors.white,
                                size: 30.0,
                              ),
                            ],
                          ),
                          subtitle: Center(
                              child: Text(
                            businessData.openTimes,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
      //position of the floating action button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //the floating action buttons
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          //alignment: Alignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //row which shows the recognized text by the speech to text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //dynamically sized with expanded
                Expanded(
                  child: Center(
                    child: SubstringHighlight(
                      text: _recognizedText,
                      terms: BusinessDetailsScreenCommand
                          .commandsBusinessDetailsScreen,
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
            //row that shows the count down timer on the current screen
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
            //row that shows the auto listener and mic buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "btnAutoProfile",
                  onPressed: () {
                    timer.cancel();
                    timerCont.cancel();
                    speechProvider.cancel();
                    //start auto recording for speech to text
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
                  heroTag: "btnMicProfile",
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
