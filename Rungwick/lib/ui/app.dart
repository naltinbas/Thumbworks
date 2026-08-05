import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../best.dart';
import '../ladder/build_graph.dart';
import '../ladder/climbs.dart';
import '../ladder/graph.dart';
import '../ladder/words.dart';
import 'climb_screen.dart';
import 'palette.dart';
import 'title_screen.dart';

/// The game: a list of climbs, and one being climbed.
class RungwickApp extends StatefulWidget {
  const RungwickApp({super.key, this.best, this.ladder, this.opensAt});

  final Best? best;

  /// The word graph, if somebody has one already. A test hands one in rather
  /// than waiting for it to be worked out again.
  final Ladder? ladder;

  /// Skip the list and open this climb. A test or a screenshot passes it.
  final int? opensAt;

  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Palette.night,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.rope,
      brightness: Brightness.dark,
      surface: Palette.night,
    ),
    fontFamily: 'Roboto',
  );

  @override
  State<RungwickApp> createState() => _RungwickAppState();
}

class _RungwickAppState extends State<RungwickApp> {
  Ladder? _ladder;
  late int? _climbing = widget.opensAt;

  /// Bumped whenever a climb should start over rather than be picked up where
  /// it was left.
  int _go = 0;

  @override
  void initState() {
    super.initState();
    _ladder = widget.ladder;
    if (_ladder == null) _build();
  }

  /// Two and a half thousand words, bucketed into who is next to whom. It is
  /// a moment, and it happens on an isolate of its own while the list of
  /// climbs is on screen.
  Future<void> _build() async {
    // Sent as a plain number and built on the other side, because what comes
    // back is a graph and what goes over is one int.
    final built = await compute(ladderFor, kFour.first.length);
    if (!mounted) return;
    setState(() => _ladder = built);
  }

  void _open(int number) => setState(() {
        _climbing = number;
        _go++;
      });

  @override
  Widget build(BuildContext context) {
    final ladder = _ladder;
    final climbing = _climbing;

    return MaterialApp(
      title: 'Rungwick',
      debugShowCheckedModeBanner: false,
      theme: RungwickApp.theme,
      home: climbing == null || ladder == null
          ? TitleScreen(
              best: widget.best,
              ready: ladder != null,
              onPlay: _open,
            )
          : ClimbScreen(
              key: ValueKey('$climbing $_go'),
              number: climbing,
              ladder: ladder,
              onDone: (rungs) async =>
                  await widget.best?.record(
                    Climbs.at(climbing).from,
                    Climbs.at(climbing).to,
                    rungs,
                  ) ??
                  false,
              onNext: () => climbing + 1 < Climbs.count
                  ? _open(climbing + 1)
                  : setState(() => _climbing = null),
              onLeave: () => setState(() {
                _climbing = null;
                _go++;
              }),
            ),
    );
  }
}
