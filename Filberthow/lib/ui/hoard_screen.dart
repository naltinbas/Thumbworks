import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../hoard/hoards.dart';
import '../hoard/play.dart';
import 'hoardview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One hoard: take well, and take the last nut.
class HoardScreen extends StatefulWidget {
  const HoardScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the last nut is yours, with the askings used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<HoardScreen> createState() => HoardScreenState();
}

class HoardScreenState extends State<HoardScreen> {
  static const pileKey = ValueKey('pile');

  late Play _play;

  var _pending = 0;
  var _showClusters = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pending => _pending;
  bool get showClusters => _showClusters;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(HoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Hoards.at(widget.number));
    _pending = 0;
    _showClusters = false;
    _hints = 0;
    _saying = _play.winnable
        ? null
        : 'This hoard is a Fibonacci number, and the opener is lost '
            'before the first nut moves. It is here to be felt; ask why.';
    _told = false;
    _best = false;
  }

  /// A tap on the pile marks one more nut for taking, wrapping past the
  /// cap back to one.
  void _touched() {
    if (_play.isOver) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pending = _pending >= _play.cap || _pending >= _play.nuts
          ? 1
          : _pending + 1;
      _showClusters = false;
      _saying = null;
    });
  }

  /// Commits the pending take; the grey squirrel answers on its heels.
  void _take() {
    if (_play.isOver || _pending < 1) return;
    HapticFeedback.mediumImpact();
    final wasWinnable = _play.winnable;
    final next = _play.take(_pending);
    setState(() {
      _play = next;
      _pending = 0;
      _showClusters = false;
      _saying = _note(next, wasWinnable);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play, bool wasWinnable) {
    if (play.isOver) return null;
    final theirs = play.theirLast;
    final answer = 'The grey squirrel takes $theirs: '
        '${play.nuts} stand, and you may take up to ${play.cap}.';
    if (wasWinnable && !play.winnable) {
      return 'That take handed the split over. $answer The hoard is the '
          'grey squirrel\'s now, however you take. Take the exchange '
          'back.';
    }
    return answer;
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _pending = 0;
      _showClusters = false;
      _saying = null;
    });
  }

  /// Asked. The smallest cluster, when the cap allows it.
  void _showMe() {
    final take = _play.next;
    setState(() {
      _hints++;
      _showClusters = false;
      if (_play.isOver) {
        _pending = 0;
        _saying = 'The hoard is settled.';
        return;
      }
      if (take == null) {
        _pending = 0;
        _saying = 'There is no winning take from here: the smallest '
            'cluster is out of the cap\'s reach. Take one and see what '
            'the grey squirrel does with it.';
        return;
      }
      _pending = take;
      _saying = 'Take $take: the smallest cluster of the split. Press '
          'Take to commit it.';
    });
  }

  /// Asked why. The clusters, ringed on the hoard.
  void _why() {
    setState(() {
      _hints++;
      _showClusters = true;
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
        backgroundColor: Palette.wood,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, pending: _pending, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Pile(
                    play: _play,
                    pending: _pending,
                    showClusters: _showClusters,
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
                  onBack: _takeBack,
                  onTake: _take,
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

/// The line above the pile: which hoard, and how it stands.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.play,
    required this.pending,
    required this.onLeave,
  });

  final Play play;
  final int pending;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final lost = !play.winnable && !(play.isOver && play.won);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the hoards',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.hoard.name,
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
                      ? (play.won
                          ? 'the last nut was yours'
                          : 'the last nut was the grey squirrel\'s')
                      : lost
                          ? 'the grey squirrel holds the split'
                          : pending > 0
                              ? 'taking $pending of up to ${play.cap}'
                              : '${play.nuts} nuts, take up to ${play.cap}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isOver && play.won
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
            '${play.nuts}',
            style: TextStyle(
              color: lost ? Palette.bad : Palette.ink,
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

/// The pile itself.
class _Pile extends StatelessWidget {
  const _Pile({
    required this.play,
    required this.pending,
    required this.showClusters,
    required this.onTouch,
  });

  final Play play;
  final int pending;
  final bool showClusters;
  final VoidCallback onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              if (metrics.onHoard(touch.localPosition)) onTouch();
            },
            child: CustomPaint(
              key: HoardScreenState.pileKey,
              size: size,
              painter: HoardView(
                play: play,
                pending: pending,
                showClusters: showClusters,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the pile: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onBack,
    required this.onTake,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onAgain;
  final VoidCallback onBack;
  final VoidCallback onTake;
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
                color: Palette.log,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap the hoard to mark nuts, then Take. You may take '
                        'up to twice what the grey squirrel last took, and '
                        'whoever takes the last nut has the hoard.',
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
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Back', onTap: onBack)),
                const SizedBox(width: 7),
                Expanded(
                    child: _Button(label: 'Take', onTap: onTake, lit: true)),
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
                color: lit ? Palette.edge : Palette.log,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
