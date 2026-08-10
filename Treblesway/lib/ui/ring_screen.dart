import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ring/extent.dart';
import '../ring/peals.dart';
import '../ring/play.dart';
import '../ring/tower.dart';
import 'palette.dart';
import 'result_card.dart';
import 'towerview.dart';

/// One peal: every row once, and rounds struck home at the end.
class RingScreen extends StatefulWidget {
  const RingScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time the peal comes round, with the hints used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int hints)? onDone;

  @override
  State<RingScreen> createState() => RingScreenState();
}

class RingScreenState extends State<RingScreen> {
  static const towerKey = ValueKey('tower');

  static final _extents = <int, Extent>{};

  late Play _play;

  var _hints = 0;
  Change? _pointing;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get hints => _hints;
  Change? get pointing => _pointing;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(RingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    final peal = Peals.at(widget.number);
    _play = Play.of(
      peal,
      _extents.putIfAbsent(
        widget.number,
        () => Extent(peal.tower, goalRows: peal.goalRows),
      ),
    );
    _hints = 0;
    _pointing = null;
    _saying = peal.hopeless
        ? 'This tower cannot ring the twenty four, and the label says so. '
            'Why shows what stands in the way; the peal is here to be felt.'
        : null;
    _told = false;
    _best = false;
  }

  void _pull(Change change) {
    if (_play.isDone) return;

    if (!_play.mayRing(change)) {
      final next = change.apply(_play.at);
      final rounds =
          _play.tower.keyOf(next) == _play.tower.keyOf(_play.tower.rounds);
      setState(() {
        _pointing = null;
        _saying = rounds
            ? 'That would bring rounds home early. Every row must sound '
                'first.'
            : 'That would sound ${Tower.spoken(next)} again, and a row may '
                'sound only once.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.pull(change);
    setState(() {
      _play = next;
      _pointing = null;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the chamber has to say after a pull.
  String? _note(Play play) {
    if (play.isDone) return null;
    if (!play.canStillRing) {
      return 'From here the peal cannot come round: some row has been '
          'stranded. Take back, or begin again.';
    }
    if (play.isStuck) {
      return 'Nothing may be rung: every change repeats a row. Take back.';
    }
    final left = play.peal.goalRows - play.rung.length;
    return left > 0 && left <= 3
        ? '$left row${left == 1 ? '' : 's'} still to sound.'
        : null;
  }

  void _again() {
    setState(_set);
  }

  void _back() {
    if (_play.made == 0) return;
    setState(() {
      _play = _play.back;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. A change that keeps the peal alive.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = null;
        _saying = _play.isDone
            ? 'The peal is home.'
            : 'No change keeps it alive from here.';
        return;
      }
      _pointing = next;
      _saying = 'Ring ${next.name}: it brings '
          '${Tower.spoken(next.apply(_play.at))}, and the peal can still '
          'come round after it.';
    });
  }

  /// Asked why. Each tower has its own story, and the split tower's is the
  /// one the game exists for.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      final peal = _play.peal;

      if (peal.hopeless) {
        _saying = 'No change in this tower moves a bell across the middle: '
            'the front pair swap with each other, the back pair with each '
            'other, or both at once. So the bells that begin in front stay '
            'in front, and only four of the twenty four rows can ever sound. '
            'Watch the first two places as you ring: they never hold '
            'anything but bells 1 and 2.';
        return;
      }
      if (peal.tower.changes.length == 2) {
        _saying = 'With two changes only, every row has one way forward and '
            'one way back, and going back repeats a row. The road is forced '
            'from the first pull, ${peal.extents} ways in all, one each '
            'direction round the same circle.';
        return;
      }
      _saying = 'The peal is ${peal.goalRows} rows, a new row sounds with '
          'every change, and rounds strikes home at the end, so it is '
          '${peal.goalRows} changes exactly, no fewer and no more. There are '
          '${peal.extents} ways of doing it, counted with direction, and the '
          'game holds a live one at every moment, which is what Show me '
          'reads from.';
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
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CustomPaint(
                    key: RingScreenState.towerKey,
                    size: Size.infinite,
                    painter: TowerView(
                      play: _play,
                      labels: const TextStyle(fontFamily: 'Roboto'),
                    ),
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  play: _play,
                  hints: _hints,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  play: _play,
                  pointing: _pointing,
                  onPull: _pull,
                  onBack: _back,
                  onAgain: _again,
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

/// The line above the chamber: which peal, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dying = !play.isDone && !play.canStillRing;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: material.Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the towers',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.peal.name,
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
                      ? 'rounds has struck home'
                      : dying
                          ? 'the peal cannot come round from here'
                          : '${play.rung.length} of ${play.peal.goalRows} '
                              'rows have sounded',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : dying
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.made} / ${play.peal.goalRows}',
            style: TextStyle(
              color: dying ? Palette.bad : Palette.ink,
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

/// Under the chamber: the changes to ring, and everything else.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.play,
    required this.pointing,
    required this.onPull,
    required this.onBack,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final Play play;
  final Change? pointing;
  final ValueChanged<Change> onPull;
  final VoidCallback onBack;
  final VoidCallback onAgain;
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
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Ring changes until every row has sounded once, then '
                        'bring rounds home. Each change swaps the pairs it '
                        'names.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            material.Row(
              children: [
                for (final change in play.tower.changes) ...[
                  Expanded(
                    child: _Button(
                      label: change.name,
                      loud: identical(change, pointing) ||
                          change.name == pointing?.name,
                      quiet: !play.mayRing(change),
                      onTap: () => onPull(change),
                    ),
                  ),
                  if (change != play.tower.changes.last)
                    const SizedBox(width: 7),
                ],
              ],
            ),
            const SizedBox(height: 8),
            material.Row(
              children: [
                Expanded(child: _Button(label: 'Take back', onTap: onBack)),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Why', onTap: onWhy)),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.onTap,
    this.loud = false,
    this.quiet = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool loud;

  /// Drawn as though it were dead, but still worth tapping.
  final bool quiet;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: loud ? Palette.bronze : Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: quiet ? Palette.line : Palette.edge,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: loud
                        ? Palette.night
                        : quiet
                            ? Palette.inkDim
                            : Palette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
