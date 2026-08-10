import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../wire/game.dart';
import '../wire/play.dart';
import '../wire/rounds.dart';
import '../wire/webs.dart';
import 'netview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One round: bring the line down, or hold it up, against a machine that
/// plays as well as the game can be played.
class WireScreen extends StatefulWidget {
  const WireScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a round is won, with the player's moves.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int moves)? onDone;

  @override
  State<WireScreen> createState() => WireScreenState();
}

class WireScreenState extends State<WireScreen> {
  static const netKey = ValueKey('net');

  late Play _play;

  var _pointing = -1;
  TwoWebs? _webs;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  TwoWebs? get webs => _webs;
  int get hints => _hints;
  String? get saying => _saying;

  bool get _cutting => _play.mine == Part.cutter;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(WireScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Rounds.at(widget.number), Rounds.gameFor(widget.number));
    _pointing = -1;
    _webs = null;
    _hints = 0;
    _saying = _play.round.hopeless
        ? 'This line cannot be brought down, and the label says so. Why '
            'shows the reason; the round is here to be felt.'
        : null;
    _told = false;
    _best = false;
  }

  void _touched(int wire) {
    if (wire < 0 || _play.isOver) return;

    if (!_play.isFree(wire)) {
      setState(() {
        _pointing = -1;
        _webs = null;
        _saying = _play.isCut(wire)
            ? 'That wire is already down.'
            : 'That wire is braced. Nothing touches it now.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.touch(wire);
    setState(() {
      _play = next;
      _pointing = -1;
      _webs = null;
      _saying = _note(next);
    });
    if (next.isOver) _finished();
  }

  /// What the line has to say after an exchange.
  String? _note(Play play) {
    if (play.isOver) return null;

    final theirs = play.theirLast;
    final answer = theirs < 0
        ? ''
        : 'He ${_cutting ? 'braced' : 'cut'} ${_ends(theirs)}. ';

    final could = play.couldFinishIn;
    if (could == null) {
      return '${answer}The round cannot be won from here.';
    }
    if (play.round.fewest != null && could > play.round.fewest!) {
      return '${answer}The fewest this can be won in now is $could, which is '
          '${could - play.round.fewest!} more than the ${play.round.fewest} '
          'it takes.';
    }
    return answer.isEmpty ? null : answer.trim();
  }

  void _again() {
    setState(_set);
  }

  void _back() {
    if (_play.made == 0) return;
    setState(() {
      _play = _play.back;
      _pointing = -1;
      _webs = null;
      _saying = null;
    });
  }

  /// Asked. Points at the wire that wins as soon as the round can now be won.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      _webs = null;
      if (next == null) {
        _pointing = -1;
        _saying = _play.isOver
            ? 'The round is over.'
            : 'No wire wins it from here.';
        return;
      }
      _pointing = next;
      final left = _play.canStillWinIn!;
      _saying = '${_cutting ? 'Cut' : 'Brace'} ${_ends(next)}. '
          '${left - 1 == 0 ? 'That ends it' : '${left - 1} more after it'}.';
    });
  }

  /// Asked why. Two webs over what is left when they exist, since they settle
  /// the rest of the game on their own, and the search's word when they do
  /// not.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      final webs = _play.websNow;
      if (webs != null) {
        _webs = webs;
        _saying = _cutting
            ? 'Two webs of wire each still join the stations, and they share '
                'nothing. A cut wounds one web at most, and he mends it '
                'through the other before you can strike again. Two webs, one '
                'cut a turn: the line is past cutting.'
            : 'Two webs of wire each still join the stations, and they share '
                'nothing. Whatever he cuts wounds one web at most, and you '
                'mend it through the other. Hold the two webs and the line '
                'holds itself.';
        return;
      }

      _webs = null;
      final could = _play.canStillWinIn;
      _saying = could != null
          ? 'No two webs settle this net, so it is won a move at a time. The '
              'search has held every position there is, and from here it is '
              'yours in $could.'
          : 'From here the machine holds every answer. The search settled '
              'every position, and none of them comes out yours.';
    });
  }

  String _ends(int wire) =>
      '${_play.net.posts[_play.net[wire].from].name} to '
      '${_play.net.posts[_play.net[wire].to].name}';

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told || !_play.won) return;
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
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _Line(
                    play: _play,
                    pointing: _pointing,
                    webs: _webs,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isOver)
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
                  cutting: _cutting,
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

/// The line above the map: which round, whose part is whose, and the score.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final fewest = play.round.fewest;
    final could = play.couldFinishIn;
    final over = !play.isOver &&
        (could == null || (fewest != null && could > fewest));

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the rounds',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.round.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isOver
                      ? (play.isDown ? 'the line is down' : 'the line held')
                      : play.mine == Part.cutter
                          ? 'you cut, he braces'
                          : 'you brace, he cuts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isOver
                        ? (play.won ? Palette.good : Palette.bad)
                        : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            fewest == null ? '${play.made}' : '${play.made} / $fewest',
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

/// The line itself.
class _Line extends StatelessWidget {
  const _Line({
    required this.play,
    required this.pointing,
    required this.webs,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final TwoWebs? webs;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.wireAt(touch.localPosition)),
            child: CustomPaint(
              key: WireScreenState.netKey,
              size: size,
              painter: NetView(
                play: play,
                pointing: pointing,
                webs: webs,
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
    required this.cutting,
    required this.onBack,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final bool cutting;
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
                    (cutting
                        ? 'Tap a wire to cut it. He braces one back each turn, '
                            'and braced wire cannot be cut.'
                        : 'Tap a wire to brace it. He cuts one each turn, and '
                            'you win when braced wire alone joins the '
                            'stations.'),
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
