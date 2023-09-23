import 'dart:async';
import 'dart:developer';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text_provider.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../models/app_text_to_speech.dart';
import '../models/global_preferences.dart';
import '../providers/item_in_cart_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../providers/orders_provider.dart';
import '../commands/cart_screen_commands.dart';
import '../screens/view_business_menu_screen.dart';

//cart screen user interface
class CartScreen extends StatefulWidget {
  //for navigation reference between screens
  static const routeName = '/cartScreen';

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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

  //to show loading on screen
  var _isItLoading = false;

  //the dynamic voice commands based on data from the database
  Map<String, String> voiceCommandData = {};

  //late List<FoodCategoryProvider> foodCategories;
  //to be used in to show the count down timer
  int _startingIn = 0;

  //the countdown timer that will be shown on the screen before listening
  late Timer _timerNew;

  //to control the slider value
  double _sliderVal = 7.0;

  //to store the instance of the Cart class
  late CustomerCart currentCart;

  //to store the cart items
  late Map<String, CustomerCartItem> cartItems;

  //to store the owner ID who's menu it is being bought from
  late String ownerID;

  //to store the business name
  late String businessName;

  //to store the service requested by the user , delivery or collection
  late int service;

  //to control the scroll on the list
  final ScrollController _listController = ScrollController();

  //initializing...
  @override
  void initState() {
    super.initState();
    //runs after the widgets have finished building
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        //speaking text
        AppTextToSpeech.replyText = "Cart";
        AppTextToSpeech.speak();
      });
    });*/
    //initializing cart
    currentCart = CustomerCart();
    //initializing cart items
    cartItems = {};
    //initializing owner id
    ownerID = '';
    //initializing default service selected
    service = 0;
    //initializing business name
    businessName = '';
    //initializing timers
    timer = RestartableTimer(const Duration(seconds: 0), () => {});
    timerCont = Timer(const Duration(seconds: 0), () => {});
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
    //ownerID = ModalRoute.of(context)?.settings.arguments as String;
    //to store the cart provider
    currentCart = Provider.of<CustomerCart>(context);
    //storing the current cart items
    cartItems = currentCart.allCartItems;
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    if (arguments['ownerID'] != null &&
        arguments['businessName'] != 'businessName') {
      ownerID = arguments['ownerID'];
      businessName = arguments['businessName'];
      mapCartItems();
    } else {
      debugPrint('error in getting owner id or business name in CART');
    }
  }

  //after leaving the screen, disposes of any active elements on the screen
  @override
  void dispose() {
    super.dispose();
    //log('disposing the cart screen');
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
    //log('speechListen() in cart screen RAN');
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
  void mapCartItems() {
    cartItems.forEach((key, theCartItem) {
      //log('key: $key = CartItem: /id: ${theCartItem.id}/${theCartItem.title}/${theCartItem.price}/${theCartItem.quantity}');
      voiceCommandData[theCartItem.theTitle] = key;
      //debugPrint('cart item title: ${theCartItem.title}');
    });
    //debugPrint('Map Now: $voiceCommandData');
  }

  //process the text recognized by the speech to text
  void handleCommand(String text) async {
    //send to command process class to see if text spoke is a command or not
    String actionCommand = CartScreenCommandProcess.handleSpokenWords(text);
    //_recognizedText = '';
    //log('received back command: $actionCommand');
    //log(voiceCommandData.values.toString());
    //log(voiceCommandData.keys.toString());
    String removeID = '';
    String removeAllID = '';
    String addID = '';
    voiceCommandData.forEach((key, value) {
      //log(key+' : '+value);
      key = key.toLowerCase();
      if ('delete $key' == actionCommand) {
        //log('$key : match found : $value');
        removeID = value;
      } else if ('delete all $key' == actionCommand) {
        //log('$key : match found : $value');
        removeAllID = value;
      } else if ('add $key' == actionCommand) {
        //log('$key : match found : $value');
        addID = value;
      }
    });
    //log('removeID this ID: $removeID');
    if (removeID != '') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      speechProvider.cancel();
      Provider.of<CustomerCart>(context, listen: false)
          .removeSingleCartItem(removeID);
      AppTextToSpeech.replyText = 'one item removed';
    }
    if (removeAllID != '') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      speechProvider.cancel();
      Provider.of<CustomerCart>(context, listen: false)
          .removeCartItemByID(removeAllID);
      AppTextToSpeech.replyText = 'items removed';
    }
    if (addID != '') {
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      speechProvider.cancel();
      Provider.of<CustomerCart>(context, listen: false)
          .addSingleItemToCart(addID);
      AppTextToSpeech.replyText = 'item added';
    }
    if (actionCommand == 'back') {
      speechProvider.cancel();
      Navigator.pushReplacementNamed(context, ViewBusinessMenuScreen.routeName,
          arguments: {
            'ownerID': ownerID,
            'businessName': businessName,
          });
    } else if (actionCommand == 'repeat') {
      Navigator.of(context).pushReplacementNamed(CartScreen.routeName);
    } else if (actionCommand == 'collect') {
      setState(() {
        service = 0;
        AppTextToSpeech.replyText = 'collection selected';
      });
    } else if (actionCommand == 'deliver') {
      setState(() {
        service = 1;
        AppTextToSpeech.replyText = 'delivery selected';
      });
    } else if (actionCommand == 'order') {
      //log('running order command');
      setState(() {
        AppTextToSpeech.replyText = '';
        AppTextToSpeech.stop();
      });
      speechProvider.cancel();
      if (currentCart.getTotalAmount <= 0 || _isItLoading) {
        //log('do nothing');
        AppTextToSpeech.replyText = 'Cart is Empty';
      } else {
        setState(() {
          _isItLoading = true;
          AppTextToSpeech.replyText = 'Order Placed';
        });
        await Provider.of<AllOrders>(context, listen: false).addNewOrder(
          currentCart.allCartItems.values.toList(),
          currentCart.getTotalAmount,
          ownerID,
          businessName,
          getService,
        );
        setState(() {
          _isItLoading = false;
        });
        currentCart.clearCart();
      }
    } else if (actionCommand == 'scroll up') {
      _scrollUp();
      AppTextToSpeech.replyText = 'Scrolling Up';
    } else if (actionCommand == 'scroll down') {
      _scrollDown();
      AppTextToSpeech.replyText = 'Scrolling Down';
    } else if (actionCommand == 'scroll stop') {
      _scrollStop();
      AppTextToSpeech.replyText = 'Stopped';
    } else if (actionCommand == 'clear cart') {
      currentCart.clearCart();
      AppTextToSpeech.replyText = 'Cart Cleared';
    } else if (actionCommand == 'nothing') {
      AppTextToSpeech.replyText = '';
    }

    Future.delayed(const Duration(milliseconds: 2000), () {
      //debugPrint("Now Speaking this: ${AppTextToSpeech.replyText}");
      if (AppTextToSpeech.replyText != '') {
        AppTextToSpeech.speak();
      }
    });
  }

  //speak the current screen elements
  void speakCurrentScreen() {
    //log('speakCurrentScreen() RAN in customer screen');
    AppTextToSpeech.replyText = 'Cart Screen';
    AppTextToSpeech.speak();
    List<String> toSpeak = [];
    cartItems.forEach((key, cartItem) {
      //log(cartItem.title);
      String currentElement =
          '${cartItem.theQuantity}, ${cartItem.theTitle}, of price, ${cartItem.thePrice}, making Total, £${(cartItem.thePrice * cartItem.theQuantity)}';
      toSpeak.add(currentElement);
      //totalSecondsWait+=10;
    });
    //sending to recognize commands
    CartScreenCommand.cartCommands(cartItems);
    int speakLength = (toSpeak.length * 8) + 15;
    //log('toSpeak List: $toSpeak');
    //log('cart items : ${toSpeak.length}');
    String speakAll = '';
    toSpeak.forEach((element) {
      speakAll += '$element ';
    });
    //log('speakAll: $speakAll');
    Future.delayed(const Duration(seconds: 2), () async {
      if (toSpeak.isEmpty) {
        //log('nothing to speak yet');
        await AppTextToSpeech.flutterTts.speak(
            'the cart is empty, please go back to add some items, now you can ask me to go back or repeat');
      } else {
        AppTextToSpeech.replyText = speakAll;
        await AppTextToSpeech.flutterTts.speak(
            'Your cart has: $speakAll, total is £${currentCart.getTotalAmount}, now you can ask me to to choose delivery or collection, remove one or all items, clear cart or add items, place the order, or go back');
      }
    });
    //}).then((value) =>
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

  //to return the service selected delivery ir collection
  String get getService {
    String theService = '';
    if (service == 0) {
      theService = 'collection';
    } else {
      theService = 'delivery';
    }
    return theService;
  }

  //return service int
  int get getToggle {
    return service;
  }

// Scroll Down
  void _scrollDown() {
    _listController.animateTo(
      _listController.position.maxScrollExtent,
      duration: const Duration(seconds: 10),
      curve: Curves.fastOutSlowIn,
    );
  }

  // Scroll Up
  void _scrollUp() {
    _listController.animateTo(
      _listController.position.minScrollExtent,
      duration: const Duration(seconds: 10),
      curve: Curves.fastOutSlowIn,
    );
  }

  //stop scrolling
  void _scrollStop() {
    _listController.animateTo(_listController.offset,
        duration: const Duration(milliseconds: 1), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    //get current window size
    final deviceSize = MediaQuery.of(context).size;
    //Creates a visual scaffold for widgets
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Your Cart')),
      ),
      //Creates a vertical array of children.
      body: Column(
        children: [
          const SizedBox(height: 10),
          //Creates a horizontal array of children.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleSwitch(
                minWidth: 90.0,
                cornerRadius: 20.0,
                activeBgColors: [
                  [Colors.green[800]!],
                  [Colors.teal[800]!],
                ],
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                //initialLabelIndex: 3,
                initialLabelIndex: getToggle,
                //initialLabelIndex: 0,
                totalSwitches: 2,
                labels: const ['Collection', 'Delivery'],
                radiusStyle: true,
                //onToggle: (index) {
                onToggle: (index) {
                  //print('switched to: $index');
                  service = index!;
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Total: ',
                style: TextStyle(fontSize: 20),
              ),
              //const Spacer(),
              //compact element that represents the price text,
              Chip(
                label: Text(
                  '£${currentCart.getTotalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    //backgroundColor: Colors.white,
                  ),
                ),
                backgroundColor: Colors.deepOrange,
              ),
              // a bit of space in between
              const SizedBox(width: 150),
              ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(Colors.blue)),
                onPressed: (_isItLoading || currentCart.getTotalAmount <= 0)
                    ? null
                    : () async {
                        setState(() {
                          _isItLoading = true;
                        });
                        await Provider.of<AllOrders>(context, listen: false)
                            .addNewOrder(
                          currentCart.allCartItems.values.toList(),
                          currentCart.getTotalAmount,
                          ownerID,
                          businessName,
                          getService,
                        );
                        setState(() {
                          _isItLoading = false;
                        });
                        //clear cart after order placed
                        currentCart.clearCart();
                      },
                child: _isItLoading
                //Create a circular progress indicator
                    ? const CircularProgressIndicator()
                //otherwise, show the text widget.
                    : const Text(
                        'ORDER',
                        //the style to use for this text
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          currentCart.allCartItems.isEmpty
              ? const Center(
                  child: Text(
                  '(No items added to Cart/Basket yet!)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ))
              : SizedBox(
                  height: deviceSize.height * 0.60,
                  //Creates a scrollable, linear array of widgets
                  child: ListView.builder(
                    controller: _listController,
                    itemBuilder: (ctx, c) => CartItemWidget(
                      currentCart.allCartItems.values.toList()[c].id,
                      currentCart.allCartItems.keys.toList()[c],
                      currentCart.allCartItems.values.toList()[c].thePrice,
                      currentCart.allCartItems.values.toList()[c].theQuantity,
                      currentCart.allCartItems.values.toList()[c].theTitle,
                    ),
                    itemCount: currentCart.allCartItems.length,
                  ),
                )
        ],
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
                      terms: CartScreenCommand.commandsCartScreen,
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
                  heroTag: "btnAutoCart",
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
                  heroTag: "btnMicCart",
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
                        context, ViewBusinessMenuScreen.routeName,
                        arguments: {
                          'ownerID': ownerID,
                          'businessName': businessName,
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
