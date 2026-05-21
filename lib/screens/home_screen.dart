import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/segmented_tabs.dart';
import 'clock_screen.dart';
import 'pomodoro_screen.dart';
import 'pomodoro_settings_sheet.dart';
import 'skin_picker_screen.dart';
import 'timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 1; // Clock by default
  late final PageController _pageController =
      PageController(initialPage: _tabIndex);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToTab(int i) {
    setState(() => _tabIndex = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final skin = context.watch<AppState>().skin;

    return Scaffold(
      backgroundColor: skin.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.palette_outlined,
                      color: skin.primaryTextColor,
                    ),
                    tooltip: 'Change skin',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SkinPickerScreen(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  SegmentedTabs(
                    items: const ['Pomodoro', 'Clock', 'Timer'],
                    selectedIndex: _tabIndex,
                    onChanged: _goToTab,
                    skin: skin,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.tune, color: skin.primaryTextColor),
                    tooltip: 'Pomodoro settings',
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: skin.background,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => const PomodoroSettingsSheet(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _tabIndex = i),
                children: const [
                  PomodoroScreen(),
                  ClockScreen(),
                  TimerScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
