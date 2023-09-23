import 'dart:async';
import 'package:async/async.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/models/encrypt_data.dart';
import 'package:fyp/models/global_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:provider/provider.dart';

import '../models/app_exceptions.dart';
import '../models/app_text_to_speech.dart';
import '../providers/authentication_provider.dart';
import '../commands/authentication_commands.dart';

//enumeration with two predefined constants
enum RegisterOrLogin { signup, login }

//authentication screen user interface
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  //for navigation reference between screens
  static const routeName = '/authentication';

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  //to store the timer that check for the auto listener feature
  late Timer _timerCont;

  //timer that runs the method to listen to user speech
  late RestartableTimer _timer;

  //for auto listener feature which is set to true or false based on the user choice
  late bool _autoRecord;

  //unique key to identify form widget
  final GlobalKey<FormState> _keyForm = GlobalKey();

  //enum, default is shown as login
  RegisterOrLogin _regOrLog = RegisterOrLogin.login;

  //map with default values, that will be updated by the email, and password fields
  final Map<String, String> _regLogData = {
    'email': '',
    'password': '',
  };

  //storing the user role
  int _userRole = 3;

  //to be used in to show loading on screen
  var _isItLoading = false;

  //password text box controller
  final _passwordController = TextEditingController();

  //confirm password text box controller
  final _cnfPassController = TextEditingController();

  //email text box controller
  final _emailController = TextEditingController();

  //focus nodes for email, password and confirm password  ----- *
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();
  final FocusNode _cnfPassFocus = FocusNode();

  //  ----- *
  //to store text recognized by the speech to text
  String _recognizedText = '';

  //speech to text provider to control the speech recognition
  late SpeechToTextProvider _speechProvider;

  //returns the user role
  int get getToggle {
    return _userRole;
  }

  //to be used in to show the count down timer
  int _startingIn = 0;

  //to control the slider value
  late double _sliderVal;

  //the countdown timer that will be shown on the screen before listening
  late Timer _timerNew;

  //initializing...
  @override
  void initState() {
    super.initState();
    //for auto filling data at login, read the storage
    _readSecureStorage();
    //stop any text to speech activity
    AppTextToSpeech.stop();
    //speechToTextProvider = Provider.of<SpeechToTextProvider>(context);
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      //delay of one second
      Future.delayed(const Duration(milliseconds: 1000), () {
        //speaking text
        AppTextToSpeech.replyText = "Welcome";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing timers
    _timer = RestartableTimer(const Duration(seconds: 1), () => {});
    _timerCont = Timer(const Duration(seconds: 1), () => {});
    _timerNew = Timer(const Duration(seconds: 1), () => {});
    /*Future.delayed(const Duration(seconds: 5), () {
      speakCurrentScreen();
    });*/
    //default auto record
    _autoRecord = true;
    //check for any stored user preferences
    setUserPreferences();
  }

  //Called when a dependency of this State object changes, called after initState
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //storing the speech to text provider to be used on this screen
    _speechProvider = Provider.of<SpeechToTextProvider>(context);
  }

  //after leaving the screen, disposes of any active elements on the screen
  @override
  void dispose() {
    super.dispose();
    //log('disposing the authentication screen');
    //also stop listening and speaking when leaving the screen
    AppTextToSpeech.replyText = '';
    //AppTextToSpeech.speak;
    AppTextToSpeech.stop();
    //AppTextToSpeech.flutterTts.stop();
    //stopping the auto mic listener after leaving this screen
    //cancelling all the timers running on this screen
    _timer.cancel();
    _timerCont.cancel();
    _timerNew.cancel();
  }

  //read the data stored on device for auto filling on the login screen
  Future<void> _readSecureStorage() async {
    //log('_readSecureStorage');
    //instance of shared preferences
    final secureStorage = await SharedPreferences.getInstance();
    //fill email box
    _emailController.text = secureStorage.getString('email') ?? '';
    //get the encrypted password
    String encryptedPass = secureStorage.getString('password') ?? '';
    //log('encrypted pass : ${secureStorage.getString('password')}');
    //decrypting password and filling the password box
    if (encryptedPass != '') {
      await AesEncryption.decryptAES(encryptedPass);
      _passwordController.text = await AesEncryption.decrypted;
    }
    //getting and setting the user role
    int newUserRole = secureStorage.getInt('role') ?? 3;
    //log('newUserRole: $newUserRole');
    setState(() {
      _userRole = newUserRole;
      //log('user role from secure database: $userRole');
    });
    //making sure that all the data exists before attempting auto login
    if (secureStorage.containsKey('email') &&
        secureStorage.containsKey('password') &&
        secureStorage.containsKey('role')) {
      Future.delayed(const Duration(seconds: 1), () {
        //login
        _submitForm();
      });
    } else {
      //if no data exists then ask the user to login manually
      speakCurrentScreen();
    }
  }

  //get the user preferences stored on the device and set respectively
  Future<void> setUserPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    //sharedPreferences.setBool('autoListener', autoListener);
    bool? userAutoListener = sharedPreferences.getBool('autoListener');
    //switch auto listener ON or OFF based on the user preferences
    setState(() {
      if (userAutoListener != null) {
        _autoRecord = userAutoListener;
      }
    });
  }

  //speak the current screen elements
  void speakCurrentScreen() {
    //log('speakCurrentScreen() RAN in authentication screen');
    //stop any previous text to speech activity
    AppTextToSpeech.stop();
    Future.delayed(const Duration(seconds: 3), () {
      String speak =
          'Welcome, In the current screen, you can login or register using your email, password, and user role customer or business! ';
      //await AppTextToSpeech.flutterTts.speak(speak);
      AppTextToSpeech.replyText = speak;
      AppTextToSpeech.speak();
    }).then((value) => Future.delayed(const Duration(seconds: 7), () {
          //debugPrint('finished speaking');
          //if user wants the auto listener then run it after speaking current screen
          if (_autoRecord == true) {
            if (mounted) {
              setState(() {
                AppTextToSpeech.replyText = '';
                //to show the count down on screen
                _startingIn = 7;
                _sliderVal = 7;
                countDownListener();
                //starting timer related to the auto listener feature
                _timer = RestartableTimer(
                    const Duration(seconds: 7), () => speechListen());
                _timerCont = Timer.periodic(
                    const Duration(seconds: 13), (Timer t) => checkAuto());
              });
            }
          }
        }));
  }

  //listen for user input via microphone
  void speechListen() {
    //make sure TTS is not speaking before listening
    AppTextToSpeech.replyText='';
    AppTextToSpeech.speak();
    AppTextToSpeech.stop();
    //log('speechListen() in authentication screen RAN');
    if (!_speechProvider.isAvailable || _speechProvider.isListening) {
      //stop listening if already listening
      //speechProvider.stop();
      //log('not available: NULL');
    } else {
      //speechProvider.listen(partialResults: true);
      //speechProvider.stop();
      _speechProvider.listen();
    }
    //show the listened text on screen
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _recognizedText = _speechProvider.lastResult?.recognizedWords ?? '';
        });
      }
    });
    //check for for commands in the recognized text
    Future.delayed(const Duration(seconds: 6), () {
      //log(textSample);
      if (mounted) {
        handleCommand(_recognizedText);
      }
    });
    //could also stop listening instead of null if button is pressed again
    //!speechProvider.isAvailable || speechProvider.isListening ? null : () => speechProvider.listen(partialResults: true);
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

  //check if the auto listener feature was disabled or still enabled
  void checkAuto() {
    //log('checkAuto() in authentication screen RAN');
    try {
      //if auto record enabled then continue auto listener, else don't do anything
      if (_autoRecord) {
        if (!_speechProvider.isListening) {
          setState(() {
            _startingIn = 7;
            _sliderVal = 7;
          });
          countDownListener();
          _timer.reset();
        }
        //log('timer reset');
      } else if (!_autoRecord) {
        log('Stopped');
      }
    } catch (error) {
      log('handled error');
    }
  }

  //to show any errors on the login screen
  void _alertError(String message) {
    showDialog(
        context: context,
        builder: (context) {
          //hide after 5 seconds automatically
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          });
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AlertDialog(
                title: const Text('An Error Occurred:'),
                content: Text(message),
              ),
              //5 seconds animation that shows reverse progress bar
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(seconds: 5),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                ),
              ),
            ],
          );
        });
  }

//submit form data and take actions based on login or signup, also show errors if any
  Future<void> _submitForm() async {
    _speechProvider.cancel();
    //speechProvider.stop();
    //debugPrint('authentication button pressed');
    //if any invalid data has been input then do no submit
    if (!_keyForm.currentState!.validate()) {
      // Invalid!
      return;
    }
    //if all data valid then submit
    _keyForm.currentState!.save();
    setState(() {
      _isItLoading = true;
    });
    try {
      //take action on selected option login or signup
      if (_regOrLog == RegisterOrLogin.login) {
        // Log user in
        await Provider.of<Authentication>(context, listen: false)
            .login(_regLogData['email']!, _regLogData['password']!, _userRole);
        //setting role back to default
        _userRole = 3;
      } else {
        // Sign user up
        await Provider.of<Authentication>(context, listen: false)
            .signup(_regLogData['email']!, _regLogData['password']!, _userRole);
        //setting role back to default
        _userRole = 3;
      }
    } on AppExceptions catch (error) {
      var errorMessage = 'User Authentication Failed!';
      if (error.toString().contains('EMAIL_EXISTS')) {
        //if user with that email already registered
        errorMessage = 'Sorry, This email has already been registered.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        //invalid email
        errorMessage = 'sorry, email or password invalid!';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        //email not registered
        errorMessage = 'No account has been registered with this email!';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        //password is weak
        errorMessage = 'Please choose a strong password!';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        //password is invalid
        errorMessage = 'sorry, email or password invalid!';
      } else if (error.toString().contains('role')) {
        //a role has not been chosen, or wrong role chosen
        errorMessage = 'Role Error: Please choose the correct role!';
      }
      //setting role to default
      _userRole = 3;
      //show the error on screen
      _alertError(errorMessage);
      //speak the error
      AppTextToSpeech.replyText = errorMessage;
      _speechProvider.cancel();
      //AppTextToSpeech.speak();
      //await AppTextToSpeech.flutterTts.speak(errorMessage);
    } catch (error) {
      //print(error);
      const errorMessage = 'Something went wrong, Please try again later!';
      _alertError(errorMessage);
      _speechProvider.cancel();
    }
    //speak error too
    Future.delayed(const Duration(milliseconds: 100),(){
      _speechProvider.cancel();
      AppTextToSpeech.speak();
    });
    setState(() {
      _isItLoading = false;
    });
  }

  //update screen if user switches between login and signup
  void _switchRegLog() {
    if (_regOrLog == RegisterOrLogin.login) {
      setState(() {
        _regOrLog = RegisterOrLogin.signup;
      });
    } else {
      setState(() {
        _regOrLog = RegisterOrLogin.login;
      });
    }
  }

  //auto listening functionality controlled by the button on screen
  void _autoListenerSwitch() {
    setState(() {
      //reversing auto record, so if ON then OFF and vice-versa
      _autoRecord = !_autoRecord;
      //storing user preferences about auto listener
      GlobalPreferences.autoListener = _autoRecord;
      GlobalPreferences.storeAutoListener();
      //if enabled then show countdown animation and enable the auto listener
      if (_autoRecord) {
        setState(() {
          _startingIn = 7;
          _sliderVal = 7;
        });
        countDownListener();
        _timer =
            RestartableTimer(const Duration(seconds: 7), () => speechListen());
        _timerCont = Timer.periodic(
            const Duration(seconds: 13), (Timer t) => checkAuto());
      } else {
        //setState((){
        _startingIn = 0;
        //});
        _timer = RestartableTimer(const Duration(seconds: 0), () => {});
        _timerCont = Timer(const Duration(seconds: 0), () => {});
      }
    });
    //debugPrint('AUTO LISTENER: $autoRecord');
  }

  //process the text recognized by the speech to text
  void handleCommand(String text) {
    //when the user stop speaking.
    //log(recognizedText);
    //send to command process class to see if text spoke is a command or not
    String actionCommand =
        AuthenticationCommandProcess.handleSpokenWords(_recognizedText);
    //textSample = '';
    //log('received back command: $actionCommand');
    //print('object');
    if (mounted) {
      setState(() {
        if (actionCommand.contains('_emailFocus')) {
          //log('received back email command, now focus on email field');
          fieldFocus(_emailFocus);
        } else if (actionCommand == '_passFocus') {
          //log('received back password command, now focus on password field');
          fieldFocus(_passFocus);
        } else if (actionCommand == '_cnfrmPassFocus') {
          //log('received back confirm password command, now focus on confirm password field');
          fieldFocus(_cnfPassFocus);
        } else if (actionCommand == 'customer') {
          //log('received back customer toggle command, now focus on customer');
          _userRole = 0;
          removeFocus();
        } else if (actionCommand == 'business') {
          //log('received back business toggle command, now focus on business');
          _userRole = 1;
          removeFocus();
        } else if (actionCommand == 'submitBtn') {
          //log('received back submitBtn');
          _submitForm();
          removeFocus();
        } else if (actionCommand == 'loginPage') {
          //log('received back Page Change to Login');
          setState(() {
            _regOrLog = RegisterOrLogin.login;
          });
        } else if (actionCommand == 'signUpPage') {
          //log('page change to Sign up');
          setState(() {
            _regOrLog = RegisterOrLogin.signup;
          });
        } else if (actionCommand.contains('@') && actionCommand.contains('.')) {
          _emailController.text = actionCommand;
        } else if (actionCommand.contains('clearEmail')) {
          //log('received back clear email field');
          _emailController.text = '';
          fieldFocus(_emailFocus);
        } else if (actionCommand.contains('clearPass')) {
          //log('received back clear password field');
          _passwordController.text = '';
          fieldFocus(_passFocus);
        } else if (actionCommand.contains('clearCnfrmPass')) {
          //log('received back clear confirm password field');
          _cnfPassController.text = '';
          fieldFocus(_passFocus);
        } else if (_passFocus.hasFocus && _passwordController.text.isEmpty) {
          //log("already focused on password so text will go in");
          String convertToPass = _recognizedText.trim();
          String passCorrection = '';
          //Iterate over password to remove spaces added from speech to text
          for (int i = 0; i < convertToPass.length; i++) {
            //only add non-space characters
            if (convertToPass[i] != ' ') {
              passCorrection += convertToPass[i];
            }
          }
          _passwordController.text = passCorrection;
          if (_passwordController.text != '' ||
              _passwordController.text.isNotEmpty) {
            AppTextToSpeech.replyText = 'password input successfully';
            removeFocus();
          }
          //log("password text is: $passCorrection");
        } else if (_cnfPassFocus.hasFocus && _cnfPassController.text.isEmpty) {
          //log("already focused on password so text will go in");
          //_cnfPassController.text = "";
          String convertToPass = _recognizedText.trim();
          String passCorrection = '';
          //Iterate over password to remove spaces added from speech to text
          for (int i = 0; i < convertToPass.length; i++) {
            //only add non-space characters
            if (convertToPass[i] != ' ') {
              passCorrection += convertToPass[i];
            }
          }
          //return the password without any spaces
          _cnfPassController.text = passCorrection;
          if (_cnfPassController.text != '' ||
              _cnfPassController.text.isNotEmpty) {
            AppTextToSpeech.replyText = 'confirm password entered';
            removeFocus();
          }
          //log("password text is: $passCorrection");
        } else if (actionCommand=='nothing') {
          AppTextToSpeech.replyText='';
        }
      });
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
    //focus on given text box focus node
    FocusScope.of(context).requestFocus(toFocusOn);
    //hide keyboard
    Future.delayed(const Duration(milliseconds: 1), () {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
    //debugPrint('Focus is set, keyboard should be hidden: $hide');
  }

  //removing focus from text boxes
  void removeFocus() {
    FocusScope.of(context).unfocus();
  }

  // -----------------
  @override
  Widget build(BuildContext context) {
    //get current window size
    final deviceSize = MediaQuery.of(context).size;
    //return the visual scaffold
    return Scaffold(
      //single widget that can be scrolled
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: Text(
                  'The Food Ordering App',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: deviceSize.width * 0.85,
                //width: deviceSize.width * 0.50,
                padding: const EdgeInsets.all(50.0),
                child: Form(
                  key: _keyForm,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        //Creates an Email FormField that contains a TextField
                        TextFormField(
                          key: (const Key('email_field_key')),
                          focusNode: _emailFocus,
                          decoration:
                              const InputDecoration(labelText: 'E-Mail'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              AppTextToSpeech.stop();
                              AppTextToSpeech.replyText = 'Invalid email';
                              AppTextToSpeech.speak();
                              return 'Invalid email!';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _regLogData['email'] = value!;
                          },
                        ),
                        //Creates Password FormField that contains a TextField
                        TextFormField(
                          key: (const Key('password_field_key')),
                          focusNode: _passFocus,
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value!.isEmpty || value.length < 5) {
                              AppTextToSpeech.stop();
                              AppTextToSpeech.replyText =
                                  'Password is too short';
                              AppTextToSpeech.speak();
                              return 'Password is too short!';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _regLogData['password'] = value!;
                          },
                        ),
                        if (_regOrLog == RegisterOrLogin.signup)
                        //Creates Confirm-Password FormField that contains a TextField
                          TextFormField(
                            key: (const Key('confirmPass_field_key')),
                            enabled: _regOrLog == RegisterOrLogin.signup,
                            //to obtain the keyboard focus
                            focusNode: _cnfPassFocus,
                            //to control modifications to the text field
                            controller: _cnfPassController,
                            //to decorate the text field.
                            decoration: const InputDecoration(
                                labelText: 'Confirm Password'),
                            obscureText: true,
                            validator: _regOrLog == RegisterOrLogin.signup
                                ? (value) {
                                    if (value != _passwordController.text) {
                                      AppTextToSpeech.stop();
                                      AppTextToSpeech.replyText =
                                          'Passwords do not match';
                                      AppTextToSpeech.speak();
                                      return 'Passwords do not match!';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        const SizedBox(height: 20),
                        //toggle switch widget
                        ToggleSwitch(
                          key: (const Key('role_toggle_key')),
                          //to set Minimum switch width
                          minWidth: 90.0,
                          //to set the corner radius
                          cornerRadius: 20.0,
                          //List of active foreground color
                          activeBgColors: [
                            [Colors.green[800]!],
                            [Colors.blue[800]!]
                          ],
                          //Active foreground color
                          activeFgColor: Colors.white,
                          //Inactive background color
                          inactiveBgColor: Colors.grey,
                          //Inactive foreground color
                          inactiveFgColor: Colors.white,
                          //Initial label index
                          //initialLabelIndex: 3,
                          initialLabelIndex: getToggle,
                          //Total number of switches
                          totalSwitches: 2,
                          //List of labels
                          labels: const ['Customer', 'Business'],
                          radiusStyle: true,
                          //onToggle: (index) {
                          onToggle: (index) {
                            //print('switched to: $index');
                            //userRole = index!;
                            _userRole = index!;
                          },
                        ),
                        const SizedBox(height: 10),
                        if (_isItLoading)
                          //Creates a circular progress indicator
                          const CircularProgressIndicator()
                        else
                          //Create an ElevatedButton
                          ElevatedButton(
                            key: (const Key('submit_btn_key')),
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                textStyle: const TextStyle(
                                    //fontSize: 30,
                                    fontWeight: FontWeight.bold)),
                            child: Text(_regOrLog == RegisterOrLogin.login
                                ? 'LOGIN'
                                : 'SIGN UP'),
                          ),
                        //Creates a fixed size box, in this case to add vertical space with height
                        const SizedBox(height: 10),
                        //Creates a TextButton
                        TextButton(
                          key: (const Key('switchRegLog_key')),
                          onPressed: _switchRegLog,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                              '${_regOrLog == RegisterOrLogin.login ? 'REGISTER' : 'SIGN IN'} INSTEAD'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      //position of the floating action button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //the floating action buttons
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          //alignment: Alignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //row which shows the recognized text by the speech to text
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //dynamically sized with expanded
                Expanded(
                  child: Center(
                    //to highlight the text recognized as a command
                    child: SubstringHighlight(
                      //The String searched
                      text: _recognizedText,
                      //text: '',
                      //The array of sub-strings that are highlighted
                      terms: AuthenticationCommand.commandsAuthentication,
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        backgroundColor: Colors.white,
                      ),
                      //text style for the matched text
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
            //row that shows the count down timer on the current screen
            Row(
              children: [
                if (_startingIn == 0)
                  const Text('')
                else
                  //child fills the available space with expanded
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
                        //Creates a slider which is passed value dynamically in this case
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
            //row that shows the auto listener and mic buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Creates a circular floating action button
                FloatingActionButton(
                  key: const Key('autolistener_key'),
                  heroTag: "btnAutoAuthentication",
                  onPressed: () {
                    _timer.cancel();
                    _timerCont.cancel();
                    _speechProvider.cancel();
                    //start recording for speech to text
                    _autoListenerSwitch();
                  },
                  //onPressed: () => {debugPrint('pressed <-------------------------------')} ,
                  child: Icon(
                    _autoRecord
                        ? Icons.autorenew_outlined
                        : Icons.sync_disabled,
                    size: 50,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                //Creates a circular floating action button
                FloatingActionButton(
                  heroTag: "btnMicOneAuthentication",
                  onPressed: speechListen,
                  //onPressed: () => {debugPrint('pressed <-------------------------------')} ,
                  child: Icon(
                    _speechProvider.isListening
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
