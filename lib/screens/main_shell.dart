import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import 'explore_screen.dart';
import 'home_screen.dart';
import 'placeholder_screen.dart';
import 'saved_screen.dart';
import 'search_screen.dart';

/// The app frame: 5 tabs and the bottom navigation bar.
/// NavigationProvider knows the open tab. IndexedStack keeps all tabs alive.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const List<Widget> _tabs = [
    HomeScreen(),
    ExploreScreen(),
    SearchScreen(),
    SavedScreen(),
    PlaceholderScreen(title: 'Settings', icon: Icons.settings_outlined),
  ];

  void _goTo(BuildContext context, AppTab tab) {
    FocusScope.of(context).unfocus();
    context.read<NavigationProvider>().goTo(tab);
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = context.watch<NavigationProvider>().currentTab;

    return PopScope(
      canPop: currentTab == AppTab.home,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goTo(context, AppTab.home);
      },
      child: Scaffold(
        body: IndexedStack(index: currentTab.index, children: _tabs),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentTab.index,
          onDestinationSelected: (index) =>
              _goTo(context, AppTab.values[index]),
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