import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../toss/call.dart';
import '../toss/play.dart';
import '../toss/wagers.dart';
import 'palette.dart';
import 'result_card.dart';
import 'tossview.dart';

/// One table: call, toss, and see whose run shows first.
class TossScreen extends StatefulWidget {
  const TossScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, if you take the match, with the rounds the house took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int conceded)? onDone;

  @override
  State<TossScreen> createState() => TossScreenState();
}

class TossScreenState extends State<TossScreen> {
  static const tableKey = ValueKey('table');

  late Play _play;
  final _coin = math.Random();

  Call? _pointing;
  var _showRing = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  Call? get pointing => _pointing;
  bool get showRing => _showRing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(TossScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Wagers.at(widget.number));
    _pointing = null;
    _showRing = false;
    _hints = 0;
    _saying = _opening();
    _told = false;
    _best = false;
  }

  String? _opening() {
    final wager = Wagers.at(widget.number);
    if (wager.theyCallFirst) {
      return 'The house has called ${wager.theirCall.said}. Your reply, '
          'and this once the odds can be yours.';
    }
    if (wager.forced != null) {
      return 'This table holds you to ${wager.forced!.said}. Call it and '
          'see what that costs.';
    }
    return null;
  }

  void _touched(Offset local, Metrics metrics) {
    if (_play.isOver) return;

    if (_play.yours == null) {
      final call = metrics.callAt(local);
      if (call == null) return;
      final held = _play.wager.forced;
      if (held != null && call != held) {
        HapticFeedback.selectionClick();
        setState(() {
          _saying = 'This table holds you to ${held.said}.';
        });
        return;
      }
      HapticFeedback.selectionClick();
      final next = _play.call(call);
      setState(() {
        _play = next;
        _pointing = null;
        _showRing = false;
        _saying = 'You call ${next.yours!.said}; the house calls '
            '${next.theirs!.said}. Toss, and first call shown takes the '
            'round.';
      });
      return;
    }

    _toss();
  }

  /// One flip of the coin.
  void _toss() {
    if (_play.yours == null || _play.isOver) return;
    if (_play.roundOver) {
      setState(() {
        _play = _play.nextRound;
        _saying = null;
      });
      return;
    }
    HapticFeedback.selectionClick();
    final next = _play.flip(_coin.nextBool());
    setState(() {
      _play = next;
      _pointing = null;
      _showRing = false;
      if (next.roundOver) {
        final yours = next.shownBy == next.yours;
        _saying = '${next.shownBy!.said} shows: '
            '${yours ? 'you take the round' : 'the house takes the round'}.'
            '${next.isOver ? '' : ' Toss on for the next.'}';
      }
    });
    if (next.isOver) _finished();
  }

  void _again() {
    setState(_set);
  }

  /// Asked. The best that can be said at this table.
  void _showMe() {
    setState(() {
      _hints++;
      _showRing = false;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The match is settled.';
        return;
      }
      if (_play.yours == null) {
        if (_play.wager.theyCallFirst) {
          _pointing = _play.beatingReply;
          _saying = 'Call ${_play.beatingReply!.said}: the other side of '
              'the house\'s middle flip, then its first two. Its call now '
              'ends where yours begins.';
          return;
        }
        if (_play.wager.forced != null) {
          _pointing = _play.wager.forced;
          _saying = 'The table holds you to ${_play.wager.forced!.said}; '
              'there is nothing to choose.';
          return;
        }
        _pointing = null;
        _saying = _play.wager.evenTable
            ? 'Call anything: the house answers with your opposite, and '
                'every such pair is exactly even.'
            : 'There is no good call: whatever you say, the house\'s '
                'reply beats it. The middle six lose two to one; the runs '
                'of three lose seven to one.';
        return;
      }
      _pointing = null;
      _saying = 'The coin has no memory. Nothing to show but the toss.';
    });
  }

  /// Asked why. The ring.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _showRing = !_showRing;
      _saying = _showRing ? whyWords(_play) : null;
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (!_play.won) return;
    widget.onDone?.call(_play.theirRounds).then((best) {
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
        backgroundColor: Palette.taproom,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Table(
                    play: _play,
                    pointing: _pointing,
                    showRing: _showRing,
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
                  onAgain: _again,
                  onToss: _toss,
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

/// The line above the table: which wager, and how it stands.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the tables',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.wager.name,
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
                      ? (play.won ? 'the match is yours' : 'the house has it')
                      : 'first to ${play.wager.stakes}',
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
            '${play.yourRounds} : ${play.theirRounds}',
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

/// The table itself.
class _Table extends StatelessWidget {
  const _Table({
    required this.play,
    required this.pointing,
    required this.showRing,
    required this.onTouch,
  });

  final Play play;
  final Call? pointing;
  final bool showRing;
  final void Function(Offset, Metrics) onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(touch.localPosition, metrics),
            child: CustomPaint(
              key: TossScreenState.tableKey,
              size: size,
              painter: TossView(
                play: play,
                pointing: pointing,
                showRing: showRing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the table: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onToss,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onAgain;
  final VoidCallback onToss;
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
                color: Palette.board,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Call three flips. The house calls after you, the coin '
                        'goes up, and the first call shown in the run takes '
                        'the round.',
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
                Expanded(child: _Button(label: 'Toss', onTap: onToss)),
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
                color: Palette.board,
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
