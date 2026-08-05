import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../berth/play.dart';
import '../berth/quays.dart';
import 'bookview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One day: give the berth to as many ships as it will take.
class BerthScreen extends StatefulWidget {
  const BerthScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a day fills up, with how many ships got the
  /// berth. Answers whether that beat what was written down before.
  final Future<bool> Function(int ships)? onDone;

  @override
  State<BerthScreen> createState() => BerthScreenState();
}

class BerthScreenState extends State<BerthScreen> {
  static const bookKey = ValueKey('book');

  late Day _day;
  late Play _play;

  var _pointing = -1;
  var _showMarks = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Day get day => _day;
  Play get play => _play;
  int get pointing => _pointing;
  bool get showMarks => _showMarks;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(BerthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _day = Days.at(widget.number);
    _play = Play.of(_day.quay, Days.answerFor(widget.number));
    _pointing = -1;
    _showMarks = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int ship) {
    if (ship < 0) return;

    if (!_play.has(ship) && !_play.canTake(ship)) {
      final other = _play.clashFor(ship);
      setState(() {
        _pointing = other;
        _showMarks = false;
        _saying = '${_name(ship)} wants the berth from ${_hour(ship, true)} '
            'and ${_name(other)} has it until ${_hour(other, false)}.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.take(ship);
    setState(() {
      _play = next;
      _pointing = -1;
      _showMarks = false;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the harbour master has to say after a ship is taken or turned away.
  ///
  /// One thing, and only when it is true: that the day can no longer be as
  /// good as it might have been. The game can say that because it runs the
  /// same rule again over the ships that do not clash with anything already in
  /// the berth, which is a different question from the one it answered when
  /// the day opened.
  String? _note(Play play) {
    if (play.isDone) return null;
    final could = play.couldStillGet;
    if (could >= _day.most) return null;
    return 'The best this day can come to now is $could ships, which is '
        '${_day.most - could} short of the ${_day.most} there are.';
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _pointing = -1;
      _showMarks = false;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Points at a ship to take next that still leaves the day as good as
  /// it can now be, worked out from what is in the berth rather than read off
  /// the answer the day opened with.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      _showMarks = false;
      if (next == null) {
        _pointing = -1;
        _saying = 'Nothing else will fit.';
        return;
      }
      _pointing = next;
      _saying = '${_name(next)}, ${_hour(next, true)} to ${_hour(next, false)}. '
          'She casts off before anything else that could still have the berth.';
    });
  }

  /// Asked why the day cannot be better. Draws the hours that settle it: every
  /// ship in the book wants the berth at one of them, and two ships that want
  /// it at the same hour cannot both have it, so there cannot be more ships in
  /// the day than there are hours marked.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showMarks = true;
      final hours = _play.answer.marks.map((hour) => '$hour').toList();
      final when = hours.length == 1
          ? '${hours.first} o\'clock'
          : '${hours.sublist(0, hours.length - 1).join(', ')} or '
              '${hours.last} o\'clock';
      _saying = 'Every ship in the book wants the berth at $when. Two ships '
          'wanting it at the same hour cannot both have it, so ${hours.length} '
          'is all there is.';
    });
  }

  String _name(int ship) => _day.quay[ship].name;

  String _hour(int ship, bool coming) =>
      '${coming ? _day.quay[ship].from : _day.quay[ship].to}';

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.taken.length).then((best) {
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
              _Ledger(day: _day, play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: _Book(
                    play: _play,
                    pointing: _pointing,
                    showMarks: _showMarks,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  day: _day,
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

/// The line above the book: which day, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.day,
    required this.play,
    required this.onLeave,
  });

  final Day day;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final short = play.couldStillGet < day.most;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the days',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.name,
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
                      ? 'nothing else will fit'
                      : '${play.stillFree.length} of '
                          '${play.quay.count} still waiting',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? (play.isMost ? Palette.good : Palette.bad)
                        : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.taken.length} / ${day.most}',
            style: TextStyle(
              color: short ? Palette.bad : Palette.ink,
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

/// The book itself.
class _Book extends StatelessWidget {
  const _Book({
    required this.play,
    required this.pointing,
    required this.showMarks,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showMarks;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.shipAt(touch.localPosition)),
            child: CustomPaint(
              key: BerthScreenState.bookKey,
              size: size,
              painter: BookView(
                play: play,
                pointing: pointing,
                showMarks: showMarks,
                labels: const TextStyle(fontFamily: 'Roboto', fontSize: 12),
              ),
            ),
          );
        },
      );
}

/// Under the book: what the game has to say, and what else can be done.
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
                    'Tap a ship to give her the berth. There is only the one, '
                        'so two ships wanting the same hour is one of them '
                        'turned away.',
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
