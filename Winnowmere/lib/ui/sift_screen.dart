import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../sift/fewest.dart';
import '../sift/play.dart';
import '../sift/puzzles.dart';
import 'frame.dart';
import 'palette.dart';
import 'result_card.dart';

/// One puzzle: build a network that sorts every row there is.
class SiftScreen extends StatefulWidget {
  const SiftScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a network sorts, with how many comparators
  /// it took. Answers whether that beat what was written down before.
  final Future<bool> Function(int crosses)? onDone;

  @override
  State<SiftScreen> createState() => SiftScreenState();
}

class SiftScreenState extends State<SiftScreen> {
  static const frameKey = ValueKey('frame');

  late Sifting _sifting;
  late Play _play;

  /// A line waiting for a second one, or -1.
  var _holding = -1;

  /// A row of noughts and ones on show, or -1.
  var _showing = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Sifting get sifting => _sifting;
  Play get play => _play;
  int get holding => _holding;
  int get showing => _showing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(SiftScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _sifting = Siftings.at(widget.number);
    _play = Play.of(_sifting);
    _holding = -1;
    _showing = -1;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  /// A tap on a comparator takes it out. A tap on a line takes hold of it,
  /// and the second line puts a comparator between the two.
  void _touched(int line, int cross) {
    if (_play.isDone) return;

    if (cross >= 0) {
      if (cross < _play.given) {
        setState(() => _saying = 'That one came with the puzzle.');
        return;
      }
      HapticFeedback.selectionClick();
      setState(() {
        _play = _play.take(cross);
        _holding = -1;
        _showing = -1;
        _saying = null;
      });
      return;
    }

    if (line < 0) return;
    if (_holding < 0) {
      HapticFeedback.selectionClick();
      setState(() {
        _holding = line;
        _saying = null;
      });
      return;
    }
    if (_holding == line) {
      setState(() {
        _holding = -1;
        _saying = null;
      });
      return;
    }

    final next = _play.add(_holding, line);
    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _holding = -1;
      _showing = next.fails ?? -1;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the frame has to say after a comparator goes in or comes out.
  ///
  /// A row that still comes out unsorted, named. There is no need to search
  /// for one, because there are only 2^n rows and a network that sorts all of
  /// them sorts everything: that is the whole of the checking, and it is why
  /// the answer is instant.
  String? _note(Play play) {
    if (play.isDone) return null;
    final row = play.fails;
    if (row == null) return null;
    return '${play.wordsOf(row)} comes out ${play.outOf(row)}. '
        '${play.right} of ${play.rows} rows are right.';
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _holding = -1;
      _showing = -1;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Finishes the network in the fewest there is from where it stands,
  /// and puts the next comparator of that in.
  void _showMe() {
    if (_play.isDone) return;
    final rest = Fewest.fromHere(_play.sieve);
    setState(() {
      _hints++;
      if (rest == null) {
        _saying = 'Nothing finishes this off. Take some out.';
        return;
      }
      if (rest.$2.crosses.length <= _play.count) {
        _saying = 'It already sorts everything.';
        return;
      }
      final next = rest.$2.crosses[_play.count];
      _play = _play.add(next.upper, next.lower);
      _holding = -1;
      _showing = _play.fails ?? -1;
      _saying = 'Lines ${next.upper + 1} and ${next.lower + 1}. '
          '${rest.$1 - 1} more after that.';
      if (_play.isDone) _finished();
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.count).then((best) {
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
                  child: _Frame(
                    play: _play,
                    holding: _holding,
                    showing: _showing,
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line above the frame: which puzzle, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.over > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the puzzles',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.sifting.name,
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
                      ? 'every row comes out sorted'
                      : '${play.right} of ${play.rows} rows sorted',
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
            '${play.count} / ${play.sifting.fewest}',
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

/// The frame itself.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.play,
    required this.holding,
    required this.showing,
    required this.onTouch,
  });

  final Play play;
  final int holding;
  final int showing;
  final void Function(int line, int cross) onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(
              metrics.lineAt(touch.localPosition),
              metrics.crossAt(touch.localPosition),
            ),
            child: CustomPaint(
              key: SiftScreenState.frameKey,
              size: size,
              painter: Frame(
                play: play,
                holding: holding,
                showing: showing,
                labels: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      );
}

/// Under the frame: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onShowMe,
  });

  final String? saying;
  final VoidCallback onAgain;
  final VoidCallback onShowMe;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Palette.bench,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.rail, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap two lines to put a comparator between them. It puts '
                        'the smaller of the two on the upper line.',
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
                color: Palette.bench,
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
