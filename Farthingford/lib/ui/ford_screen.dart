import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ford/play.dart';
import '../ford/reaches.dart';
import 'fordview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One reach: wade to the ford the task names.
class FordScreen extends StatefulWidget {
  const FordScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the landing, with the wades taken. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int wades)? onDone;

  @override
  State<FordScreen> createState() => FordScreenState();
}

class FordScreenState extends State<FordScreen> {
  static const streamKey = ValueKey('stream');

  late Play _play;

  /// The action being pointed at: 'left', 'right', 'cross', or null.
  String? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  String? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(FordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Reaches.at(widget.number));
    _pointing = null;
    _hints = 0;
    _saying = _play.reach.winnable
        ? null
        : 'The label has said already that nothing shallower than '
            'fifths crosses this reach. Wade where you like and '
            'watch the stones only deepen; ask why for the depths.';
    _told = false;
    _best = false;
  }

  void _wade(bool leftward) {
    if (_play.isOver) return;
    HapticFeedback.selectionClick();
    final held = _play.holdsTarget;
    final next = leftward ? _play.wadeLeft() : _play.wadeRight();
    setState(() {
      _play = next;
      _pointing = null;
      _saying = _note(next, held);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play, bool held) {
    if (play.isOver) return null;
    final target = play.reach.target;
    if (target != null && held && !play.holdsTarget) {
      return 'That wade left ${target.$1}/${target.$2} behind: the '
          'banks no longer hold it between them. Back wades out.';
    }
    return null;
  }

  void _cross() {
    if (_play.isOver) return;
    HapticFeedback.selectionClick();
    if (!_play.stoneIsTarget) {
      setState(() {
        _pointing = null;
        _saying = 'The stone is ${_play.stone.$1}/'
            '${_play.stone.$2}, not the ford the task names.';
      });
      return;
    }
    final next = _play.cross();
    setState(() {
      _play = next;
      _pointing = null;
      _saying = null;
    });
    if (next.isOver) _finished();
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. What the true walk does here.
  void _showMe() {
    setState(() {
      _hints++;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The crossing is made.';
        return;
      }
      final way = _play.next;
      if (way == null) {
        _pointing = null;
        _saying = _play.reach.winnable
            ? 'The banks no longer hold the ford; there is nothing '
                'to point at but Back.'
            : 'There is nothing to show: no ford of any depth '
                'crosses shallower than fifths, and the sweep has '
                'read them all. Ask why instead.';
        return;
      }
      _pointing = way;
      _saying = switch (way) {
        'left' => 'Wade left: the ford lies between the left bank '
            'and the stone.',
        'right' => 'Wade right: the ford lies between the stone '
            'and the right bank.',
        _ => 'Cross here: the stone is the ford itself.',
      };
    });
  }

  /// Asked why. The stream's law in words.
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
    if (_play.isDone) {
      widget.onDone?.call(_play.wades).then((best) {
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
                      key: FordScreenState.streamKey,
                      size: Size(room.maxWidth, room.maxHeight),
                      painter: FordView(
                        play: _play,
                        crossLit: _pointing == 'cross',
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
                  saying: _saying,
                  pointing: _pointing,
                  onLeft: () => _wade(true),
                  onRight: () => _wade(false),
                  onCross: _cross,
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

/// The line above the stream: which reach, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.reach.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the reaches',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.reach.name,
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
                      ? 'the crossing is made'
                      : play.gaveUp
                          ? 'never shallower, as the label said'
                          : dead
                              ? '${play.reach.task}: no ford of any '
                                  'depth does'
                              : play.reach.task,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : dead || play.gaveUp
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.wades} wade${play.wades == 1 ? '' : 's'}',
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

/// Under the stream: the wading, what the game has to say, and what
/// else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.pointing,
    required this.onLeft,
    required this.onRight,
    required this.onCross,
    required this.onAgain,
    required this.onBack,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final String? pointing;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onCross;
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
                    'The gold stone is the banks\' mediant. Wade '
                        'left or right to keep the flagged ford '
                        'between your banks, and cross when the '
                        'stone is the ford itself.',
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
                  child: _BigButton(
                    label: 'Wade left',
                    lit: pointing == 'left',
                    onTap: onLeft,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BigButton(
                    label: 'Cross here',
                    lit: pointing == 'cross',
                    onTap: onCross,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _BigButton(
                    label: 'Wade right',
                    lit: pointing == 'right',
                    onTap: onRight,
                  ),
                ),
              ],
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
  });

  final String label;
  final bool lit;
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
                  color: lit ? Palette.shown : Palette.edge,
                  width: lit ? 2.6 : 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 15,
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
