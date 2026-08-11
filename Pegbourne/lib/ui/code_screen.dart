import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../code/play.dart';
import '../code/riddles.dart';
import 'codeview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One riddle: set the pegs every row allows.
class CodeScreen extends StatefulWidget {
  const CodeScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the answer, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<CodeScreen> createState() => CodeScreenState();
}

class CodeScreenState extends State<CodeScreen> {
  static const tableKey = ValueKey('table');

  late Play _play;

  (int, int)? _pointing;
  int? _other;
  var _otherAt = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  int? get other => _other;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(CodeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Riddles.at(widget.number));
    _pointing = null;
    _other = null;
    _otherAt = -1;
    _hints = 0;
    _saying = switch (_play.riddle.ways) {
      0 => 'No code earns every row its marks, and the label said '
          'so. Set the pegs how you like and watch the rows; ask why '
          'for the counting.',
      1 => null,
      _ => 'More than one code answers these rows, and the label '
          'says so: set any code they all allow.',
    };
    _told = false;
    _best = false;
  }

  void _touched(int slot) {
    if (slot < 0 || _play.isDone) return;

    HapticFeedback.selectionClick();
    final couldBreak = _play.broken.length;
    final next = _play.cycle(slot);
    setState(() {
      _play = next;
      _pointing = null;
      _other = null;
      _otherAt = -1;
      _saying = _note(next, couldBreak);
    });
    if (next.isDone) _finished();
  }

  String? _note(Play play, int couldBreak) {
    if (play.isDone || !play.isComplete) return null;
    final broken = play.broken;
    if (broken.isEmpty) return null;
    return 'Row ${broken.first + 1} would not mark your pegs that '
        'way: the red rows disagree with what is written.';
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _pointing = null;
      _other = null;
      _otherAt = -1;
      _saying = null;
    });
  }

  /// Asked. The mend toward the nearest agreeing code.
  void _showMe() {
    final mend = _play.next;
    setState(() {
      _hints++;
      _other = null;
      _otherAt = -1;
      if (_play.isDone) {
        _pointing = null;
        _saying = 'The riddle is answered.';
        return;
      }
      if (mend == null) {
        _pointing = null;
        _saying = 'There is nothing to show: no code earns every '
            'row its marks, and the sweep set all 256 against them. '
            'Ask why instead.';
        return;
      }
      _pointing = mend;
      _saying = 'That slot wants '
          '${const ['red', 'green', 'blue', 'yellow'][mend.$2]}: so '
          'it stands in a code the sweep counted.';
    });
  }

  /// Asked why. The sweep, and for the two minds each answer in turn.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      if (_play.riddle.ways > 1) {
        _otherAt = (_otherAt + 1) % _play.answers.length;
        _other = _play.answers[_otherAt];
      }
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
        backgroundColor: Palette.table,
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
                    other: _other,
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

/// The line above the table: which riddle, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final broken = play.broken.length;
    final dead = !play.riddle.winnable;
    final filled =
        play.slots.where((peg) => peg >= 0).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the riddles',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.riddle.name,
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
                      ? 'every row agrees'
                      : broken > 0
                          ? '$broken row${broken == 1 ? '' : 's'} '
                              'disagree${broken == 1 ? 's' : ''}'
                          : dead
                              ? 'no code earns every row its marks'
                              : '$filled of 4 pegs set',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : broken > 0 || dead
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.moves} turned',
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
    required this.other,
    required this.onTouch,
  });

  final Play play;
  final (int, int)? pointing;
  final int? other;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.slotAt(touch.localPosition)),
            child: CustomPaint(
              key: CodeScreenState.tableKey,
              size: size,
              painter: CodeView(
                play: play,
                pointing: pointing,
                other: other,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the table: what the game has to say, and what else can be
/// done.
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
                    'Tap a slot to turn its peg through the colours. '
                        'A black mark is the right colour in the '
                        'right place; a white is the right colour '
                        'astray. Set pegs every row marks true.',
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
