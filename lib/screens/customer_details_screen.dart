import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:fyp/providers/customer_data_provider.dart';
import 'package:fyp/providers/customer_details_provider.dart';
import 'package:fyp/screens/customer_orders_screen.dart';
import 'package:fyp/screens/customer_screen.dart';
import 'package:fyp/screens/edit_customer_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../commands/customer_details_screen_commands.dart';
import '../models/app_text_to_speech.dart';
import '../models/global_preferences.dart';
import '../providers/authentication_provider.dart';

import '../widgets/customer_drawer_widget.dart';

//customer profile screen user interface
class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({Key? key}) : super(key: key);
  //for navigation reference between screens
  static const routeName = '/customerDetailsScreen';

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
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
  //to store the customer data
  late CustomerData customerData;
  //to check if its initialized
  var _isInit = true;
  //to be used in to show the count down timer
  int _startingIn = 0;
  //the countdown timer that will be shown on the screen before listening
  late Timer _timerNew;
  //to control the slider value
  double _sliderVal = 7.0;
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
    //initializing customer data
    customerData = CustomerData(
      id: '', customerFirstName: '', customerLastName: '', customerDoorNo: '', customerPostCode: '', phoneNumber: '', userID: '',
    );
    //initializing timers
    timer = RestartableTimer(const Duration(seconds: 1), () => {});
    timerCont = Timer(const Duration(seconds: 1), () => {});
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
      //update UI using set state
      //debugPrint('showing data from database');
      if (mounted) {
        //update UI using set state
        setState(() {
          Provider.of<CustomerDetails>(context, listen: false)
              .fetchCustomerDetails()
              .then((_) {
            setState(() {
              _isItLoading = false;
              customerData =
                  Provider.of<CustomerDetails>(context, listen: false)
                      .getCustomerDetails;
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
    CustomerDetailsScreenCommandProcess.handleSpokenWords(text);
    //log('received back command: $actionCommand');
    if (actionCommand == 'home') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, CustomerScreen.routeName);
    } else if (actionCommand == 'orders') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, CustomerOrdersScreen.routeName);
    } else if (actionCommand == 'repeat') {
      Navigator.pushReplacementNamed(context, CustomerDetailsScreen.routeName);
    } else if (actionCommand == 'edit profile') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(
          context, EditCustomerDetailsScreen.routeName);
    } else if (actionCommand == 'logout') {
      //log('signing out');
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
      Future.delayed(const Duration(seconds: 1),() {
        Provider.of<Authentication>(context, listen: false).userLogout();
        Navigator.of(context).pushReplacementNamed('/');
      });
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
    AppTextToSpeech.replyText = 'Your Profile Screen';
    AppTextToSpeech.speak();
    String speakAll;
    //sending to recognize commands
    if (customerData.id == 'newID' ||
        customerData.id.isEmpty ||
        customerData.id == '' ||
        customerData.id == 'null') {
      speakAll =
      'Please setup your profile by going to edit business details screen!, now, you can ask me to edit profile or goto home or orders screen';
    } else {
      speakAll =
      'Your first name is, ${customerData.customerFirstName}, last name is, ${customerData.customerLastName}, door number is, ${customerData.customerDoorNo}, post-code is,${customerData.customerPostCode}, and phone number is,${customerData.phoneNumber}, now, you can ask me to edit profile, repeat or goto home or orders screen';
      //log('speakAll: $speakAll');
    }

    Future.delayed(const Duration(seconds: 2), () async {
      await AppTextToSpeech.flutterTts.speak(speakAll);
    });
    Future.delayed(const Duration(seconds: 25), () {
      //debugPrint('finished speaking');
      //if user wants the auto listener then run it after speaking current screen
      if(autoRecord==true) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
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
                  context, EditCustomerDetailsScreen.routeName);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      drawer: const CustomerDrawerWidget(),
      body: _isItLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
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
                        'First Name:',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Expanded(
                        child: Text(''),
                      ),
                      Icon(
                        Icons.text_rotation_none,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ],
                  ),
                  subtitle: Center(
                      child: Text(
                        customerData.customerFirstName,
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
                        'Last Name:',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Expanded(
                        child: Text(''),
                      ),
                      Icon(
                        Icons.text_rotation_none,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ],
                  ),
                  subtitle: Center(
                      child: Text(
                        customerData.customerLastName,
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
                        'Door No. :',
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
                        customerData.customerDoorNo,
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
                        customerData.customerPostCode,
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
                        'Phone Number:',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Expanded(
                        child: Text(''),
                      ),
                      Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ],
                  ),
                  subtitle: Center(
                      child: Text(
                        customerData.phoneNumber,
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
                      //text: ' pizza samfnhk kjdf kjasid jodj burger',
                      terms: CustomerDetailsScreenCommand
                          .commandsCustomerDetailsScreen,
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
                  heroTag: "btnAutoCProfile",
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
                  heroTag: "btnMicCProfile",
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
