import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../hall/halls.dart';
import '../hall/play.dart';
import 'hallview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One hall: post the watch and light every flag.
class HallScreen extends StatefulWidget {
  const HallScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the lighting, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<HallScreen> createState() => HallScreenState();
}

class HallScreenState extends State<HallScreen> {
  static const hallKey = ValueKey('hall');

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
  void didUpdateWidget(HallScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Halls.at(widget.number));
    _pointing = null;
    _hints = 0;
    _saying = _play.hall.winnable
        ? null
        : 'Two wards are allowed, and the label has said already '
            'that this comb needs three. Post them where you like '
            'and watch a tooth stay dark; ask why for the sweep.';
    _told = false;
    _best = false;
  }

  void _touched(int? corner) {
    if (corner == null || _play.isOver) return;

    if (_play.wards.contains(corner)) {
      HapticFeedback.selectionClick();
      setState(() {
        _play = _play.lift(corner);
        _pointing = null;
        _saying = null;
      });
      return;
    }

    if (_play.wards.length >= _play.hall.asked) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'The watch is at its full '
            '${_play.hall.asked}: lift a lantern before posting '
            'another.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final next = _play.post(corner);
    setState(() {
      _play = next;
      _pointing = null;
      _saying = _note(next);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play) {
    if (play.isOver) return null;
    if (play.short && play.hall.winnable) {
      final dark = play.unlit.length;
      return 'The watch stands full and $dark '
          'flag${dark == 1 ? '' : 's'} stay dark: lift a lantern '
          'and try another corner.';
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

  /// Asked. The next corner of a watch the sweep found.
  void _showMe() {
    setState(() {
      _hints++;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The hall is lit.';
        return;
      }
      final watch = _play.finished;
      if (watch == null) {
        _pointing = null;
        _saying = _play.hall.winnable
            ? 'No watch within the asking grows from these '
                'lanterns: the sweep has posted every one. Lift a '
                'ward first.'
            : 'There is nothing to show: no two corners light this '
                'comb, and the sweep has posted all sixty-six '
                'pairs. Ask why instead.';
        return;
      }
      final corner = _play.nextOf(watch);
      _pointing = corner;
      _saying = 'Post a ward there: a full watch within the asking '
          'stands through it.';
    });
  }

  /// Asked why. The colouring and the sweep in words.
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
      widget.onDone?.call(_hints).then((best) {
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
                            metrics.cornerUnder(touch.localPosition)),
                        child: CustomPaint(
                          key: HallScreenState.hallKey,
                          size: size,
                          painter: HallView(
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

/// The line above the hall: which one, and how the floor stands.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.hall.winnable;
    final dark = play.unlit.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the halls',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.hall.name,
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
                      ? 'every flag is lit'
                      : play.isOver
                          ? 'a tooth stays dark, as the label said'
                          : dead
                              ? '${play.hall.task}: no watch ever '
                                  'has'
                              : '${play.hall.task}; $dark dark now',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : dead || play.isOver
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.wards.length} of ${play.hall.asked}',
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

/// Under the hall: what the game has to say, and what else can be
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
                    'Tap a corner to post a ward there, tap its '
                        'lantern to lift it. A ward lights every '
                        'flag no wall stands between.',
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
