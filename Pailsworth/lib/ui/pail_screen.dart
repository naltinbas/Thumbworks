import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../pail/errands.dart';
import '../pail/play.dart';
import 'pailview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One errand: pour until a pail holds the ask.
class PailScreen extends StatefulWidget {
  const PailScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the errand run, with the pours made. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int pours)? onDone;

  @override
  State<PailScreen> createState() => PailScreenState();
}

class PailScreenState extends State<PailScreen> {
  static const wellKey = ValueKey('well');

  late Play _play;

  int? _armed;
  (int, int)? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int? get armed => _armed;
  (int, int)? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(PailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Errands.at(widget.number));
    _armed = null;
    _pointing = null;
    _hints = 0;
    _saying = _play.errand.winnable
        ? null
        : 'No pouring runs this errand, and the label said so. Pour '
            'as you like and watch the waterlines; ask why for the '
            'measure.';
    _told = false;
    _best = false;
  }

  void _touched(int? end) {
    if (end == null || _play.isDone) return;

    HapticFeedback.selectionClick();
    final held = _armed;
    if (held == null) {
      if (end == Play.drain) {
        setState(() {
          _saying = 'The drain takes; it does not give. Arm a pail '
              'or the spring first.';
        });
        return;
      }
      if (end != Play.spring && _play.held[end] == 0) {
        setState(() {
          _armed = end;
          _pointing = null;
          _saying = null;
        });
        return;
      }
      setState(() {
        _armed = end;
        _pointing = null;
      });
      return;
    }
    if (held == end) {
      setState(() => _armed = null);
      return;
    }

    if (!_play.mayPour(held, end)) {
      setState(() {
        _armed = null;
        _saying = held == Play.spring
            ? 'That pail is already full.'
            : end == Play.drain
                ? 'That pail is already dry.'
                : _play.held[held] == 0
                    ? 'That pail has nothing to tip.'
                    : 'That pail is already full.';
      });
      return;
    }

    final could = _play.fewestFromHere;
    final next = _play.pour(held, end);
    setState(() {
      _play = next;
      _armed = null;
      _pointing = null;
      _saying = _note(next, could);
    });
    if (next.isDone) _finished();
  }

  String? _note(Play play, int? could) {
    if (play.isDone || !play.errand.winnable) return null;
    final now = play.fewestFromHere;
    if (could != null && now != null && now > could) {
      return 'That pour wandered: the errand is now $now pours away. '
          'Back takes it off the count.';
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
      _armed = null;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. The pour the walk steps nearer with.
  void _showMe() {
    final pour = _play.next;
    setState(() {
      _hints++;
      _armed = null;
      if (_play.isDone) {
        _pointing = null;
        _saying = 'The errand is run.';
        return;
      }
      if (pour == null) {
        _pointing = null;
        _saying = 'There is nothing to show: no pouring reaches '
            '${_play.errand.ask} pints in these pails, and the walk '
            'stood on every waterline. Ask why instead.';
        return;
      }
      _pointing = pour;
      _saying = 'Pour ${_endName(pour.$1)} to ${_endName(pour.$2)}: '
          'the walk has measured every waterline, and this steps one '
          'nearer.';
    });
  }

  String _endName(int end) => end == Play.spring
      ? 'the spring'
      : end == Play.drain
          ? 'the drain'
          : 'the ${_play.errand.caps[end]}-pint pail';

  /// Asked why. The walk, or the measure.
  void _why() {
    setState(() {
      _hints++;
      _armed = null;
      _pointing = null;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.pours).then((best) {
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
        backgroundColor: Palette.stone,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Well(
                    play: _play,
                    armed: _armed,
                    pointing: _pointing,
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

/// The line above the well: which errand, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.errand.winnable;
    final away = play.fewestFromHere;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the errands',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.errand.name,
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
                      ? 'the errand is run'
                      : dead
                          ? 'no pouring runs this errand'
                          : 'fetch ${play.errand.ask} pints; '
                              '$away pour${away == 1 ? '' : 's'} away',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
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
            '${play.pours} poured',
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

/// The well itself.
class _Well extends StatelessWidget {
  const _Well({
    required this.play,
    required this.armed,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final int? armed;
  final (int, int)? pointing;
  final ValueChanged<int?> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.endAt(touch.localPosition)),
            child: CustomPaint(
              key: PailScreenState.wellKey,
              size: size,
              painter: PailView(
                play: play,
                armed: armed,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the well: what the game has to say, and what else can be done.
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
                    'Tap where the water comes from, then where it '
                        'goes: spring fills a pail, pail tips into '
                        'pail, drain empties one. The gold dashes '
                        'mark the ask.',
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
