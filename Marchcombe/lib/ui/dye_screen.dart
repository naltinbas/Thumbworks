import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dye/lands.dart';
import '../dye/play.dart';
import 'mapview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One estate: paint every field so that nothing matches across a hedge.
class DyeScreen extends StatefulWidget {
  const DyeScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a map is painted, with how many dyes it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int dyes)? onDone;

  @override
  State<DyeScreen> createState() => DyeScreenState();
}

class DyeScreenState extends State<DyeScreen> {
  static const mapKey = ValueKey('map');

  late Estate _estate;
  late Play _play;

  var _dye = 0;
  var _pointing = -1;
  var _showRing = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Estate get estate => _estate;
  Play get play => _play;
  int get dye => _dye;
  int get pointing => _pointing;
  bool get showRing => _showRing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(DyeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _estate = Estates.at(widget.number);
    _play = Play.of(_estate.land, Estates.answerFor(widget.number));
    _dye = 0;
    _pointing = -1;
    _showRing = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int field) {
    if (field < 0) return;
    final next = _play.paint(field, _dye);
    if (identical(next, _play)) return;

    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _pointing = -1;
      _showRing = false;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  void _pickDye(int dye) {
    HapticFeedback.selectionClick();
    setState(() {
      _dye = dye;
      _saying = null;
      _pointing = -1;
      _showRing = false;
    });
  }

  /// What the map has to say after a field is painted.
  ///
  /// A clash first, because that is the thing somebody can put on the map
  /// without noticing. Otherwise, whether the map can still be finished in the
  /// fewest dyes there are, which is the same search that found the answer run
  /// again with the fields already painted held where they are.
  String? _note(Play play) {
    if (play.isDone) return null;

    final clashes = play.clashes;
    if (clashes.isNotEmpty) {
      final (one, other) = clashes.first;
      return '${_name(one)} and ${_name(other)} share a hedge and are both '
          '${Palette.dyeNames[play.dyeOf(one)]}.';
    }
    if (!play.canStillDoIt) {
      return 'This cannot be finished on ${play.fewest} now. Rub something '
          'out.';
    }
    return null;
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _pointing = -1;
      _showRing = false;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Names a field and the dye to put on it that still leaves the map
  /// finishable in the fewest there are. Worked out from what is on the map
  /// rather than from an answer decided in advance, so it is still right after
  /// a mistake.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      _showRing = false;
      if (next == null) {
        _pointing = -1;
        _saying = _play.isFull
            ? 'Every field is painted.'
            : 'Nothing finishes this on ${_play.fewest}. Rub something out.';
        return;
      }
      _pointing = next.$1;
      _dye = next.$2;
      _saying = '${_name(next.$1)}, in ${Palette.dyeNames[next.$2]}.';
    });
  }

  /// Asked why it takes what it takes. Marks a set of fields that all share a
  /// hedge with one another. Every one of them has to be a different dye from
  /// every other, so the map cannot be done in fewer than there are fields in
  /// the set. It is a proof anybody can check by looking at the map.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showRing = true;
      final ring = _play.painting.ring.map(_name).toList();
      _saying = '${ring.sublist(0, ring.length - 1).join(', ')} and '
          '${ring.last} all share a hedge with each other, so no two of them '
          'can be the same. That is ${ring.length} dyes before anything else '
          'is painted at all.';
    });
  }

  String _name(int field) => _estate.land.fields[field].name;

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.used.length).then((best) {
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
                estate: _estate,
                play: _play,
                onLeave: widget.onLeave,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _Map(
                    play: _play,
                    pointing: _pointing,
                    showRing: _showRing,
                    onTouch: _touched,
                  ),
                ),
              ),
              _Pots(most: _play.most, picked: _dye, onPick: _pickDye),
              if (_play.isDone)
                ResultCard(
                  estate: _estate,
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

/// The line above the map: which estate, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.estate,
    required this.play,
    required this.onLeave,
  });

  final Estate estate;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final clashes = play.clashes.length;
    final over = play.used.length > estate.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the estates',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estate.name,
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
                      ? 'no two the same across a hedge'
                      : clashes > 0
                          ? '$clashes ${clashes == 1 ? 'hedge has' : 'hedges have'} '
                              'the same dye on both sides'
                          : '${play.done} of ${play.land.count} fields painted',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : clashes > 0
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.used.length} / ${estate.fewest}',
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
class _Map extends StatelessWidget {
  const _Map({
    required this.play,
    required this.pointing,
    required this.showRing,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showRing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play.land, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.fieldAt(touch.localPosition)),
            child: CustomPaint(
              key: DyeScreenState.mapKey,
              size: size,
              painter: MapView(
                play: play,
                pointing: pointing,
                showRing: showRing,
                labels: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: metrics.side * 0.21,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      );
}

/// The pots of dye. One more than the map needs, so that a map can be
/// finished the wrong way and be told so.
class _Pots extends StatelessWidget {
  const _Pots({
    required this.most,
    required this.picked,
    required this.onPick,
  });

  final int most;
  final int picked;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var dye = 0; dye < most; dye++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Semantics(
                  button: true,
                  label: Palette.dyeNames[dye],
                  child: GestureDetector(
                    onTap: () => onPick(dye),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Palette.dyes[dye],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dye == picked ? Palette.ink : Palette.line,
                          width: dye == picked ? 3 : 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// Under the pots: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onAgain;
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
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Pick a dye and tap a field to put it on. No two fields '
                        'that share a hedge can have the same one.',
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
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 9),
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
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
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
