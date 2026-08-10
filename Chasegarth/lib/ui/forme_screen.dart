import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../forme/chases.dart';
import '../forme/parity.dart';
import '../forme/play.dart';
import 'formeview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One forme: slide the type about until the line reads right.
class FormeScreen extends StatefulWidget {
  const FormeScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a forme locks, with the slides it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int slides)? onDone;

  @override
  State<FormeScreen> createState() => FormeScreenState();
}

class FormeScreenState extends State<FormeScreen> {
  static const formeKey = ValueKey('forme');

  late Play _play;

  var _pointing = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(FormeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Formes.at(widget.number), Formes.slidesFor(widget.number));
    _pointing = -1;
    _hints = 0;
    _saying = _play.canBeLocked
        ? null
        : 'This forme cannot be made to read right as it stands. Why says '
            'what is wrong with it.';
    _told = false;
    _best = false;
  }

  void _touched(int cell) {
    if (cell < 0 || _play.isLocked) return;

    if (_play.sortIn(cell) < 0) return;
    if (!_play.canSlide.contains(cell)) {
      setState(() {
        _pointing = -1;
        _saying = 'Only a letter beside the empty cell can be slid into it.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.slide(cell);
    setState(() {
      _play = next;
      _pointing = -1;
      _saying = _note(next);
    });
    if (next.isLocked) _finished();
  }

  /// What the bench has to say after a slide.
  ///
  /// One thing, and only when it is true: that the forme can no longer be
  /// locked in as few slides as it could have been. The game can say that
  /// because the walk that settled the forme settled every arrangement there
  /// is, so the distance from anywhere is a look in a table.
  String? _note(Play play) {
    if (play.isLocked || !play.canBeLocked) return null;
    final could = play.couldFinishIn!;
    if (could <= play.forme.fewest) return null;
    return 'The fewest this can be locked in now is $could slides, which is '
        '${could - play.forme.fewest} more than the ${play.forme.fewest} it '
        'takes.';
  }

  void _again() {
    setState(() {
      _set();
    });
  }

  /// Asked. Points at the letter to slide next, on a shortest way to reading
  /// right from where the type actually stands.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = -1;
        _saying = _play.canBeLocked
            ? 'It reads right already.'
            : 'No slide will do it. The pair have to be swapped back.';
        return;
      }
      _pointing = next;
      _saying = 'Slide the ${_play.chase.letterOf(_play.sortIn(next))} in. '
          '${_play.left! - 1} more after that.';
    });
  }

  /// Swaps the dropped pair back, on the forme that needs it.
  void _mend() {
    final pair = Parity.swapThatWouldDoIt(_play.chase, _play.stands);
    if (pair == null) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _play = _play.mend();
      _pointing = -1;
      _saying = 'The ${_play.chase.letterOf(pair.$1)} and the '
          '${_play.chase.letterOf(pair.$2)} are the right way round again. '
          '${_play.left} slides finish it.';
    });
  }

  /// Asked why. The pairs out of order, and what they mean for this frame.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      final pairs = _play.outOfOrder;
      final wide = _play.chase.wide;

      final counted = wide.isOdd
          ? 'Reading straight through, $pairs pairs of letters are out of '
              'order. A sideways slide changes no pairs, and on a frame '
              '$wide cells wide an up or down slide carries a letter past '
              '${wide - 1} others, so the count stays '
              '${pairs.isEven ? 'even' : 'odd'} whatever anybody does.'
          : 'Reading straight through, $pairs pairs of letters are out of '
              'order, and the empty cell is ${Parity.emptyAway(_play.chase, _play.stands)} '
              'rows from its own. On a frame $wide cells wide an up or down '
              'slide flips both of those at once, so odd or even, taken '
              'together, never changes.';

      _saying = _play.canBeLocked
          ? '$counted The finished frame comes out the same way, so this can '
              'still be slid right.'
          : '$counted The finished frame comes out the other way, so no '
              'sliding will ever make this read right. Not because nobody has '
              'found the way. There is no way.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.made).then((best) {
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
                  padding: const EdgeInsets.all(14),
                  child: _Forme(
                    play: _play,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isLocked)
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
                  canBeLocked: _play.canBeLocked,
                  onAgain: _again,
                  onShowMe: _showMe,
                  onMend: _mend,
                  onWhy: _why,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line above the chase: which forme, what it reads, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final could = play.couldFinishIn;
    final over = could != null && could > play.forme.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the formes',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.forme.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isLocked
                      ? 'the line reads right'
                      : 'reads "${play.reads.trim()}"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isLocked ? Palette.good : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.made} / ${play.forme.fewest}',
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

/// The chase itself.
class _Forme extends StatelessWidget {
  const _Forme({
    required this.play,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.cellAt(touch.localPosition)),
            child: CustomPaint(
              key: FormeScreenState.formeKey,
              size: size,
              painter: FormeView(
                play: play,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the chase: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.canBeLocked,
    required this.onAgain,
    required this.onShowMe,
    required this.onMend,
    required this.onWhy,
  });

  final String? saying;
  final bool canBeLocked;
  final VoidCallback onAgain;
  final VoidCallback onShowMe;
  final VoidCallback onMend;
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
                    'Tap a letter beside the empty cell to slide it in. The '
                        'line reads left to right, top row first.',
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
                Expanded(
                  child: canBeLocked
                      ? _Button(label: 'Show me', onTap: onShowMe)
                      : _Button(label: 'Swap them', onTap: onMend, loud: true),
                ),
                const SizedBox(width: 9),
                Expanded(child: _Button(label: 'Why', onTap: onWhy)),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap, this.loud = false});

  final String label;
  final VoidCallback onTap;
  final bool loud;

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
                color: loud ? Palette.brass : Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: loud ? Palette.brass : Palette.edge,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: loud ? Palette.night : Palette.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
