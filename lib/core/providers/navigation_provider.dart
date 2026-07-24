import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _bookingTabIndex = 0;

  int get currentIndex => _currentIndex;
  int get bookingTabIndex => _bookingTabIndex;

  void setIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  void setBookingTabIndex(int tabIndex) {
    _bookingTabIndex = tabIndex;
    notifyListeners();
  }

  void navigateToBookingsWithTab(int tabIndex) {
    _currentIndex = 1; // Tab 1 is PsychologistBookingsScreen
    _bookingTabIndex = tabIndex;
    notifyListeners();
  }
}
