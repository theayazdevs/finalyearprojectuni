import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../models/app_text_to_speech.dart';
import '../models/global_preferences.dart';
import '../providers/authentication_provider.dart';
import '../providers/business_data_provider.dart';
import '../providers/customer_food_provider.dart';
import '../commands/customer_screen_commands.dart';
import '../screens/customer_orders_screen.dart';
import '../screens/customer_details_screen.dart';
import '../screens/view_business_menu_screen.dart';
import '../widgets/business_item_widget.dart';
import '../widgets/customer_drawer_widget.dart';

//customer home screen user interface
class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});
  //for navigation reference between screens
  static const routeName = '/customerScreen';

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
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
  //late List<FoodCategoryProvider> foodCategories;
  //to store business data to be shown on customer homepage
  late List<BusinessData> businessData;
  //to be used in to show the count down timer
  int _startingIn = 0;
  //the countdown timer that will be shown on the screen before listening
  late Timer _timerNew;
  //to control the slider value
  double _sliderVal = 7.0;
  //search box focus
  final FocusNode _searchFocus = FocusNode();
  //search box text controller
  final _searchController = TextEditingController();
  //to store the search results
  final List<BusinessData> _searchResult = [];
  //to control the scroll on list
  final ScrollController _listController = ScrollController();
  //initializing...
  @override
  void initState() {
    super.initState();
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        //speaking text
        AppTextToSpeech.replyText = "Homepage";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing business data
    businessData = [];
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
      //debugPrint('showing data from database in customer screen');
      if (mounted) {
        Provider.of<CustomerFoodProvider>(context)
            .fetchAndSetBusiness()
            .then((_) {
          if (mounted) {
            //update UI using set state
            setState(() {
              _isItLoading = false;
              businessData =
                  Provider.of<CustomerFoodProvider>(context, listen: false)
                      .businessItems;
              Future.delayed(const Duration(seconds: 2), () {
                speakCurrentScreen();
              });
              mapBusinessNames();
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
    //log('disposing the customer screen');
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
    AppTextToSpeech.replyText='';
    AppTextToSpeech.speak();
    AppTextToSpeech.stop();
    //log('speechListen() in customer screen screen RAN');
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
    //log('checkAuto() in customer screen RAN');
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
  //mapping database data for dynamic commands
  void mapBusinessNames() {
    for (var element in businessData) {
      //debugPrint('mapBusinessNames business title: ${element.businessName}');
      //voiceCommandData[element.name] = element.id;
      voiceCommandData[element.businessName] = element.ownerID;
    }
    //debugPrint('Map Now: $voiceCommandData');
  }
  //process the text recognized by the speech to text
  Future<void> handleCommand(String text) async {
    //send to command process class to see if text spoke is a command or not
    String actionCommand = CustomerScreenCommandProcess.handleSpokenWords(text);
    //_recognizedText = '';
    //log('received back command: $actionCommand');
    //log(voiceCommandData.values.toString());
    //log(voiceCommandData.keys.toString());
    String takeToID = '';
    String theName = '';
    voiceCommandData.forEach((key, value) {
      //log(key+' : '+value);
      key = key.toLowerCase();
      if (key == actionCommand) {
        //log('$key : match found : $value');
        takeToID = value;
        theName = key;
      }
    });
    //log('take me to this ID: $takeToID');
    if (takeToID != '') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      speechProvider.cancel();
      Navigator.pushReplacementNamed(
          context,
          ViewBusinessMenuScreen.routeName,
          arguments: {
            'ownerID': takeToID,
            'businessName': theName,
          });
    }
    if (actionCommand == 'logout') {
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
    } else if (actionCommand == 'search') {
      AppTextToSpeech.replyText = 'Please say your search term';
      _searchController.text = '';
      FocusScope.of(context).requestFocus(_searchFocus);
      Future.delayed(const Duration(milliseconds: 1), () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });
    } else if (_searchFocus.hasFocus && _searchController.text.isEmpty) {
      AppTextToSpeech.replyText = 'Searched';
      _searchController.text = _recognizedText.trim();
      onSearchTextChanged(_recognizedText.trim());
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear search') {
      _searchController.text = '';
      onSearchTextChanged('');
      FocusScope.of(context).requestFocus(_searchFocus);
      Future.delayed(const Duration(milliseconds: 1), () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });
      AppTextToSpeech.replyText = 'search box cleared';
    } else if (actionCommand == 'cancel search') {
      _searchController.text = '';
      onSearchTextChanged('');
      FocusScope.of(context).unfocus();
      AppTextToSpeech.replyText = 'Search Cancelled';
    } else if (actionCommand == 'repeat') {
      Navigator.of(context).pushReplacementNamed(CustomerScreen.routeName);
    } else if (actionCommand == 'profile') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      speechProvider.cancel();
      Navigator.of(context)
          .pushReplacementNamed(CustomerDetailsScreen.routeName);
    } else if (actionCommand == 'orders') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      speechProvider.cancel();
      Navigator.of(context)
          .pushReplacementNamed(CustomerOrdersScreen.routeName);
    } else if (actionCommand == 'scroll up') {
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
    //log('speakCurrentScreen() RAN in customer screen');
    AppTextToSpeech.replyText = 'Home Screen';
    AppTextToSpeech.speak();
    List<String> toSpeak = [];
    businessData.forEach((element) {
      //log(element.businessName);
      String currentElement =
          ',${element.businessType} name, ${element.businessName}, services, ${element.deliveryOrCollection}, ${element.openTimes},';
      toSpeak.add(currentElement);
      //totalSecondsWait+=10;
    });
    //sending to recognize commands
    CustomerScreenCommand.businessNameCommands(businessData);
    int speakLength = (toSpeak.length * 10)+10;
    //log('toSpeak List: $toSpeak');
    //log('Available Restaurants : ${toSpeak.length}');
    String speakAll = '';
    toSpeak.forEach((element) {
      speakAll += '$element ';
    });
    //log('speakAll: $speakAll');
    Future.delayed(const Duration(seconds: 2), () async {
      if (toSpeak.isEmpty) {
        //log('nothing to speak yet');
        await AppTextToSpeech.flutterTts
            .speak('No Food Places available yet, now, you can ask me to repeat, goto orders or profile screen');
      } else {
        AppTextToSpeech.replyText = speakAll;
        await AppTextToSpeech.flutterTts
            .speak('you can goto these Available Food Places: $speakAll, or you can ask me to search, repeat, goto orders or profile screen');
      }
    });
    //}).then((value) =>
    Future.delayed(Duration(seconds: speakLength), () {
      //debugPrint('finished speaking');
      //if user wants the auto listener then run it after speaking current screen
      if (autoRecord == true) {
        if (mounted) {
          //CODE REFACTORING
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
  //on search update UI
  onSearchTextChanged(String text) async {
    //log('running onSearchTextChanged');
    text = text.trim().toLowerCase();
    _searchResult.clear();
    if (text.isEmpty) {
      //log('search text empty');
      setState(() {});
      return;
    }
    //businessData.forEach((theBusinessData) {
    businessData.forEach((theBusinessData) {
      //log('inside loop');
      if (theBusinessData.businessName.toLowerCase().contains(text) ||
          theBusinessData.businessDoorNo.toLowerCase().contains(text) ||
          theBusinessData.businessPostCode.toLowerCase().contains(text) ||
          theBusinessData.deliveryOrCollection.toLowerCase().contains(text) ||
          theBusinessData.openTimes.toLowerCase().contains(text)) {
        //log('adding search match...');
        _searchResult.add(theBusinessData);
      }
    });
    setState(() {});
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
    //if something is updated rebuilt the LIST
    final customerFoodProvider = Provider.of<CustomerFoodProvider>(context);
    Future<void> refreshCurrentBusiness() async {
      //await Provider.of<FoodsMenu>(context, listen: false).fetchAndSetMenu();
      await customerFoodProvider.fetchAndSetBusiness();
    }
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Container(
              color: Colors.white,
              height: 50,
              alignment: Alignment.center,
              child: ListTile(
                leading: const Icon(Icons.search),
                title: TextField(
                  key: const Key('search_key'),
                  focusNode: _searchFocus,
                  controller: _searchController,
                  decoration: const InputDecoration(
                      hintText: 'Search', border: InputBorder.none),
                  onChanged: onSearchTextChanged,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    _searchController.clear();
                    onSearchTextChanged('');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: const CustomerDrawerWidget(),
      body: _isItLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: refreshCurrentBusiness,
              child: Padding(
                padding: const EdgeInsets.all(8),
                //child: ListView.builder(
                child: _searchResult.isNotEmpty ||
                        _searchController.text.isNotEmpty
                    ? SizedBox(
                      height: deviceSize.height*0.78,
                      child: ListView.builder(
                  key: const Key('searched_list_key'),
                          //to solve vertical height issues
                          //scrollDirection: Axis.vertical,
                          //shrinkWrap: true,
                          itemBuilder: (_, i) => Column(
                            children: [
                              BusinessItemWidget(
                                businessName: _searchResult[i].businessName,
                                businessType: _searchResult[i].businessType,
                                businessDoorNo: _searchResult[i].businessDoorNo,
                                businessPostCode:
                                    _searchResult[i].businessPostCode,
                                businessService:
                                    _searchResult[i].deliveryOrCollection,
                                businessOpenTimes: _searchResult[i].openTimes,
                                ownerID: _searchResult[i].ownerID,
                              ),
                              const Divider(),
                            ],
                          ),
                          itemCount: _searchResult.length,
                        ),
                    )
                    : customerFoodProvider.businessItems.isNotEmpty ?
                SizedBox(
                  height: deviceSize.height*0.78,
                  child: ListView.builder(
                    controller: _listController,
                    key: const Key('business_list_key'),
                          //to solve vertical height issues
                          //scrollDirection: Axis.vertical,
                          //shrinkWrap: true,
                          itemBuilder: (_, i) => Column(
                            children: [
                              BusinessItemWidget(
                                businessName: customerFoodProvider
                                    .businessItems[i].businessName,
                                businessType: customerFoodProvider
                                    .businessItems[i].businessType,
                                businessDoorNo: customerFoodProvider
                                    .businessItems[i].businessDoorNo,
                                businessPostCode: customerFoodProvider
                                    .businessItems[i].businessPostCode,
                                businessService: customerFoodProvider
                                    .businessItems[i].deliveryOrCollection,
                                businessOpenTimes: customerFoodProvider
                                    .businessItems[i].openTimes,
                                ownerID:
                                    customerFoodProvider.businessItems[i].ownerID,
                                //add category names and id in a map which can be called later anywhere
                              ),
                              const Divider(),
                            ],
                          ),
                          itemCount: customerFoodProvider.businessItems.length,
                        ),
                ) : const Center(child: Text('No Food Businesses registered yet!')),
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
                      terms: CustomerScreenCommand.commandsCustomerScreen,
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
                  heroTag: "btnAutoCHome",
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
                  heroTag: "btnMicCHome",
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
