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
import '../providers/food_category_provider.dart';
import '../providers/authentication_provider.dart';
import '../providers/foods_menu_provider.dart';
import '../commands/business_screen_commands.dart';
import '../screens/manage_menu_screen.dart';
import '../screens/view_category_items_screen.dart';
import '../screens/business_details_screen.dart';
import '../screens/business_orders_screen.dart';
import '../widgets/business_drawer_widget.dart';
import '../widgets/view_category_widget.dart';


//business home screen user interface
class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});
  //for navigation reference between screens
  static const routeName = '/businessHome';

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
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
  //to store food categories list
  late List<FoodCategoryProvider> foodCategories;
  //to be used in to show the count down timer
  int _startingIn = 0;
  //the countdown timer that will be shown on the screen before listening
  late Timer _timerNew;
  //to control the slider value
  double _sliderVal = 7.0;

  //initializing...
  @override
  void initState() {
    super.initState();
    //AppTextToSpeech.replyText='';
    //AppTextToSpeech.stop();
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        //speaking text
        AppTextToSpeech.replyText = "Your Menu";
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
        Provider.of<FoodsMenu>(context).fetchAndSetMenu().then((_) {
          if (mounted) {
            //update UI using set state
            setState(() {
              _isItLoading = false;
              foodCategories =
                  Provider.of<FoodsMenu>(context, listen: false).getCategoryItems;
              Future.delayed(const Duration(seconds: 2), () {
                speakCurrentScreen();
              });
              mapCategories();
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

  //mapping database data for dynamic commands
  void mapCategories() {
    for (var element in foodCategories) {
      //debugPrint('category title: ${element.title}');
      voiceCommandData[element.title] = element.id;
    }
    //debugPrint('Map Now: $voiceCommandData');
  }

  //process the text recognized by the speech to text
  Future<void> handleCommand(String text) async {
    //send to command process class to see if text spoke is a command or not
    String actionCommand = BusinessScreenCommandProcess.handleSpokenWords(text);
    //log('received back command: $actionCommand');
    //print('object');
    //setState(() {
    //log(voiceCommandData.values.toString());
    //log(voiceCommandData.keys.toString());
    String takeToID = '';
    voiceCommandData.forEach((key, value) {
      //log(key+' : '+value);
      key = key.toLowerCase();
      if (key == actionCommand) {
        //log('$key : match found : $value');
        takeToID = value;
      }
    });
    //log('take me to this ID: $takeToID');
    if (takeToID != '') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      speechProvider.cancel();
      Navigator.pushReplacementNamed(context, ViewCategoryItemScreen.routeName,
          arguments: takeToID);
    }
    if (actionCommand == 'manage') {
      speechProvider.cancel();
      Navigator.pushReplacementNamed(context, ManageMenuScreen.routeName);
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
      //MyApp.restartApp(context);
    } else if (actionCommand == 'repeat') {
      Navigator.of(context).pushReplacementNamed(BusinessScreen.routeName);
    } else if (actionCommand == 'profile') {
      Navigator.of(context)
          .pushReplacementNamed(BusinessDetailsScreen.routeName);
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
      //AppTextToSpeech.replyText='';
    });
  }

  //speak the current screen elements
  void speakCurrentScreen() {
    //log('speakCurrentScreen() RAN in view category items/business screen');
    AppTextToSpeech.replyText = 'Home Screen';
    AppTextToSpeech.speak();
    List<String> toSpeak = [];
    foodCategories.forEach((element) {
      //log(element.title);
      String currentElement = ', ${element.title},';
      toSpeak.add(currentElement);
      //totalSecondsWait+=10;
    });
    //sending to recognize commands
    BusinessScreenCommand.categoryCommands(foodCategories);
    //int speakLength = toSpeak.length;
    int speakLength = (toSpeak.length*3) + 10;
    //log('toSpeak List: $toSpeak');
    //log('You currently have : ${toSpeak.length}');
    String speakAll = '';
    toSpeak.forEach((element) {
      speakAll += '$element ';
    });
    //log('speakAll: $speakAll');
    Future.delayed(const Duration(seconds: 2), () {
      if (toSpeak.isEmpty) {
        //log('nothing to speak yet');
        AppTextToSpeech.flutterTts.speak('You do not have any categories yet, please goto manage screen to add categories, now, you can ask me to repeat or goto manage menu, orders, or profile screen');
      } else {
        AppTextToSpeech.replyText = speakAll;
        AppTextToSpeech.flutterTts.speak('You currently have:$speakAll, now, You can say a category name to view items in it, or you can ask me to repeat or goto manage, orders, or profile screen');
      }
      //AppTextToSpeech.flutterTts.awaitSpeakCompletion(true);

      //AppTextToSpeech.replyText = '';
      //log('');
    });
    //}).then((value) =>
    Future.delayed(Duration(seconds: speakLength), () {
      //debugPrint('finished speaking');
      //if user wants the auto listener then run it after speaking current screen
      if(autoRecord==true) {
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
  //Build UI
  @override
  Widget build(BuildContext context) {
    //get current window size
    final deviceSize = MediaQuery.of(context).size;
    //if something is updated rebuilt the LIST
    final foodsMenu = Provider.of<FoodsMenu>(context);
    Future<void> refreshCurrentMenu() async {
      //await Provider.of<FoodsMenu>(context, listen: false).fetchAndSetMenu();
      await foodsMenu.fetchAndSetMenu();
    }
    //Creates a visual scaffold for widgets
    return Scaffold(
        //Creates the app bar.
      appBar: AppBar(
        title: const Text('Your Menu'),
      ),
      drawer: const BusinessDrawerWidget(),
      body: _isItLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: refreshCurrentMenu,
              child: Padding(
                padding: const EdgeInsets.all(8),
                //child: ListView.builder(
                child: foodsMenu.getCategoryItems.isEmpty ? const Center(child: Text('No categories added yet!')) : SizedBox(
                  height: deviceSize.height*0.78,
                  //Creates a scrollable, linear array of widgets that are created based on item count
                  child: ListView.builder(
                      key: const Key('category_list_business'),
                    //to solve vertical height issues
                    //scrollDirection: Axis.vertical,
                    //shrinkWrap: true,
                    itemBuilder: (_, i) => Column(
                    children: [
                        ViewCategoryWidget(
                          theTitle: foodsMenu.getCategoryItems[i].title,
                          id: foodsMenu.getCategoryItems[i].id.toString(),
                        ),
                        const Divider(),
                      ],
                    ),
                    itemCount: foodsMenu.getCategoryItems.length,
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
                      terms: BusinessScreenCommand.commandsBusinessScreen,
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
                  heroTag: "btnAutoBHome",
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
                  heroTag: "btnMicBHome",
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
