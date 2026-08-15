import 'package:flutter/material.dart';

import 'palette.dart';
import 'title_screen.dart';

/// The app around the sham.
class FoldwickApp extends StatelessWidget {
  const FoldwickApp({super.key});

  static final theme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Palette.night,
    colorScheme: const ColorScheme.dark(
      primary: Palette.sheep,
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
        title: 'Foldwick',
        debugShowCheckedModeBanner: false,
        theme: theme,
        builder: (context, child) => RepaintBoundary(
          key: const Key('screen'),
          child: child!,
        ),
        home: const TitleScreen(),
      );
}
