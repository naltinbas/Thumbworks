import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../hire/fairs.dart';
import '../hire/play.dart';
import 'boardview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One day: give out as much of the work as the hands will cover.
class HireScreen extends StatefulWidget {
  const HireScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a day is finished, with how much of the work
  /// was covered. Answers whether that beat what was written down before.
  final Future<bool> Function(int covered)? onDone;

  @override
  State<HireScreen> createState() => HireScreenState();
}

class HireScreenState extends State<HireScreen> {
  static const boardKey = ValueKey('board');

  late Day _day;
  late Play _play;

  var _showShort = false;
  var _pointing = (-1, -1);
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Day get day => _day;
  Play get play => _play;
  bool get showShort => _showShort;
  (int, int) get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(HireScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _day = Days.at(widget.number);
    _play = Play.of(_day.fair, Days.answerFor(widget.number));
    _showShort = false;
    _pointing = (-1, -1);
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int job, int hand) {
    if (job < 0) return;

    // A tap on the words down the side takes the job back off whoever has it.
    if (hand < 0) {
      if (_play.handOn(job) < 0) return;
      _went(_play.let(job));
      return;
    }

    if (!_day.fair.can(job, hand)) {
      setState(() {
        _pointing = (-1, -1);
        _showShort = false;
        _saying = '${_hand(hand)} does not do ${_work(job).toLowerCase()}.';
      });
      return;
    }

    if (_play.handOn(job) != hand && !_play.isFree(hand)) {
      final on = _play.jobOf(hand);
      setState(() {
        _pointing = (on, hand);
        _showShort = false;
        _saying = '${_hand(hand)} is already on '
            '${_work(on).toLowerCase()}.';
      });
      return;
    }

    _went(_play.take(job, hand));
  }

  void _went(Play next) {
    if (identical(next, _play)) return;
    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _pointing = (-1, -1);
      _showShort = false;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the board has to say after a job is given out or taken back.
  ///
  /// One thing, and only when it is true: that the day can no longer cover as
  /// much as it might have. The game can say that because it runs the same
  /// walk again over the work nobody is on and the hands nobody has taken,
  /// which is a different question from the one it answered when the day
  /// opened.
  String? _note(Play play) {
    if (play.isDone) return null;
    final could = play.couldStillGet;
    if (could >= _day.most) return null;
    return 'The best this day can come to now is $could jobs, which is '
        '${_day.most - could} short of the ${_day.most} that can be covered.';
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _showShort = false;
      _pointing = (-1, -1);
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Points at a job and a hand that still leaves the day as good as it
  /// can now be.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      _showShort = false;
      if (next == null) {
        _pointing = (-1, -1);
        _saying = 'There is nothing left to give out.';
        return;
      }
      _pointing = next;
      _saying = '${_work(next.$1)} to ${_hand(next.$2)}.';
    });
  }

  /// Asked why the whole board cannot be covered. Marks a set of jobs that
  /// have fewer hands between them than there are jobs, which is the whole of
  /// the answer and can be checked by looking: every cross in those rows falls
  /// inside the ringed columns.
  void _why() {
    setState(() {
      _hints++;
      _pointing = (-1, -1);
      _showShort = true;
      final hiring = _play.answer;
      if (hiring.undone == 0) {
        _saying = 'Every set of jobs on this board has at least as many hands '
            'that can take one of them on, so all ${_day.most} can be '
            'covered. That is the whole of what decides it.';
        return;
      }
      final jobs = hiring.short.map(_work).toList();
      final hands = hiring.onlyThese.map(_hand).toList();
      _saying = '${_list(jobs)} can only be taken on by ${_list(hands)}. That '
          'is ${jobs.length} jobs and ${hands.length} hands, and nobody can be '
          'in two places, so ${hiring.undone} of them '
          '${hiring.undone == 1 ? 'goes' : 'go'} undone whatever anybody does.';
    });
  }

  String _list(List<String> words) => words.length == 1
      ? words.first
      : '${words.sublist(0, words.length - 1).join(', ')} and ${words.last}';

  String _work(int job) => _day.fair.work[job];
  String _hand(int hand) => _day.fair.hands[hand];

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.covered).then((best) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _Board(
                    play: _play,
                    showShort: _showShort,
                    pointing: _pointing,
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

/// The line above the board: which day, and how it is going.
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
            tooltip: 'Back to the fairs',
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
                      ? 'nothing else can be given out'
                      : '${play.fair.jobs - play.covered} of '
                          '${play.fair.jobs} still to give out',
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
            '${play.covered} / ${day.most}',
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

/// The board itself.
class _Board extends StatelessWidget {
  const _Board({
    required this.play,
    required this.showShort,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final bool showShort;
  final (int, int) pointing;
  final void Function(int job, int hand) onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              final (job, hand) = metrics.cellUnder(touch.localPosition);
              onTouch(job, hand);
            },
            child: CustomPaint(
              key: HireScreenState.boardKey,
              size: size,
              painter: BoardView(
                play: play,
                showShort: showShort,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto', fontSize: 12),
              ),
            ),
          );
        },
      );
}

/// Under the board: what the game has to say, and what else can be done.
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
                    'Tap a cross to give that job to that hand. Nobody can be '
                        'in two places, so a hand taken on is a hand nobody '
                        'else can have.',
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
