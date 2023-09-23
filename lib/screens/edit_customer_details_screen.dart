import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

import '../commands/edit_customer_details_screen_commands.dart';
import '../models/app_text_to_speech.dart';
import '../models/global_preferences.dart';
import '../providers/customer_data_provider.dart';
import '../providers/customer_details_provider.dart';
import '../screens/customer_details_screen.dart';

//edit customer profile screen user interface
class EditCustomerDetailsScreen extends StatefulWidget {
  const EditCustomerDetailsScreen({Key? key}) : super(key: key);
  //for navigation reference between screens
  static const routeName = '/editCustomerDetailsScreen';

  @override
  State<EditCustomerDetailsScreen> createState() =>
      _EditCustomerDetailsScreenState();
}

class _EditCustomerDetailsScreenState extends State<EditCustomerDetailsScreen> {
  //to access the form outside widgets
  final _formCustomerDetails = GlobalKey<FormState>();

  //default customer details
  var _editedCustomerDetails = CustomerData(
    id: 'newID',
    customerFirstName: 'null',
    customerLastName: 'null',
    customerDoorNo: 'null',
    customerPostCode: 'null',
    phoneNumber: 'null',
    userID: 'null',
  );

//initial customer details
  var _initValues = {
    'fName': '',
    'lName': '',
    'customerDoorNo': '',
    'customerPostCode': '',
    'phoneNumber': '',
  };
  //to check if its initialized
  var _isInit = true;
  //to store customer data ID
  var customerDataID = '';
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
  // ------ focus nodes for first name, last name, door, post code, and phone number text boxes
  final FocusNode _customerFName = FocusNode();
  final FocusNode _customerLName = FocusNode();
  final FocusNode _customerDoorNo = FocusNode();
  final FocusNode _customerPostCode = FocusNode();
  final FocusNode _phoneNumber = FocusNode();
  //----------------
  // ------ text controllers for first name, last name, door, post code, and phone number text boxes
  final _customerFNameController = TextEditingController();
  final _customerLNameController = TextEditingController();
  final _customerDoorNoController = TextEditingController();
  final _customerPostCodeController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  //----------------
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
      if (mounted) {
        //update UI using set state
        setState(() {
          Provider.of<CustomerDetails>(context, listen: false)
              .fetchCustomerDetails()
              .then((_) {
            setState(() {
              _editedCustomerDetails =
                  Provider.of<CustomerDetails>(context, listen: false)
                      .getCustomerDetails;
              _initValues = {
                'fName': _editedCustomerDetails.customerFirstName,
                'lName': _editedCustomerDetails.customerLastName,
                'customerDoorNo': _editedCustomerDetails.customerDoorNo,
                'customerPostCode': _editedCustomerDetails.customerPostCode,
                'phoneNumber': _editedCustomerDetails.phoneNumber,
              };
              _customerFNameController.text = _initValues['fName'].toString();
              _customerLNameController.text = _initValues['lName'].toString();
              _customerDoorNoController.text =
                  _initValues['customerDoorNo'].toString();
              _customerPostCodeController.text =
                  _initValues['customerPostCode'].toString();
              _phoneNumberController.text =
                  _initValues['phoneNumber'].toString();
            });
          });
        });
      }
      //values that will be edited so filled into the text boxes but all these have to be string
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
    //log('disposing the edit customer details screen');
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
    //log('speechListen() in edit customer details RAN');
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
        EditCustomerDetailsScreenCommandProcess.handleSpokenWords(text);
    //_recognizedText = '';
    //log('received back command: $actionCommand');
    if (actionCommand == 'back') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
        speechProvider.cancel();
      });
      Navigator.pushReplacementNamed(context, CustomerDetailsScreen.routeName);
    } else if (actionCommand == 'save') {
      _saveForm();
    } else if (actionCommand == 'firstName') {
      _customerFNameController.text = '';
      fieldFocus(_customerFName);
    } else if (_customerFName.hasFocus &&
        _customerFNameController.text.isEmpty) {
      _customerFNameController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'first name input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear firstName') {
      _customerFNameController.text = '';
      fieldFocus(_customerFName);
      AppTextToSpeech.replyText = 'first name cleared';
    } else if (actionCommand == 'lastName') {
      _customerLNameController.text = '';
      fieldFocus(_customerLName);
    } else if (_customerLName.hasFocus &&
        _customerLNameController.text.isEmpty) {
      _customerLNameController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'last name input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear lastName') {
      _customerLNameController.text = '';
      fieldFocus(_customerLName);
      AppTextToSpeech.replyText = 'last name cleared';
    } else if (actionCommand == 'door') {
      _customerDoorNoController.text = '';
      fieldFocus(_customerDoorNo);
    } else if (_customerDoorNo.hasFocus &&
        _customerDoorNoController.text.isEmpty) {
      _customerDoorNoController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'door number input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear door') {
      _customerDoorNoController.text = '';
      fieldFocus(_customerDoorNo);
      AppTextToSpeech.replyText = 'door number cleared';
    } else if (actionCommand == 'post code') {
      _customerPostCodeController.text = '';
      fieldFocus(_customerPostCode);
    } else if (_customerPostCode.hasFocus &&
        _customerPostCodeController.text.isEmpty) {
      _customerPostCodeController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'post code input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear postcode') {
      _customerPostCodeController.text = '';
      fieldFocus(_customerPostCode);
      AppTextToSpeech.replyText = 'post code cleared';
    } else if (actionCommand == 'phone number') {
      _phoneNumberController.text = '';
      fieldFocus(_phoneNumber);
    } else if (_phoneNumber.hasFocus && _phoneNumberController.text.isEmpty) {
      _phoneNumberController.text = _recognizedText.trim();
      AppTextToSpeech.replyText = 'phone number input successfully';
      FocusScope.of(context).unfocus();
    } else if (actionCommand == 'clear phone number') {
      _phoneNumberController.text = '';
      fieldFocus(_phoneNumber);
      AppTextToSpeech.replyText = 'phone number cleared';
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
    //log('checkAuto() in edit customer details screen RAN');
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
  //speak the current screen elements
  void speakCurrentScreen() {
    //log('speakCurrentScreen() RAN in edit customer details screen');
    AppTextToSpeech.replyText = 'Edit Profile Screen';
    AppTextToSpeech.speak();
    Future.delayed(const Duration(seconds: 2), () async {
      String speak;
      //log('title now is: ${_editedCustomerDetails.id}');
      if (_editedCustomerDetails.id == 'newID' ||
          _editedCustomerDetails.id.isEmpty ||
          _editedCustomerDetails.id == '' ||
          _editedCustomerDetails.id == 'null') {
        speak =
            'you can add your new profile, with a name, last name, door number, postcode, and phone number, now, you can say save when done, or ask me to repeat or go back';
      } else {
        speak =
            'you can edit your first name which is, ${_editedCustomerDetails.customerFirstName} , last name which is ${_editedCustomerDetails.customerLastName}, door number which is,  ${_editedCustomerDetails.customerDoorNo}, postcode which is, ${_editedCustomerDetails.customerPostCode}, phone number is, ${_editedCustomerDetails.phoneNumber}, now, you can say save when done, or ask me to go back';
      }
      //AppTextToSpeech.speak();
      await AppTextToSpeech.flutterTts.speak(speak);
    }).then((value) => Future.delayed(const Duration(seconds: 25), () {
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
  void _saveForm() {
    //check if valid
    final isValid = _formCustomerDetails.currentState?.validate();
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
    _formCustomerDetails.currentState?.save();
    //check and update existing or add new
    if (_editedCustomerDetails.id != 'newID' &&
        _editedCustomerDetails.id.isNotEmpty) {
      //('updating existing category item');
      //details exists so update it
      Provider.of<CustomerDetails>(context, listen: false)
          .updateCustomerDetails(
              _editedCustomerDetails.id, _editedCustomerDetails);
    } else {
      //otherwise adding a new details
      Provider.of<CustomerDetails>(context, listen: false)
          .addCustomerDetails(_editedCustomerDetails);
    }
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, CustomerDetailsScreen.routeName);
    });
  }
  //Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Customer Profile'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        //Creates a container for form fields
        child: Form(
            //assigning form key
            key: _formCustomerDetails,
            child: ListView(
              //Creates a scrollable, linear array of widgets from an explicit List
              children: [
                //connected with FORM
                TextFormField(
                  focusNode: _customerFName,
                  controller: _customerFNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name:',
                  ),
                  validator: (value) {
                    if (value.toString().isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText =
                      'Please provide your first name.';
                      AppTextToSpeech.speak();
                      return 'Please provide your first name.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('title of f name now: ${value.toString()}');
                    _editedCustomerDetails = CustomerData(
                      id: _editedCustomerDetails.id,
                      customerFirstName: value.toString().trim(),
                      customerLastName: _editedCustomerDetails.customerLastName,
                      customerDoorNo: _editedCustomerDetails.customerDoorNo,
                      customerPostCode: _editedCustomerDetails.customerPostCode,
                      phoneNumber: _editedCustomerDetails.phoneNumber,
                      userID: '',
                    );
                  },
                ),
                TextFormField(
                  focusNode: _customerLName,
                  controller: _customerLNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name:',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText =
                      'Please provide your last name.';
                      AppTextToSpeech.speak();
                      return 'Please provide your last name.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    debugPrint('type now: ${value.toString()}');
                    _editedCustomerDetails = CustomerData(
                      id: _editedCustomerDetails.id,
                      customerFirstName: _editedCustomerDetails.customerFirstName,
                      customerLastName: value.toString().trim(),
                      customerDoorNo: _editedCustomerDetails.customerDoorNo,
                      customerPostCode: _editedCustomerDetails.customerPostCode,
                      phoneNumber: _editedCustomerDetails.phoneNumber,
                      userID: '',
                    );
                  },
                ),
                TextFormField(
                  focusNode: _customerDoorNo,
                  controller: _customerDoorNoController,
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
                    _editedCustomerDetails = CustomerData(
                      id: _editedCustomerDetails.id,
                      customerFirstName: _editedCustomerDetails.customerFirstName,
                      customerLastName: _editedCustomerDetails.customerLastName,
                      customerDoorNo: value.toString(),
                      customerPostCode: _editedCustomerDetails.customerPostCode,
                      phoneNumber: _editedCustomerDetails.phoneNumber,
                      userID: '',
                    );
                  },
                ),
                TextFormField(
                  focusNode: _customerPostCode,
                  controller: _customerPostCodeController,
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
                    _editedCustomerDetails = CustomerData(
                      id: _editedCustomerDetails.id,
                      customerFirstName: _editedCustomerDetails.customerFirstName,
                      customerLastName: _editedCustomerDetails.customerLastName,
                      customerDoorNo: _editedCustomerDetails.customerDoorNo,
                      customerPostCode: value.toString().trim(),
                      phoneNumber: _editedCustomerDetails.phoneNumber,
                      userID: '',
                    );
                  },
                ),
                TextFormField(
                  focusNode: _phoneNumber,
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Phone:',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      AppTextToSpeech.stop();
                      AppTextToSpeech.replyText = 'Please enter a Phone number.';
                      AppTextToSpeech.speak();
                      return 'Please enter a phone number.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    //debugPrint('phone now: ${value.toString()}');
                    _editedCustomerDetails = CustomerData(
                      id: _editedCustomerDetails.id,
                      customerFirstName: _editedCustomerDetails.customerFirstName,
                      customerLastName: _editedCustomerDetails.customerLastName,
                      customerDoorNo: _editedCustomerDetails.customerDoorNo,
                      customerPostCode: _editedCustomerDetails.customerPostCode,
                      phoneNumber: value.toString().trim(),
                      userID: '',
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
                      terms: EditCustomerDetailsScreenCommand
                          .commandsEditCustomerDetailsScreen,
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
                  heroTag: "btnAutoEditCProfile",
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
                  heroTag: "btnMicEditCProfile",
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
                          context, CustomerDetailsScreen.routeName);
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
