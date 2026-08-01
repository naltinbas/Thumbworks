import 'package:flutter/material.dart';

import 'game/progress.dart';
import 'ui/home_screen.dart';
import 'ui/palette.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read before the first frame, so no screen has to be built without knowing
  // which level the player is on and no menu flickers from Start to Continue.
  runApp(Wirewend(progress: await Progress.open()));
}

class Wirewend extends StatelessWidget {
  const Wirewend({super.key, required this.progress});

  final Progress progress;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wirewend',
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      home: HomeScreen(progress: progress),
    );
  }

  /// One dark theme, taken from the same colours the board is painted in, so
  /// the chrome around a level looks like it belongs to the level.
  static ThemeData _theme() {
    final base = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Palette.accent,
        brightness: Brightness.dark,
        surface: Palette.backdrop,
      ),
    );
    return base.copyWith(
      scaffoldBackgroundColor: Palette.backdrop,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Palette.accent,
          foregroundColor: Palette.accentInk,
          // Wide and tall enough to be the obvious thing to hit with a thumb.
          minimumSize: const Size(230, 56),
          shape: const StadiumBorder(),
          // Copied from the theme rather than written out, so a button label
          // is set in the same face as everything else on the screen.
          textStyle: base.textTheme.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Palette.inkDim,
          minimumSize: const Size(0, 48),
          textStyle: base.textTheme.titleMedium?.copyWith(fontSize: 15),
        ),
      ),
    );
  }
}
