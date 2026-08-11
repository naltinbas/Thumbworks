import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cheese/blocks.dart';
import '../cheese/play.dart';
import 'cheeseview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One block: bite well, and let the grey mouse take the mould.
class CheeseScreen extends StatefulWidget {
  const CheeseScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the grey mouse takes the mould, with the bites it
  /// took you. Answers whether that beat what was written down before.
  final Future<bool> Function(int bites)? onDone;

  @override
  State<CheeseScreen> createState() => CheeseScreenState();
}

class CheeseScreenState extends State<CheeseScreen> {
  static const cheeseKey = ValueKey('cheese');

  late Play _play;

  (int, int)? _pointing;
  var _showWhy = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  bool get showWhy => _showWhy;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(CheeseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Blocks.at(widget.number));
    _pointing = null;
    _showWhy = false;
    _hints = 0;
    _saying = _play.winnable || _play.isOver
        ? null
        : 'The grey mouse bit first, and first wins every block. This one '
            'is here to be felt, not won.';
    _told = false;
    _best = false;
  }

  void _touched((int, int)? crumb) {
    if (crumb == null || _play.isOver) return;
    final (x, y) = crumb;
    if (!_play.standing(x, y)) return;

    HapticFeedback.selectionClick();
    final wasWinnable = _play.winnable;
    final next = _play.touch(x, y);
    setState(() {
      _play = next;
      _pointing = null;
      _showWhy = false;
      _saying = _note(next, wasWinnable);
    });
    if (next.isOver) _finished();
  }

  /// What the larder has to say after an exchange.
  String? _note(Play play, bool wasWinnable) {
    if (play.isOver) return null;
    if (wasWinnable && !play.winnable) {
      return 'The grey mouse has the block now: whatever you bite, it has '
          'an answer, all the way down to the mould. Take the bite back.';
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
      _showWhy = false;
      _saying = null;
    });
  }

  /// Asked. The winning bite, when there is one.
  void _showMe() {
    final bite = _play.next;
    setState(() {
      _hints++;
      _showWhy = false;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The block is settled.';
        return;
      }
      if (bite == null) {
        _pointing = null;
        _saying = 'There is nothing to show: every bite from here loses '
            'against a mouse that knows. Bite and see what it does.';
        return;
      }
      _pointing = bite;
      _saying = 'Bite the crumb ${bite.$1} along, ${bite.$2} up. The '
          'shape it leaves is one the grey mouse cannot answer.';
    });
  }

  /// Asked why.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _showWhy = true;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (!_play.won) return;
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
        backgroundColor: Palette.larder,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _Cheese(
                    play: _play,
                    pointing: _pointing,
                    showWhy: _showWhy,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isOver)
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

/// The line above the shelf: which block, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final lost = !play.winnable && !(play.isOver && play.won);
    var crumbs = 0;
    for (final column in play.heights) {
      crumbs += column;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the shelf',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.block.name,
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
                          ? 'the mould was the grey mouse\'s'
                          : 'the mould was yours')
                      : '$crumbs crumb${crumbs == 1 ? '' : 's'} standing',
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
            play.block.hopeless
                ? '${play.made} / none'
                : '${play.made} / ${play.block.fewest}',
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

/// The cheese itself.
class _Cheese extends StatelessWidget {
  const _Cheese({
    required this.play,
    required this.pointing,
    required this.showWhy,
    required this.onTouch,
  });

  final Play play;
  final (int, int)? pointing;
  final bool showWhy;
  final ValueChanged<(int, int)?> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.crumbAt(touch.localPosition)),
            child: CustomPaint(
              key: CheeseScreenState.cheeseKey,
              size: size,
              painter: CheeseView(
                play: play,
                pointing: pointing,
                showWhy: showWhy,
              ),
            ),
          );
        },
      );
}

/// Under the shelf: what the game has to say, and what else can be done.
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
                color: Palette.shelf,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a crumb to bite it and everything above and right '
                        'of it. The grey mouse bites back. Whoever takes '
                        'the mouldy crumb has lost.',
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
                color: Palette.shelf,
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
