import 'dart:async';
import 'package:async/async.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../models/app_text_to_speech.dart';
import '../models/global_preferences.dart';
import '../providers/item_in_cart_provider.dart';
import '../screens/business_screen.dart';
import '../screens/edit_category_item_screen.dart';
import '../commands/buy_items_screen_commands.dart';
import '../providers/category_item_provider.dart';
import '../providers/customer_food_provider.dart';
import '../providers/food_category_provider.dart';
import '../screens/view_business_menu_screen.dart';
import '../widgets/buy_item_widget.dart';

//view and buy items screen user interface
class BuyItemsScreen extends StatefulWidget {
  const BuyItemsScreen({Key? key}) : super(key: key);
  //for navigation reference between screens
  static const routeName = '/buyItemsScreen';

  @override
  State<BuyItemsScreen> createState() => _BuyItemsScreenState();
}

class _BuyItemsScreenState extends State<BuyItemsScreen> {
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
  //to call methods and variables in the customer food provider class
  late CustomerFoodProvider customerFoodProvider;
  //late List<CategoryItemProvider> foodCategoryItems;
  //to store food categories list
  late FoodCategoryProvider foodCategory;
  //to store the category ID currently being viewed
  late String theCategoryID;
  //to store the owner ID who's menu is being viewed
  late String ownerID;
  //to store the business name of the current menu
  late String businessName='';
  //to check if its initialized
  var _isInit = true;
  //to be used in to show the count down timer
  int _startingIn = 0;
  //the countdown timer that will be shown on the screen before listening
  late Timer _timerNew;
  //to control the slider value
  double _sliderVal = 7.0;
  //to store the current cart instance, to add items, or to remove
  late CustomerCart cart;

  //initializing...
  @override
  void initState() {
    super.initState();
    //initializing food category
    foodCategory =
        FoodCategoryProvider(id: 'id', title: 'title', itemsInCategory: []);
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        //speaking text
        AppTextToSpeech.replyText = "Buy items";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing owner ID
    ownerID = '';
    //initializing business name
    businessName='';
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
      customerFoodProvider = Provider.of<CustomerFoodProvider>(context);
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;
      if (arguments['categoryID'] != null) {
        theCategoryID = arguments['categoryID'];
        foodCategory =
            Provider.of<CustomerFoodProvider>(context).findCategoryById(theCategoryID);
        ownerID = arguments['ownerID'];
        businessName = arguments['businessName'];
        cart = Provider.of<CustomerCart>(context, listen: false);
        //log('businessName in Buy items screen received = ' + businessName);
        mapCategoryItems();
      }
    }
    _isInit = false;
  }

  //after leaving the screen, disposes of any active elements on the screen
  @override
  void dispose() {
    super.dispose();
    //log('disposing the buy items screen');
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
    AppTextToSpeech.replyText='';
    AppTextToSpeech.speak();
    AppTextToSpeech.stop();
    //log('speechListen() in buy items screen RAN');
    if (!speechProvider.isAvailable || speechProvider.isListening) {
      log('not available: NULL');
    } else {
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
    //log('checkAuto() in manage category item screen RAN');
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
  void mapCategoryItems() {
    for (var element in foodCategory.itemsInCategory) {
      //debugPrint('category title: ${element.title}');
      voiceCommandData[element.categoryItemTitle] = element.id;
    }
    //debugPrint('Map Now: $voiceCommandData');
  }
  //process the text recognized by the speech to text
  void handleCommand(String text) {
    //send to command process class to see if text spoke is a command or not
    String actionCommand = BuyItemsScreenCommandProcess.handleSpokenWords(text);
    //_recognizedText = '';
    //log('received back command: $actionCommand');
    //log(voiceCommandData.values.toString());
    //log(voiceCommandData.keys.toString());
    //String takeToID = '';
    String addID = '';
    int addTimes=1;
    voiceCommandData.forEach((key, value) {
      //log('$key : $value');
      key = key.toLowerCase();
      if (('buy $key') == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
      } else if (('buy 2 $key') == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
        addTimes=2;
      } else if (('buy 3 $key') == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
        addTimes=3;
      } else if (('buy 4 $key') == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
        addTimes=4;
      } else if (('buy 5 $key') == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
        addTimes=5;
      } else if (('buy 6 $key') == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
        addTimes=6;
      } else if (('buy 7 $key') == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
        addTimes=7;
      } else if (('buy 8 $key') == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
        addTimes=8;
      } else if (('buy 9 $key') == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
        addTimes=9;
      } else if (('buy 10 $key') == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
        addTimes=10;
      }
    });
    //log('addTimes= $addTimes');
    //log('add this ID: $addID');
    if (addID != '') {
      for(int i=0; i < addTimes; i++) {
        //log('running buy loop: $addTimes times');
        CategoryItemProvider theItemToAdd = customerFoodProvider.findItemById(
            theCategoryID, addID);
        cart.addItemToCart(addID, theItemToAdd.categoryItemPrice, theItemToAdd.categoryItemTitle, ownerID);
      }
      setState(() {
        AppTextToSpeech.replyText = '$addTimes items added!';
        //log(AppTextToSpeech.replyText);
        //AppTextToSpeech.speak();
        //AppTextToSpeech.stop();
      });
    }
    if (actionCommand == 'home') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, BusinessScreen.routeName);
    } else if (actionCommand == 'add') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, EditCategoryItemScreen.routeName,
          arguments: {'categoryID': theCategoryID, 'categoryItemID': 'newID'});
    } else if (actionCommand == 'back') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, ViewBusinessMenuScreen.routeName, arguments: {
        'ownerID': ownerID,
        'businessName':businessName,
      });
    } else if (actionCommand == 'repeat') {
      Navigator.pushReplacementNamed(context, BuyItemsScreen.routeName, arguments: {
        'categoryID': theCategoryID,
        'ownerID': ownerID,
        'businessName':businessName,
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
    //log('speakCurrentScreen() RAN in manage category items screen');
    AppTextToSpeech.replyText = 'Buy items Screen';
    AppTextToSpeech.speak();
    List<String> toSpeak = [];
    foodCategory.itemsInCategory.forEach((element) {
      //log(element.title);
      String currentElement = ',${element.categoryItemTitle}, description,: ${element.categoryItemDescription}, price,: ${element.categoryItemPrice} pounds,';
      toSpeak.add(currentElement);
      //totalSecondsWait+=10;
    });
    //sending to recognize commands
    BuyItemsScreenCommand.categoryItemsCommands(
        foodCategory.itemsInCategory);
    //int speakLength = toSpeak.length;
    int speakLength = (toSpeak.length*8)+5;
    //int speakLength = (toSpeak.length * 0.5) as int;
    //log('toSpeak List: $toSpeak');
    //log('This category has : ${toSpeak.length}');
    String speakAll = '';
    toSpeak.forEach((element) {
      speakAll += '$element ';
    });
    //log('speakAll: $speakAll');
    Future.delayed(const Duration(seconds: 2), () async {
      //AppTextToSpeech.flutterTts.awaitSpeakCompletion(true);
      //AppTextToSpeech.replyText = speakAll;
      await AppTextToSpeech.flutterTts.speak('In this category you can buy :$speakAll, or ask me to repeat, or go back');
      //AppTextToSpeech.replyText = '';
      //log('');
    });
    Future.delayed(Duration(seconds: speakLength), () {
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
    //get current window size
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        //title: const Center(child: Text('Buy From Category')),
        title: Center(child: Text('Buy ${foodCategory.title}')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        //child: ListView.builder(
        child: foodCategory.itemsInCategory.isEmpty || (foodCategory.itemsInCategory[0].id == 'null') ? const Center(child: Text('No items added yet, please check back later!')) : SizedBox(
          height: deviceSize.height*0.78,
          child: ListView.builder(
            itemBuilder: (_, i) => Column(
              children: [
                  BuyItemWidget(
                      theTitle: foodCategory.itemsInCategory[i].categoryItemTitle,
                      theDescription: foodCategory.itemsInCategory[i].categoryItemDescription,
                      thePrice: foodCategory.itemsInCategory[i].categoryItemPrice.toString(),
                      categoryID: foodCategory.id,
                      categoryItemID: foodCategory.itemsInCategory[i].id,
                      ownerID: ownerID,
                  ),
                const Divider(),
              ],
            ),
            itemCount: foodCategory.itemsInCategory.length,
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
                      terms: BuyItemsScreenCommand
                          .commandsBuyItemsScreen,
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
                  heroTag: "btnAutoBuyItems",
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
                  heroTag: "btnMicBuyItems",
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
                  key: const Key('back_to_view_business_menu'),
                  onPressed: () {
                    setState(() {
                      AppTextToSpeech.replyText = '';
                      AppTextToSpeech.stop();
                      speechProvider.cancel();
                    });
                    Navigator.pushReplacementNamed(context, ViewBusinessMenuScreen.routeName, arguments: {
                      'ownerID': ownerID,
                      'businessName':businessName,
                    });
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
