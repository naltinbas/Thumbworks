import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tilth/play.dart';
import '../tilth/tilths.dart';
import 'palette.dart';
import 'result_card.dart';
import 'tilthview.dart';

/// One tilth: sow every seed home.
class TilthScreen extends StatefulWidget {
  const TilthScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when every seed is home, with the askings used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<TilthScreen> createState() => TilthScreenState();
}

class TilthScreenState extends State<TilthScreen> {
  static const stripKey = ValueKey('strip');

  late Play _play;

  var _pointing = -1;
  var _showSowable = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get showSowable => _showSowable;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(TilthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Tilths.at(widget.number));
    _pointing = -1;
    _showSowable = false;
    _hints = 0;
    _saying = _play.tilth.winnable
        ? null
        : 'This board is dead where it lies, and the label said so. The '
            'red furrow is the reason; ask why for the words.';
    _told = false;
    _best = false;
  }

  void _touched(int furrow) {
    if (furrow < 1 || _play.isHome) return;

    if (!_play.maySow(furrow)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'Furrow $furrow holds ${_play.seedsIn(furrow)} and may '
            'be sown only holding exactly $furrow.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.canStill;
    final next = _play.sow(furrow);
    setState(() {
      _play = next;
      _pointing = -1;
      _showSowable = false;
      _saying = _note(next, could);
    });
    if (next.isHome) _finished();
  }

  String? _note(Play play, bool could) {
    if (play.isHome) return null;
    if (play.trapped.isNotEmpty) {
      return 'Furrow ${play.trapped.join(" and ")} now holds more than '
          'its number: trapped, and the seeds in it can never leave. '
          'Take the sowing back.';
    }
    if (could && play.tilth.winnable && !play.canStill) {
      return 'That sowing left a board no play brings home. Take it '
          'back.';
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
      _pointing = -1;
      _showSowable = false;
      _saying = null;
    });
  }

  /// Asked. The sowing that keeps the way home.
  void _showMe() {
    final furrow = _play.next;
    setState(() {
      _hints++;
      _showSowable = false;
      if (_play.isHome) {
        _pointing = -1;
        _saying = 'Every seed is home.';
        return;
      }
      if (furrow == null) {
        _pointing = -1;
        _saying = _play.tilth.winnable
            ? 'No sowing keeps the way home. Take some back.'
            : 'There is nothing to show: this board was dead before a '
                'hand touched it. Ask why instead.';
        return;
      }
      _pointing = furrow;
      _saying = 'Sow furrow $furrow: from there the way home stays '
          'open, and the search has checked it.';
    });
  }

  /// Asked why. The sowable rims, and the words.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showSowable = true;
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
        backgroundColor: Palette.field,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Strip(
                    play: _play,
                    pointing: _pointing,
                    showSowable: _showSowable,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isHome)
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

/// The line above the strip: which tilth, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.isHome &&
        (!play.canStill || play.trapped.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the tilths',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.tilth.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isHome
                      ? 'every seed is home'
                      : dead
                          ? 'seeds are trapped'
                          : 'a furrow sows holding exactly its number',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isHome
                        ? Palette.good
                        : dead
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.barned} / ${play.tilth.seeds}',
            style: TextStyle(
              color: dead ? Palette.bad : Palette.ink,
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

/// The strip itself.
class _Strip extends StatelessWidget {
  const _Strip({
    required this.play,
    required this.pointing,
    required this.showSowable,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showSowable;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.furrowAt(touch.localPosition)),
            child: CustomPaint(
              key: TilthScreenState.stripKey,
              size: size,
              painter: TilthView(
                play: play,
                pointing: pointing,
                showSowable: showSowable,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the strip: what the game has to say, and what else can be done.
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
                color: Palette.barnwood,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a furrow holding exactly its number to sow it: '
                        'one seed to each nearer furrow, the last into '
                        'the barn. Bring every seed home.',
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
                color: Palette.barnwood,
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
