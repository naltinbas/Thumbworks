import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../show/play.dart';
import '../show/rules.dart';
import '../show/show.dart';
import '../show/shows.dart';
import 'palette.dart';
import 'result_card.dart';
import 'showview.dart';

/// One bench: judge the marrows as they come.
class ShowScreen extends StatefulWidget {
  const ShowScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
    this.deals,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at a winnable bench's closing, with the sittings
  /// taken. Answers whether that beat what was written down before.
  final Future<bool> Function(int sittings)? onDone;

  /// The sittings to deal, in order. A test hands them written out;
  /// left null, the screen shuffles the lot of them.
  final List<List<int>>? deals;

  @override
  State<ShowScreen> createState() => ShowScreenState();
}

class ShowScreenState extends State<ShowScreen> {
  static const benchKey = ValueKey('bench');

  late Play _play;

  bool? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  bool? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(ShowScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    final show = Shows.at(widget.number);
    final deals = widget.deals ??
        (Rules.allSittings(show.marrows)..shuffle(math.Random()));
    _play = Play.of(show, deals);
    _pointing = null;
    _hints = 0;
    _saying = show.sure
        ? 'Land the best marrow of every sitting, and the label has '
            'said already that no rule does. Judge as well as can '
            'be judged and see where it has you; ask why for the '
            'fork.'
        : null;
    _told = false;
    _best = false;
  }

  void _take() {
    if (!_play.judging) return;
    HapticFeedback.selectionClick();
    final next = _play.take();
    setState(() {
      _play = next;
      _pointing = null;
      _saying = _verdict(next);
    });
    if (next.isOver) _finished();
  }

  void _wave() {
    if (!_play.mayWave) return;
    HapticFeedback.selectionClick();
    setState(() {
      _play = _play.wave();
      _pointing = null;
      _saying = null;
    });
  }

  String _verdict(Play play) {
    final best = play.deal.indexOf(play.show.marrows - 1);
    if (play.sittingWon) {
      return 'The best of the bench, taken at seat ${play.kept! + 1}.';
    }
    final stood = play.show.marrows - play.deal[play.kept!];
    return 'The best sat seat ${best + 1}; the one taken stood '
        '$stood${_th(stood)} of the ${play.show.marrows}.';
  }

  String _th(int count) {
    if (count == 1) return 'st';
    if (count == 2) return 'nd';
    if (count == 3) return 'rd';
    return 'th';
  }

  void _nextDeal() {
    if (_play.judging || _play.isOver) return;
    setState(() {
      _play = _play.nextDeal();
      _pointing = null;
      _saying = null;
    });
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    final before = _play.before;
    if (!_play.judging ||
        before == null ||
        !before.judging ||
        before.dealAt != _play.dealAt) {
      setState(() {
        _saying = 'Nothing to take back this sitting: a marrow '
            'waved by in an earlier one is gone for good.';
      });
      return;
    }
    setState(() {
      _play = _play.back;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. What the rule does with the marrow up now.
  void _showMe() {
    setState(() {
      _hints++;
      if (!_play.judging) {
        _pointing = null;
        _saying = 'The sitting is judged; bring up the next.';
        return;
      }
      final takes = _play.ruleTakes;
      _pointing = takes;
      if (!_play.mayWave) {
        _saying = 'Take it: the bench is out, and the last is '
            'always taken.';
      } else if (takes) {
        _saying = 'Take it: past the waved-by and the best yet, '
            'which is the whole of the rule.';
      } else if (_play.record) {
        _saying = 'Wave it by: the best yet, but the rule waves '
            '${_play.show.skip} past before it will take.';
      } else {
        _saying = 'Wave it by: not the best yet, and no rule takes '
            'a lesser marrow while the bench holds.';
      }
    });
  }

  /// Asked why. The rule and the sweep in words.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (_play.benchWon && _play.show.winnable) {
      widget.onDone?.call(_play.played).then((best) {
        if (mounted && best) setState(() => _best = true);
      });
    }
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
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: LayoutBuilder(
                    builder: (context, room) => CustomPaint(
                      key: ShowScreenState.benchKey,
                      size: Size(room.maxWidth, room.maxHeight),
                      painter: ShowView(
                        play: _play,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                    ),
                  ),
                ),
              ),
              if (_play.isOver)
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
                  play: _play,
                  saying: _saying,
                  pointing: _pointing,
                  onTake: _take,
                  onWave: _wave,
                  onNextDeal: _nextDeal,
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

/// The line above the bench: which one, and how the tally stands.
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
            tooltip: 'Back to the benches',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.show.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.show.sure
                      ? 'every sitting must land the best'
                      : 'won ${play.won} of the ${Show.asked} '
                          'asked, ${play.played} sat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.show.sure
                        ? Palette.bad
                        : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.won} won',
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

/// Under the bench: the judging, what the game has to say, and what
/// else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.play,
    required this.saying,
    required this.pointing,
    required this.onTake,
    required this.onWave,
    required this.onNextDeal,
    required this.onAgain,
    required this.onBack,
    required this.onShowMe,
    required this.onWhy,
  });

  final Play play;
  final String? saying;
  final bool? pointing;
  final VoidCallback onTake;
  final VoidCallback onWave;
  final VoidCallback onNextDeal;
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
                    'One marrow up at a time, sized only against '
                        'the seen. Take it and the sitting ends; '
                        'wave it by and it is gone for good.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (play.judging)
              Row(
                children: [
                  Expanded(
                    child: _BigButton(
                      label: 'Take it',
                      lit: pointing == true,
                      onTap: onTake,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BigButton(
                      label: 'Wave it by',
                      lit: pointing == false,
                      dim: !play.mayWave,
                      onTap: onWave,
                    ),
                  ),
                ],
              )
            else
              _BigButton(
                label: 'Next sitting',
                lit: true,
                onTap: onNextDeal,
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

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.label,
    required this.lit,
    required this.onTap,
    this.dim = false,
  });

  final String label;
  final bool lit;
  final bool dim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Palette.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: lit
                      ? Palette.shown
                      : dim
                          ? Palette.line
                          : Palette.edge,
                  width: lit ? 2.6 : 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: dim ? Palette.inkDim : Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
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
