import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../hold/consignments.dart';
import '../hold/play.dart';
import 'holdview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One consignment: give each crate's ropes to the lines, and stack fair.
class HoldScreen extends StatefulWidget {
  const HoldScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the stack stands fair, with the askings used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<HoldScreen> createState() => HoldScreenState();
}

class HoldScreenState extends State<HoldScreen> {
  static const yardKey = ValueKey('yard');

  late Play _play;

  (int, int)? _pointing;
  var _showRopes = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  bool get showRopes => _showRopes;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(HoldScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Consignments.at(widget.number));
    _pointing = null;
    _showRopes = false;
    _hints = 0;
    _saying = _play.consignment.possible
        ? null
        : 'No stacking of this consignment exists, and the label said '
            'so. It is here for the why: count one paint\'s faces.';
    _told = false;
    _best = false;
  }

  void _touched((int, int)? chip) {
    if (chip == null || _play.isStacked) return;
    final (crate, pair) = chip;

    final next = _play.cycle(crate, pair);
    if (identical(next, _play)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'Both lines are served on that crate. Free one of its '
            'ropes first.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.canStill;
    setState(() {
      _play = next;
      _pointing = null;
      _showRopes = false;
      _saying = _note(next, could);
    });
    if (next.isStacked) _finished();
  }

  String? _note(Play play, bool could) {
    if (play.isStacked) return null;
    if (play.isComplete && !play.isStacked) {
      return 'Every rope is given and a side repeats a paint: the counts '
          'by the posts say where. Take something back.';
    }
    if (could && play.consignment.possible && !play.canStill) {
      return 'That choice strands the stack: no way to finish honours '
          'it. Take it back.';
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
      _showRopes = false;
      _saying = null;
    });
  }

  /// Asked. A rope and line the search has checked through.
  void _showMe() {
    final hint = _play.next;
    setState(() {
      _hints++;
      _showRopes = false;
      if (_play.isStacked) {
        _pointing = null;
        _saying = 'The stack stands.';
        return;
      }
      if (hint == null) {
        _pointing = null;
        _saying = _play.consignment.possible
            ? 'No choice works from here. Take some back.'
            : 'There is nothing to show: no stacking exists at all. Ask '
                'why instead.';
        return;
      }
      _pointing = (hint.$1, hint.$2);
      _saying = 'Give that rope of crate ${hint.$1 + 1} to the '
          '${hint.$3 == 'ns' ? 'north-south' : 'east-west'} line: from '
          'there the stack still stands, and the search has checked it.';
    });
  }

  /// Asked why. The posts and ropes.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _showRopes = true;
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
        backgroundColor: Palette.yard,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Yard(
                    play: _play,
                    pointing: _pointing,
                    showRopes: _showRopes,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isStacked)
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

/// The line above the yard: which consignment, and how it stands.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final wrong = play.isComplete && !play.isStacked;
    final stranded = play.consignment.possible &&
        !play.isStacked &&
        !play.canStill;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the consignments',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.consignment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isStacked
                      ? 'every side shows all four paints'
                      : wrong
                          ? 'a side repeats a paint'
                          : stranded
                              ? 'the stack is stranded'
                              : 'one rope each to each line',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isStacked
                        ? Palette.good
                        : (wrong || stranded)
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.chosenCount} / 8',
            style: TextStyle(
              color: (wrong || stranded) ? Palette.bad : Palette.ink,
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
    required this.showRopes,
    required this.onTouch,
  });

  final Play play;
  final (int, int)? pointing;
  final bool showRopes;
  final ValueChanged<(int, int)?> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.chipAt(touch.localPosition)),
            child: CustomPaint(
              key: HoldScreenState.yardKey,
              size: size,
              painter: HoldView(
                play: play,
                pointing: pointing,
                showRopes: showRopes,
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
                color: Palette.shed,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Each chip is one crate\'s pair of opposite faces. '
                        'Tap to give it to the north-south line, again '
                        'for east-west, again to free it: one rope each, '
                        'to each line, from every crate.',
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
                color: Palette.shed,
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
