import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../herd/moors.dart';
import '../herd/play.dart';
import 'herdview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One moor: herd it to a single colour.
class HerdScreen extends StatefulWidget {
  const HerdScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the settling, with the meetings made. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int meetings)? onDone;

  @override
  State<HerdScreen> createState() => HerdScreenState();
}

class HerdScreenState extends State<HerdScreen> {
  static const moorKey = ValueKey('moor');

  late Play _play;

  var _armed = -1;
  (int, int)? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get armed => _armed;
  (int, int)? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(HerdScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Moors.at(widget.number));
    _armed = -1;
    _pointing = null;
    _hints = 0;
    _saying = _play.moor.winnable
        ? null
        : 'This moor never settles, and the label said so. Meet the '
            'herds as you like and watch the counts; ask why for the '
            'remainders.';
    _told = false;
    _best = false;
  }

  void _touched(int herd) {
    if (herd < 0 || _play.isSettled) return;

    HapticFeedback.selectionClick();
    if (_play.countOf(herd) == 0) {
      setState(() {
        _saying = 'That herd is empty.';
        _armed = -1;
      });
      return;
    }
    if (_armed < 0) {
      setState(() {
        _armed = herd;
        _pointing = null;
      });
      return;
    }
    if (_armed == herd) {
      setState(() => _armed = -1);
      return;
    }

    final could = _play.fewestFromHere;
    final next = _play.meet(_armed, herd);
    setState(() {
      _play = next;
      _armed = -1;
      _pointing = null;
      _saying = _note(next, could);
    });
    if (next.isSettled) _finished();
  }

  String? _note(Play play, int? could) {
    if (play.isSettled || !play.moor.winnable) return null;
    final now = play.fewestFromHere;
    if (could != null && now != null && now > could) {
      return 'That meeting wandered: the moor is now $now meetings '
          'from settling. Back takes it off the count.';
    }
    return null;
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _armed = -1;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. The meeting the walk steps nearer with.
  void _showMe() {
    final meeting = _play.next;
    setState(() {
      _hints++;
      _armed = -1;
      if (_play.isSettled) {
        _pointing = null;
        _saying = 'The moor is settled.';
        return;
      }
      if (meeting == null) {
        _pointing = null;
        _saying = 'There is nothing to show: no herding settles this '
            'moor, and the walk stood on every one. Ask why instead.';
        return;
      }
      _pointing = meeting;
      _saying = 'Meet those two herds: the walk has measured every '
          'herding, and that meeting steps one nearer.';
    });
  }

  /// Asked why. The remainders, in words.
  void _why() {
    setState(() {
      _hints++;
      _armed = -1;
      _pointing = null;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.meetingsMade).then((best) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Moorland(
                    play: _play,
                    armed: _armed,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isSettled)
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

/// The line above the moor: which one, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.moor.winnable;
    final away = play.fewestFromHere;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the moors',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.moor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isSettled
                      ? 'the moor wears one colour'
                      : dead
                          ? 'no herding settles this moor'
                          : '$away meeting${away == 1 ? '' : 's'} '
                              'from settling',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isSettled
                        ? Palette.good
                        : dead
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.meetingsMade} met',
            style: const TextStyle(
              color: Palette.ink,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// The moorland itself.
class _Moorland extends StatelessWidget {
  const _Moorland({
    required this.play,
    required this.armed,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final int armed;
  final (int, int)? pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.patchAt(touch.localPosition)),
            child: CustomPaint(
              key: HerdScreenState.moorKey,
              size: size,
              painter: HerdView(
                play: play,
                armed: armed,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the moor: what the game has to say, and what else can be
/// done.
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
                color: Palette.panel,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap two herds to make a meeting: one from each '
                        'turns the third colour. Herd the whole moor '
                        'to one colour.',
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
                color: Palette.panel,
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
