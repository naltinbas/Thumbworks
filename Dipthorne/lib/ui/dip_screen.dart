import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ring/play.dart';
import '../ring/rings.dart';
import 'palette.dart';
import 'result_card.dart';
import 'ringview.dart';

/// One dip: choose your seat, then let the rhyme do what it does.
class DipScreen extends StatefulWidget {
  const DipScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when you are last in, with the hints used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int hints)? onDone;

  @override
  State<DipScreen> createState() => DipScreenState();
}

class DipScreenState extends State<DipScreen> {
  static const yardKey = ValueKey('yard');

  late Play _play;

  var _pointing = -1;
  var _showSafe = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get showSafe => _showSafe;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(DipScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Rings.at(widget.number));
    _pointing = -1;
    _showSafe = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int seat) {
    if (_play.isOver) return;

    if (!_play.hasChosen) {
      if (seat < 1) return;
      HapticFeedback.selectionClick();
      setState(() {
        _play = _play.choose(seat);
        _pointing = -1;
        _showSafe = false;
        _saying = 'You stand at seat $seat. Tap anywhere, or Count, and '
            'the rhyme begins.';
      });
      return;
    }

    _count();
  }

  /// One chant of the rhyme.
  void _count() {
    if (!_play.hasChosen || _play.isOver) return;
    HapticFeedback.selectionClick();
    final next = _play.step();
    setState(() {
      _play = next;
      _pointing = -1;
      _showSafe = false;
      final gone = next.out.last;
      _saying = '"${next.ring.rhyme.join(' ')}" and '
          '${gone == next.chosen ? 'it lands on you' : 'seat $gone steps '
              'out'}.';
    });
    if (next.isOver) _finished();
  }

  void _again() {
    setState(_set);
  }

  /// Asked. The safe seat before the rhyme, the next landing after.
  void _showMe() {
    setState(() {
      _hints++;
      _showSafe = false;
      if (_play.isOver) {
        _pointing = -1;
        _saying = 'The dip is done.';
        return;
      }
      if (!_play.hasChosen) {
        _pointing = _play.safe;
        _saying = 'Seat ${_play.safe}, counted the way of the sun from the '
            'dip stone. The rhyme cannot find it.';
        return;
      }
      _pointing = _play.landsOn!;
      _saying = 'The rhyme lands next on '
          '${_play.landsOn == _play.chosen ? 'you' : 'seat ${_play.landsOn}'}.';
    });
  }

  /// Asked why. The safe seat marked, and the arithmetic that finds it.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showSafe = true;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (!_play.won) return;
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
        backgroundColor: Palette.dusk,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _Yard(
                    play: _play,
                    pointing: _pointing,
                    showSafe: _showSafe,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isOver)
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
                  chosen: _play.hasChosen,
                  onAgain: _again,
                  onCount: _count,
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

/// The line above the yard: which ring, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final lost = play.isOver && !play.won;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the rings',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.ring.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isOver
                      ? (play.won ? 'last in' : 'the rhyme found you')
                      : '${play.standing.length} of ${play.ring.children} '
                          'still in',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.won
                        ? Palette.good
                        : lost
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            play.hasChosen ? 'seat ${play.chosen}' : 'choose a seat',
            style: TextStyle(
              color: play.hasChosen ? Palette.ink : Palette.inkDim,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The ring itself.
class _Yard extends StatelessWidget {
  const _Yard({
    required this.play,
    required this.pointing,
    required this.showSafe,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showSafe;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.seatUnder(touch.localPosition)),
            child: CustomPaint(
              key: DipScreenState.yardKey,
              size: size,
              painter: RingView(
                play: play,
                pointing: pointing,
                showSafe: showSafe,
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
    required this.chosen,
    required this.onAgain,
    required this.onCount,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final bool chosen;
  final VoidCallback onAgain;
  final VoidCallback onCount;
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
                color: Palette.wall,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a seat to stand in it. The rhyme starts at the dip '
                        'stone, goes the way of the sun, and whoever each '
                        'chant lands on steps out. Last in is safe.',
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
                Expanded(
                  child: _Button(
                    label: 'Count',
                    onTap: onCount,
                    lit: chosen,
                  ),
                ),
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
  const _Button({required this.label, required this.onTap, this.lit = false});

  final String label;
  final VoidCallback onTap;
  final bool lit;

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
                color: lit ? Palette.edge : Palette.wall,
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
