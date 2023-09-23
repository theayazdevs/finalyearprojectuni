import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../models/app_text_to_speech.dart';
import '../commands/categories_items_view_commands.dart';
import '../models/global_preferences.dart';
import '../providers/food_category_provider.dart';
import '../providers/foods_menu_provider.dart';
import '../screens/business_screen.dart';
import '../widgets/view_category_items_widget.dart';

//view items in a category screen user interface
class ViewCategoryItemScreen extends StatefulWidget {
  const ViewCategoryItemScreen({Key? key}) : super(key: key);

  //for navigation reference between screens
  static const routeName = '/viewCategoryItemScreen';

  @override
  State<ViewCategoryItemScreen> createState() => _ViewCategoryItemScreenState();
}

class _ViewCategoryItemScreenState extends State<ViewCategoryItemScreen> {
  //to store the timer that check for the auto listener feature
  late Timer timerCont;

  //timer that runs the method to listen to user speech
  late RestartableTimer timer;

  //for auto listener feature which is set to true or false based on the user choice
  late bool autoRecord;

  //to store text recognized by the speech to text
  String _recognizedText = '';

  //to store the food category ID
  String categoryID = '';

  //to store food category provider
  late FoodCategoryProvider foodsMenu;

  //speech to text provider to control the speech recognition
  late SpeechToTextProvider speechProvider;

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
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        //speaking text
        AppTextToSpeech.replyText = "Items in Category";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing timers
    timer = RestartableTimer(const Duration(seconds: 1), () => {});
    timerCont = Timer(const Duration(seconds: 1), () => {});
    _timerNew = Timer(const Duration(seconds: 1), () => {});
    //default auto record
    autoRecord = true;
    //check for any stored user preferences
    setUserPreferences();
    Future.delayed(const Duration(seconds: 2), () {
      speakCurrentScreen();
    });
  }

  //Called when a dependency of this State object changes, called after initState
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //storing the speech to text provider to be used on this screen
    speechProvider = Provider.of<SpeechToTextProvider>(context);
    //storing the category ID to be used on this screen
    categoryID = ModalRoute.of(context)?.settings.arguments as String;
    //storing the Foods Menu instance to be used on this screen
    foodsMenu = Provider.of<FoodsMenu>(context).findCategoryById(categoryID);
  }

  //after leaving the screen, disposes of any active elements on the screen
  @override
  void dispose() {
    super.dispose();
    //log('disposing the category items view screen');
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
    //log('speechListen() in view category items RAN');
    if (!speechProvider.isAvailable || speechProvider.isListening) {
      log('not available: NULL');
    } else {
      //speechProvider.listen(partialResults: true);
      //speechProvider.stop();
      speechProvider.listen();
    }
    //show the listened text on screen
    Future.delayed(const Duration(seconds: 5), () {
      //mounted check , to resolve set state errors
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

  //process the text recognized by the speech to text
  void handleCommand(String text) {
    //send to command process class to see if text spoke is a command or not
    String actionCommand =
        CategoryItemsViewCommandProcess.handleSpokenWords(text);
    //_recognizedText = '';
    //log('received back command: $actionCommand');
    if (actionCommand == 'back') {
      //AppTextToSpeech.replyText = 'Going Back';
      setState(() {
        //AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
        speechProvider.cancel();
      });
      Navigator.pushReplacementNamed(context, BusinessScreen.routeName);
    } else if (actionCommand == 'repeat') {
      //Navigator.pushReplacementNamed(context, ViewCategoryItemScreen.routeName);
      Navigator.pushReplacementNamed(context, ViewCategoryItemScreen.routeName,
          arguments: categoryID);
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

  //check if the auto listener feature was disabled or still enabled
  void checkAuto() {
    //log('checkAuto() in view category items screen RAN');
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

  //speak the current screen elements
  void speakCurrentScreen() {
    //log('speakCurrentScreen() RAN in view category items screen');
    AppTextToSpeech.replyText = 'View Items Screen';
    AppTextToSpeech.speak();
    List<String> toSpeak = [];
    bool itIsEmpty = false;
    foodsMenu.itemsInCategory.forEach((element) {
      //log(element.title);
      String currentElement =
          ',item, ${element.categoryItemTitle}, description, ${element.categoryItemDescription}, price, ${element.categoryItemPrice}0 pounds';
      toSpeak.add(currentElement);
      if (element.categoryItemTitle == 'title') {
        itIsEmpty = true;
      }
    });
    int speakLength = (toSpeak.length * 10) + 10;
    //log('toSpeak List: $toSpeak');
    //log('Items in the List so Category: ${toSpeak.length}');
    String speakAll = '';
    toSpeak.forEach((element) {
      speakAll += '$element ';
    });
    //log('speakAll: $speakAll');
    Future.delayed(const Duration(seconds: 2), () async {
      if (itIsEmpty == false) {
        AppTextToSpeech.replyText = speakAll;
        await AppTextToSpeech.flutterTts.speak(
          'This Category has,: $speakAll, now, you can ask me to repeat or go back',
        );
      } else {
        await AppTextToSpeech.flutterTts.speak('No Items in this category yet, now, you can ask me to repeat or go back');
      }
    });
    //.then((value) =>
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
            //starting timer related to the auto listener feature
            countDownListener();
            timer = RestartableTimer(
                const Duration(seconds: 7), () => speechListen());
            timerCont = Timer.periodic(
                const Duration(seconds: 13), (Timer t) => checkAuto());
            //AppTextToSpeech.replyText='';
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
    //Creates a visual scaffold for widgets
    return Scaffold(
      appBar: AppBar(
        //title: Text('Category Name'),
        title: Text(foodsMenu.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        //child: ListView.builder(
        child: foodsMenu.itemsInCategory.isEmpty ||
                foodsMenu.itemsInCategory[0].categoryItemTitle == 'title'
            ? const Center(child: Text('No items added yet!'))
            : SizedBox(
                height: deviceSize.height * 0.78,
                //Creates a scrollable, linear array of widgets that are created on demand
                child: ListView.builder(
                  itemBuilder: (_, i) => Column(
                    children: [
                      ViewCategoryItemsWidget(
                        theTitle: foodsMenu.itemsInCategory[i].categoryItemTitle,
                        theDescription: foodsMenu.itemsInCategory[i].categoryItemDescription,
                        thePrice: foodsMenu.itemsInCategory[i].categoryItemPrice.toString(),
                      ),
                      const Divider(),
                    ],
                  ),
                  itemCount: foodsMenu.itemsInCategory.length,
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
                    //to highlight the text recognized as a command
                    child: SubstringHighlight(
                      text: _recognizedText,
                      terms: CategoryItemsViewCommand.commandsCategoryItemsView,
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
                  heroTag: "btnAutoViewCatItems",
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
                  heroTag: "btnMicViewCatItems",
                  onPressed: speechListen,
                  //onPressed: () => {debugPrint('pressed <-------------------------------')} ,
                  child: Icon(
                    speechProvider.isListening
                        ? Icons.record_voice_over
                        : Icons.mic,
                    size: 50,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                  key: const Key('back_to_business_home'),
                  onPressed: () {
                    setState(() {
                      AppTextToSpeech.replyText = '';
                      AppTextToSpeech.stop();
                      speechProvider.cancel();
                    });
                    Navigator.pushReplacementNamed(
                        context, BusinessScreen.routeName);
                  },
                  child: const Icon(Icons.arrow_back),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
