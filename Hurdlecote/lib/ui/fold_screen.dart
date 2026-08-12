import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../fold/green.dart';
import '../fold/greens.dart';
import '../fold/play.dart';
import 'foldview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One green: raise a fence that settles the task.
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

  /// Called once, at the settling, with the hurdles used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int hurdles)? onDone;

  @override
  State<FoldScreen> createState() => FoldScreenState();
}

class FoldScreenState extends State<FoldScreen> {
  static const greenKey = ValueKey('green');

  late Play _play;

  (int, int)? _pointing;
  var _hints = 0;

  /// Fences closed that missed the task; not reset by Again, so a
  /// hopeless green can call it after enough of them.
  var _misses = 0;
  var _gaveUp = false;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  int get hints => _hints;
  int get misses => _misses;
  bool get gaveUp => _gaveUp;
  String? get saying => _saying;

  bool get isOver => _play.isDone || _gaveUp;

  @override
  void initState() {
    super.initState();
    _misses = 0;
    _gaveUp = false;
    _set();
  }

  @override
  void didUpdateWidget(FoldScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      setState(() {
        _misses = 0;
        _gaveUp = false;
        _set();
      });
    }
  }

  void _set() {
    _play = Play.of(Greens.at(widget.number));
    _pointing = null;
    _hints = 0;
    _saying = _play.green.winnable
        ? null
        : 'No fence pens this, and the label said so. Close any '
            'fence you like and watch the halves refuse to make a '
            'third; ask why for the counting.';
    _told = false;
    _best = false;
  }

  void _touched((int, int)? spot) {
    if (spot == null || isOver) return;

    if (_play.posts.isNotEmpty &&
        spot == _play.posts.first &&
        _play.mayClose) {
      _close();
      return;
    }

    if (!_play.maySet(spot)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = _play.closed
            ? 'The fence is closed. Back opens it again.'
            : 'A rail cannot cross the fence already stood, nor a '
                'hurdle stand on another\'s rail.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final grew = _play.green.winnable ? _play.finished : null;
    final next = _play.set(spot);
    setState(() {
      _play = next;
      _pointing = null;
      _saying = _note(next, grew);
    });
  }

  String? _note(Play play, List<(int, int)>? grew) {
    if (!play.green.winnable || grew == null) return null;
    final now = play.finished;
    if (now == null) {
      return 'No fence settling the task grows from that hurdle, '
          'and the walk of every extension has looked. Back takes '
          'it down.';
    }
    if (now.length > grew.length) {
      return 'A fence still grows from there, but a longer one: '
          '${now.length} hurdles where ${grew.length} would have '
          'done. Back takes it down.';
    }
    return null;
  }

  void _close() {
    HapticFeedback.selectionClick();
    final next = _play.close();
    setState(() {
      _play = next;
      _pointing = null;
      if (next.isDone) {
        _saying = null;
      } else {
        _misses++;
        if (!next.green.winnable && _misses >= Greens.missesAllowed) {
          _gaveUp = true;
          _saying = null;
        } else {
          _saying = 'That fence pens ${Green.acres(next.pens!)} and '
              'swallows ${next.swallows}; the task is to '
              '${next.green.task}. Back opens it again.';
        }
      }
    });
    if (next.isDone || _gaveUp) _finished();
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. The next hurdle of a fence the walk found, or the close.
  void _showMe() {
    setState(() {
      _hints++;
      if (isOver) {
        _pointing = null;
        _saying = 'The fence is settled.';
        return;
      }
      if (_play.closed) {
        _pointing = null;
        _saying = 'This fence is closed and missed; Back opens it '
            'again.';
        return;
      }
      final fence = _play.finished;
      if (fence == null) {
        _pointing = null;
        _saying = _play.posts.isEmpty
            ? 'There is nothing to show: no fence on this green '
                'settles the task, and the walk has grown them all. '
                'Ask why instead.'
            : 'No settling fence grows from these hurdles, and the '
                'walk has looked. Back takes one down.';
        return;
      }
      final next = _play.nextOf(fence);
      if (next == null) {
        _pointing = _play.posts.first;
        _saying = 'Close it: tap the first hurdle, and the fence '
            'stands at ${_play.posts.length}.';
      } else {
        _pointing = next;
        _saying = 'Set a hurdle there: a fence of ${fence.length} '
            'settling the task grows through it.';
      }
    });
  }

  /// Asked why. The two countings in words.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (_play.isDone) {
      widget.onDone?.call(_play.posts.length).then((best) {
        if (mounted && best) setState(() => _best = true);
      });
    }
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
              _Ledger(
                  play: _play, gaveUp: _gaveUp, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: LayoutBuilder(
                    builder: (context, room) {
                      final size = Size(room.maxWidth, room.maxHeight);
                      final metrics = Metrics(_play, size);

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (touch) => _touched(
                            metrics.crossUnder(touch.localPosition)),
                        child: CustomPaint(
                          key: FoldScreenState.greenKey,
                          size: size,
                          painter: FoldView(
                            play: _play,
                            pointing: _pointing,
                            labels:
                                const TextStyle(fontFamily: 'Roboto'),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (isOver)
                ResultCard(
                  play: _play,
                  gaveUp: _gaveUp,
                  best: _best,
                  hints: _hints,
                  onAgain: () {
                    setState(() {
                      _gaveUp = false;
                      _misses = 0;
                      _set();
                    });
                  },
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

/// The line above the green: which task, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger(
      {required this.play, required this.gaveUp, required this.onLeave});

  final Play play;
  final bool gaveUp;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.green.winnable;

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
                  play.isDone
                      ? 'the task is penned'
                      : gaveUp
                          ? 'unpenned, as the label said it must stay'
                          : dead
                              ? '${play.green.task}: no fence ever '
                                  'will'
                              : play.green.task,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : dead || gaveUp
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.posts.length} hurdle${play.posts.length == 1 ? '' : 's'}',
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

/// Under the green: what the game has to say, and what else can be
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
                    'Tap crossings to set hurdles, rail by rail; tap '
                        'the first hurdle again to close the fence '
                        'and see what it pens.',
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
