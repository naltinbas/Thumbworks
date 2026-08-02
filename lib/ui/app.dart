import 'package:flutter/material.dart';

import '../progress.dart';
import 'palette.dart';
import 'puzzle_screen.dart';
import 'title_screen.dart';

/// The game: the title, and whichever puzzle is open.
///
/// One widget holds which puzzle that is, rather than a stack of routes, so
/// Next goes to the next puzzle without piling up a hundred of them behind it
/// for a player working through the book in one sitting.
class TallyloomApp extends StatefulWidget {
  const TallyloomApp({super.key, required this.progress, this.opensAt});

  final Progress progress;

  /// Which puzzle to open straight away. Only a test or a screenshot passes
  /// this; a player arrives at the title.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Palette.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.good,
      surface: Palette.paper,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<TallyloomApp> createState() => _TallyloomAppState();
}

class _TallyloomAppState extends State<TallyloomApp> {
  int? _open;

  @override
  void initState() {
    super.initState();
    _open = widget.opensAt;
  }

  @override
  Widget build(BuildContext context) {
    final open = _open;
    return MaterialApp(
      title: 'Tallyloom',
      debugShowCheckedModeBanner: false,
      theme: TallyloomApp.theme,
      home: open == null
          ? TitleScreen(
              progress: widget.progress,
              onPlay: () => setState(() => _open = widget.progress.next),
            )
          : PuzzleScreen(
              number: open,
              progress: widget.progress,
              onNumber: (number) => setState(() => _open = number),
              onBook: () => setState(() => _open = null),
            ),
    );
  }
}
