import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:get/get.dart';

class VoiceService extends GetxService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  final RxString lastWords = ''.obs;
  final RxBool isListening = false.obs;
  final RxBool isTtsSpeaking = false.obs;
  final RxDouble soundLevel = 0.0.obs;

  Future<VoiceService> init() async {
    await _initSpeech();
    await _initTts();
    return this;
  }

  Future<void> _initSpeech() async {
    print('VoiceService: _initSpeech start');
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('STT Status: $status'),
      onError: (error) => print('STT Error: $error'),
      debugLogging: true,
    );
    print('VoiceService: STT availability: $available');
    if (!available) {
      print('Speech recognition not available - might need to enable Speech Services by Google');
    }
    print('VoiceService: _initSpeech end');
  }

  Future<void> _initTts() async {
    print('VoiceService: _initTts start');
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      isTtsSpeaking.value = false;
    });
    print('VoiceService: _initTts end');
  }

  Future<void> speak(String text) async {
    isTtsSpeaking.value = true;
    
    // Clean text before speaking
    String cleanText = text
        .replaceAll('`', '') // Remove backticks
        .replaceAll('*', '') // Remove bold/italic markers
        .replaceAll('#', '') // Remove header markers
        .replaceAll(RegExp(r'\n+'), ' ') // Replace newlines with spaces
        .replaceAll(RegExp(r' {2,}'), ' ') // Replace multiple spaces
        .trim();

    await _flutterTts.speak(cleanText);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    isTtsSpeaking.value = false;
  }

  void startListening(Function(String) onResult) async {
    lastWords.value = '';
    isListening.value = true;
    soundLevel.value = 0.0;
    await _speechToText.listen(
      onResult: (result) {
        lastWords.value = result.recognizedWords;
        onResult(result.recognizedWords);
      },
      onSoundLevelChange: (level) {
        soundLevel.value = level;
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
  }

  void stopListening() async {
    await _speechToText.stop();
    isListening.value = false;
  }
}
