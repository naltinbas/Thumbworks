import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../fold/fewest.dart';
import '../fold/folds.dart';
import '../fold/play.dart';
import 'foldview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One night: post the fewest shepherds that leave no lane unwatched.
class FoldScreen extends StatefulWidget {
  const FoldScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time every lane is watched, with the shepherds
  /// standing. Answers whether that beat what was written down before.
  final Future<bool> Function(int shepherds)? onDone;

  @override
  State<FoldScreen> createState() => FoldScreenState();
}

class FoldScreenState extends State<FoldScreen> {
  static const foldKey = ValueKey('fold');

  late Play _play;

  var _pointing = -1;
  var _showMatching = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get showMatching => _showMatching;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(FoldScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    final fold = Folds.at(widget.number);
    _play = Play.of(fold, Watches.of(fold));
    _pointing = -1;
    _showMatching = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int gate) {
    if (gate < 0) return;

    HapticFeedback.selectionClick();
    final wasDone = _play.isDone;
    final next = _play.touch(gate);
    setState(() {
      _play = next;
      _pointing = -1;
      _showMatching = false;
      _saying = _note(next);
    });
    if (!wasDone && next.isDone) _finished();
  }

  /// What the fold has to say after a shepherd is posted or stood down.
  String? _note(Play play) {
    if (play.isDone) return null;
    final could = play.couldStillBe;
    if (could > play.fold.fewest) {
      return 'The fewest this night can be watched with now is $could, which '
          'is ${could - play.fold.fewest} more than the ${play.fold.fewest} '
          'it takes.';
    }
    return play.unwatched <= 3
        ? '${play.unwatched} lane${play.unwatched == 1 ? '' : 's'} still '
            'dark.'
        : null;
  }

  void _again() {
    setState(_set);
  }

  /// Asked. A gate to post next that keeps the night at what it can still
  /// be.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      _showMatching = false;
      if (next == null) {
        _pointing = -1;
        _saying = 'Every lane is watched.';
        return;
      }
      _pointing = next;
      _saying = '${_play.fold.gates[next].name}. A shepherd there keeps the '
          'night at ${_play.couldStillBe}.';
    });
  }

  /// Asked why. The matching when it carries the number, and the lane count
  /// when it does not.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      final watch = _play.watch;
      final fold = _play.fold;

      if (watch.matchingIsTight) {
        _showMatching = true;
        _saying = 'The ${watch.matching.length} marked lanes keep apart: no '
            'two of them share a gate. Each needs a shepherd of its own, so '
            '${watch.matching.length} is the fewest, and '
            '${watch.matching.length} is enough.';
        return;
      }

      _showMatching = false;
      _saying = 'No two lanes of this ring keep apart, so pairing proves '
          'nothing here. Count instead: ${fold.many} lanes, and no gate '
          'touches more than ${fold.busiest}, so one shepherd watches '
          '${fold.busiest} at best and ${watch.byLanes} is the fewest.';
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
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _FoldMap(
                    play: _play,
                    pointing: _pointing,
                    showMatching: _showMatching,
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

/// The line above the fold: which night, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.couldStillBe > play.fold.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the folds',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.fold.name,
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
                      ? 'no lane is dark'
                      : '${play.unwatched} of ${play.fold.many} lanes dark',
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
            '${play.standing} / ${play.fold.fewest}',
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

/// The fold itself.
class _FoldMap extends StatelessWidget {
  const _FoldMap({
    required this.play,
    required this.pointing,
    required this.showMatching,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showMatching;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.gateAt(touch.localPosition)),
            child: CustomPaint(
              key: FoldScreenState.foldKey,
              size: size,
              painter: FoldView(
                play: play,
                pointing: pointing,
                showMatching: showMatching,
                labels: const TextStyle(fontFamily: 'Roboto', fontSize: 11),
              ),
            ),
          );
        },
      );
}

/// Under the fold: what the game has to say, and what else can be done.
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
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a gate to post a shepherd there. A shepherd watches '
                        'every lane that touches the gate, and the night is '
                        'safe when no lane is dark.',
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
                const SizedBox(width: 9),
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 9),
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
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
