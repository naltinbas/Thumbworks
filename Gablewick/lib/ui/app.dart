import 'package:flutter/material.dart';

import 'palette.dart';
import 'title_screen.dart';

/// The app around the sham.
class GablewickApp extends StatelessWidget {
  const GablewickApp({super.key});

  static final theme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Palette.night,
    colorScheme: const ColorScheme.dark(
      primary: Palette.brass,
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
        title: 'Gablewick',
        debugShowCheckedModeBanner: false,
        theme: theme,
        builder: (context, child) => RepaintBoundary(
          key: const Key('screen'),
          child: child!,
        ),
        home: const TitleScreen(),
      );
}
