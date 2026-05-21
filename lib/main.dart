import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            theme: ThemeData(
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: skin.buttonColor,
                primary: skin.buttonColor,
                surface: skin.background,
              ),
              scaffoldBackgroundColor: skin.background,
              textTheme: const TextTheme().apply(
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
