import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'placeholder_screen.dart';
import 'search_screen.dart';

/// The app frame: 5 tabs and the bottom navigation bar.
/// IndexedStack keeps every tab alive, so each tab remembers its scroll and data.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTab = 0;

  static const List<Widget> _tabs = [
    HomeScreen(),
    PlaceholderScreen(title: 'Explore', icon: Icons.explore_outlined),
    SearchScreen(),
    PlaceholderScreen(title: 'Saved', icon: Icons.bookmark_border),
    PlaceholderScreen(title: 'Settings', icon: Icons.settings_outlined),
  ];

  void _selectTab(int index) {
    FocusScope.of(context).unfocus();
    setState(() => _currentTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentTab == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _selectTab(0);
      },
      child: Scaffold(
        body: IndexedStack(index: _currentTab, children: _tabs),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentTab,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}