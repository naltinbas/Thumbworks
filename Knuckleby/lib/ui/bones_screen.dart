import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bones/benches.dart';
import '../bones/play.dart';
import 'bonesview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One bench: cut the pips to the trade asked.
class BonesScreen extends StatefulWidget {
  const BonesScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the matching, with the cuts taken. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int cuts)? onDone;

  @override
  State<BonesScreen> createState() => BonesScreenState();
}

class BonesScreenState extends State<BonesScreen> {
  static const benchKey = ValueKey('bench');

  late Play _play;

  (int, int)? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(BonesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Benches.at(widget.number));
    _pointing = null;
    _hints = 0;
    _saying = _play.bench.winnable
        ? null
        : 'The label has said already that no even-pipped pair '
            'ever matches. Cut what you like and watch the odd '
            'totals stay empty; ask why for the parity.';
    _told = false;
    _best = false;
  }

  void _touched((int, int)? face) {
    if (face == null || _play.isOver) return;

    final (die, at) = face;
    if (!_play.mayCut(die)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'That die is the standard, locked as the bench '
            'asks: only its partner takes the knife.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.bench.winnable ? _play.apart : -1;
    final next = _play.cut(die, at);
    setState(() {
      _play = next;
      _pointing = null;
      _saying = _note(next, could);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play, int could) {
    if (play.isOver) return null;
    if (play.matches && play.isStandard &&
        play.bench.otherThanStandard) {
      return 'The standard pair falls like itself, of course; the '
          'bench asks for the OTHER pair that does.';
    }
    if (could == -1) return null;
    final now = play.apart;
    if (now > could) {
      return 'That cut moved the bones no nearer: $now '
          'pip${now == 1 ? '' : 's'} stand apart from the nearest '
          'matching pair. Back uncuts it.';
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

  /// Asked. The face the nearest matching pair would recut first.
  void _showMe() {
    setState(() {
      _hints++;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The trade is made.';
        return;
      }
      final cut = _play.pointed;
      if (cut == null) {
        _pointing = null;
        _saying = 'There is nothing to show: no even-pipped pair '
            'matches, and the sweep has recut them all. Ask why '
            'instead.';
        return;
      }
      final (die, face, want) = cut;
      _pointing = (die, face);
      _saying = 'Cut that face to $want: the nearest matching pair '
          'holds $want there, and the sweep knows every pair there '
          'is.';
    });
  }

  /// Asked why. The trade in words.
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
      widget.onDone?.call(_play.cuts).then((best) {
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
                            metrics.faceUnder(touch.localPosition)),
                        child: CustomPaint(
                          key: BonesScreenState.benchKey,
                          size: size,
                          painter: BonesView(
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

/// The line above the bench: which one, and how near the trade is.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.bench.winnable;
    final apart = dead ? -1 : play.apart;

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
                  play.bench.name,
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
                      ? 'the trade is made'
                      : play.gaveUp
                          ? 'unmatched, as the label said it must '
                              'stay'
                          : dead
                              ? '${play.bench.task}: no pair ever '
                                  'does'
                              : '${play.bench.task}; $apart '
                                  'pip${apart == 1 ? '' : 's'} '
                                  'apart',
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
            '${play.cuts} cut${play.cuts == 1 ? '' : 's'}',
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

/// Under the bench: what the game has to say, and what else can be
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
                    'Tap a face to cut its pips one higher, eight '
                        'wrapping round. The bars below count every '
                        'throw against the standard table.',
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
