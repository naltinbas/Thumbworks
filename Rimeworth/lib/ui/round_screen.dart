import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../round/parishes.dart';
import '../round/play.dart';
import 'palette.dart';
import 'parishview.dart';
import 'result_card.dart';

/// One parish: salt every lane, in as few runs as it can be done in.
class RoundScreen extends StatefulWidget {
  const RoundScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a parish is finished, with the runs it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int runs)? onDone;

  @override
  State<RoundScreen> createState() => RoundScreenState();
}

class RoundScreenState extends State<RoundScreen> {
  static const parishKey = ValueKey('parish');

  late Gritting _gritting;
  late Play _play;

  var _pointing = -1;
  var _showOdd = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Gritting get gritting => _gritting;
  Play get play => _play;
  int get pointing => _pointing;
  bool get showOdd => _showOdd;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(RoundScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _gritting = Grittings.at(widget.number);
    _play = Play.of(_gritting.parish);
    _pointing = -1;
    _showOdd = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  /// A tap on a junction. It sets the lorry down, drives it there, or says
  /// why the tap was none of those.
  void _touched(int junction) {
    if (_play.isDone || junction < 0) return;

    final next = _play.touch(junction);
    if (!identical(next, _play)) {
      _went(next);
      return;
    }

    final at = _play.at;
    setState(() {
      if (at == junction) {
        _saying = 'The lorry is at ${_name(junction)} already.';
      } else if (at >= 0 && !_play.isStuck) {
        _saying = 'No lane from ${_name(at)} to ${_name(junction)} that is '
            'not salted yet.';
      } else {
        _saying = 'Every lane at ${_name(junction)} is salted, so there is '
            'nothing to set off for there.';
      }
    });
  }

  /// A tap on a lane, which is the same as a tap on the far end of it when
  /// the lorry is standing at the near end.
  void _touchedLane(int lane) {
    if (_play.isDone || lane < 0) return;
    final at = _play.at;
    if (at < 0 || !_gritting.parish.lanes[lane].touches(at)) return;
    _touched(_gritting.parish.otherEnd(lane, at));
  }

  void _went(Play next) {
    if (identical(next, _play)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _pointing = -1;
      _showOdd = false;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the parish has to say after the lorry moves.
  ///
  /// One thing, and only when it is true: that it can no longer be finished
  /// in as few runs as it takes. The game can say that because it counts the
  /// odd junctions among the lanes that are left over, which is a different
  /// question from the one it answered at the start and just as cheap.
  String? _note(Play play) {
    if (play.isDone) return null;
    final could = play.couldFinishIn;
    if (could > _gritting.runs) {
      final over = could - _gritting.runs;
      return 'The best this can be finished in now is $could runs, which is '
          '$over more than the ${_gritting.runs} it takes.';
    }
    if (play.isStuck) {
      return 'Nothing left to salt at ${_name(play.at)}. Tap a junction to '
          'set off again from there.';
    }
    return null;
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _pointing = -1;
      _showOdd = false;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  void _back() {
    if (!_play.canTakeBack) return;
    setState(() {
      _play = _play.back;
      _pointing = -1;
      _showOdd = false;
      _saying = null;
    });
  }

  /// Asked. Points at where to go next to still finish in as few runs as the
  /// parish can now be finished in, which is the only honest answer once a
  /// lane has been salted that cost something.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      _showOdd = false;
      if (next == null) {
        _pointing = -1;
        _saying = 'There is nowhere left to go.';
        return;
      }
      _pointing = next;
      if (_play.at < 0) {
        _saying = '${_name(next)} to set off from. It has '
            '${_gritting.parish.lanesOn(next)} lanes on it, so a run has to '
            'start or finish there.';
        return;
      }
      final left = _play.rest.runsLeft;
      _saying = '${_name(next)} next. '
          '${left == 0 ? 'This run does the rest' : '$left more '
              '${left == 1 ? 'run' : 'runs'} after this one'}.';
    });
  }

  /// Asked why it takes what it takes. Rings the junctions with an odd number
  /// of lanes on them, which is the whole of the answer: a lorry that drives
  /// into a junction drives out again, so an odd one has to be an end of some
  /// run, and a run has two ends.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showOdd = true;
      final odd = _gritting.parish.oddJunctions;
      if (odd.isEmpty) {
        _saying = 'Every junction has an even number of lanes on it, so one '
            'run salts the lot and finishes where it set off.';
        return;
      }
      final names = odd.map(_name).toList();
      _saying = '${names.length} junctions have an odd number of lanes: '
          '${names.sublist(0, names.length - 1).join(', ')} and '
          '${names.last}. The lorry drives out of a junction as often as it '
          'drives in, so an odd one has to be where a run starts or finishes. '
          'A run has two ends, so ${_gritting.runs} '
          '${_gritting.runs == 1 ? 'run' : 'runs'} is the fewest.';
    });
  }

  String _name(int junction) => _gritting.parish.junctions[junction].name;

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.runs).then((best) {
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
              _Ledger(
                gritting: _gritting,
                play: _play,
                onLeave: widget.onLeave,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _Parish(
                    play: _play,
                    pointing: _pointing,
                    showOdd: _showOdd,
                    onJunction: _touched,
                    onLane: _touchedLane,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  gritting: _gritting,
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  canTakeBack: _play.canTakeBack,
                  onBack: _back,
                  onAgain: _again,
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

/// The line above the map: which parish, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.gritting,
    required this.play,
    required this.onLeave,
  });

  final Gritting gritting;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.couldFinishIn > gritting.runs;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the parishes',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gritting.name,
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
                      ? 'every lane salted'
                      : '${play.done} of ${play.parish.laneCount} lanes '
                          'salted',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone ? Palette.good : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.runs} / ${gritting.runs}',
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

/// The map itself.
class _Parish extends StatelessWidget {
  const _Parish({
    required this.play,
    required this.pointing,
    required this.showOdd,
    required this.onJunction,
    required this.onLane,
  });

  final Play play;
  final int pointing;
  final bool showOdd;
  final ValueChanged<int> onJunction;
  final ValueChanged<int> onLane;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              final junction = metrics.junctionAt(touch.localPosition);
              if (junction >= 0) {
                onJunction(junction);
              } else {
                onLane(metrics.laneAt(touch.localPosition));
              }
            },
            child: CustomPaint(
              key: RoundScreenState.parishKey,
              size: size,
              painter: ParishView(
                play: play,
                pointing: pointing,
                showOdd: showOdd,
                labels: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 11,
                ),
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
    required this.canTakeBack,
    required this.onBack,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final bool canTakeBack;
  final VoidCallback onBack;
  final VoidCallback onAgain;
  final VoidCallback onShowMe;
  final VoidCallback onWhy;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
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
                    'Tap a junction to set the lorry down there, and a lane to '
                        'salt it. It has no grit for a lane twice.',
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
                  child: _Button(
                    label: 'Take back',
                    dead: !canTakeBack,
                    onTap: onBack,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _Button(
                    label: 'Again',
                    dead: !canTakeBack,
                    onTap: onAgain,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _Button(label: 'Show me', dead: false, onTap: onShowMe),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _Button(label: 'Why', dead: false, onTap: onWhy),
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
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: dead ? Palette.line : Palette.edge,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: dead ? Palette.inkDim : Palette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
