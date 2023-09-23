import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../commands/edit_business_details_commands.dart';
import '../models/app_text_to_speech.dart';
import '../models/global_preferences.dart';
import '../providers/business_data_provider.dart';
import '../providers/business_details_provider.dart';
import '../screens/business_details_screen.dart';
import '../screens/business_screen.dart';

//edit business profile screen user interface
class EditBusinessDetailsScreen extends StatefulWidget {
  const EditBusinessDetailsScreen({Key? key}) : super(key: key);

  //for navigation reference between screens
  static const routeName = '/editBusinessDetailsScreen';

  @override
  State<EditBusinessDetailsScreen> createState() =>
      _EditBusinessDetailsScreenState();
}

class _EditBusinessDetailsScreenState extends State<EditBusinessDetailsScreen> {
  //global reference to the form widget on screen
  final _formBusinessDetails = GlobalKey<FormState>();

  //initialize business details
  var _editedBusinessDetails = BusinessData(
      id: 'newID',
      businessName: 'null',
      businessType: 'null',
      businessDoorNo: 'null',
      businessPostCode: 'null',
      deliveryOrCollection: 'null',
      openTimes: 'null',
      ownerID: '');

//initial business details
  var _initValues = {
    'businessName': '',
    'businessType': '',
    'businessDoorNo': '',
    'businessPostCode': '',
    'deliveryOrCollection': '',
    'openTimes': '',
  };

  //to check if its initialized
  var _isInit = true;

  //to store business Data ID
  var businessDataID = '';

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

  // ---- focus nodes for the name, type, door, post code, service, times text boxes on screen
  final FocusNode _businessName = FocusNode();
  final FocusNode _businessType = FocusNode();
  final FocusNode _businessDoorNo = FocusNode();
  final FocusNode _businessPostCode = FocusNode();
  final FocusNode _deliveryOrCollection = FocusNode();
  final FocusNode _openTimes = FocusNode();

  //-----------------
  // ---- text controllers for the name, type, door, post code, service, times text boxes on screen
  final _businessNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _businessDoorNoController = TextEditingController();
  final _businessPostCodController = TextEditingController();
  final _deliveryOrCollectionController = TextEditingController();
  final _openTimesController = TextEditingController();

  //-----------------
  //initializing...
  @override
  void initState() {
    super.initState();
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        //speaking text
        AppTextToSpeech.replyText = "Edit Profile";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing timers
    timer = RestartableTimer(const Duration(seconds: 0), () => {});
    timerCont = Timer(const Duration(seconds: 0), () => {});
    _timerNew = Timer(const Duration(seconds: 0), () => {});
    Future.delayed(const Duration(seconds: 3), () {
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
      if (mounted) {
        //update UI using set state
        setState(() {
          Provider.of<BusinessDetails>(context, listen: false)
              .fetchBusinessDetails('')
              .then((_) {
            setState(() {
              _editedBusinessDetails =
                  Provider.of<BusinessDetails>(context, listen: false)
                      .getBusinessDetails;
              //log('_editedBusinessDetails: ${_editedBusinessDetails.businessName}');
              _initValues = {
                'businessName': _editedBusinessDetails.businessName,
                'businessType': _editedBusinessDetails.businessType,
                'businessDoorNo': _editedBusinessDetails.businessDoorNo,
                'businessPostCode': _editedBusinessDetails.businessPostCode,
                'deliveryOrCollection':
                    _editedBusinessDetails.deliveryOrCollection,
                'openTimes': _editedBusinessDetails.openTimes,
              };
              //values that will be edited so filled into the text boxes but all these have to be string
              _businessNameController.text =
                  _initValues['businessName'].toString();
              _businessTypeController.text =
                  _initValues['businessType'].toString();
              _businessDoorNoController.text =
                  _initValues['businessDoorNo'].toString();
              _businessPostCodController.text =
                  _initValues['businessPostCode'].toString();
              _deliveryOrCollectionController.text =
                  _initValues['deliveryOrCollection'].toString();
              _openTimesController.text = _initValues['openTimes'].toString();
            });
          });
          //Provider.of<BusinessDetails>(context, listen: false);
        });
      }
    } else {
      debugPrint('error in new food ID');
    }
    _isInit = false;
    //super.didChangeDependencies();
  }

  //after leaving the screen, disposes of any active elements on the screen
  @override
  void dispose() {
    super.dispose();
    //log('disposing the edit business details screen');
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
    //make sure TTS is not speaking before listening
    AppTextToSpeech.replyText = '';
    AppTextToSpeech.speak();
    AppTextToSpeech.stop();
    //log('speechListen() in edit business details RAN');
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
        EditBusinessDetailsScreenCommandProcess.handleSpokenWords(text);
    //_recognizedText = '';
    //log('received back command: $actionCommand');
    if (actionCommand == 'back') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
        speechProvider.cancel();
      });
      Navigator.pushReplacementNamed(context, BusinessDetailsScreen.routeName);
    } else if (actionCommand == 'home') {
      //take to home screen
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      Navigator.pushReplacementNamed(context, BusinessScreen.routeName);
    } else if (actionCommand == 'save') {
      _saveForm();
    } else if (actionCommand == 'business name') {
      _businessNameController.text = '';
      fieldFocus(_businessName);
    } else if (_businessName.hasFocus && _businessNameController.text.isEmpty) {
      _businessNameController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'business name input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear name') {
      _businessNameController.text = '';
      fieldFocus(_businessName);
      AppTextToSpeech.replyText = 'business name cleared';
    } else if (actionCommand == 'business type') {
      _businessTypeController.text = '';
      fieldFocus(_businessType);
    } else if (_businessType.hasFocus && _businessTypeController.text.isEmpty) {
      _businessTypeController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'business type input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear type') {
      _businessTypeController.text = '';
      fieldFocus(_businessType);
      AppTextToSpeech.replyText = 'business type cleared';
    } else if (actionCommand == 'door') {
      _businessDoorNoController.text = '';
      fieldFocus(_businessDoorNo);
    } else if (_businessDoorNo.hasFocus &&
        _businessDoorNoController.text.isEmpty) {
      _businessDoorNoController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'door number input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear door') {
      _businessDoorNoController.text = '';
      fieldFocus(_businessDoorNo);
      AppTextToSpeech.replyText = 'door number cleared';
    } else if (actionCommand == 'post code') {
      _businessPostCodController.text = '';
      fieldFocus(_businessPostCode);
    } else if (_businessPostCode.hasFocus &&
        _businessPostCodController.text.isEmpty) {
      _businessPostCodController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'post code input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear postcode') {
      _businessPostCodController.text = '';
      fieldFocus(_businessPostCode);
      AppTextToSpeech.replyText = 'post code cleared';
    } else if (actionCommand == 'service') {
      _deliveryOrCollectionController.text = '';
      fieldFocus(_deliveryOrCollection);
    } else if (_deliveryOrCollection.hasFocus &&
        _deliveryOrCollectionController.text.isEmpty) {
      _deliveryOrCollectionController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'service input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear service') {
      _deliveryOrCollectionController.text = '';
      fieldFocus(_deliveryOrCollection);
      AppTextToSpeech.replyText = 'service cleared';
    } else if (actionCommand == 'times') {
      _openTimesController.text = '';
      fieldFocus(_openTimes);
    } else if (_openTimes.hasFocus && _openTimesController.text.isEmpty) {
      _openTimesController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'times input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear times') {
      _openTimesController.text = '';
      fieldFocus(_openTimes);
      AppTextToSpeech.replyText = 'times cleared';
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
    //debugPrint('Focus is set, keyboard should be hidden: ');
  }

  //check if the auto listener feature was disabled or still enabled
  void checkAuto() {
    //log('checkAuto() in edit business details screen RAN');
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
    //log('speakCurrentScreen() RAN in edit business details screen');
    AppTextToSpeech.replyText = 'Edit Profile Screen';
    AppTextToSpeech.speak();
    Future.delayed(const Duration(seconds: 2), () async {
      String speak;
      //log('title now is: ${_editedBusinessDetails.businessName}');
      if (_editedBusinessDetails.businessName == 'newID' ||
          _editedBusinessDetails.businessName.isEmpty ||
          _editedBusinessDetails.businessName == '' ||
          _editedBusinessDetails.businessName == 'null') {
        speak =
            'you can add your new profile, with a business name, type, door number, postcode, service, opening times, say save, when done, or ask me to go back';
      } else {
        speak =
            'you can edit business name which is, ${_editedBusinessDetails.businessName} , type which says ${_editedBusinessDetails.businessType}, door number which is,  ${_editedBusinessDetails.businessDoorNo}, postcode which is, ${_editedBusinessDetails.businessPostCode}, services is, ${_editedBusinessDetails.deliveryOrCollection}, and opening time is, ${_editedBusinessDetails.openTimes}, say save, when done, or ask me to go back';
      }
      //AppTextToSpeech.speak();
      await AppTextToSpeech.flutterTts.speak(speak);
    }).then((value) => Future.delayed(const Duration(seconds: 25), () {
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

  //to save current details if valid
  void _saveForm() {
    //check if all data is valid
    final isValid = _formBusinessDetails.currentState?.validate();
    //f not valid then don't proceed
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
    //save data
    _formBusinessDetails.currentState?.save();
    //check and update existing or add new
    if (_editedBusinessDetails.id != 'newID' &&
        _editedBusinessDetails.id.isNotEmpty) {
      //debugPrint('updating existing category item');
      //details exists so update it
      Provider.of<BusinessDetails>(context, listen: false)
          .updateBusinessDetails(
              _editedBusinessDetails.id, _editedBusinessDetails);
      AppTextToSpeech.replyText = 'updated';
    } else {
      /*debugPrint('adding new item in category, categoryID: ' +
          ' itemID:' +
          _editedBusinessDetails.toString());*/
      //otherwise adding a new details
      Provider.of<BusinessDetails>(context, listen: false)
          .addBusinessDetails(_editedBusinessDetails);
      AppTextToSpeech.replyText = 'added';
    }
    //Navigator.pushReplacementNamed(context, BusinessDetailsScreen.routeName);
    AppTextToSpeech.speak();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, BusinessDetailsScreen.routeName);
    });
  }

  //Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Business Profile'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            //assigning form key
            key: _formBusinessDetails,
            child: ListView(
              children: [
                //connected with FORM
                TextFormField(
                  focusNode: _businessName,
                  controller: _businessNameController,
                  decoration: const InputDecoration(
                    labelText: 'Business Name:',
                  ),
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText =
                          'Please provide a Business name.';
                      AppTextToSpeech.speak();
                      return 'Please provide a Business name.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('title of Business now: ${value.toString()}');
                    _editedBusinessDetails = BusinessData(
                      id: _editedBusinessDetails.id,
                      businessName: value.toString().trim(),
                      businessType: _editedBusinessDetails.businessType,
                      businessDoorNo: _editedBusinessDetails.businessDoorNo,
                      businessPostCode: _editedBusinessDetails.businessPostCode,
                      deliveryOrCollection:
                          _editedBusinessDetails.deliveryOrCollection,
                      openTimes: _editedBusinessDetails.openTimes,
                      ownerID: '',
                    );
                  },
                ),
                TextFormField(
                  focusNode: _businessType,
                  controller: _businessTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Business type:',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText =
                          'Please enter a Business type.';
                      AppTextToSpeech.speak();
                      return 'Please enter a Business type.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('type now: ${value.toString()}');
                    _editedBusinessDetails = BusinessData(
                      id: _editedBusinessDetails.id,
                      businessName: _editedBusinessDetails.businessName,
                      businessType: value.toString().trim(),
                      businessDoorNo: _editedBusinessDetails.businessDoorNo,
                      businessPostCode: _editedBusinessDetails.businessPostCode,
                      deliveryOrCollection:
                          _editedBusinessDetails.deliveryOrCollection,
                      openTimes: _editedBusinessDetails.openTimes,
                      ownerID: '',
                    );
                  },
                ),
                TextFormField(
                  focusNode: _businessDoorNo,
                  controller: _businessDoorNoController,
                  decoration: const InputDecoration(
                    labelText: 'Door No#:',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText = 'Please enter a door number.';
                      AppTextToSpeech.speak();
                      return 'Please enter a door number.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('door now: ${value.toString()}');
                    _editedBusinessDetails = BusinessData(
                      id: _editedBusinessDetails.id,
                      businessName: _editedBusinessDetails.businessName,
                      businessType: _editedBusinessDetails.businessType,
                      businessDoorNo: value.toString().trim(),
                      businessPostCode: _editedBusinessDetails.businessPostCode,
                      deliveryOrCollection:
                          _editedBusinessDetails.deliveryOrCollection,
                      openTimes: _editedBusinessDetails.openTimes,
                      ownerID: '',
                    );
                  },
                ),
                TextFormField(
                  focusNode: _businessPostCode,
                  controller: _businessPostCodController,
                  decoration: const InputDecoration(
                    labelText: 'Post-Code:',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText = 'Please enter a Post-Code.';
                      AppTextToSpeech.speak();
                      return 'Please enter a Post-Code.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('post code now: ${value.toString()}');
                    _editedBusinessDetails = BusinessData(
                      id: _editedBusinessDetails.id,
                      businessName: _editedBusinessDetails.businessName,
                      businessType: _editedBusinessDetails.businessType,
                      businessDoorNo: _editedBusinessDetails.businessDoorNo,
                      businessPostCode: value.toString().trim(),
                      deliveryOrCollection:
                          _editedBusinessDetails.deliveryOrCollection,
                      openTimes: _editedBusinessDetails.openTimes,
                      ownerID: '',
                    );
                  },
                ),
                TextFormField(
                  focusNode: _deliveryOrCollection,
                  controller: _deliveryOrCollectionController,
                  decoration: const InputDecoration(
                    labelText: 'Service:',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText = 'Please enter a service.';
                      AppTextToSpeech.speak();
                      return 'Please enter a service.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('service now: ${value.toString()}');
                    _editedBusinessDetails = BusinessData(
                      id: _editedBusinessDetails.id,
                      businessName: _editedBusinessDetails.businessName,
                      businessType: _editedBusinessDetails.businessType,
                      businessDoorNo: _editedBusinessDetails.businessDoorNo,
                      businessPostCode: _editedBusinessDetails.businessPostCode,
                      deliveryOrCollection: value.toString().trim(),
                      openTimes: _editedBusinessDetails.openTimes,
                      ownerID: '',
                    );
                  },
                ),
                TextFormField(
                  focusNode: _openTimes,
                  controller: _openTimesController,
                  decoration: const InputDecoration(
                    labelText: 'Opening Times:',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText = 'Please enter opening times';
                      AppTextToSpeech.speak();
                      return 'Please enter opening times';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('times now: ${value.toString()}');
                    _editedBusinessDetails = BusinessData(
                      id: _editedBusinessDetails.id,
                      businessName: _editedBusinessDetails.businessName,
                      businessType: _editedBusinessDetails.businessType,
                      businessDoorNo: _editedBusinessDetails.businessDoorNo,
                      businessPostCode: _editedBusinessDetails.businessPostCode,
                      deliveryOrCollection:
                          _editedBusinessDetails.deliveryOrCollection,
                      ownerID: '',
                      openTimes: value.toString().trim(),
                    );
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
                      terms: EditBusinessDetailsScreenCommand
                          .commandsEditBusinessDetailsScreen,
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
                  heroTag: "btnAutoEditBProfile",
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
                  heroTag: "btnMicEditBProfile",
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
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.pushReplacementNamed(
                          context, BusinessDetailsScreen.routeName);
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
