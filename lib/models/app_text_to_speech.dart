import 'package:flutter_tts/flutter_tts.dart';

//class that handles TEXT TO SPEECH
class AppTextToSpeech {
  //to store the instance of Flutter Text To Speech
  static final FlutterTts flutterTts = FlutterTts();

  //Variable to store the text to be spoken
  static String replyText = '';

  //speak the text specified
  static void speak() async {
    //speed at which to speak
    await flutterTts.setSpeechRate(0.3);
    //speak the text
    await flutterTts.speak(replyText);
    //can be used to complete the speaking of a text
    //flutterTts.awaitSpeakCompletion(true);
    //reset after speaking
    replyText = '';
  }

  //stop speaking
  static void stop() async {
    //await flutterTts.stop();
    flutterTts.stop();
  }
}
