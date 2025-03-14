import 'dart:async';

import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchController extends GetxController {
  final stt.SpeechToText speech = stt.SpeechToText();
  final parameters = Get.arguments;

  RxBool isListening = false.obs;
  RxString searchText = ''.obs;

  String currentLocaleId = '';
  bool hasSpeech = false;
  String lastWords = '';
  Timer? _stopListeningTimer;
  Timer? _silenceTimer; // Add a timer for silence detection

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }

  void _initSpeech() async {
    bool hasSpeech = await speech.initialize();
    if (hasSpeech) {
      startListening();
    }
  }

  void startListening() async {
    isListening.value = true;
    await speech.listen(onResult: _onSpeechResult);
    _startSilenceTimer();
  }

  void _startSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(const Duration(seconds: 5), () {
      stopListening();
    });
  }

  void stopListening() async {
    if (isListening.value) {
      await speech.stop();
      isListening.value = false;

      _stopListeningTimer?.cancel();
      _silenceTimer?.cancel(); // Cancel the silence timer

      if (searchText.value.isNotEmpty) {
        Get.back();
      }

      parameters(lastWords);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    searchText.value = result.recognizedWords;
    lastWords = searchText.value;

    _startSilenceTimer(); // Reset silence timer on speech detection
  }
}
