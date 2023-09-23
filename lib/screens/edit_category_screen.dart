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
import '../providers/food_category_provider.dart';
import '../providers/foods_menu_provider.dart';
import '../commands/edit_category_screen_commands.dart';
import '../screens/manage_menu_screen.dart';
import '../screens/business_screen.dart';
//edit category screen user interface
class EditCategoryScreen extends StatefulWidget {
  const EditCategoryScreen({Key? key}) : super(key: key);
  //for navigation reference between screens
  static const routeName = '/editCategoryScreen';

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  //to access the form outside widgets
  final _formCategory = GlobalKey<FormState>();

  //default category item
  var _editedCategory =
      FoodCategoryProvider(id: 'newID', title: '', itemsInCategory: []);
  var _initValues = {
    'title': '',
  };
  //to check if its initialized
  var _isInit = true;
  //to show loading on screen
  var _isItLoading = false;
  //speech to text provider to control the speech recognition
  late SpeechToTextProvider speechProvider;
  //to store text recognized by the speech to text
  String _recognizedText = '';
  //to store the timer that check for the auto listener feature
  late Timer timerCont;
  //timer that runs the method to listen to user speech
  late RestartableTimer timer;
  //for auto listener feature which is set to true or false based on the user choice
  late bool autoRecord;
  //to be used in to show the count down timer
  int _startingIn = 0;
  //the countdown timer that will be shown on the screen before listening
  late Timer _timerNew;
  //to control the slider value
  double _sliderVal = 7.0;
  //title text box focus
  final FocusNode _categoryTitle = FocusNode();
  //title text box controller
  final _categoryTitleController = TextEditingController();
  //initializing...
  @override
  void initState() {
    super.initState();
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 2), () {
        //speaking text
        AppTextToSpeech.replyText = "Food Category";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing timers
    timer = RestartableTimer(const Duration(seconds: 0), () => {});
    timerCont = Timer(const Duration(seconds: 0), () => {});
    _timerNew = Timer(const Duration(seconds: 0), () => {});
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
    //storing the speech to text provider to be used on this screen
    speechProvider = Provider.of<SpeechToTextProvider>(context);
    //if not already loaded data then load data now from database
    if (_isInit) {
      String foodCategoryID;
      if ((ModalRoute.of(context)?.settings.arguments) != null) {
        foodCategoryID = ModalRoute.of(context)?.settings.arguments as String;
        //check if have a product before proceeding
        /*if (_editedCategory.title == 'newID' ||
            _editedCategory.title.isEmpty ||
            _editedCategory.title == '' ||
            _editedCategory.title == 'null') {*/
        //if(foodCategoryID!='null' && foodCategoryID!='newID' && foodCategoryID.isNotEmpty && foodCategoryID!='') {
          _editedCategory = Provider.of<FoodsMenu>(context, listen: false)
              .findCategoryById(foodCategoryID);
          //values that will be edited so filled into the text boxes but all these have to be string
          _initValues = {
            'title': _editedCategory.title,
            //'itemsInCategory' : _editedCategory.itemsInCategory.toString(),
          };
        /*}else{
          _initValues = {
            'title': '',
            //'itemsInCategory' : _editedCategory.itemsInCategory.toString(),
          };
        }*/
        _categoryTitleController.text = _initValues['title'].toString();
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }
  //after leaving the screen, disposes of any active elements on the screen
  @override
  void dispose() {
    super.dispose();
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
    //log('speechListen() in edit category RAN');
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
    String actionCommand = EditCategoryCommandProcess.handleSpokenWords(text);
    //log('received back command: $actionCommand');
    if (actionCommand == 'back') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
        speechProvider.cancel();
      });
      Navigator.pushReplacementNamed(context, ManageMenuScreen.routeName);
    } else if (actionCommand == 'save') {
      _saveForm();
    } else if (actionCommand == 'title') {
      _categoryTitleController.text = '';
      FocusScope.of(context).requestFocus(_categoryTitle);
      Future.delayed(const Duration(milliseconds: 1), () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });
      //SystemChannels.textInput.invokeMethod('TextInput.hide');
    } else if (_categoryTitle.hasFocus &&
        _categoryTitleController.text.isEmpty) {
      _categoryTitleController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'title input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear title') {
      //clear title
      _categoryTitleController.text = '';
      AppTextToSpeech.replyText = 'title cleared';
      FocusScope.of(context).requestFocus(_categoryTitle);
      //SystemChannels.textInput.invokeMethod('TextInput.hide');
      Future.delayed(const Duration(milliseconds: 1), () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      });
    } else if (actionCommand == 'home') {
      //take to home screen
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, BusinessScreen.routeName);
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
    //log('checkAuto() in edit category screen RAN');
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
  //speak the current screen elements
  void speakCurrentScreen() {
    //log('speakCurrentScreen() RAN in edit category screen');
    AppTextToSpeech.replyText = 'Add or Edit Category Screen';
    AppTextToSpeech.speak();
    Future.delayed(const Duration(seconds: 3), () async {
      String speak;
      //log('title now is: ${_editedCategory.title}');
      if (_editedCategory.title == 'newID' ||
          _editedCategory.title.isEmpty ||
          _editedCategory.title == '' ||
          _editedCategory.title == 'null') {
        speak =
            'you can add new category with a title! say save when done, or ask me to go back';
      } else {
        speak =
            'you can edit category title of, ${_editedCategory.title}, say save when done, or ask me to go back';
      }
      //AppTextToSpeech.speak();
      await AppTextToSpeech.flutterTts.speak(speak);
    }).then((value) => Future.delayed(const Duration(seconds: 5), () {
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
        }));
  }
  //save form if valid
  Future<void> _saveForm() async {
    //check if valid
    final isValid = _formCategory.currentState?.validate();
    //if invalid then don't proceed
    if (!isValid!) {
      return;
    }
    //if valid save form
    _formCategory.currentState?.save();
    setState(() {
      _isItLoading = true;
    });
    //check and update existing or add new
    if (_editedCategory.id != 'newID') {
      //debugPrint('updating existing product');
      //category exists so update it
      //Provider.of<FoodsMenu>(context, listen: false)
      await Provider.of<FoodsMenu>(context, listen: false)
          .updateFoodCategory(_editedCategory.id, _editedCategory);
      AppTextToSpeech.replyText='Updated';
    } else {
      //debugPrint('adding product');
      try {
        //otherwise adding a new Category
        await Provider.of<FoodsMenu>(context, listen: false)
            .addFoodCategory(_editedCategory);
        AppTextToSpeech.replyText='added';
      } catch (error) {
        AppTextToSpeech.replyText='error while saving';
        await showDialog(
            context: context,
            builder: (context) {
              Future.delayed(const Duration(seconds: 5), () {
                Navigator.pushReplacementNamed(
                    context, ManageMenuScreen.routeName);
              });
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const AlertDialog(
                    title: Text('An Error Occurred:'),
                    content: Text(
                        'Something went wrong while saving please try again!'),
                  ),
                  //const LinearProgressIndicator(),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(seconds: 5),
                    builder: (context, value, _) =>
                        //CircularProgressIndicator(value: value),
                        LinearProgressIndicator(
                      value: value,
                    ),
                  ),
                ],
              );
            });
      }
    }
    setState(() {
      _isItLoading = false;
    });
    AppTextToSpeech.speak();
    Future.delayed(const Duration(seconds: 1), (){
      Navigator.pushReplacementNamed(context, ManageMenuScreen.routeName);
    });
  }
  //Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category'),
        actions: [IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))],
      ),
      body: _isItLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              //Creates a container for form fields
              child: Form(
                  //assigning form key
                  key: _formCategory,
                  //Creates a scrollable, linear array of widgets from an explicit List
                  child: ListView(
                    children: [
                      //connected with FORM
                      TextFormField(
                        focusNode: _categoryTitle,
                        controller: _categoryTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                        onSaved: (value) {
                          _editedCategory = FoodCategoryProvider(
                            id: _editedCategory.id,
                            title: value.toString().trim(),
                            itemsInCategory: _editedCategory.itemsInCategory,
                          );
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            AppTextToSpeech.stop();
                            AppTextToSpeech.replyText =
                            'Title cannot be empty!';
                            AppTextToSpeech.speak();
                            return 'Title cannot be empty!';
                          }
                          return null;
                        },
                      ),
                    ],
                  )),
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
                      terms: EditCategoryScreenCommand.commandsEditCategory,
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
                  heroTag: "btnAutoEditCat",
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
                  heroTag: "btnMicEditCat",
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
                  onPressed: () {
                    setState(() {
                      AppTextToSpeech.replyText = '';
                      AppTextToSpeech.stop();
                      speechProvider.cancel();
                    });
                    Navigator.pushReplacementNamed(
                        context, ManageMenuScreen.routeName);
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
