import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../mere/fields.dart';
import '../mere/play.dart';
import 'mereview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One field: link your banks before the mere links its own.
class MereScreen extends StatefulWidget {
  const MereScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at a linking, with the steps taken. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int steps)? onDone;

  @override
  State<MereScreen> createState() => MereScreenState();
}

class MereScreenState extends State<MereScreen> {
  static const marshKey = ValueKey('marsh');

  late Play _play;

  int? _pointing;
  String? _pieLit;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int? get pointing => _pointing;
  String? get pieLit => _pieLit;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(MereScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Fields.at(widget.number));
    _pointing = null;
    _pieLit = null;
    _hints = 0;
    _saying = _play.field.winnable
        ? null
        : 'The label has said already that every line from this '
            'chair loses. Step the marsh out and watch the solve '
            'close every door; ask why for the whole of it.';
    _told = false;
    _best = false;
  }

  void _touched(int? at) {
    if (at == null || _play.isOver) return;

    if (_play.pieOpen) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'The pie is on the table: take the mere\'s '
            'opening for your own, or wave it by.';
      });
      return;
    }

    if (!_play.mayStep(at)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'That tussock is taken.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final held = _play.field.winnable && _play.standing == 1;
    final next = _play.step(at);
    setState(() {
      _play = next;
      _pointing = null;
      _pieLit = null;
      _saying = _note(next, held);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play, bool held) {
    if (play.isOver) return null;
    if (held && play.standing != 1) {
      return 'That step handed the marsh away: the solve holds '
          'every line from here. Back steps out.';
    }
    return null;
  }

  void _pie(bool take) {
    if (!_play.pieOpen) return;
    HapticFeedback.selectionClick();
    final next = take ? _play.takePie() : _play.declinePie();
    setState(() {
      _play = next;
      _pointing = null;
      _pieLit = null;
      _saying = take
          ? 'The opening is yours, laid across the slant; the mere '
              'steps on.'
          : (_play.field.winnable && next.standing != 1
              ? 'The pie went by, and the solve now holds the far '
                  'chair. Back reconsiders.'
              : 'The pie went by; the opening stands against you.');
    });
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _pointing = null;
      _pieLit = null;
      _saying = null;
    });
  }

  /// Asked. What the solve does here.
  void _showMe() {
    setState(() {
      _hints++;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The marsh is settled.';
        return;
      }
      final way = _play.next;
      if (way == null) {
        _pointing = null;
        _pieLit = null;
        _saying = _play.field.winnable
            ? 'No step of yours keeps the marsh: the solve holds '
                'every line from here. Back is the only door.'
            : 'There is nothing to show: the solve holds every '
                'line from the second chair. Ask why instead.';
        return;
      }
      if (way == 'take' || way == 'decline') {
        _pointing = null;
        _pieLit = way;
        _saying = way == 'take'
            ? 'Take the pie: the opening sits on the short '
                'diagonal, and survives perfect play.'
            : 'Wave it by: the opening sits off the short '
                'diagonal, and the solve beats it from your chair.';
        return;
      }
      final at = int.parse(way);
      _pointing = at;
      _pieLit = null;
      _saying = 'Step there: the solve keeps the win through it.';
    });
  }

  /// Asked why. The marsh's law in words.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _pieLit = null;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (_play.isDone) {
      widget.onDone?.call(_play.moves).then((best) {
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
                    builder: (context, room) {
                      final size = Size(room.maxWidth, room.maxHeight);
                      final metrics = Metrics(_play, size);

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (touch) => _touched(
                            metrics.tussockUnder(touch.localPosition)),
                        child: CustomPaint(
                          key: MereScreenState.marshKey,
                          size: size,
                          painter: MereView(
                            play: _play,
                            pointing: _pointing,
                            labels:
                                const TextStyle(fontFamily: 'Roboto'),
                          ),
                        ),
                      );
                    },
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
                  pieLit: _pieLit,
                  onTake: () => _pie(true),
                  onDecline: () => _pie(false),
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

/// The line above the marsh: which field, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.field.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the fields',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.field.name,
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
                      ? 'west meets east'
                      : play.isLost
                          ? dead
                              ? 'the mere crossed, as the label said'
                              : 'the mere crossed first'
                          : dead
                              ? '${play.field.task}: every line '
                                  'loses'
                              : play.field.task,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : dead || play.isLost
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.moves} step${play.moves == 1 ? '' : 's'}',
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

/// Under the marsh: the pie when it is on the table, what the game
/// has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.play,
    required this.saying,
    required this.pieLit,
    required this.onTake,
    required this.onDecline,
    required this.onAgain,
    required this.onBack,
    required this.onShowMe,
    required this.onWhy,
  });

  final Play play;
  final String? saying;
  final String? pieLit;
  final VoidCallback onTake;
  final VoidCallback onDecline;
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
                    'Step a tussock; the mere answers with the game '
                        'solved to its end. Gold links west to '
                        'east, the rushes north to south.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            if (play.pieOpen) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _BigButton(
                      label: 'Take the pie',
                      lit: pieLit == 'take',
                      onTap: onTake,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _BigButton(
                      label: 'Wave it by',
                      lit: pieLit == 'decline',
                      onTap: onDecline,
                    ),
                  ),
                ],
              ),
            ],
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
                  color: lit ? Palette.shown : Palette.gold,
                  width: lit ? 2.6 : 1.4,
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
