import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../alley/frames.dart';
import '../alley/play.dart';
import 'alleyview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One alley: knock last against the house.
class AlleyScreen extends StatefulWidget {
  const AlleyScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at a win, with the askings used. Answers whether
  /// that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<AlleyScreen> createState() => AlleyScreenState();
}

class AlleyScreenState extends State<AlleyScreen> {
  static const laneKey = ValueKey('lane');

  late Play _play;

  (int, int)? _armed;
  (int, int, int)? _pointing;
  var _showCounts = false;
  var _hints = 0;

  var _won = false;
  var _lost = false;
  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get armed => _armed;
  (int, int, int)? get pointing => _pointing;
  bool get showCounts => _showCounts;
  int get hints => _hints;
  bool get won => _won;
  bool get lost => _lost;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(AlleyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Frames.at(widget.number));
    _armed = null;
    _pointing = null;
    _showCounts = false;
    _hints = 0;
    _won = false;
    _lost = false;
    _saying = _play.frame.winnable
        ? null
        : 'This alley counts nought before the first ball, and the '
            'label said so. Whatever you knock, the house zeroes it '
            'back; ask why for the arithmetic.';
    _told = false;
    _best = false;
  }

  void _touched((int, int)? pin) {
    if (pin == null || _won || _lost) return;
    final (row, at) = pin;
    if (!_play.stands(row, at)) return;

    HapticFeedback.selectionClick();
    final held = _armed;
    if (held == null) {
      setState(() {
        _armed = pin;
        _pointing = null;
      });
      return;
    }
    if (held == pin) {
      _knock(_play.knockOne(row, at));
      return;
    }
    if (held.$1 == row && (held.$2 - at).abs() == 1) {
      _knock(_play.knockTwo(row, held.$2, at));
      return;
    }
    setState(() {
      _armed = null;
      _saying = 'A pair must stand shoulder to shoulder in one row: '
          'tap the armed skittle itself for a single.';
    });
  }

  void _knock(Play after) {
    if (identical(after, _play)) return;
    if (after.isCleared) {
      setState(() {
        _play = after;
        _armed = null;
        _pointing = null;
        _won = true;
        _saying = null;
      });
      _finished();
      return;
    }
    // The house replies at once.
    final house = after.houseKnock!;
    final replied = house.$3 < 0
        ? after.knockOne(house.$1, house.$2)
        : after.knockTwo(house.$1, house.$2, house.$3);
    setState(() {
      _play = replied;
      _armed = null;
      _pointing = null;
      if (replied.isCleared) {
        _lost = true;
        _saying = null;
      } else {
        final pair = house.$3 >= 0;
        _saying = 'The house knocks '
            '${pair ? 'a pair' : 'one'} in row ${house.$1 + 1} and '
            'the count stands at ${replied.count}.';
      }
    });
  }

  void _again() {
    setState(_set);
  }

  /// Take back a full round: the house's knock and yours.
  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      var back = _play.back;
      if (back.before != null && !_won && !_lost) back = back.back;
      _play = back;
      _armed = null;
      _pointing = null;
      _won = false;
      _lost = false;
      _saying = null;
    });
  }

  /// Asked. The knock that zeroes the count.
  void _showMe() {
    final knock = _play.zeroing;
    setState(() {
      _hints++;
      _armed = null;
      _showCounts = false;
      if (_won || _lost) {
        _pointing = null;
        _saying = 'The alley is settled.';
        return;
      }
      if (knock == null) {
        _pointing = null;
        _saying = 'No knock zeroes the count from here: whatever '
            'falls, the house can zero it back. '
            '${_play.frame.winnable ? 'Take a knock back.' : 'It was '
                'so before the first ball; ask why.'}';
        return;
      }
      _pointing = knock;
      _saying = knock.$3 < 0
          ? 'Knock that one alone: the count falls to nought, and '
              'the house inherits nothing.'
          : 'Knock that pair together: the count falls to nought, '
              'and the house inherits nothing.';
    });
  }

  /// Asked why. The counts, gold under the runs.
  void _why() {
    setState(() {
      _hints++;
      _armed = null;
      _pointing = null;
      _showCounts = true;
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
        backgroundColor: Palette.alley,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(
                  play: _play,
                  won: _won,
                  lost: _lost,
                  onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Lane(
                    play: _play,
                    armed: _armed,
                    pointing: _pointing,
                    showCounts: _showCounts,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_won || _lost)
                ResultCard(
                  play: _play,
                  won: _won,
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

/// The line above the lane: which alley, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.play,
    required this.won,
    required this.lost,
    required this.onLeave,
  });

  final Play play;
  final bool won;
  final bool lost;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.frame.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the alleys',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.frame.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  won
                      ? 'the last skittle was yours'
                      : lost
                          ? 'the last skittle was the house\'s'
                          : dead
                              ? 'the count stands at nought, and '
                                  'always will'
                              : 'the count stands at ${play.count}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: won
                        ? Palette.good
                        : lost || dead
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.knocks} knocked',
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

/// The lane itself.
class _Lane extends StatelessWidget {
  const _Lane({
    required this.play,
    required this.armed,
    required this.pointing,
    required this.showCounts,
    required this.onTouch,
  });

  final Play play;
  final (int, int)? armed;
  final (int, int, int)? pointing;
  final bool showCounts;
  final ValueChanged<(int, int)?> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.pinAt(touch.localPosition)),
            child: CustomPaint(
              key: AlleyScreenState.laneKey,
              size: size,
              painter: AlleyView(
                play: play,
                armed: armed,
                pointing: pointing,
                showCounts: showCounts,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the lane: what the game has to say, and what else can be done.
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
                    'Arm a skittle, then tap it for a single or a '
                        'standing neighbour for a pair. The house '
                        'replies at once; whoever knocks the last '
                        'skittle has the alley.',
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
