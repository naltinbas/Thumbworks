import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../walk/play.dart';
import '../walk/towns.dart';
import 'palette.dart';
import 'result_card.dart';
import 'walkview.dart';

/// One town: walk every bridge exactly once.
class WalkScreen extends StatefulWidget {
  const WalkScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the last bridge, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<WalkScreen> createState() => WalkScreenState();
}

class WalkScreenState extends State<WalkScreen> {
  static const townKey = ValueKey('town');

  late Play _play;

  var _pointingBridge = -1;
  var _pointingGround = -1;
  var _showOdd = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointingBridge => _pointingBridge;
  int get pointingGround => _pointingGround;
  bool get showOdd => _showOdd;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(WalkScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Towns.at(widget.number));
    _pointingBridge = -1;
    _pointingGround = -1;
    _showOdd = false;
    _hints = 0;
    _saying = _play.town.walkable
        ? null
        : 'No walk crosses every bridge of this town, and the label '
            'said so. The red tallies are the reason; ask why for the '
            'words.';
    _told = false;
    _best = false;
  }

  void _touchedGround(int ground) {
    if (_play.isDone) return;
    if (_play.started) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'The walk stands at '
            '${_play.town.grounds[_play.standing!]}: tap a bridge it '
            'touches.';
      });
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _play = _play.stand(ground);
      _pointingBridge = -1;
      _pointingGround = -1;
      _saying = null;
    });
  }

  void _touchedBridge(int bridge) {
    if (_play.isDone) return;
    if (!_play.started) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'Stand somewhere first: tap a landing.';
      });
      return;
    }
    if (!_play.mayCross(bridge)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = _play.bridgeWalked(bridge)
            ? 'That bridge is already walked, and a walk crosses each '
                'bridge once.'
            : 'That bridge does not touch '
                '${_play.town.grounds[_play.standing!]}.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.canStill;
    final next = _play.cross(bridge);
    setState(() {
      _play = next;
      _pointingBridge = -1;
      _pointingGround = -1;
      _saying = _note(next, could);
    });
    if (next.isDone) _finished();
  }

  String? _note(Play play, bool could) {
    if (play.isDone) return null;
    if (play.stuck) {
      return 'No unwalked bridge leaves '
          '${play.town.grounds[play.standing!]}, and '
          '${play.rules.bridgeCount - play.crossed} wait. Take a '
          'crossing back.';
    }
    if (could && play.town.walkable && !play.canStill) {
      return 'That crossing stranded the walk: no way from here '
          'crosses the rest. Take it back.';
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
      _pointingBridge = -1;
      _pointingGround = -1;
      _saying = null;
    });
  }

  /// Asked. The start or crossing a finishing walk makes next.
  void _showMe() {
    setState(() {
      _hints++;
      _showOdd = false;
      if (_play.isDone) {
        _saying = 'Every bridge is walked.';
        return;
      }
      if (!_play.started) {
        final start = _play.nextStart;
        if (start == null) {
          _saying = 'There is nothing to show: no walk crosses every '
              'bridge of this town. Ask why instead.';
          return;
        }
        _pointingGround = start;
        _saying = 'Stand at ${_play.town.grounds[start]}: complete '
            'walks leave from there, and the search has counted them.';
        return;
      }
      final bridge = _play.nextBridge;
      if (bridge == null) {
        _saying = 'No way from here crosses the rest. Take some '
            'crossings back.';
        return;
      }
      _pointingBridge = bridge;
      _saying = 'Cross there: the search has walked the rest from its '
          'far side.';
    });
  }

  /// Asked why. The tallies and the words.
  void _why() {
    setState(() {
      _hints++;
      _pointingBridge = -1;
      _pointingGround = -1;
      _showOdd = true;
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
        backgroundColor: Palette.water,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _TownMap(
                    play: _play,
                    pointingBridge: _pointingBridge,
                    pointingGround: _pointingGround,
                    showOdd: _showOdd,
                    onGround: _touchedGround,
                    onBridge: _touchedBridge,
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

/// The line above the map: which town, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.town.walkable;
    final strand = play.started && !play.isDone && !play.canStill;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the towns',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.town.name,
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
                      ? 'every bridge walked once'
                      : dead
                          ? 'no walk crosses every bridge'
                          : strand
                              ? 'the walk is stranded'
                              : play.started
                                  ? 'standing at '
                                      '${play.town.grounds[play.standing!]}'
                                  : 'tap a landing to stand there',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : dead || strand
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.crossed} / ${play.rules.bridgeCount}',
            style: TextStyle(
              color: play.isDone ? Palette.good : Palette.ink,
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

/// The map itself.
class _TownMap extends StatelessWidget {
  const _TownMap({
    required this.play,
    required this.pointingBridge,
    required this.pointingGround,
    required this.showOdd,
    required this.onGround,
    required this.onBridge,
  });

  final Play play;
  final int pointingBridge;
  final int pointingGround;
  final bool showOdd;
  final ValueChanged<int> onGround;
  final ValueChanged<int> onBridge;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              final ground = metrics.groundAt(touch.localPosition);
              if (ground >= 0) {
                onGround(ground);
                return;
              }
              final bridge = metrics.bridgeAt(touch.localPosition);
              if (bridge >= 0) onBridge(bridge);
            },
            child: CustomPaint(
              key: WalkScreenState.townKey,
              size: size,
              painter: WalkView(
                play: play,
                pointingBridge: pointingBridge,
                pointingGround: pointingGround,
                showOdd: showOdd,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the map: what the game has to say, and what else can be done.
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
                    'Tap a landing to stand there, then tap bridges to '
                        'cross them, each exactly once. The tallies '
                        'count each landing\'s bridges.',
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
