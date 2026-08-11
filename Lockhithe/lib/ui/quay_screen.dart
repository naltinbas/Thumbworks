import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../quay/berths.dart';
import '../quay/play.dart';
import '../quay/stow.dart';
import 'palette.dart';
import 'quayview.dart';
import 'result_card.dart';

/// One round: find your chit in your looks, and hope the loops are kind.
class QuayScreen extends StatefulWidget {
  const QuayScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.dealt,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// A stowing to use instead of dealing one, for tests and screenshots.
  final Stow? dealt;

  /// Called once, when the whole crew comes through, with the askings
  /// used. Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<QuayScreen> createState() => QuayScreenState();
}

class QuayScreenState extends State<QuayScreen> {
  static const storeKey = ValueKey('store');

  late Play _play;
  final _bosun = math.Random();

  var _pointing = -1;
  var _showLoops = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get showLoops => _showLoops;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(QuayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  Stow _deal() {
    if (widget.dealt != null) return widget.dealt!;
    final chits = [
      for (var chit = 0; chit < Berths.at(widget.number).lockers; chit++)
        chit,
    ]..shuffle(_bosun);
    return Stow(chits);
  }

  void _set() {
    _play = Play.of(Berths.at(widget.number), _deal());
    _pointing = -1;
    _showLoops = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int locker) {
    if (locker < 0 || _play.isOver) return;

    HapticFeedback.selectionClick();
    final next = _play.open(locker);
    setState(() {
      _play = next;
      _pointing = -1;
      _showLoops = false;
      if (!next.isOver) {
        final chit = next.stow.chits[locker];
        _saying = 'Sailor ${chit + 1}\'s chit. '
            '${next.berth.looks - next.opened.length} look'
            '${next.berth.looks - next.opened.length == 1 ? '' : 's'} '
            'left.';
      } else {
        _saying = null;
      }
    });
    if (next.isOver) _finished();
  }

  void _again() {
    setState(_set);
  }

  /// Asked. The chit-following move.
  void _showMe() {
    final locker = _play.next;
    setState(() {
      _hints++;
      _showLoops = false;
      if (_play.isOver) {
        _pointing = -1;
        _saying = 'The round is settled.';
        return;
      }
      if (locker == null) {
        _pointing = -1;
        _saying = 'The chits have led you round to a locker already open: '
            'your loop is longer than your looks, and the round is past '
            'saving.';
        return;
      }
      _pointing = locker;
      _saying = _play.opened.isEmpty
          ? 'Your own locker first: your chit\'s loop starts there, and '
              'following it is the whole trick.'
          : 'Locker ${locker + 1}: the locker of the sailor whose chit '
              'you just found. Stay on the loop.';
    });
  }

  /// Asked why. The loops, drawn as ropes.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showLoops = true;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (!(_play.found && _play.through)) return;
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
        backgroundColor: Palette.quay,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Store(
                    play: _play,
                    pointing: _pointing,
                    showLoops: _showLoops,
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

/// The line above the store: which berth, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final sunk = play.isOver && !(play.found && play.through);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the berths',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.berth.name,
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
                      ? (sunk ? 'the crew is sunk' : 'the crew is through')
                      : 'you are sailor 1: find your chit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isOver
                        ? (sunk ? Palette.bad : Palette.good)
                        : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.opened.length} / ${play.berth.looks}',
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

/// The store itself.
class _Store extends StatelessWidget {
  const _Store({
    required this.play,
    required this.pointing,
    required this.showLoops,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showLoops;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.lockerAt(touch.localPosition)),
            child: CustomPaint(
              key: QuayScreenState.storeKey,
              size: size,
              painter: QuayView(
                play: play,
                pointing: pointing,
                showLoops: showLoops,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the store: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
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
                color: Palette.wharf,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Your chit is in one of these lockers, and you may '
                        'open half of them. The rest of the crew goes '
                        'after you, each following the chits. All must '
                        'find their own.',
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
                color: Palette.wharf,
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
