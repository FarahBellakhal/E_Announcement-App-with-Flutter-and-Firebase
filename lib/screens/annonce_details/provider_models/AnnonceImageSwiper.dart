import 'package:flutter/material.dart';
//image swiper
class AnnonceImageSwiper extends ChangeNotifier {
  int _currentImageIndex = 0;
  int get currentImageIndex {
    return _currentImageIndex;
  }

  set currentImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }
}
