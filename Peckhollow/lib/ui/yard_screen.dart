import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../yard/play.dart';
import '../yard/rules.dart';
import '../yard/yards.dart';
import 'palette.dart';
import 'result_card.dart';
import 'yardview.dart';

/// One yard: flip the arrows to the crowning asked.
class YardScreen extends StatefulWidget {
  const YardScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the crowning, with the flips taken. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int flips)? onDone;

  @override
  State<YardScreen> createState() => YardScreenState();
}

class YardScreenState extends State<YardScreen> {
  static const yardKey = ValueKey('yard');

  late Play _play;

  int? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(YardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Yards.at(widget.number));
    _pointing = null;
    _hints = 0;
    _saying = _play.yard.winnable
        ? null
        : 'Two crowns are asked, and the label has said already '
            'that no yard wears exactly two. Flip what you like and '
            'watch a second crown drag a third; ask why for the '
            'peckers.';
    _told = false;
    _best = false;
  }

  void _touched(int? arrow) {
    if (arrow == null || _play.isOver) return;

    HapticFeedback.selectionClick();
    final could = _play.yard.winnable ? _play.toDone : -1;
    final next = _play.flip(arrow);
    setState(() {
      _play = next;
      _pointing = null;
      _saying = _note(next, could);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play, int could) {
    if (play.isOver || could == -1) return null;
    final now = play.toDone;
    if (now >= could) {
      return 'That flip went nowhere: still $now '
          'flip${now == 1 ? '' : 's'} at fewest. Back unflips it.';
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
      _pointing = null;
      _saying = null;
    });
  }

  String _name(int bird) => bird == _play.yard.birds - 1 &&
          _play.yard.wantOnly != null
      ? 'the bantam'
      : 'bird ${bird + 1}';

  /// Asked. A flip on a shortest crowning.
  void _showMe() {
    setState(() {
      _hints++;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The crowning is done.';
        return;
      }
      final arrow = _play.next;
      if (arrow == null) {
        _pointing = null;
        _saying = 'There is nothing to show: no flipping of any '
            'yard reaches two crowns, and the sweep has flipped '
            'them all. Ask why instead.';
        return;
      }
      _pointing = arrow;
      final (one, two) = Rules.pairs(_play.yard.birds)[arrow];
      _saying = 'Flip the arrow between ${_name(one)} and '
          '${_name(two)}: a shortest crowning runs through it.';
    });
  }

  /// Asked why. The king theorems in words.
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
      widget.onDone?.call(_play.flips).then((best) {
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
                            metrics.arrowUnder(touch.localPosition)),
                        child: CustomPaint(
                          key: YardScreenState.yardKey,
                          size: size,
                          painter: YardView(
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

/// The line above the yard: which one, and how the crowns stand.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.yard.winnable;
    final crowned = play.kings.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the yards',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.yard.name,
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
                      ? 'the crowning stands'
                      : play.gaveUp
                          ? 'never two, as the label said'
                          : dead
                              ? '${play.yard.task}: no yard ever '
                                  'wears it'
                              : '${play.yard.task}; $crowned '
                                  'crowned now',
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
            '${play.flips} flip${play.flips == 1 ? '' : 's'}',
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

/// Under the yard: what the game has to say, and what else can be
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
                    'Every arrow shows who pecks whom; tap one to '
                        'turn it. A crowned bird reaches every '
                        'other in a peck or a peck-of-a-peck.',
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
