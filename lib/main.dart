import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final state = await AppState.create();
  runApp(FlipclockApp(state: state));
}

class FlipclockApp extends StatelessWidget {
  const FlipclockApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: state,
      child: Consumer<AppState>(
        builder: (context, app, _) {
          final skin = app.skin;
          return MaterialApp(
            title: 'Flipclock',
            debugShowCheckedModeBanner: false,
            // Allow dragging scroll views (e.g. the countdown wheels) with a
            // mouse/trackpad on web and desktop, not just touch + wheel.
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: skin.buttonColor,
                primary: skin.buttonColor,
                surface: skin.background,
              ),
              scaffoldBackgroundColor: skin.background,
              // App-wide UI font: a soft rounded sans (tabs, buttons, labels,
              // settings). Headings (date / Focus / signature) override this
              // with Playfair Display.
              textTheme: GoogleFonts.quicksandTextTheme().apply(
                bodyColor: skin.primaryTextColor,
                displayColor: skin.primaryTextColor,
              ),
              useMaterial3: true,
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
