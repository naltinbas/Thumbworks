import 'package:flutter/material.dart';

import 'palette.dart';
import 'title_screen.dart';

/// The app around the sham.
class SkeinwellApp extends StatelessWidget {
  const SkeinwellApp({super.key});

  static final theme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Palette.night,
    colorScheme: const ColorScheme.dark(
      primary: Palette.whole,
      secondary: Palette.shown,
      surface: Palette.board,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Palette.shown),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.ink,
        side: const BorderSide(color: Palette.line),
      ),
    ),
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Skeinwell',
        debugShowCheckedModeBanner: false,
        theme: theme,
        builder: (context, child) => RepaintBoundary(
          key: const Key('screen'),
          child: child!,
        ),
        home: const TitleScreen(),
      );
}
