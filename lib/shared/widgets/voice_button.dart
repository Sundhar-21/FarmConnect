import 'package:flutter/foundation.dart';
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
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVoiceService();
    });
  }

  Future<void> _initVoiceService() async {
    final voiceService = ref.read(voiceServiceProvider.notifier);
    final handler = ref.read(voiceCommandHandlerProvider);
    voiceService.setCommandHandler((command) {
      handler.handleCommand(command);
    });
    await voiceService.initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startListening() async {
    if (_isProcessing) return;
    
    final voiceState = ref.read(voiceServiceProvider);
    final voiceService = ref.read(voiceServiceProvider.notifier);

    if (voiceState.state == VoiceState.listening) {
      _isProcessing = true;
      await voiceService.stopListening();
      _animationController.stop();
      _animationController.reset();
      _isProcessing = false;
    } else {
      _isProcessing = true;
      _animationController.repeat(reverse: true);
      await voiceService.startListening();
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceServiceProvider);

    ref.listen<VoiceServiceState>(voiceServiceProvider, (previous, next) {
      if (next.state == VoiceState.idle && _animationController.isAnimating) {
        _animationController.stop();
        _animationController.reset();
      }
    });

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: voiceState.state == VoiceState.listening
              ? _scaleAnimation.value
              : 1.0,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: voiceState.state == VoiceState.listening
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
              color: (voiceState.state == VoiceState.listening
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF28D339))
                  .withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _startListening,
            customBorder: const CircleBorder(),
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Icon(
                voiceState.state == VoiceState.listening
                    ? Icons.mic
                    : Icons.mic_none,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
