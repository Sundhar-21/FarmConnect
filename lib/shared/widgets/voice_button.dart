import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmconnect/core/services/voice_service.dart';
import 'package:farmconnect/core/services/voice_command_handler.dart';

class VoiceButton extends ConsumerStatefulWidget {
  const VoiceButton({super.key});

  @override
  ConsumerState<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends ConsumerState<VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _initialized = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initService();
    });
  }

  Future<void> _initService() async {
    if (_initialized || _isInitializing) return;
    _isInitializing = true;
    
    debugPrint('Initializing voice service...');
    final voiceService = ref.read(voiceServiceProvider.notifier);
    final handler = ref.read(voiceCommandHandlerProvider);
    
    voiceService.setCommandHandler((cmd) {
      debugPrint('Command received: $cmd');
      handler.handleCommand(cmd);
    });
    
    final success = await voiceService.initialize();
    debugPrint('Voice service initialized: $success');
    _initialized = true;
    _isInitializing = false;
    
    if (success) {
      await voiceService.speak('Voice assistant ready');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    final voiceService = ref.read(voiceServiceProvider.notifier);
    final currentState = ref.read(voiceServiceProvider).state;
    
    debugPrint('Current voice state: $currentState');
    
    if (currentState == VoiceState.listening) {
      _controller.stop();
      _controller.reset();
      await voiceService.stopListening();
    } else if (currentState == VoiceState.idle || currentState == VoiceState.error) {
      _controller.repeat(reverse: true);
      await voiceService.startListening();
    } else if (currentState == VoiceState.speaking) {
      await voiceService.stopSpeaking();
      _controller.repeat(reverse: true);
      await voiceService.startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceServiceProvider);
    final isListening = voiceState.state == VoiceState.listening;

    ref.listen<VoiceServiceState>(voiceServiceProvider, (prev, next) {
      debugPrint('Voice state changed: ${prev?.state} -> ${next.state}');
      
      if (next.state == VoiceState.idle && _controller.isAnimating) {
        _controller.stop();
        _controller.reset();
      }
      
      if (next.state == VoiceState.speaking && prev?.state != VoiceState.speaking) {
        debugPrint('Speaking: ${next.lastResult}');
      }
    });

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isListening ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _toggleListening,
        child: Container(
          decoration: BoxDecoration(
            gradient: isListening
                ? const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF28D339), Color(0xFF1BAF26)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isListening ? const Color(0xFFFF6B6B) : const Color(0xFF28D339))
                    .withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
