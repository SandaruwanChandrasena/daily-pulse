import 'package:flutter/foundation.dart';

/// The bottom tabs, in the same order as the navigation bar.
enum AppTab { home, explore, search, saved, settings }

/// Knows which tab is open, so any screen can switch to another tab.
class NavigationProvider extends ChangeNotifier {
  AppTab _currentTab = AppTab.home;

  AppTab get currentTab => _currentTab;

  void goTo(AppTab tab) {
    if (tab == _currentTab) return;
    _currentTab = tab;
    notifyListeners();
  }
}