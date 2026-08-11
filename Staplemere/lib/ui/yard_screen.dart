import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../yard/deals.dart';
import '../yard/fewest.dart';
import '../yard/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'yardview.dart';

/// One morning: set every bale down in the fewest piles.
class YardScreen extends StatefulWidget {
  const YardScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the last bale goes down, with the piles standing.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int piles)? onDone;

  @override
  State<YardScreen> createState() => YardScreenState();
}

class YardScreenState extends State<YardScreen> {
  static const yardKey = ValueKey('yard');

  late Play _play;

  var _pointing = -1;
  var _showThread = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get showThread => _showThread;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(YardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Deals.at(widget.number));
    _pointing = -1;
    _showThread = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int slot) {
    if (slot < 0 || _play.isDone) return;

    if (!_play.mayRest(slot)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'The ${_play.arriving} cannot rest on the '
            '${_play.topOf(slot)}. Lighter sits on heavier, never the other '
            'way: wool crushes.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.put(slot);
    setState(() {
      _play = next;
      _pointing = -1;
      _showThread = false;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the yard has to say after a bale goes down.
  String? _note(Play play) {
    if (play.isDone) return null;
    final could = play.couldStillBe;
    if (could > play.deal.fewest) {
      return 'The fewest piles this morning can still end in is $could, '
          'which is ${could - play.deal.fewest} more than the '
          '${play.deal.fewest} it takes. Take the bale back, or carry on '
          'and see.';
    }
    return null;
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.placed == 0) return;
    setState(() {
      _play = _play.back;
      _pointing = -1;
      _showThread = false;
      _saying = _note(_play);
    });
  }

  /// Asked. Where the arriving bale should go.
  void _showMe() {
    final slot = _play.next;
    setState(() {
      _hints++;
      _showThread = false;
      if (slot == null) {
        _pointing = -1;
        _saying = 'Every bale is down.';
        return;
      }
      _pointing = slot;
      _saying = slot == _play.standing
          ? 'On the ground. Nothing standing can take the ${_play.arriving}, '
              'so it starts a pile of its own.'
          : 'On the ${_play.topOf(slot)}: the snuggest top that can take '
              'the ${_play.arriving}. The snug fit is the right one, every '
              'time, because it leaves every heavier top still standing for '
              'what comes later.';
    });
  }

  /// Asked why. The thread, drawn through the yard.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showThread = true;
      final thread = Runs.thread(_play.deal.tods).length;
      final note = _play.deal.note;
      _saying = 'The $thread marked bales come up the lane each heavier than '
          'the last. A pile only gets lighter at the top as the morning goes '
          'on, so no two of them can ever share one: $thread piles at least, '
          'and the snuggest top each time ends at exactly $thread.'
          '${note == null ? '' : ' $note'}';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.standing).then((best) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _Yard(
                    play: _play,
                    pointing: _pointing,
                    showThread: _showThread,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  play: _play,
                  best: _best,
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

/// The line above the yard: which morning, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.couldStillBe > play.deal.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the deals',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.deal.name,
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
                      ? 'every bale down'
                      : '${play.deal.many - play.placed} of ${play.deal.many} '
                          'bales still on the cart',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone ? Palette.good : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.standing} / ${play.deal.fewest}',
            style: TextStyle(
              color: over ? Palette.bad : Palette.ink,
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
    required this.showThread,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showThread;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(
            room.maxWidth,
            math.min(
              room.maxHeight,
              Metrics.heightFor(play.deal, room.maxWidth),
            ),
          );
          final metrics = Metrics(play, size);

          return Center(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (touch) =>
                    onTouch(metrics.slotAt(touch.localPosition)),
                child: CustomPaint(
                  key: YardScreenState.yardKey,
                  size: size,
                  painter: YardView(
                    play: play,
                    pointing: pointing,
                    showThread: showThread,
                    labels: const TextStyle(fontFamily: 'Roboto'),
                  ),
                ),
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
                color: Palette.barn,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a pile to set the arriving bale on it, or the '
                        'dashed ground to start a new one. Lighter rests on '
                        'heavier, and the morning wants the fewest piles.',
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
                color: Palette.barn,
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
