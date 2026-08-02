import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/field.dart';
import '../game/maker.dart';
import '../game/play.dart';
import '../game/plots.dart';
import '../game/reason.dart';
import '../game/words.dart';
import 'hud.dart';
import 'palette.dart';
import 'plot_painter.dart';
import 'result_card.dart';

/// One board: open it, or be told why.
class PlotScreen extends StatefulWidget {
  const PlotScreen({
    super.key,
    required this.which,
    required this.seed,
    required this.onLeave,
    required this.onAgain,
    this.onCleared,
    this.opening,
  });

  final int which;

  /// Which board. Bumped for Another one, so the same plot lays out a new
  /// board rather than the one just finished.
  final int seed;

  final VoidCallback onLeave;
  final VoidCallback onAgain;

  /// Called once, with the seconds it took, the first time a board is
  /// cleared. Answers whether that was the quickest clear of this plot yet.
  final Future<bool> Function(int seconds)? onCleared;

  /// A board to play instead of laying one out. Only a test or a screenshot
  /// passes this.
  final Field? opening;

  @override
  State<PlotScreen> createState() => PlotScreenState();
}

class PlotScreenState extends State<PlotScreen> {
  late Plot _plot;
  late Play _play;

  /// The step the player has been shown, if they asked why.
  Finding? _showing;

  var _flagging = false;
  var _asked = 0;
  var _seconds = 0;
  var _best = false;
  var _told = false;
  Timer? _clock;

  Plot get plot => _plot;
  Play get play => _play;
  int get seconds => _seconds;
  bool get flagging => _flagging;
  Finding? get showing => _showing;

  @override
  void initState() {
    super.initState();
    _lay();
  }

  @override
  void didUpdateWidget(PlotScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.which != widget.which || oldWidget.seed != widget.seed) {
      _lay();
    }
  }

  void _lay() {
    _plot = Plots.at(widget.which);
    // Laid out here and now rather than shipped in a book. Every board comes
    // out of the same maker, which hands back nothing it has not played
    // through by reasoning alone — so a board nobody has ever seen is as
    // guaranteed as one that was checked in.
    final field = widget.opening ??
        Maker.find(
          across: _plot.across,
          down: _plot.down,
          mines: _plot.mines,
          seed: widget.seed * 7919 + widget.which * 101 + 1,
          needs: _plot.needs,
        )!.field;

    setState(() {
      _play = Play.of(field);
      _showing = null;
      _flagging = false;
      _asked = 0;
      _seconds = 0;
      _best = false;
      _told = false;
    });
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_play.isOver) return;
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  void _touched(int at) {
    if (_play.isOver) return;
    setState(() {
      _showing = null;
      if (_play.isOpen(at)) {
        _play = _play.sweep(at);
      } else if (_flagging) {
        _play = _play.flag(at);
      } else {
        _play = _play.open(at);
      }
    });
    _ended();
  }

  void _held(int at) {
    if (_play.isOver || _play.isOpen(at)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _showing = null;
      _play = _flagging ? _play.open(at) : _play.flag(at);
    });
    _ended();
  }

  void _ended() {
    if (!_play.isOver) return;
    _clock?.cancel();
    HapticFeedback.mediumImpact();
    if (_play.ending == Ending.cleared && !_told) {
      _told = true;
      widget.onCleared?.call(_seconds).then((best) {
        if (mounted && best) setState(() => _best = true);
      });
    }
  }

  /// Asked why: works out the next thing that follows, and says it. Asked
  /// again with an answer on show: does it.
  void _why() {
    if (_play.isOver) return;
    final showing = _showing;
    if (showing != null) {
      setState(() {
        for (final at in showing.mined) {
          if (_play.isShut(at)) _play = _play.flag(at);
        }
        for (final at in showing.safe) {
          _play = _play.open(at);
        }
        _showing = null;
      });
      _ended();
      return;
    }

    // Only the rules this plot promises. Being shown reasoning the plot said
    // it would not ask for is not help, it is a different game.
    final step = Reasoner(_play, upTo: _plot.needs, known: _flagged).step;
    setState(() {
      _asked++;
      _showing = step;
    });
  }

  /// The player's flags, taken as known mines for the sake of a hint.
  ///
  /// The solver never reasons from a flag when it is proving a board — a
  /// wrong flag would prove anything. Here it is different: the player has
  /// said those are mines, and a hint that ignored them would keep answering
  /// the question they have already answered.
  Set<int> get _flagged => {
        for (var at = 0; at < _play.field.cells; at++)
          if (_play.isFlagged(at)) at,
      };

  @override
  Widget build(BuildContext context) {
    final step = _showing;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            children: [
              Ledger(
                plot: _plot,
                play: _play,
                seconds: _seconds,
                onLeave: widget.onLeave,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final metrics = Metrics(
                      Size(box.maxWidth, box.maxHeight),
                      _plot.across,
                      _plot.down,
                    );
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (touch) {
                        final at = metrics.under(touch.localPosition);
                        if (at != null) _touched(at);
                      },
                      onLongPressStart: (touch) {
                        final at = metrics.under(touch.localPosition);
                        if (at != null) _held(at);
                      },
                      child: CustomPaint(
                        size: Size(box.maxWidth, box.maxHeight),
                        painter: PlotPainter(
                          play: _play,
                          metrics: metrics,
                          showing: step,
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_play.isOver)
                ResultCard(
                  plot: _plot,
                  play: _play,
                  seconds: _seconds,
                  asked: _asked,
                  best: _best,
                  onAgain: widget.onAgain,
                  onLeave: widget.onLeave,
                )
              else
                Tools(
                  flagging: _flagging,
                  saying: step == null ? null : saying(_play, step),
                  onFlagging: () => setState(() => _flagging = !_flagging),
                  onWhy: _why,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
