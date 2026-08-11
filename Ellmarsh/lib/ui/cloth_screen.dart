import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cloth/benches.dart';
import '../cloth/play.dart';
import 'clothview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One bench: cut well, and cut the last ell.
class ClothScreen extends StatefulWidget {
  const ClothScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when a bolt falls to nothing under your shears, with
  /// the askings used. Answers whether that beat what was written down.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<ClothScreen> createState() => ClothScreenState();
}

class ClothScreenState extends State<ClothScreen> {
  static const benchKey = ValueKey('bench');

  late Play _play;

  var _pending = 0;
  var _showGap = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pending => _pending;
  bool get showGap => _showGap;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(ClothScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Benches.at(widget.number));
    _pending = 0;
    _showGap = false;
    _hints = 0;
    _saying = _play.winnable
        ? null
        : 'This bench sits inside the golden gap, and the mercer holds '
            'it before a cut is made. It is here to be felt; ask why.';
    _told = false;
    _best = false;
  }

  /// A tap on the long bolt marks one more short-length for cutting,
  /// wrapping past the quotient back to one.
  void _touched() {
    if (_play.isOver) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pending = _pending >= _play.quotient ? 1 : _pending + 1;
      _showGap = false;
      _saying = null;
    });
  }

  /// Commits the pending cut; the mercer answers on its heels.
  void _cut() {
    if (_play.isOver || _pending < 1) return;
    HapticFeedback.mediumImpact();
    final wasWinnable = _play.winnable;
    final next = _play.cut(_pending);
    setState(() {
      _play = next;
      _pending = 0;
      _showGap = false;
      _saying = _note(next, wasWinnable);
    });
    if (next.isOver) _finished();
  }

  String? _note(Play play, bool wasWinnable) {
    if (play.isOver) return null;
    final answer = 'The mercer cuts ${play.theirLast} '
        'length${play.theirLast == 1 ? '' : 's'}: the bolts lie '
        '${play.long} and ${play.short}.';
    if (wasWinnable && !play.winnable) {
      return 'That cut left the bolts outside your reach: $answer The '
          'bench is the mercer\'s now. Take the exchange back.';
    }
    return answer;
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.before == null) return;
    setState(() {
      _play = _play.back;
      _pending = 0;
      _showGap = false;
      _saying = null;
    });
  }

  /// Asked. The winning cut, when there is one.
  void _showMe() {
    final times = _play.next;
    setState(() {
      _hints++;
      _showGap = false;
      if (_play.isOver) {
        _pending = 0;
        _saying = 'The bench is settled.';
        return;
      }
      if (times == null) {
        _pending = 0;
        _saying = 'There is no cut that holds the bench from here. The '
            'quotient is one, the move is forced, and the count is the '
            'mercer\'s. Cut and see.';
        return;
      }
      _pending = times;
      _saying = 'Cut $times length${times == 1 ? '' : 's'} of the short '
          'bolt: what is left sits inside the gap, where the mercer\'s '
          'moves are forced. Press Cut to commit it.';
    });
  }

  /// Asked why. The golden tick on the bolt itself.
  void _why() {
    setState(() {
      _hints++;
      _showGap = true;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (!_play.won) return;
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
        backgroundColor: Palette.shop,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, pending: _pending, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Bench(
                    play: _play,
                    pending: _pending,
                    showGap: _showGap,
                    onTouch: _touched,
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
                  onCut: _cut,
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

/// The line above the bench: which bolts, and how they lie.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.play,
    required this.pending,
    required this.onLeave,
  });

  final Play play;
  final int pending;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final lost = !play.winnable && !(play.isOver && play.won);

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
                  play.isOver
                      ? (play.won
                          ? 'the last cut was yours'
                          : 'the last cut was the mercer\'s')
                      : lost
                          ? 'the mercer holds the bench'
                          : pending > 0
                              ? 'cutting $pending of up to ${play.quotient}'
                              : 'the short bolt fits ${play.quotient} '
                                  'time${play.quotient == 1 ? '' : 's'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isOver && play.won
                        ? Palette.good
                        : lost
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.long} : ${play.short}',
            style: TextStyle(
              color: lost ? Palette.bad : Palette.ink,
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

/// The bench itself.
class _Bench extends StatelessWidget {
  const _Bench({
    required this.play,
    required this.pending,
    required this.showGap,
    required this.onTouch,
  });

  final Play play;
  final int pending;
  final bool showGap;
  final VoidCallback onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              if (metrics.onLong(touch.localPosition)) onTouch();
            },
            child: CustomPaint(
              key: ClothScreenState.benchKey,
              size: size,
              painter: ClothView(
                play: play,
                pending: pending,
                showGap: showGap,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the bench: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onBack,
    required this.onCut,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onAgain;
  final VoidCallback onBack;
  final VoidCallback onCut;
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
                color: Palette.bench,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap the long bolt to mark lengths of the short one, '
                        'then Cut. Whoever cuts a bolt to nothing keeps '
                        'the bench.',
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
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Back', onTap: onBack)),
                const SizedBox(width: 7),
                Expanded(
                    child: _Button(label: 'Cut', onTap: onCut, lit: true)),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Show me', onTap: onShowMe)),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Why', onTap: onWhy)),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.onTap, this.lit = false});

  final String label;
  final VoidCallback onTap;
  final bool lit;

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
                color: lit ? Palette.edge : Palette.bench,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
