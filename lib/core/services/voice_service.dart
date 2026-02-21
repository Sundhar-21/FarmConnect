import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

enum VoiceState {
  idle,
  listening,
  speaking,
  error,
}

class VoiceServiceState {
  final VoiceState state;
  final String lastCommand;
  final String lastResult;
  final bool isEnabled;

  const VoiceServiceState({
    this.state = VoiceState.idle,
    this.lastCommand = '',
    this.lastResult = '',
    this.isEnabled = false,
  });

  VoiceServiceState copyWith({
    VoiceState? state,
    String? lastCommand,
    String? lastResult,
    bool? isEnabled,
  }) {
    return VoiceServiceState(
      state: state ?? this.state,
      lastCommand: lastCommand ?? this.lastCommand,
      lastResult: lastResult ?? this.lastResult,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class VoiceService extends StateNotifier<VoiceServiceState> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  Function(String command)? _onCommand;
  bool _speechEnabled = false;
  bool _isInitialized = false;
  Future<void>? _initFuture;

  VoiceService() : super(const VoiceServiceState()) {
    _initServices();
  }

  Future<void> _initServices() async {
    _initFuture = _doInit();
    await _initFuture;
  }

  Future<void> _doInit() async {
    await _initTts();
    await _initSpeech();
    _isInitialized = true;
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.1);
      
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _tts.setVoice({'name': 'en-us-x-sfg#female_2-local', 'locale': 'en-US'});
      }
      
      _tts.setCompletionHandler(() {
        if (state.state == VoiceState.speaking) {
          state = state.copyWith(state: VoiceState.idle);
        }
      });
      
      _tts.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        state = state.copyWith(state: VoiceState.idle);
      });
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> _initSpeech() async {
    try {
      var micStatus = await Permission.microphone.status;
      debugPrint('Microphone permission status: $micStatus');
      
      if (micStatus.isDenied) {
        micStatus = await Permission.microphone.request();
        debugPrint('Microphone permission after request: $micStatus');
      }
      
      if (micStatus.isPermanentlyDenied) {
        debugPrint('Microphone permission permanently denied');
        _speechEnabled = false;
        state = state.copyWith(isEnabled: false, state: VoiceState.error);
        return;
      }
      
      if (micStatus.isGranted) {
        _speechEnabled = await _speech.initialize(
          onError: (error) {
            debugPrint('Speech error: $error');
            state = state.copyWith(state: VoiceState.error);
          },
          onStatus: (status) {
            debugPrint('Speech status: $status');
          },
        );
      } else {
        debugPrint('Microphone permission not granted');
        _speechEnabled = false;
      }
      state = state.copyWith(isEnabled: _speechEnabled);
    } catch (e) {
      debugPrint('Speech init error: $e');
      state = state.copyWith(state: VoiceState.error);
    }
  }

  void setCommandHandler(Function(String command) handler) {
    _onCommand = handler;
  }

  Future<bool> initialize() async {
    await _initSpeech();
    return _speechEnabled;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    try {
      state = state.copyWith(state: VoiceState.speaking, lastResult: text);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('Speak error: $e');
      state = state.copyWith(state: VoiceState.idle);
    }
  }

  Future<void> startListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
    }

    if (!_speechEnabled) {
      final micStatus = await Permission.microphone.status;
      if (micStatus.isPermanentlyDenied) {
        await speak('Microphone permission denied. Please enable it in app settings.');
        await openAppSettings();
      } else {
        await speak('Voice recognition not available. Please check microphone permission.');
      }
      return;
    }

    state = state.copyWith(state: VoiceState.listening, lastCommand: '');
    
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          final text = result.recognizedWords.toLowerCase().trim();
          debugPrint('Recognized: $text');
          state = state.copyWith(lastCommand: result.recognizedWords, state: VoiceState.idle);
          
          if (text.isNotEmpty && text != 'error') {
            _onCommand?.call(text);
          }
        } else {
          final partial = result.recognizedWords;
          if (partial.isNotEmpty) {
            state = state.copyWith(lastCommand: partial);
          }
        }
      },
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 4),
      localeId: 'en_US',
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
      state = state.copyWith(state: VoiceState.idle);
    } catch (e) {
      debugPrint('Stop speaking error: $e');
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
      state = state.copyWith(state: VoiceState.idle);
    } catch (e) {
      debugPrint('Stop error: $e');
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    super.dispose();
  }
}

final voiceServiceProvider = StateNotifierProvider<VoiceService, VoiceServiceState>((ref) {
  return VoiceService();
});
