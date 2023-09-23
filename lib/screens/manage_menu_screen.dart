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
import '../providers/foods_menu_provider.dart';
import '../providers/authentication_provider.dart';
import '../providers/food_category_provider.dart';
import '../commands/manage_menu_commands.dart';
import '../screens/business_screen.dart';
import '../screens/manage_category_item_screen.dart';
import '../screens/edit_category_screen.dart';
import '../screens/business_details_screen.dart';
import '../widgets/category_widget.dart';
import '../widgets/business_drawer_widget.dart';
import '../screens/business_orders_screen.dart';

//manage menu screen user interface
class ManageMenuScreen extends StatefulWidget {
  const ManageMenuScreen({Key? key}) : super(key: key);

  //for navigation reference between screens
  static const routeName = '/businessManage';

  @override
  State<ManageMenuScreen> createState() => _ManageMenuScreenState();
}

class _ManageMenuScreenState extends State<ManageMenuScreen> {
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

  //to store food categories
  late List<FoodCategoryProvider> foodCategories;

  //to check if its initialized
  var _isInit = true;

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
        AppTextToSpeech.replyText = "Manage Menu";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing food categories
    foodCategories = [];
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
      //debugPrint('showing data from database in manage menu screen');
      Provider.of<FoodsMenu>(context).fetchAndSetMenu().then((_) {
        if (mounted) {
          //update UI using set state
          setState(() {
            foodCategories =
                Provider.of<FoodsMenu>(context, listen: false).getCategoryItems;
            //debugPrint('foodCategories: '+foodCategories.toString());
            mapCategories();
            Future.delayed(const Duration(seconds: 2), () {
              speakCurrentScreen();
            });
          });
        }
      });
    }
    _isInit = false;
  }

  //after leaving the screen, disposes of any active elements on the screen
  @override
  void dispose() {
    super.dispose();
    //log('disposing the manage menu screen');
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
    AppTextToSpeech.replyText = '';
    AppTextToSpeech.speak();
    AppTextToSpeech.stop();
    //log('speechListen() in manage menu screen RAN');
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
        timer =
            RestartableTimer(const Duration(seconds: 7), () => speechListen());
        timerCont = Timer.periodic(
            const Duration(seconds: 13), (Timer t) => checkAuto());
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
    String actionCommand = ManageMenuCommandProcess.handleSpokenWords(text);
    //_recognizedText = '';
    //log('received back command: $actionCommand');
    //log(voiceCommandData.values.toString());
    //log(voiceCommandData.keys.toString());
    String takeToID = '';
    String editID = '';
    String deleteID = '';
    voiceCommandData.forEach((key, value) {
      //log(key+' : '+value);
      key = key.toLowerCase();
      if (key == actionCommand) {
        //log('$key : match found : $value');
        takeToID = value;
      } else if (('edit $key') == actionCommand) {
        //log('$key : match found : $value');
        editID = value;
      } else if (('delete $key') == actionCommand) {
        //log('$key : match found : $value');
        deleteID = value;
      }
    });
    //log('take me to this ID: $takeToID');
    //log('edit this ID: $editID');
    //log('delete this ID: $deleteID');
    if (takeToID != '') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(
          context, ManageCategoryItemScreen.routeName,
          arguments: takeToID);
    }
    //edit by ID
    if (editID != '') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, EditCategoryScreen.routeName,
          arguments: editID);
    }
    //delete by ID
    if (deleteID != '') {
      setState(() {
        AppTextToSpeech.replyText = 'Category Deleted!';
        AppTextToSpeech.speak();
        //AppTextToSpeech.stop();
      });
      Provider.of<FoodsMenu>(context, listen: false)
          .deleteFoodCategory(deleteID);
    }
    if (actionCommand == 'home') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, BusinessScreen.routeName);
    } else if (actionCommand == 'profile') {
      Navigator.of(context)
          .pushReplacementNamed(BusinessDetailsScreen.routeName);
    } else if (actionCommand == 'add') {
      Navigator.pushReplacementNamed(context, EditCategoryScreen.routeName);
    } else if (actionCommand == 'repeat') {
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
      Future.delayed(const Duration(seconds: 1), () {
        Provider.of<Authentication>(context, listen: false).userLogout();
        Navigator.of(context).pushReplacementNamed('/');
      });
    } else if (actionCommand == 'orders') {
      Navigator.of(context)
          .pushReplacementNamed(BusinessOrdersScreen.routeName);
    } else if (actionCommand == 'nothing') {
      AppTextToSpeech.replyText = '';
    }
    Future.delayed(const Duration(milliseconds: 2000), () {
      //debugPrint("Now Speaking this: ${AppTextToSpeech.replyText}");
      //speak text on event
      if (AppTextToSpeech.replyText != '') {
        AppTextToSpeech.speak();
      }
    });
  }

  //speak the current screen elements
  void speakCurrentScreen() {
    //log('speakCurrentScreen() RAN in manage menu screen');
    AppTextToSpeech.replyText = 'Manage Menu Screen';
    AppTextToSpeech.speak();
    List<String> toSpeak = [];
    foodCategories.forEach((element) {
      //log(element.title);
      String currentElement = ', ${element.title},';
      toSpeak.add(currentElement);
    });
    //sending to recognize commands
    ManageMenuCommand.categoryCommands(foodCategories);
    int speakLength = (toSpeak.length * 3) + 10;
    //log('toSpeak List: $toSpeak');
    //log('This place has : ${toSpeak.length}');
    String speakAll = '';
    toSpeak.forEach((element) {
      speakAll += '$element ';
    });
    //log('speakAll: $speakAll');
    Future.delayed(const Duration(seconds: 2), () async {
      //AppTextToSpeech.flutterTts.awaitSpeakCompletion(true);
      //AppTextToSpeech.replyText = speakAll;
      if (toSpeak.isEmpty) {
        await AppTextToSpeech.flutterTts.speak(
            'You can add a new category, or ask me to repeat or goto home, orders, or profile screens');
      } else {
        await AppTextToSpeech.flutterTts.speak(
            'You can edit or see items in: $speakAll, add a new category, or ask me to repeat or goto home, orders, or profile screens');
      }
      //AppTextToSpeech.replyText = '';
      //log('');
    });
    Future.delayed(Duration(seconds: speakLength), () {
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

  //Build UI
  @override
  Widget build(BuildContext context) {
    //get current window size
    final deviceSize = MediaQuery.of(context).size;
    //if something is updated rebuild the LIST
    final foodsMenu = Provider.of<FoodsMenu>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Your Menu'),
        actions: [
          //add a new category icon button
          IconButton(
            onPressed: () {
              setState(() {
                AppTextToSpeech.replyText = '';
                AppTextToSpeech.stop();
                speechProvider.cancel();
              });
              //when add button is clicked
              Navigator.pushReplacementNamed(
                  context, EditCategoryScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const BusinessDrawerWidget(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        //child: ListView.builder(
        child: foodsMenu.getCategoryItems.isEmpty
            ? const Center(child: Text('No categories added yet!'))
            : SizedBox(
                height: deviceSize.height * 0.78,
                //Creates a scrollable, linear array of widgets that are created on demand
                child: ListView.builder(
                  key: const Key('category_list_manage'),
                  itemBuilder: (_, i) => Column(
                    children: [
                      CategoryWidget(
                        title: foodsMenu.getCategoryItems[i].title,
                        id: foodsMenu.getCategoryItems[i].id.toString(),
                      ),
                      const Divider(),
                    ],
                  ),
                  itemCount: foodsMenu.getCategoryItems.length,
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
                      terms: ManageMenuCommand.commandsManageMenu,
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
                  heroTag: "btnAutoManageMenu",
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
                  heroTag: "btnMicManageMenu",
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
