import 'package:flutter/material.dart';
import 'package:gongdong/model/book_service.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLang = 'ไทย';

  String get currentLang => _currentLang;

  LanguageProvider() {
    _init();
  }

  Future<void> _init() async {
    _currentLang = await BookService.getLanguage();
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _currentLang = lang;
    await BookService.saveLanguage(lang);
    notifyListeners();
  }

  String translate(String thai, String english) {
    return _currentLang == 'ไทย' ? thai : english;
  }
}
