import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../floor/play.dart';
import '../floor/rooms.dart';
import 'floorview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One room: plank it whole.
class FloorScreen extends StatefulWidget {
  const FloorScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the laid floor, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<FloorScreen> createState() => FloorScreenState();
}

class FloorScreenState extends State<FloorScreen> {
  static const roomKey = ValueKey('room');

  late Play _play;

  var _armed = -1;
  (int, int)? _pointing;
  var _showColours = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get armed => _armed;
  (int, int)? get pointing => _pointing;
  bool get showColours => _showColours;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(FloorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Rooms.at(widget.number));
    _armed = -1;
    _pointing = null;
    _showColours = false;
    _hints = 0;
    _saying = _play.room.winnable
        ? null
        : 'No laying floors this room, and the label said so. Lay '
            'planks and watch them strand; ask why for the colours.';
    _told = false;
    _best = false;
  }

  void _touched(int cell) {
    if (cell < 0 || _play.isDone) return;

    HapticFeedback.selectionClick();
    if (_play.isCovered(cell)) {
      setState(() {
        _play = _play.lift(cell);
        _armed = -1;
        _pointing = null;
        _saying = null;
      });
      return;
    }
    if (_armed < 0) {
      setState(() {
        _armed = cell;
        _pointing = null;
      });
      return;
    }
    if (_armed == cell) {
      setState(() => _armed = -1);
      return;
    }
    if (!_play.mayLay(_armed, cell)) {
      setState(() {
        _armed = -1;
        _saying = 'A plank covers two bare cells side by side or one '
            'atop the other.';
      });
      return;
    }

    final could = _play.canStill;
    final next = _play.lay(_armed, cell);
    setState(() {
      _play = next;
      _armed = -1;
      _pointing = null;
      _saying = _note(next, could);
    });
    if (next.isDone) _finished();
  }

  String? _note(Play play, bool could) {
    if (play.isDone) return null;
    if (could && play.room.winnable && !play.canStill) {
      return 'That plank strands what is left: no laying covers the '
          'rest now. Lift it back.';
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
      _armed = -1;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. A plank from a full laying of what is left.
  void _showMe() {
    final plank = _play.next;
    setState(() {
      _hints++;
      _armed = -1;
      _showColours = false;
      if (_play.isDone) {
        _pointing = null;
        _saying = 'The floor is laid.';
        return;
      }
      if (plank == null) {
        _pointing = null;
        _saying = _play.room.winnable
            ? 'No laying covers what is left. Lift some planks back.'
            : 'There is nothing to show: no laying floors this room, '
                'and the count tried every one. Ask why instead.';
        return;
      }
      _pointing = plank;
      _saying = 'Lay a plank there: a full laying of what is left '
          'runs through it, and the count has been everywhere.';
    });
  }

  /// Asked why. The colours, tinted and counted.
  void _why() {
    setState(() {
      _hints++;
      _armed = -1;
      _pointing = null;
      _showColours = true;
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
        backgroundColor: Palette.house,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Room(
                    play: _play,
                    armed: _armed,
                    pointing: _pointing,
                    showColours: _showColours,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
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

/// The line above the room: which one, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.room.winnable;
    final stranded =
        play.room.winnable && !play.isDone && !play.canStill;
    var bare = 0;
    var bits = play.uncovered;
    while (bits != 0) {
      bits &= bits - 1;
      bare++;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the rooms',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.room.name,
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
                      ? 'the floor is laid'
                      : stranded
                          ? 'the rest is stranded'
                          : dead
                              ? 'no laying floors this room'
                              : '$bare cell${bare == 1 ? '' : 's'} '
                                  'bare',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : stranded || dead
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.moves} moved',
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

/// The room itself.
class _Room extends StatelessWidget {
  const _Room({
    required this.play,
    required this.armed,
    required this.pointing,
    required this.showColours,
    required this.onTouch,
  });

  final Play play;
  final int armed;
  final (int, int)? pointing;
  final bool showColours;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.cellAt(touch.localPosition)),
            child: CustomPaint(
              key: FloorScreenState.roomKey,
              size: size,
              painter: FloorView(
                play: play,
                armed: armed,
                pointing: pointing,
                showColours: showColours,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the room: what the game has to say, and what else can be done.
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
                    'Tap two bare neighbouring cells to lay a plank; '
                        'tap a plank to lift it. Cover every cell of '
                        'the room.',
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
