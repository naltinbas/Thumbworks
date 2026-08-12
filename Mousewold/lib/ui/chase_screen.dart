import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../chase/grounds.dart';
import '../chase/play.dart';
import 'chaseview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ground: corner the mouse.
class ChaseScreen extends StatefulWidget {
  const ChaseScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the catch, with the rounds taken. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int rounds)? onDone;

  @override
  State<ChaseScreen> createState() => ChaseScreenState();
}

class ChaseScreenState extends State<ChaseScreen> {
  static const groundKey = ValueKey('ground');

  late Play _play;

  var _pointing = -1;
  List<int>? _folding;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  List<int>? get folding => _folding;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(ChaseScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Grounds.at(widget.number));
    _pointing = -1;
    _folding = null;
    _hints = 0;
    _saying = _play.ground.winnable
        ? null
        : 'No chase catches this mouse, and the label said so. '
            'Chase it round and watch the lead hold; ask why for the '
            'corners.';
    _told = false;
    _best = false;
  }

  void _touched(int post) {
    if (post < 0 || _play.isOver) return;

    if (!_play.mayStep(post)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'No path runs there from where the cat stands.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.toCatch;
    final next = _play.step(post);
    setState(() {
      _play = next;
      _pointing = -1;
      _folding = null;
      _saying = _note(next, could);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play, int? could) {
    if (play.isOver || !play.ground.winnable) return null;
    final now = play.toCatch;
    if (could != null && now != null && now >= could) {
      return 'That step let the mouse breathe: still $now '
          'round${now == 1 ? '' : 's'} to the catch. Back takes it '
          'off the count.';
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
      _folding = null;
      _saying = null;
    });
  }

  /// Asked. The step the search closes with.
  void _showMe() {
    final post = _play.next;
    setState(() {
      _hints++;
      _folding = null;
      if (_play.isOver) {
        _pointing = -1;
        _saying = 'The chase is settled.';
        return;
      }
      if (post == null) {
        _pointing = -1;
        _saying = 'There is nothing to show: no step shortens this '
            'chase, and the search has read every one. Ask why '
            'instead.';
        return;
      }
      _pointing = post;
      _saying = 'Step there: the search has read every chase below '
          'it, and the mouse\'s best reply still loses ground.';
    });
  }

  /// Asked why. The folding, numbered in gold.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _folding = _play.rules.folding();
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (_play.caught) {
      widget.onDone?.call(_play.rounds).then((best) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _GroundMap(
                    play: _play,
                    pointing: _pointing,
                    folding: _folding,
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

/// The line above the ground: which one, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.ground.winnable;
    final toCatch = play.toCatch;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the grounds',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.ground.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.caught
                      ? 'the mouse is cornered'
                      : play.gaveUp
                          ? 'the mouse holds its lead, as it always '
                              'would'
                          : dead
                              ? 'the mouse keeps its lead forever'
                              : '$toCatch round'
                                  '${toCatch == 1 ? '' : 's'} to the '
                                  'catch',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.caught
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
            '${play.rounds} round${play.rounds == 1 ? '' : 's'}',
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

/// The ground itself.
class _GroundMap extends StatelessWidget {
  const _GroundMap({
    required this.play,
    required this.pointing,
    required this.folding,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final List<int>? folding;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.postUnder(touch.localPosition)),
            child: CustomPaint(
              key: ChaseScreenState.groundKey,
              size: size,
              painter: ChaseView(
                play: play,
                pointing: pointing,
                folding: folding,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the ground: what the game has to say, and what else can be
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
                    'Tap a post along a path to step the cat there; '
                        'the mouse flees at once, playing as well as '
                        'a mouse can. Land on it to win.',
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
