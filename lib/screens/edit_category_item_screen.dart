import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/commands/edit_category_item_screen_commands.dart';
import 'package:fyp/screens/manage_category_item_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../models/app_text_to_speech.dart';
import '../models/global_preferences.dart';
import '../providers/foods_menu_provider.dart';
import '../providers/category_item_provider.dart';
import '../screens/business_screen.dart';

//Edit category item screen user interface
class EditCategoryItemScreen extends StatefulWidget {
  const EditCategoryItemScreen({Key? key}) : super(key: key);

  //for navigation reference between screens
  static const routeName = '/editCategoryItemScreen';

  @override
  State<EditCategoryItemScreen> createState() => _EditCategoryItemScreenState();
}

class _EditCategoryItemScreenState extends State<EditCategoryItemScreen> {
  //global reference to the form widget on screen
  final _formCatgryItem = GlobalKey<FormState>();

  //default category item
  var _editedCategoryItem =
      CategoryItemProvider(id: 'newID', categoryItemTitle: '', categoryItemDescription: '', categoryItemPrice: 0);

  //initialized values
  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
  };

  //to check if its initialized
  var _isInit = true;

  //to store food category ID
  var foodCategoryID = '';

  //to store item ID of the food category
  var foodCategoryItemID = '';

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

  // ----- focus nodes for title, description and price text boxes
  final FocusNode _itemTitle = FocusNode();
  final FocusNode _itemDescription = FocusNode();
  final FocusNode _itemPrice = FocusNode();

  // ----------
  // ----- text controllers for title, description and price text boxes
  final _itemTitleController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _itemPriceController = TextEditingController();

  // ----------
  //initializing...
  @override
  void initState() {
    super.initState();
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2), () {
        //speaking text
        AppTextToSpeech.replyText = "Add or Edit item";
        AppTextToSpeech.speak();
      });
    });*/
    //listening always to the user
    //initializing timers
    timer = RestartableTimer(const Duration(seconds: 0), () => {});
    timerCont = Timer(const Duration(seconds: 0), () => {});
    _timerNew = Timer(const Duration(seconds: 0), () => {});
    Future.delayed(const Duration(seconds: 2), () {
      speakCurrentScreen();
    });
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
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;
      //editing a category item
      if (arguments['categoryID'] != null &&
          arguments['categoryItemID'] != 'newID') {
        foodCategoryID = arguments['categoryID'];
        this.foodCategoryID = foodCategoryID;
        foodCategoryItemID = arguments['categoryItemID'];
        /*debugPrint('categoryID: ' +
            foodCategoryID +
            ' categoryItemID: ' +
            foodCategoryItemID);*/
        /*_editedCategoryItem = Provider.of<FoodsMenu>(context, listen: false)
            .findById(foodCategoryID)
            .itemsInCategory[foodCategoryItemID];*/
        _editedCategoryItem = Provider.of<FoodsMenu>(context, listen: false)
            .findItemById(foodCategoryID, foodCategoryItemID);
        /*debugPrint('item being modified id: ${_editedCategoryItem.id}');
        debugPrint('item being modified title: ${_editedCategoryItem.title}');
        debugPrint('item being modified description: ${_editedCategoryItem.description}');
        debugPrint('item being modified price: ${_editedCategoryItem.price}');*/
        //values that will be edited so filled into the text boxes but all these have to be string
        _initValues = {
          'title': _editedCategoryItem.categoryItemTitle,
          'description': _editedCategoryItem.categoryItemDescription,
          'price': _editedCategoryItem.categoryItemPrice.toString(),
        };
        _itemTitleController.text = _initValues['title'].toString();
        _itemDescriptionController.text = _initValues['description'].toString();
        _itemPriceController.text = _initValues['price'].toString();
      }
      //otherwise add a new category item
      else if (arguments['categoryItemID'] == 'newID') {
        foodCategoryID = arguments['categoryID'];
      } else {
        debugPrint('error in new food ID');
      }
    }
    _isInit = false;
    //super.didChangeDependencies();
  }

  //after leaving the screen, disposes of any active elements on the screen
  @override
  void dispose() {
    super.dispose();
    //log('disposing the edit category item screen');
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
    AppTextToSpeech.replyText='';
    AppTextToSpeech.speak();
    AppTextToSpeech.stop();
    //log('speechListen() in edit category item RAN');
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
        EditCategoryItemsCommandProcess.handleSpokenWords(text);
    //log('received back command: $actionCommand');
    if (actionCommand == 'back') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
        speechProvider.cancel();
      });
      Navigator.pushReplacementNamed(
          context, ManageCategoryItemScreen.routeName,
          arguments: foodCategoryID);
    } else if (actionCommand == 'save') {
      Future.delayed(const Duration(seconds: 1), () {
        _saveForm();
      });
    } else if (actionCommand == 'title') {
      _itemTitleController.text = '';
      fieldFocus(_itemTitle);
    } else if (_itemTitle.hasFocus && _itemTitleController.text.isEmpty) {
      _itemTitleController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'title input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear title') {
      //clear title
      _itemTitleController.text = '';
      fieldFocus(_itemTitle);
      AppTextToSpeech.replyText = 'title cleared';
    } else if (actionCommand == 'description') {
      _itemDescriptionController.text = '';
      fieldFocus(_itemDescription);
    } else if (_itemDescription.hasFocus &&
        _itemDescriptionController.text.isEmpty) {
      _itemDescriptionController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'description input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear description') {
      //clear DESCRIPTION
      _itemDescriptionController.text = '';
      fieldFocus(_itemDescription);
      AppTextToSpeech.replyText = 'description cleared';
    } else if (actionCommand == 'price') {
      _itemPriceController.text = '';
      fieldFocus(_itemPrice);
    } else if (_itemPrice.hasFocus && _itemPriceController.text.isEmpty) {
      _itemPriceController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'price input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear price') {
      //clear PRICE
      _itemPriceController.text = '';
      fieldFocus(_itemPrice);
      AppTextToSpeech.replyText = 'price cleared';
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

  //just focusing on the field and hiding keyboard
  void fieldFocus(FocusNode toFocusOn) {
    FocusScope.of(context).requestFocus(toFocusOn);
    Future.delayed(const Duration(milliseconds: 1), () {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
    //debugPrint('Focus is set, keyboard should be hidden: $hide');
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
    //log('speakCurrentScreen() RAN in edit category item screen');
    AppTextToSpeech.replyText = 'Add or Edit Item Screen';
    AppTextToSpeech.speak();
    Future.delayed(const Duration(seconds: 3), () async {
      String speak;
      //log('title now is: ${_editedCategoryItem.title}');
      if (_editedCategoryItem.categoryItemTitle == 'newID' ||
          _editedCategoryItem.categoryItemTitle.isEmpty ||
          _editedCategoryItem.categoryItemTitle == '' ||
          _editedCategoryItem.categoryItemTitle == 'null') {
        speak =
            'you can add new item with a title, description and a price!, say save, when done, or ask me to go back ';
      } else {
        speak =
            'you can edit title, ${_editedCategoryItem.categoryItemTitle} , description, ${_editedCategoryItem.categoryItemDescription}, and price,  ${_editedCategoryItem.categoryItemPrice}, say save, when done, or ask me to go back';
      }
      //AppTextToSpeech.speak();
      await AppTextToSpeech.flutterTts.speak(speak);
    }).then((value) => Future.delayed(const Duration(seconds: 10), () {
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
        }));
  }
  //save form if valid
  void _saveForm() {
    //debugPrint(foodCategoryID.toString());
    //check if valid
    final isValid = _formCatgryItem.currentState?.validate();
    //if invalid then don't proceed
    if (!isValid!) {
      return;
    }
    /*debugPrint(isValid.toString());
    if (isValid.toString()=='null' || isValid.toString()=='false') {
      return;
    }
    else{
      debugPrint('valid check is NULL');
    }*/
    //if valid save form
    _formCatgryItem.currentState?.save();
    //check and update existing or add new
    if (_editedCategoryItem.id != 'newID') {
      //debugPrint('updating existing category item');
      //category exists so update it
      Provider.of<FoodsMenu>(context, listen: false).updateFoodCategoryItem(
          foodCategoryID, _editedCategoryItem.id, _editedCategoryItem);
      AppTextToSpeech.replyText = 'updated';
    } else {
      //debugPrint(
          //'adding new item in category, categoryID: $foodCategoryID itemID:$_editedCategoryItem');
      //otherwise adding a new Category
      Provider.of<FoodsMenu>(context, listen: false)
          .addFoodItemCategory(foodCategoryID, _editedCategoryItem);
      AppTextToSpeech.replyText = 'added';
    }
    AppTextToSpeech.speak();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(
          context, ManageCategoryItemScreen.routeName,
          arguments: foodCategoryID);
    });
    /*debugPrint(_editedCategory.title);
    debugPrint(_editedCategory.id);
    debugPrint(_editedCategory.itemsInCategory.toString());*/
    /*}
    else{
      debugPrint('valid check is NULL');
    }*/
  }
  //Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit Item'),
        actions: [IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            //assigning form key
            key: _formCatgryItem,
            child: ListView(
              children: [
                //connected with FORM
                TextFormField(
                  focusNode: _itemTitle,
                  controller: _itemTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                  ),
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText =
                      'Please provide a title.';
                      AppTextToSpeech.speak();
                      return 'Please provide a title.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('title of item now: ${value.toString()}');
                    _editedCategoryItem = CategoryItemProvider(
                        id: _editedCategoryItem.id,
                        categoryItemTitle: value.toString().trim(),
                        categoryItemDescription: _editedCategoryItem.categoryItemDescription,
                        categoryItemPrice: _editedCategoryItem.categoryItemPrice);
                  },
                ),
                TextFormField(
                  focusNode: _itemDescription,
                  controller: _itemDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Item Description',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText =
                      'Please enter a description.';
                      AppTextToSpeech.speak();
                      return 'Please enter a description.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('description now: ${value.toString()}');
                    _editedCategoryItem = CategoryItemProvider(
                        id: _editedCategoryItem.id,
                        categoryItemTitle: _editedCategoryItem.categoryItemTitle,
                        categoryItemDescription: value.toString().trim(),
                        categoryItemPrice: _editedCategoryItem.categoryItemPrice);
                  },
                ),
                TextFormField(
                  focusNode: _itemPrice,
                  controller: _itemPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText =
                      'Please enter a price.';
                      AppTextToSpeech.speak();
                      return 'Please enter a price.';
                    }
                    if (double.tryParse(value.toString()) == null) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText =
                      'Please enter a valid price.';
                      AppTextToSpeech.speak();
                      return 'Please enter a valid price.';
                    }
                    if (double.parse(value.toString()) <= 0) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText =
                      'Please enter a number greater than zero.';
                      AppTextToSpeech.speak();
                      return 'Please enter a number greater than zero.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('price now: ${value.toString()}');
                    _editedCategoryItem = CategoryItemProvider(
                        id: _editedCategoryItem.id,
                        categoryItemTitle: _editedCategoryItem.categoryItemTitle,
                        categoryItemDescription: _editedCategoryItem.categoryItemDescription,
                        categoryItemPrice: double.parse(value.toString().trim()));
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
                      terms: EditCategoryItemsScreenCommand
                          .commandsEditCategoryItems,
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
                  heroTag: "btnAutoCatItem",
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
                  heroTag: "btnMicCatItem",
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
                        context, ManageCategoryItemScreen.routeName,
                        arguments: foodCategoryID);
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
