import 'package:flutter/material.dart';
import 'package:gongdong/model/book_service.dart';

class FontProvider extends ChangeNotifier {
  double _fontSizeFactor = 1.0;

  double get fontSizeFactor => _fontSizeFactor;

  FontProvider() {
    _init();
  }

  Future<void> _init() async {
    _fontSizeFactor = await BookService.getFontSize();
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSizeFactor = size;
    await BookService.saveFontSize(size);
    notifyListeners();
  }
}
