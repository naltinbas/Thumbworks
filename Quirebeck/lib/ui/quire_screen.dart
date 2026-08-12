import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../quire/play.dart';
import '../quire/quires.dart';
import 'palette.dart';
import 'quireview.dart';
import 'result_card.dart';

/// One quire: weave it to the binder's asking.
class QuireScreen extends StatefulWidget {
  const QuireScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the settling, with the weaves taken. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int weaves)? onDone;

  @override
  State<QuireScreen> createState() => QuireScreenState();
}

class QuireScreenState extends State<QuireScreen> {
  static const stackKey = ValueKey('stack');

  late Play _play;

  /// The weave being pointed at: true in, false out, null neither.
  bool? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  bool? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(QuireScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Quires.at(widget.number));
    _pointing = null;
    _hints = 0;
    _saying = _play.quire.winnable
        ? null
        : 'No weaving mends this quire, and the label said so. '
            'Weave it any way you like and watch the pair stay '
            'turned; ask why for the count of swaps.';
    _told = false;
    _best = false;
  }

  void _weave(bool inward) {
    if (_play.isOver) return;

    HapticFeedback.selectionClick();
    final could = _play.toDone;
    final next = _play.step(inward);
    setState(() {
      _play = next;
      _pointing = null;
      _saying = _note(next, could);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play, int could) {
    if (play.isOver || could == -1) return null;
    final now = play.toDone;
    if (now >= could) {
      return 'That weave gave the task nothing: still $now '
          'weave${now == 1 ? '' : 's'} to go at best. Back unweaves '
          'it.';
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
      _saying = null;
    });
  }

  /// Asked. The weave the walk closes with.
  void _showMe() {
    final weave = _play.next;
    setState(() {
      _hints++;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The weaving is over.';
        return;
      }
      if (weave == null) {
        _pointing = null;
        _saying = 'There is nothing to show: no weaving from here '
            'ever mends this quire, and the walk has read them all. '
            'Ask why instead.';
        return;
      }
      _pointing = weave;
      _saying = 'Weave ${weave ? 'in' : 'out'}: the walk of every '
          'weaving from here closes in ${_play.toDone}.';
    });
  }

  /// Asked why. The figures in words.
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
      widget.onDone?.call(_play.weaves).then((best) {
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
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                  child: LayoutBuilder(
                    builder: (context, room) => CustomPaint(
                      key: QuireScreenState.stackKey,
                      size: Size(room.maxWidth, room.maxHeight),
                      painter: QuireView(
                        play: _play,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                    ),
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
                  pointing: _pointing,
                  onWeave: _weave,
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

/// The line above the stack: which quire, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.quire.winnable;
    final toDone = play.toDone;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the quires',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.quire.name,
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
                      ? play.quire.home
                          ? 'every leaf sits its bound seat'
                          : 'the plate sits its seat'
                      : play.gaveUp
                          ? 'unmended, as the label said it must stay'
                          : dead
                              ? 'no weaving ever mends this one'
                              : '$toDone weave${toDone == 1 ? '' : 's'} '
                                  'to the task at best',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : dead || play.gaveUp
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.weaves} weave${play.weaves == 1 ? '' : 's'}',
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

/// Under the stack: the two weaves, what the game has to say, and
/// what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.pointing,
    required this.onWeave,
    required this.onAgain,
    required this.onBack,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final bool? pointing;
  final ValueChanged<bool> onWeave;
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
                    'A weave splits the stack in half and lays the '
                        'halves together one leaf at a time. Out '
                        'keeps the first leaf first; in buries it.',
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
                Expanded(
                  child: _WeaveButton(
                    label: 'Weave out',
                    lit: pointing == false,
                    onTap: () => onWeave(false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _WeaveButton(
                    label: 'Weave in',
                    lit: pointing == true,
                    onTap: () => onWeave(true),
                  ),
                ),
              ],
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

class _WeaveButton extends StatelessWidget {
  const _WeaveButton({
    required this.label,
    required this.lit,
    required this.onTap,
  });

  final String label;
  final bool lit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Palette.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: lit ? Palette.shown : Palette.leafRim,
                  width: lit ? 2.6 : 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
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
