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
  LanguageOption(
    code: 'kn',
    name: 'Kannada',
    nativeName: 'ಕನ್ನಡ',
  ),
  LanguageOption(
    code: 'te',
    name: 'Telugu',
    nativeName: 'తెలుగు',
  ),
  LanguageOption(
    code: 'ml',
    name: 'Malayalam',
    nativeName: 'മലയാളം',
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
    case 'kn':
      return 'ಕನ್ನಡ';
    case 'te':
      return 'తెలుగు';
    case 'ml':
      return 'മലയാളം';
    default:
      return 'English';
  }
}
