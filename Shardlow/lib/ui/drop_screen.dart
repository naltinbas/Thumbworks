import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../drop/fewest.dart';
import '../drop/ladders.dart';
import '../drop/play.dart';
import 'ladderview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One morning: find the highest safe rung in the fewest drops.
class DropScreen extends StatefulWidget {
  const DropScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a morning settles, with the drops it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int drops)? onDone;

  @override
  State<DropScreen> createState() => DropScreenState();
}

class DropScreenState extends State<DropScreen> {
  static const ladderKey = ValueKey('ladder');

  static final _tables = <int, Drops>{};

  late Play _play;

  var _pointing = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(DropScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    final ladder = Ladders.at(widget.number);
    _play = Play.of(
      ladder,
      _tables.putIfAbsent(ladder.pots, () => Drops(ladder.pots)),
    );
    _pointing = -1;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int rung) {
    if (rung < 0 || _play.isDone) return;

    if (!_play.worthDropping(rung)) {
      final standing = _play.standing;
      setState(() {
        _pointing = -1;
        _saying = rung <= standing.lowest
            ? 'A pot has already lived from rung ${standing.lowest}, so '
                'rung $rung can teach nothing.'
            : 'A pot has already broken from rung ${standing.highest + 1}, '
                'so rung $rung can teach nothing.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.drop(rung);
    setState(() {
      _play = next;
      _pointing = -1;
      _saying = _note(next, rung);
    });
    if (next.isDone) _finished();
  }

  /// What the yard has to say after a drop.
  String? _note(Play play, int rung) {
    final broke = play.done.last.broke;
    final what = broke
        ? 'It broke on rung $rung.'
        : 'It lived from rung $rung.';
    if (play.isDone) return null;

    final could = play.couldFinishIn;
    if (could > play.ladder.fewest) {
      return '$what The fewest this can settle in now is $could drops, which '
          'is ${could - play.ladder.fewest} more than the '
          '${play.ladder.fewest} it takes.';
    }
    return '$what ${play.standing.answers} answers still stand'
        '${play.hand == 1 ? ', and one pot is left' : ''}.';
  }

  void _again() {
    setState(_set);
  }

  void _back() {
    if (_play.made == 0) return;
    setState(() {
      _play = _play.back;
      _pointing = -1;
      _saying = null;
    });
  }

  /// Asked. The rung whose worse half still settles in as few drops as the
  /// whole can, worked out from what is possible now.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = -1;
        _saying = 'It is settled.';
        return;
      }
      _pointing = next;
      _saying = 'Rung $next. ${_play.left - 1} more after it, whatever '
          'happens.';
    });
  }

  /// Asked why. The counting: a run of drops is a word of breaks and
  /// survivals, and there are only so many words.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      final ladder = _play.ladder;
      final fewer = ladder.fewest - 1;
      final most = Drops.tellsApart(fewer, ladder.pots);
      _saying = 'A morning of drops reads as a word of breaks and survivals, '
          'with at most ${ladder.pots} break${ladder.pots == 1 ? '' : 's'} in '
          'it. $fewer drops give $most such words at most, and this ladder '
          'has ${ladder.answers} answers to tell apart, so $fewer drops '
          'cannot always do it. ${ladder.fewest} can, and the pots in this '
          'yard break as awkwardly as pots can break, so getting it in '
          '${ladder.fewest} here means ${ladder.fewest} always does.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
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
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _Ladder(
                    play: _play,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
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

/// The line above the ladder: which morning, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.couldFinishIn > play.ladder.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the yard',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.ladder.name,
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
                      ? play.answer == 0
                          ? 'no rung is safe at all'
                          : 'the highest safe rung is ${play.answer}'
                      : '${play.standing.answers} answers still stand, '
                          '${play.hand} pot${play.hand == 1 ? '' : 's'} in '
                          'hand',
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
            '${play.made} / ${play.ladder.fewest}',
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

/// The ladder itself.
class _Ladder extends StatelessWidget {
  const _Ladder({
    required this.play,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.rungAt(touch.localPosition)),
            child: CustomPaint(
              key: DropScreenState.ladderKey,
              size: size,
              painter: LadderView(
                play: play,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the ladder: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onBack,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onBack;
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
                    'Tap a rung to drop a pot from it. A pot that breaks is '
                        'gone, and the pots here break as awkwardly as pots '
                        'can.',
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
                Expanded(child: _Button(label: 'Take back', onTap: onBack)),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 7),
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
                  maxLines: 1,
                  style: const TextStyle(
                    color: Palette.ink,
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
