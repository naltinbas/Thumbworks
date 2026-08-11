import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../green/greens.dart';
import '../green/play.dart';
import 'greenview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One card: pair the sides round by round until everyone has met.
class GreenScreen extends StatefulWidget {
  const GreenScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the card is written, with the askings used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<GreenScreen> createState() => GreenScreenState();
}

class GreenScreenState extends State<GreenScreen> {
  static const greenKey = ValueKey('green');

  late Play _play;

  (int, int)? _pointing;
  var _showWheel = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  bool get showWheel => _showWheel;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(GreenScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Greens.at(widget.number));
    _pointing = null;
    _showWheel = false;
    _hints = 0;
    _saying = _play.green.possible
        ? null
        : 'This card cannot be written, and the label said so. It is '
            'here for the why: one breath of pigeonhole.';
    _told = false;
    _best = false;
  }

  void _touched(int side) {
    if (side < 0 || _play.isWritten) return;

    if (_play.busy(side)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'Side ${side + 1} is already paired this round.';
      });
      return;
    }
    if (_play.chosen >= 0 &&
        _play.chosen != side &&
        _play.haveMet(_play.chosen, side)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'Sides ${_play.chosen + 1} and ${side + 1} have '
            'already met. Every pair meets exactly once.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.canStill;
    final wasRound = _play.roundInHand;
    final next = _play.pick(side);
    setState(() {
      _play = next;
      _pointing = null;
      _showWheel = false;
      if (next.chosen >= 0) {
        _saying = 'Side ${side + 1} waits for its opponent.';
      } else if (next.roundInHand != wasRound && !next.isWritten) {
        _saying = 'Round $wasRound is full. Round '
            '${next.roundInHand} begins.';
      } else {
        _saying = _note(next, could);
      }
    });
    if (next.isWritten) _finished();
  }

  String? _note(Play play, bool could) {
    if (play.isWritten) return null;
    if (could && play.green.possible && !play.canStill) {
      return 'That pairing strands the card: the rounds left cannot '
          'cover the pairs left. Take it back.';
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
      _pointing = null;
      _showWheel = false;
      _saying = null;
    });
  }

  /// Asked. A pairing the search has checked through.
  void _showMe() {
    final match = _play.next;
    setState(() {
      _hints++;
      _showWheel = false;
      if (_play.isWritten) {
        _pointing = null;
        _saying = 'The card is written.';
        return;
      }
      if (match == null) {
        _pointing = null;
        _saying = _play.green.possible
            ? 'No pairing works from here. Take some back.'
            : 'There is nothing to show: no card fits these rounds. Ask '
                'why instead.';
        return;
      }
      _pointing = match;
      _saying = 'Sides ${match.$1 + 1} and ${match.$2 + 1}: from there '
          'the card still writes, and the search has checked it.';
    });
  }

  /// Asked why. The wheel, laid as ghosts.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _showWheel = _play.green.possible;
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
        backgroundColor: Palette.evening,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _GreenBoard(
                    play: _play,
                    pointing: _pointing,
                    showWheel: _showWheel,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isWritten)
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

/// The line above the green: which card, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final stranded =
        play.green.possible && !play.isWritten && !play.canStill;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the greens',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.green.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isWritten
                      ? 'every side has met every side'
                      : stranded
                          ? 'the card is stranded'
                          : 'round ${play.roundInHand} of '
                              '${play.green.rounds}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isWritten
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
            '${play.matchesMade} / ${play.green.pairs}',
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

/// The green itself.
class _GreenBoard extends StatelessWidget {
  const _GreenBoard({
    required this.play,
    required this.pointing,
    required this.showWheel,
    required this.onTouch,
  });

  final Play play;
  final (int, int)? pointing;
  final bool showWheel;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.sideAt(touch.localPosition)),
            child: CustomPaint(
              key: GreenScreenState.greenKey,
              size: size,
              painter: GreenView(
                play: play,
                pointing: pointing,
                showWheel: showWheel,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the green: what the game has to say, and what else can be done.
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
                color: Palette.pavilion,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap two free sides to pair them this round. Every '
                        'side plays every side exactly once, one match a '
                        'round each.',
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
                color: Palette.pavilion,
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
