import 'package:flutter/material.dart';
//annonce fav 
class AnnonceActions extends ChangeNotifier {
  bool _annonceFavStatus = false;

  bool get annonceFavStatus {
    return _annonceFavStatus;
  }

  set initialAnnonceFavStatus(bool status) {
    _annonceFavStatus = status;
  }

  set annonceFavStatus(bool status) {
    _annonceFavStatus = status;
    notifyListeners();
  }

  void switchAnnonceFavStatus() {
    _annonceFavStatus = !_annonceFavStatus;
    notifyListeners();
  }
}
