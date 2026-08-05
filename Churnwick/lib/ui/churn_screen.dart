import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../churn/dairies.dart';
import '../churn/dairy.dart';
import '../churn/fewest.dart';
import '../churn/play.dart';
import 'dairyview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One morning: get the amount wanted standing in a churn.
class ChurnScreen extends StatefulWidget {
  const ChurnScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a morning is measured out, with how many
  /// goes it took. Answers whether that beat what was written down before.
  final Future<bool> Function(int goes)? onDone;

  @override
  State<ChurnScreen> createState() => ChurnScreenState();
}

class ChurnScreenState extends State<ChurnScreen> {
  static const dairyKey = ValueKey('dairy');

  late Morning _morning;
  late Play _play;

  var _showSteps = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Morning get morning => _morning;
  Play get play => _play;
  bool get showSteps => _showSteps;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(ChurnScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _morning = Mornings.at(widget.number);
    _play = Play.of(_morning.dairy, Mornings.answerFor(widget.number));
    _showSteps = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  /// A tap on a churn, on the vat or on the drain.
  void _touched(int what) {
    if (_play.isDone) return;

    if (what == Thing.nothing) return;

    if (what == Thing.vat || what == Thing.drain) {
      if (_play.holding < 0) {
        setState(() => _saying = 'Pick a churn up first.');
        return;
      }
      _did(_play.doIt(what == Thing.vat
          ? Pour.fill(_play.holding)
          : Pour.empty(_play.holding)));
      return;
    }

    if (_play.holding < 0 || _play.holding == what) {
      HapticFeedback.selectionClick();
      setState(() {
        _play = _play.hold(what);
        _saying = null;
      });
      return;
    }

    _did(_play.doIt(Pour.tip(_play.holding, what)));
  }

  void _did(Play next) {
    if (identical(next, _play)) {
      setState(() => _saying = 'That would not change anything.');
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _showSteps = false;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the dairy has to say after a pour.
  ///
  /// One thing, and only when it is true: that the morning can no longer be
  /// done in as few goes as it might have been. The game can say that because
  /// it walks the dairy again from where the milk stands now, which is a
  /// different question from the one it answered when the morning opened and
  /// costs no more.
  String? _note(Play play) {
    if (play.isDone) return null;
    final could = play.couldFinishIn;
    if (could == null || could <= _morning.fewest) return null;
    return 'The best this can be finished in now is $could goes, which is '
        '${could - _morning.fewest} more than the ${_morning.fewest} it takes.';
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _showSteps = false;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  void _back() {
    if (_play.goes == 0) return;
    setState(() {
      _play = _play.back;
      _showSteps = false;
      _saying = null;
    });
  }

  /// Asked. Does the next thing that still finishes in as few goes as the
  /// morning can now be finished in, and says what it did.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      _showSteps = false;
      if (next == null) {
        _saying = 'There is nothing left to do.';
        return;
      }
      _play = _play.doIt(next);
      _saying = '${_didWhat(next)} ${_play.rest?.pours ?? 0} more after that.';
    });
    if (_play.isDone) _finished();
  }

  String _didWhat(Pour pour) {
    final size = _morning.dairy.churns;
    if (pour.isFill) return 'Fill the ${size[pour.churn]}.';
    if (pour.isEmpty) return 'Empty the ${size[pour.churn]}.';
    return 'Pour the ${size[pour.churn]} into the ${size[pour.into]}.';
  }

  /// Asked what can be measured here at all. Nothing to do with the morning in
  /// hand: it is the one fact about a dairy that needs no search. Filling puts
  /// a churnful in, emptying takes one out, and pouring moves milk about
  /// without losing any, so what stands anywhere is always a whole number of
  /// the step added and taken away.
  void _why() {
    setState(() {
      _hints++;
      _showSteps = true;
      final step = _play.stepOfDairy;
      final can = Pouring.whatCanStand(_morning.dairy);
      final sizes = _morning.dairy.churns.join(' and ');
      if (step == 1) {
        _saying = 'The $sizes have no whole number in common but one, so every '
            'amount from 1 to ${_morning.dairy.biggest} can be got to stand '
            'somewhere.';
        return;
      }
      _saying = 'Every churn here is a whole number of $step, and pouring only '
          'ever moves whole ${step}s about, so nothing else can ever stand in '
          'one. Only ${can.join(', ')} can be measured in this dairy at all.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.goes).then((best) {
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
              _Ledger(
                morning: _morning,
                play: _play,
                onLeave: widget.onLeave,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _Dairy(
                    play: _play,
                    showSteps: _showSteps,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  morning: _morning,
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  canTakeBack: _play.goes > 0,
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

/// The line above the dairy: which morning, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.morning,
    required this.play,
    required this.onLeave,
  });

  final Morning morning;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.goes > morning.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the mornings',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  morning.name,
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
                      ? '${play.dairy.want} gallons standing'
                      : '${play.dairy.want} gallons wanted',
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
            '${play.goes} / ${morning.fewest}',
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

/// The dairy itself.
class _Dairy extends StatelessWidget {
  const _Dairy({
    required this.play,
    required this.showSteps,
    required this.onTouch,
  });

  final Play play;
  final bool showSteps;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.whatAt(touch.localPosition)),
            child: CustomPaint(
              key: ChurnScreenState.dairyKey,
              size: size,
              painter: DairyView(
                play: play,
                showSteps: showSteps,
                labels: const TextStyle(fontFamily: 'Roboto', fontSize: 13),
              ),
            ),
          );
        },
      );
}

/// Under the dairy: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.canTakeBack,
    required this.onBack,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final bool canTakeBack;
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
                    'Tap a churn to pick it up. Then the vat to fill it, the '
                        'drain to empty it, or another churn to pour it in.',
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
                Expanded(
                  child: _Button(
                    label: 'Take back',
                    dead: !canTakeBack,
                    onTap: onBack,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _Button(
                    label: 'Again',
                    dead: !canTakeBack,
                    onTap: onAgain,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _Button(label: 'Show me', dead: false, onTap: onShowMe),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _Button(label: 'Why', dead: false, onTap: onWhy),
                ),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.dead,
    required this.onTap,
  });

  final String label;
  final bool dead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: dead ? null : onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: dead ? Palette.line : Palette.edge,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: dead ? Palette.inkDim : Palette.ink,
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
