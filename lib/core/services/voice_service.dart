import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

enum VoiceState {
  idle,
  listening,
  processing,
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
  static const String _wakeWord = 'hey nova';

  VoiceService() : super(const VoiceServiceState()) {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-GB');
    await _tts.setSpeechRate(0.6);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.2);
    await _tts.setVoice({'name': 'Google UK English Female', 'locale': 'en-GB'});
    _tts.setCompletionHandler(() {
      if (state.state == VoiceState.speaking) {
        state = state.copyWith(state: VoiceState.idle);
      }
    });
  }

  void setCommandHandler(Function(String command) handler) {
    _onCommand = handler;
  }

  Future<bool> initialize() async {
    try {
      final available = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech error: $error');
          state = state.copyWith(state: VoiceState.error);
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            if (state.state == VoiceState.listening) {
              state = state.copyWith(state: VoiceState.idle);
            }
          }
        },
      );
      state = state.copyWith(isEnabled: available);
      return available;
    } catch (e) {
      debugPrint('Speech init error: $e');
      state = state.copyWith(state: VoiceState.error);
      return false;
    }
  }

  Future<void> speak(String text) async {
    state = state.copyWith(state: VoiceState.speaking, lastResult: text);
    await _tts.speak(text);
  }

  Future<void> startListening() async {
    if (!state.isEnabled) {
      final initialized = await initialize();
      if (!initialized) {
        await speak('Voice recognition not available');
        return;
      }
    }

    await _speech.stop();
    
    state = state.copyWith(state: VoiceState.listening, lastCommand: '');
    
    await _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords.toLowerCase();
        state = state.copyWith(lastCommand: result.recognizedWords);
        
        if (result.finalResult) {
          _processCommand(text);
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_US',
      cancelOnError: false,
      partialResults: true,
    );
  }

  void _processCommand(String text) {
    if (text.isNotEmpty) {
      speak('Processing: $text');
      _onCommand?.call(text);
    } else {
      state = state.copyWith(state: VoiceState.idle);
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    state = state.copyWith(state: VoiceState.idle);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    state = state.copyWith(state: VoiceState.idle);
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
