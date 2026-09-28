import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../widgets/seasonal_overlay.dart';
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
    final app = context.watch<AppState>();
    final skin = app.skin;
    final landscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    // The bar costs a quarter of the height on a phone held sideways, so it
    // is slimmer there and disappears entirely in the immersive view.
    final barPad = landscape ? 2.0 : 12.0;
    final iconSize = landscape ? 20.0 : 24.0;

    return Scaffold(
      backgroundColor: skin.background,
      body: Stack(
        children: [
          SafeArea(
        bottom: false,
        child: Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: app.immersive
                  ? const SizedBox(width: double.infinity, height: 0)
                  : Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: barPad),
              child: Row(
                children: [
                  IconButton(
                    iconSize: iconSize,
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
                  // Expanded + scaleDown instead of Spacers: on a narrow
                  // screen (or with a large system font) the tabs shrink
                  // rather than pushing the settings button off the edge.
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SegmentedTabs(
                          items: const ['Pomodoro', 'Clock', 'Timer'],
                          selectedIndex: _tabIndex,
                          onChanged: _goToTab,
                          skin: skin,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: iconSize,
                    icon: Icon(Icons.tune, color: skin.primaryTextColor),
                    tooltip: 'Pomodoro settings',
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: skin.background,
                      // Cap the height so a tappable scrim stays at the top
                      // (tap outside to dismiss), plus the X button in the sheet.
                      constraints: BoxConstraints(
                        maxHeight:
                            MediaQuery.of(context).size.height * 0.85,
                      ),
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
            ),
            Expanded(
              // A tap on empty space toggles the immersive view; buttons and
              // the tabs keep their own taps.
              child: GestureDetector(
                onTap: context.read<AppState>().toggleImmersive,
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
            ),
          ],
        ),
          ),
          if (app.seasonalEffect)
            Positioned.fill(
              child: SeasonalOverlay(
                season: seasonForMonth(DateTime.now().month),
              ),
            ),
        ],
      ),
    );
  }
}
