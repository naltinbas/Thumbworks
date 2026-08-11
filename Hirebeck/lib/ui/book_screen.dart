import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../book/days.dart';
import '../book/play.dart';
import 'bookview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One day: book the ask without a clash.
class BookScreen extends StatefulWidget {
  const BookScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the filled book, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<BookScreen> createState() => BookScreenState();
}

class BookScreenState extends State<BookScreen> {
  static const dayKey = ValueKey('day');

  late Play _play;

  var _pointing = -1;
  var _strikes = const <int>[];
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  List<int> get strikes => _strikes;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(BookScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Days.at(widget.number));
    _pointing = -1;
    _strikes = const [];
    _hints = 0;
    _saying = _play.day.winnable
        ? null
        : 'The day cannot hold ${_play.day.ask} bookings, and the '
            'label said so. Book what you like and count; ask why '
            'for the o\'clocks.';
    _told = false;
    _best = false;
  }

  void _touched(int hiring) {
    if (hiring < 0 || _play.isDone) return;

    HapticFeedback.selectionClick();
    final couldClash = _play.clashes.length;
    final next = _play.toggle(hiring);
    setState(() {
      _play = next;
      _pointing = -1;
      _strikes = const [];
      _saying = _note(next, couldClash, hiring);
    });
    if (next.isDone) _finished();
  }

  String? _note(Play play, int couldClash, int hiring) {
    if (play.isDone) return null;
    final clashes = play.clashes;
    if (clashes.length > couldClash) {
      final (one, other) = clashes.last;
      return '${play.day.guests[one]} and ${play.day.guests[other]} '
          'both want the hall at once: the red says so. One of them '
          'must go.';
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
      _pointing = -1;
      _strikes = const [];
      _saying = null;
    });
  }

  /// Asked. The mend toward the early-finish book.
  void _showMe() {
    final mend = _play.next;
    setState(() {
      _hints++;
      _strikes = const [];
      if (_play.isDone) {
        _pointing = -1;
        _saying = 'The book is full.';
        return;
      }
      if (mend == null) {
        _pointing = -1;
        _saying = 'There is nothing to show: the day cannot hold '
            '${_play.day.ask} bookings, and the sweep tried every '
            'choice. Ask why instead.';
        return;
      }
      _pointing = mend;
      _saying = _play.isBooked(mend)
          ? 'Cancel ${_play.day.guests[mend]}: the full book has no '
              'room for that hiring.'
          : 'Book ${_play.day.guests[mend]}: it stands in the book '
              'the early-finish rule fills, and the sweep says that '
              'book is as full as any.';
    });
  }

  /// Asked why. The o'clocks, struck gold.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _strikes = _play.rules.piercing();
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
        backgroundColor: Palette.ledger,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Day(
                    play: _play,
                    pointing: _pointing,
                    strikes: _strikes,
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

/// The line above the day: which one, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final clashes = play.clashes.length;
    final dead = !play.day.winnable;

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
                  play.day.name,
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
                      ? 'the book is full, no clash in it'
                      : clashes > 0
                          ? '$clashes clash${clashes == 1 ? '' : 'es'} '
                              'on the book'
                          : dead
                              ? 'the day cannot hold the ask'
                              : 'book ${play.day.ask}; '
                                  '${play.bookedCount} stand booked',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : clashes > 0 || dead
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

/// The day itself.
class _Day extends StatelessWidget {
  const _Day({
    required this.play,
    required this.pointing,
    required this.strikes,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final List<int> strikes;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.hiringAt(touch.localPosition)),
            child: CustomPaint(
              key: BookScreenState.dayKey,
              size: size,
              painter: BookView(
                play: play,
                pointing: pointing,
                strikes: strikes,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the day: what the game has to say, and what else can be done.
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
                    'Tap a hiring to book it, again to cancel. Book '
                        'the asked number so that no two share an '
                        'hour of the hall.',
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
