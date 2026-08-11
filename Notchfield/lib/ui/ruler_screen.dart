import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ruler/cuts.dart';
import '../ruler/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'rulerview.dart';

/// One ruler: notch it to the ask.
class RulerScreen extends StatefulWidget {
  const RulerScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the finished ruler, with the askings used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<RulerScreen> createState() => RulerScreenState();
}

class RulerScreenState extends State<RulerScreen> {
  static const ruleKey = ValueKey('rule');

  late Play _play;

  var _pointing = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(RulerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Cuts.at(widget.number));
    _pointing = -1;
    _hints = 0;
    _saying = _play.cut.winnable
        ? null
        : 'No cutting of this ruler avoids a repeat, and the label '
            'said so. Notch it any way you like and watch the census '
            'double; ask why for the counting.';
    _told = false;
    _best = false;
  }

  void _touched(int mark) {
    if (mark < 0 || _play.isDone) return;

    if (!_play.hasNotch(mark) && _play.isFull) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'Every notch is cut: fill one before cutting '
            'another.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final couldDouble = _play.doubled.length;
    final next = _play.toggle(mark);
    setState(() {
      _play = next;
      _pointing = -1;
      _saying = _note(next, couldDouble);
    });
    if (next.isDone) _finished();
  }

  String? _note(Play play, int couldDouble) {
    if (play.isDone) return null;
    final doubled = play.doubled;
    if (doubled.length > couldDouble) {
      final distance = doubled.last;
      final clash = play.rules.clashesAt(play.notched, distance).first;
      final ((a, b), (c, d)) = clash;
      return 'Length $distance is measured twice now: $a to $b, and '
          '$c to $d. The census shows it red.';
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
      _pointing = -1;
      _saying = null;
    });
  }

  /// Asked. The mend toward the kept answer.
  void _showMe() {
    final mend = _play.next;
    setState(() {
      _hints++;
      if (_play.isDone) {
        _pointing = -1;
        _saying = 'The ruler is cut.';
        return;
      }
      if (mend == null) {
        _pointing = -1;
        _saying = 'There is nothing to show: no cutting of this '
            'ruler meets the ask, and the sweep tried every one. Ask '
            'why instead.';
        return;
      }
      _pointing = mend;
      _saying = _play.hasNotch(mend)
          ? 'Fill the notch at $mend: the kept cutting has none '
              'there.'
          : 'Cut at $mend: it stands so in a cutting the sweep '
              'counted.';
    });
  }

  /// Asked why. The counting, and the sweep.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
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
        backgroundColor: Palette.slate,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Rule(
                    play: _play,
                    pointing: _pointing,
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

/// The line above the rule: which ruler, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final doubled = play.doubled.length;
    final dead = !play.cut.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the rulers',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.cut.name,
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
                      ? play.cut.perfect
                          ? 'every length measured once'
                          : 'no length measured twice'
                      : doubled > 0
                          ? '$doubled length'
                              '${doubled == 1 ? '' : 's'} measured '
                              'twice'
                          : dead
                              ? 'no cutting avoids a repeat'
                              : '${play.notched.length} of '
                                  '${play.cut.notches} notches cut',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : doubled > 0 || dead
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.moves} moved',
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

/// The rule itself.
class _Rule extends StatelessWidget {
  const _Rule({
    required this.play,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.markAt(touch.localPosition)),
            child: CustomPaint(
              key: RulerScreenState.ruleKey,
              size: size,
              painter: RulerView(
                play: play,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the rule: what the game has to say, and what else can be done.
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
                    'Tap a mark to cut a notch there, tap it again to '
                        'fill it. Every pair of notches measures its '
                        'distance; the census below keeps the count.',
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
