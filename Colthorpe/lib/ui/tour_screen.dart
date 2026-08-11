import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tour/play.dart';
import '../tour/yards.dart';
import 'palette.dart';
import 'result_card.dart';
import 'tourview.dart';

/// One yard: ride the colt through every paddock once.
class TourScreen extends StatefulWidget {
  const TourScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the round is ridden, with the askings used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<TourScreen> createState() => TourScreenState();
}

class TourScreenState extends State<TourScreen> {
  static const yardKey = ValueKey('yard');

  late Play _play;

  var _pointing = -1;
  var _showColours = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get showColours => _showColours;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(TourScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Yards.at(widget.number));
    _pointing = -1;
    _showColours = false;
    _hints = 0;
    _saying = _play.yard.possible
        ? null
        : 'No round rides this yard, and the label said so. It is here for '
            'the why of it: ask, and count the grasses.';
    _told = false;
    _best = false;
  }

  void _touched(int paddock) {
    if (paddock < 0 || _play.isDone) return;

    if (!_play.mayRide(paddock)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = _play.started
            ? 'The colt jumps two paddocks one way and one the other, onto '
                'grass he has not ridden. He cannot reach that one.'
            : 'This yard starts at the gate. Ride from there.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.started ? _play.canStillRide : true;
    final next = _play.ride(paddock);
    setState(() {
      _play = next;
      _pointing = -1;
      _showColours = false;
      _saying = _note(next, could);
    });
    if (next.isDone) _finished();
  }

  /// What the yard has to say after a jump.
  String? _note(Play play, bool could) {
    if (play.isDone) return null;
    if (could && play.yard.possible && !play.canStillRide) {
      return 'That jump stranded a paddock: somewhere in the yard there is '
          'grass no round can reach any more. Take the jump back.';
    }
    return null;
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (!_play.started) return;
    setState(() {
      _play = _play.back;
      _pointing = -1;
      _showColours = false;
      _saying = null;
    });
  }

  /// Asked. A jump that keeps the round alive.
  void _showMe() {
    final paddock = _play.next;
    setState(() {
      _hints++;
      _showColours = false;
      if (_play.isDone) {
        _pointing = -1;
        _saying = 'The round is ridden.';
        return;
      }
      if (paddock == null) {
        _pointing = -1;
        _saying = _play.yard.possible
            ? 'No jump from here finishes the round. Take some back.'
            : 'There is nothing to show: no round rides this yard at all. '
                'Ask why instead.';
        return;
      }
      _pointing = paddock;
      _saying = _play.started
          ? 'That paddock keeps the round alive: from it, every patch of '
              'grass can still be reached once.'
          : 'Start there. A full round rides from that paddock, and the '
              'walk has checked it.';
    });
  }

  /// Asked why. The two grasses, tallied.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showColours = true;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_hints).then((best) {
      if (mounted && best) setState(() => _best = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onLeave();
      },
      child: Scaffold(
        backgroundColor: Palette.beyond,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _Yard(
                    play: _play,
                    pointing: _pointing,
                    showColours: _showColours,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  play: _play,
                  best: _best,
                  hints: _hints,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  onAgain: _again,
                  onBack: _takeBack,
                  onShowMe: _showMe,
                  onWhy: _why,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line above the yard: which round, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final stranded =
        play.started && !play.isDone && play.yard.possible &&
            !play.canStillRide;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the yards',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.yard.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isDone
                      ? (play.yard.closed
                          ? 'every paddock once, and home'
                          : 'every paddock once')
                      : stranded
                          ? 'a paddock is stranded'
                          : play.yard.closed
                              ? 'ride them all and come home'
                              : 'ride them all',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : stranded
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.path.length} / ${play.yard.paddocks}',
            style: TextStyle(
              color: stranded ? Palette.bad : Palette.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// The yard itself.
class _Yard extends StatelessWidget {
  const _Yard({
    required this.play,
    required this.pointing,
    required this.showColours,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showColours;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          // Room for the tally chips above the fence when asked.
          final size = Size(
            room.maxWidth,
            math.max(60.0, room.maxHeight - 8),
          );
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.paddockAt(touch.localPosition)),
            child: CustomPaint(
              key: TourScreenState.yardKey,
              size: size,
              painter: TourView(
                play: play,
                pointing: pointing,
                showColours: showColours,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the yard: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onBack,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onAgain;
  final VoidCallback onBack;
  final VoidCallback onShowMe;
  final VoidCallback onWhy;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Palette.stable,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a paddock the colt can jump to: two one way, one '
                        'the other. Ride every paddock exactly once.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Back', onTap: onBack)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 8),
                Expanded(child: _Button(label: 'Why', onTap: onWhy)),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Palette.stable,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
