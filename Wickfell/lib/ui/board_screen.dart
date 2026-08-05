import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../lamps/levels.dart';
import '../lamps/play.dart';
import '../lamps/solve.dart';
import 'lamp.dart';
import 'palette.dart';
import 'result_card.dart';

/// One board: put every lamp out.
class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, with the presses it took, the first time a board is put
  /// out. Answers whether that was the fewest yet.
  final Future<bool> Function(int presses)? onDone;

  @override
  State<BoardScreen> createState() => BoardScreenState();
}

class BoardScreenState extends State<BoardScreen> {
  late Level _level;
  late Play _play;

  /// A lamp the game is pointing at, or -1.
  var _pointing = -1;

  String? _saying;
  var _best = false;
  var _told = false;

  Level get level => _level;
  Play get play => _play;
  int get pointing => _pointing;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(BoardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _level = Levels.at(widget.number);
    // The sums are worked out for the size of board rather than for the
    // board, so they are done once and asked many times.
    _play = Play.of(_level, Sums(_level.grid));
    _pointing = -1;
    _saying = null;
    _best = false;
    _told = false;
  }

  void _press(int at) {
    if (_play.isDone) return;
    HapticFeedback.selectionClick();
    final next = _play.press(at);
    setState(() {
      _play = next;
      _pointing = -1;
      _saying = next.isDone || next.onShortest
          ? null
          : 'That press is not on any shortest way to put them out.';
    });
    if (next.isDone) _finished();
  }

  void _back() {
    if (_play.pressed == 0) return;
    setState(() {
      _play = _play.back;
      _pointing = -1;
      _saying = null;
    });
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _pointing = -1;
      _saying = null;
    });
  }

  /// Asked. Points at a lamp on a shortest way from where the board actually
  /// is — which is the only honest answer, because the presses already made
  /// change what the shortest way is.
  void _showMe() {
    if (_play.isDone) return;
    final next = _play.nextPress;
    setState(() {
      if (next == null) {
        _pointing = -1;
        _saying = 'These cannot be put out at all, which should not have '
            'happened. Start again.';
        return;
      }
      _pointing = next;
      _saying = 'From here it takes ${_play.left} more, and that one is on '
          'the way.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.pressed).then((best) {
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
            children: [
              _Ledger(level: _level, play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _Lamps(
                      play: _play,
                      pointing: _pointing,
                      onPress: _press,
                    ),
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  level: _level,
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  canTakeBack: _play.pressed > 0,
                  onBack: _back,
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

/// The line above the board: which one, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.level,
    required this.play,
    required this.onLeave,
  });

  final Level level;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.pressed > level.presses;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the boards',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.name,
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
                      ? 'all out'
                      : play.onShortest
                          ? '${play.left} to go'
                          : '${play.left} to go, ${play.wasted} more than it '
                              'had to be',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.onShortest ? Palette.inkDim : Palette.bad,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.pressed} / ${level.presses}',
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

/// The board itself.
class _Lamps extends StatelessWidget {
  const _Lamps({
    required this.play,
    required this.pointing,
    required this.onPress,
  });

  final Play play;
  final int pointing;
  final ValueChanged<int> onPress;

  @override
  Widget build(BuildContext context) {
    final grid = play.grid;

    return LayoutBuilder(
      builder: (context, box) {
        final side = (box.maxWidth / grid.across).clamp(36.0, 76.0);

        return SizedBox(
          width: side * grid.across,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var row = 0; row < grid.down; row++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var column = 0; column < grid.across; column++)
                      _One(
                        at: row * grid.across + column,
                        side: side,
                        play: play,
                        pointing: pointing,
                        onPress: onPress,
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _One extends StatelessWidget {
  const _One({
    required this.at,
    required this.side,
    required this.play,
    required this.pointing,
    required this.onPress,
  });

  final int at;
  final double side;
  final Play play;
  final int pointing;
  final ValueChanged<int> onPress;

  @override
  Widget build(BuildContext context) {
    final lit = play.grid.isLit(play.board, at);

    return Semantics(
      button: true,
      label: 'lamp ${at + 1}, ${lit ? 'lit' : 'out'}',
      child: GestureDetector(
        onTap: () => onPress(at),
        child: ExcludeSemantics(
          child: SizedBox(
            width: side,
            height: side,
            child: Center(
              child: Lamp(
                lit: lit,
                side: side * 0.92,
                pointed: at == pointing,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Under the board: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.canTakeBack,
    required this.onBack,
    required this.onAgain,
    required this.onShowMe,
  });

  final String? saying;
  final bool canTakeBack;
  final VoidCallback onBack;
  final VoidCallback onAgain;
  final VoidCallback onShowMe;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: Palette.hill,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.socket, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a lamp. It turns, and so does everything it touches.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Button(
                    label: 'Take back',
                    dead: !canTakeBack,
                    onTap: onBack,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _Button(
                    label: 'Again',
                    dead: !canTakeBack,
                    onTap: onAgain,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _Button(label: 'Show me', dead: false, onTap: onShowMe),
                ),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.dead,
    required this.onTap,
  });

  final String label;
  final bool dead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: dead ? null : onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Palette.hill,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: dead ? Palette.socket : Palette.lit,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: dead ? Palette.inkDim : Palette.ink,
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
