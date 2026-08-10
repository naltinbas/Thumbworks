import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../till/play.dart';
import '../till/rounds.dart';
import 'counterview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One customer: count the amount out in the fewest coins there are.
class CounterScreen extends StatefulWidget {
  const CounterScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time the amount is met, with the coins it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int coins)? onDone;

  @override
  State<CounterScreen> createState() => CounterScreenState();
}

class CounterScreenState extends State<CounterScreen> {
  static const counterKey = ValueKey('counter');

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
  void didUpdateWidget(CounterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Rounds.at(widget.number), Rounds.fewestsFor(widget.number));
    _pointing = -1;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touchedTill(int kind) {
    if (kind < 0 || _play.isDone) return;

    if (_play.wouldOverpay(kind)) {
      setState(() {
        _pointing = -1;
        _saying = 'A ${_play.till.coins[kind].name} would go over. Only '
            '${_play.till.spoken(_play.owed)} is owed.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.put(kind);
    setState(() {
      _play = next;
      _pointing = -1;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  void _touchedTray(int place) {
    if (place < 0 || place >= _play.used) return;
    HapticFeedback.selectionClick();
    setState(() {
      _play = _play.take(_play.tray[place]);
      _pointing = -1;
      _saying = null;
    });
  }

  /// What the counter has to say after a coin goes down.
  ///
  /// One thing, and only when it is true: that the round can no longer be
  /// counted out in the fewest. The game can say that because the table
  /// answers what is owed as readily as it answered the whole amount.
  String? _note(Play play) {
    if (play.isDone) return null;
    final could = play.couldFinishIn;
    if (could <= play.round.fewest) return null;
    return 'The fewest this can come to now is $could coins, which is '
        '${could - play.round.fewest} more than the ${play.round.fewest} it '
        'takes.';
  }

  void _again() {
    setState(_set);
  }

  /// Asked. Points at the largest coin of a fewest way of finishing from what
  /// is owed now, so it is still right after a poor coin.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = -1;
        _saying = 'The amount is met.';
        return;
      }
      _pointing = next;
      _saying = 'The ${_play.till.coins[next].name}. '
          '${_play.left - 1} more after it.';
    });
  }

  /// Asked why. The floor on the old till, since every shipped amount there
  /// sits exactly on it, and the sweep on the new one.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      final round = _play.round;
      final fewests = _play.fewests;

      if (round.till.decimal) {
        _saying = 'On this till the biggest coin that fits is always the '
            'fewest. Every amount up to 500p has been counted both ways to '
            'check, and the two never part. The old till is the odd one out, '
            'not this one.';
        return;
      }

      final fewer = round.fewest - 1;
      final most = fewer * round.till.largest.pence;
      final floor = '$fewer coins of at most 2/6 come to at most '
          '${round.till.spoken(most)}, short of ${round.spoken}, so '
          '${round.fewest} is the fewest.';

      final quick = fewests.byBiggest(round.amount).fewest;
      _saying = quick > round.fewest
          ? '$floor And reaching for the biggest coin that fits pays $quick: '
              'the half crown first strands the amount between coins. Two '
              'florins go further than a half crown and change.'
          : '$floor The biggest coin that fits finds it here, as it happens.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.used).then((best) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Counter(
                    play: _play,
                    pointing: _pointing,
                    onTill: _touchedTill,
                    onTray: _touchedTray,
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

/// The line above the counter: which round, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.couldFinishIn > play.round.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the counter book',
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
                  '${play.round.spoken} wanted, ${play.till.name.toLowerCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Palette.inkDim, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${play.used} / ${play.round.fewest}',
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

/// The counter itself.
class _Counter extends StatelessWidget {
  const _Counter({
    required this.play,
    required this.pointing,
    required this.onTill,
    required this.onTray,
  });

  final Play play;
  final int pointing;
  final ValueChanged<int> onTill;
  final ValueChanged<int> onTray;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              final tray = metrics.trayPlaceAt(touch.localPosition);
              if (tray >= 0) {
                onTray(tray);
              } else {
                onTill(metrics.tillKindAt(touch.localPosition));
              }
            },
            child: CustomPaint(
              key: CounterScreenState.counterKey,
              size: size,
              painter: CounterView(
                play: play,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the counter: what the game has to say, and what else can be done.
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
                    'Tap a coin in the till to put it down, and a coin on the '
                        'tray to take it back.',
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
