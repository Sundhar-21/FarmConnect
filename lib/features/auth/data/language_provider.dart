import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

const List<LanguageOption> supportedLanguages = [
  LanguageOption(
    code: 'en',
    name: 'English',
    nativeName: 'English',
  ),
  LanguageOption(
    code: 'ta',
    name: 'Tamil',
    nativeName: 'தமிழ்',
  ),
  LanguageOption(
    code: 'hi',
    name: 'Hindi',
    nativeName: 'हिंदी',
  ),
];

String getLanguageNameFromCode(String code) {
  switch (code) {
    case 'en':
      return 'English';
    case 'ta':
      return 'தமிழ்';
    case 'hi':
      return 'हिंदी';
    default:
      return 'English';
  }
}
