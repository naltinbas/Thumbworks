import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../griddle/batches.dart';
import '../griddle/play.dart';
import 'griddleview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One batch: flip the cakes until they sit in order, counting every flip.
class GriddleScreen extends StatefulWidget {
  const GriddleScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the batch is served, with the flips it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int flips)? onDone;

  @override
  State<GriddleScreen> createState() => GriddleScreenState();
}

class GriddleScreenState extends State<GriddleScreen> {
  static const griddleKey = ValueKey('griddle');

  late Play _play;

  var _pointing = -1;
  var _showGaps = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get showGaps => _showGaps;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(GriddleScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Batches.at(widget.number));
    _pointing = -1;
    _showGaps = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int under) {
    if (under < 0 || _play.isServed) return;

    if (!_play.mayFlip(under)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'The slice under the top cake alone turns one cake over '
            'and changes nothing. It goes under any cake below that.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.flip(under);
    setState(() {
      _play = next;
      _pointing = -1;
      _showGaps = false;
      _saying = _note(next);
    });
    if (next.isServed) _finished();
  }

  /// What the griddle has to say after a flip.
  String? _note(Play play) {
    if (play.isServed) return null;
    final could = play.couldStillBe;
    if (could > play.batch.fewest) {
      return 'The fewest flips this batch can still be served in is '
          '$could, ${could - play.batch.fewest} more than the '
          '${play.batch.fewest} it takes. Take the flip back, or carry on '
          'and see.';
    }
    return null;
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.made == 0) return;
    setState(() {
      _play = _play.back;
      _pointing = -1;
      _showGaps = false;
      _saying = _note(_play);
    });
  }

  /// Asked. Where the slice should go.
  void _showMe() {
    final under = _play.next;
    setState(() {
      _hints++;
      _showGaps = false;
      if (under == null) {
        _pointing = -1;
        _saying = 'The batch is served.';
        return;
      }
      _pointing = under;
      _saying = 'Slide the slice under the ${_play.cakes[under]} and turn. '
          'That flip brings serving one nearer.';
    });
  }

  /// Asked why. The gaps, marked on the stack.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showGaps = true;
      _saying = whyWords(_play);
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
        backgroundColor: Palette.iron,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Griddle(
                    play: _play,
                    pointing: _pointing,
                    showGaps: _showGaps,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isServed)
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

/// The line above the griddle: which batch, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = !play.isServed && play.couldStillBe > play.batch.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the batches',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.batch.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isServed
                      ? 'served'
                      : '${play.gapsNow} gap${play.gapsNow == 1 ? '' : 's'} '
                          'on the stack',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isServed ? Palette.good : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.made} / ${play.batch.fewest}',
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

/// The griddle itself.
class _Griddle extends StatelessWidget {
  const _Griddle({
    required this.play,
    required this.pointing,
    required this.showGaps,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showGaps;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.cakeAt(touch.localPosition)),
            child: CustomPaint(
              key: GriddleScreenState.griddleKey,
              size: size,
              painter: GriddleView(
                play: play,
                pointing: pointing,
                showGaps: showGaps,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the griddle: what the game has to say, and what else can be done.
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
                color: Palette.hearth,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a cake to slide the slice under it and turn '
                        'everything above in one go. Serve the batch '
                        'smallest on top, biggest on the griddle.',
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
                color: Palette.hearth,
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
