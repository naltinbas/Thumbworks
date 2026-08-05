import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../link/parishes.dart';
import '../link/play.dart';
import 'mapview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One parish: join every hamlet up for the least path there is.
class LinkScreen extends StatefulWidget {
  const LinkScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a parish is joined up, with the yards it
  /// took. Answers whether that beat what was written down before.
  final Future<bool> Function(int yards)? onDone;

  @override
  State<LinkScreen> createState() => LinkScreenState();
}

class LinkScreenState extends State<LinkScreen> {
  static const mapKey = ValueKey('map');

  late Round _round;
  late Play _play;

  var _marking = const Marking();
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Round get round => _round;
  Play get play => _play;
  Marking get marking => _marking;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(LinkScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _round = Rounds.at(widget.number);
    _play = Play.of(_round.parish, Rounds.answerFor(widget.number));
    _marking = const Marking();
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int trod) {
    if (trod < 0) return;

    if (_play.wouldLoop(trod)) {
      setState(() {
        _marking = Marking(pointing: trod);
        _saying = '${_between(trod)} would close a loop, and a loop always has '
            'a path you could do without.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.touch(trod);
    setState(() {
      _play = next;
      _marking = const Marking();
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the map has to say after a path is cut or filled in.
  ///
  /// One thing, and only when it is true: that the parish can no longer be
  /// joined for what it could have been. The game can say that because it runs
  /// the same method again over what is left, which is a different question
  /// from the one it answered when the parish opened and no dearer.
  String? _note(Play play) {
    if (play.isDone) return null;
    final could = play.couldStillCost;
    if (could <= play.answer.yards) return null;
    return 'The least this can now be joined for is $could yards, which is '
        '${could - play.answer.yards} more than the ${play.answer.yards} it '
        'takes.';
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _marking = const Marking();
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Points at the path to cut next that still leaves the parish
  /// joinable for as little as it can now be.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _marking = const Marking();
        _saying = 'There is nothing left to cut.';
        return;
      }
      _marking = Marking(pointing: next);
      _saying = '${_between(next)}, ${_play.parish[next].yards} yards.';
    });
  }

  /// Asked why. Whichever path was last pointed at, or the dearest path
  /// already cut, gets its reason: the line it is the cheapest across, or the
  /// loop it is the dearest on.
  void _why() {
    final trod = _worthExplaining();
    setState(() {
      _hints++;
      if (trod < 0) {
        _marking = const Marking();
        _saying = 'Cut a path, or ask to be shown one, and this will say why '
            'it is in the answer or why it is not.';
        return;
      }

      if (_play.answer.cut.contains(trod)) {
        final why = _play.whyIn(trod);
        _marking = Marking(
          thisSide: why.thisSide,
          thatSide: why.thatSide,
          crossing: why.crossing,
          pointing: trod,
        );
        final others = why.crossing.length - 1;
        _saying = 'Draw a line with ${_list(why.thisSide)} on one side and '
            '${_list(why.thatSide)} on the other. '
            '${why.crossing.length} paths cross it, and at '
            '${_play.parish[trod].yards} yards ${_between(trod)} is the '
            'cheapest of them, so it is in every cheapest network there is. '
            '${others == 1 ? 'The other one is dearer.' : 'The other $others '
                'are all dearer.'}';
        return;
      }

      final why = _play.whyNot(trod);
      if (why == null) {
        _marking = Marking(pointing: trod);
        _saying = 'Nothing to say about that one.';
        return;
      }
      _marking = Marking(loop: why.loop, pointing: trod);
      _saying = '${_between(trod)} closes a loop with '
          '${_list(_placesOn(why.loop))}, and at '
          '${_play.parish[trod].yards} yards it is the dearest path on that '
          'loop. Any network using it could drop it and put back a cheaper '
          'one, so it is in no cheapest network at all.';
    });
  }

  /// The path the game will explain: the one it last pointed at, or the
  /// dearest one cut so far.
  int _worthExplaining() {
    if (_marking.pointing >= 0) return _marking.pointing;
    var dearest = -1;
    for (final trod in _play.cut) {
      if (dearest < 0 ||
          _play.parish[trod].yards > _play.parish[dearest].yards) {
        dearest = trod;
      }
    }
    return dearest;
  }

  List<int> _placesOn(List<int> loop) {
    final places = <int>{};
    for (final trod in loop) {
      places
        ..add(_play.parish[trod].from)
        ..add(_play.parish[trod].to);
    }
    return places.toList()..sort();
  }

  String _between(int trod) =>
      '${_name(_play.parish[trod].from)} to ${_name(_play.parish[trod].to)}';

  String _name(int place) => _play.parish.places[place].name;

  String _list(List<int> places) {
    final names = places.map(_name).toList();
    if (names.length == 1) return names.first;
    return '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.yards).then((best) {
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
              _Ledger(round: _round, play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _Map(
                    play: _play,
                    marking: _marking,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  round: _round,
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

/// The line above the map: which parish, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.round,
    required this.play,
    required this.onLeave,
  });

  final Round round;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.couldStillCost > round.yards;

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
                  round.name,
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
                      ? 'every hamlet reaches every other'
                      : '${play.pieces} pieces still',
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
            '${play.yards} / ${round.yards}',
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
    required this.marking,
    required this.onTouch,
  });

  final Play play;
  final Marking marking;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.trodAt(touch.localPosition)),
            child: CustomPaint(
              key: LinkScreenState.mapKey,
              size: size,
              painter: MapView(
                play: play,
                marking: marking,
                labels: const TextStyle(fontFamily: 'Roboto', fontSize: 11),
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
                    'Tap a path to cut it. Every hamlet has to reach every '
                        'other one, and the yards are what it costs.',
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
