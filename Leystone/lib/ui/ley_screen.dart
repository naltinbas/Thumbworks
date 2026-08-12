import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ley/greens.dart';
import '../ley/play.dart';
import 'leyview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One green: raise the ring the mason asks for.
class LeyScreen extends StatefulWidget {
  const LeyScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the ring's standing, with the askings used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<LeyScreen> createState() => LeyScreenState();
}

class LeyScreenState extends State<LeyScreen> {
  static const greenKey = ValueKey('green');

  late Play _play;

  (int, int)? _pointing;
  (((int, int), (int, int)), (int, int))? _ley;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  (((int, int), (int, int)), (int, int))? get ley => _ley;
  int get hints => _hints;
  String? get saying => _saying;

  /// On the hopeless green: six stand and nowhere is clear.
  bool get stuck {
    if (_play.green.winnable || _play.isDone) return false;
    if (_play.stones.length != _play.green.asked - 1) return false;
    for (var x = 0; x < _play.green.size; x++) {
      for (var y = 0; y < _play.green.size; y++) {
        if (_play.mayRaise((x, y))) return false;
      }
    }
    return true;
  }

  bool get isOver => _play.isDone || stuck;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(LeyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Greens.at(widget.number));
    _pointing = null;
    _ley = null;
    _hints = 0;
    _saying = _play.green.winnable
        ? null
        : 'Seven stones are asked and the label has said already '
            'that seven never stand. Raise the six that do and '
            'watch every last berth ley; ask why for the counting.';
    _told = false;
    _best = false;
  }

  void _touched((int, int)? berth) {
    if (berth == null || isOver) return;

    if (_play.stones.contains(berth)) {
      HapticFeedback.selectionClick();
      setState(() {
        _play = _play.lower(berth);
        _pointing = null;
        _ley = null;
        _saying = null;
      });
      return;
    }

    final pair = _play.leyOf(berth);
    if (pair != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _ley = (pair, berth);
        _pointing = null;
        _saying = 'That berth stands on the ley through '
            '${_name(pair.$1)} and ${_name(pair.$2)}: the line is '
            'drawn, and no ring may hold three stones on one.';
      });
      return;
    }

    if (_play.isDone) return;
    HapticFeedback.selectionClick();
    final grew = _play.green.winnable ? _play.finished : null;
    final next = _play.raise(berth);
    setState(() {
      _play = next;
      _pointing = null;
      _ley = null;
      _saying = _note(next, grew);
    });
    if (next.isDone) _finished();
  }

  String _name((int, int) berth) =>
      'the stone at row ${berth.$2 + 1}, berth ${berth.$1 + 1}';

  String? _note(Play play, List<(int, int)>? grew) {
    if (play.isDone || !play.green.winnable || grew == null) {
      return null;
    }
    if (play.finished == null) {
      return 'No full ring grows from those stones, sound as they '
          'stand: the search has raised every extension. Take one '
          'down.';
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
      _ley = null;
      _saying = null;
    });
  }

  /// Asked. The next stone of a ring the search raised.
  void _showMe() {
    setState(() {
      _hints++;
      _ley = null;
      if (isOver) {
        _pointing = null;
        _saying = 'The ring stands.';
        return;
      }
      final ring = _play.finished;
      if (ring == null) {
        _pointing = null;
        _saying = _play.stones.isEmpty
            ? 'There is nothing to show: no ring of '
                '${_play.green.asked} stands on this green, and the '
                'search has raised them all. Ask why instead.'
            : 'No full ring grows from these stones, and the '
                'search has raised every extension. Take one down.';
        return;
      }
      final berth = _play.nextOf(ring);
      _pointing = berth;
      _saying = 'Raise a stone there: a full ring of '
          '${_play.green.asked} grows through it.';
    });
  }

  /// Asked why. The counting and the search in words.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _ley = null;
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
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, stuck: stuck, onLeave: widget.onLeave),
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
                            metrics.berthUnder(touch.localPosition)),
                        child: CustomPaint(
                          key: LeyScreenState.greenKey,
                          size: size,
                          painter: LeyView(
                            play: _play,
                            pointing: _pointing,
                            ley: _ley,
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
                  stuck: stuck,
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

/// The line above the green: which one, and how the ring stands.
class _Ledger extends StatelessWidget {
  const _Ledger(
      {required this.play, required this.stuck, required this.onLeave});

  final Play play;
  final bool stuck;
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
                      ? 'the ring stands'
                      : stuck
                          ? 'six stand and every berth leys, as the '
                              'label said'
                          : dead
                              ? 'seven asked, and seven never stand'
                              : 'raise ${play.green.asked} with no '
                                  'three on a line',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : dead || stuck
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.stones.length} of ${play.green.asked}',
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
                    'Tap a berth to raise a stone, tap a stone to '
                        'take it down. A refused berth shows the '
                        'ley it would stand on.',
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
