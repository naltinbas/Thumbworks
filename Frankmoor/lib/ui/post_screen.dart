import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../post/letters.dart';
import '../post/play.dart';
import 'palette.dart';
import 'postview.dart';
import 'result_card.dart';

/// One letter: pay the postage to the penny.
class PostScreen extends StatefulWidget {
  const PostScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the letter is paid, with the askings used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<PostScreen> createState() => PostScreenState();
}

class PostScreenState extends State<PostScreen> {
  static const counterKey = ValueKey('counter');

  late Play _play;

  var _showWalk = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  bool get showWalk => _showWalk;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(PostScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Letters.at(widget.number));
    _showWalk = false;
    _hints = 0;
    _saying = _play.letter.payable
        ? null
        : 'This amount can never be paid with these stamps, and the '
            'label said so. It is here for the why: a proof of a few '
            'lines, done at the counter.';
    _told = false;
    _best = false;
  }

  void _touched(bool? cheap) {
    if (cheap == null || _play.isPaid) return;

    HapticFeedback.selectionClick();
    final could = _play.canStill;
    final next = _play.affix(cheap);
    setState(() {
      _play = next;
      _showWalk = false;
      _saying = _note(next, could);
    });
    if (next.isPaid) _finished();
  }

  String? _note(Play play, bool could) {
    if (play.isPaid) return null;
    if (play.total > play.letter.amount) {
      return 'The stamps come to ${play.total}d against '
          '${play.letter.amount}d owed: over is as wrong as under. Take '
          'some off.';
    }
    if (could && play.letter.payable && !play.canStill) {
      return 'What is left, ${play.owed}d, cannot be made with these '
          'stamps: that stamp stranded the letter. Take it off.';
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
      _showWalk = false;
      _saying = null;
    });
  }

  /// Asked. The stamp that stays on a paying way.
  void _showMe() {
    final cheap = _play.next;
    setState(() {
      _hints++;
      _showWalk = false;
      if (_play.isPaid) {
        _saying = 'The letter is paid.';
        return;
      }
      if (cheap == null) {
        _saying = _play.letter.payable
            ? 'No stamp helps from here. Take some off.'
            : 'There is nothing to show: the amount cannot be paid at '
                'all. Ask why instead.';
        return;
      }
      _saying = cheap
          ? 'A ${_play.letter.cheap}d stamp keeps the letter payable.'
          : 'A ${_play.letter.dear}d stamp keeps the letter payable: '
              'what is owed needs more dear stamps before the '
              '${_play.letter.cheap}s can finish it.';
    });
  }

  /// Asked why. The remainder walk, laid out in chips.
  void _why() {
    setState(() {
      _hints++;
      _showWalk = true;
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
        backgroundColor: Palette.office,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Counter(
                    play: _play,
                    showWalk: _showWalk,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isPaid)
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

/// The line above the counter: which letter, and how it stands.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final stuck = !play.canStill && !play.isPaid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the letters',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.letter.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isPaid
                      ? 'paid to the penny'
                      : stuck
                          ? 'the letter is stranded'
                          : 'stamps of ${play.letter.cheap}d and '
                              '${play.letter.dear}d only',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isPaid
                        ? Palette.good
                        : stuck
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.total} / ${play.letter.amount}d',
            style: TextStyle(
              color: stuck ? Palette.bad : Palette.ink,
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

/// The counter itself.
class _Counter extends StatelessWidget {
  const _Counter({
    required this.play,
    required this.showWalk,
    required this.onTouch,
  });

  final Play play;
  final bool showWalk;
  final ValueChanged<bool?> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.pileAt(touch.localPosition)),
            child: CustomPaint(
              key: PostScreenState.counterKey,
              size: size,
              painter: PostView(
                play: play,
                showWalk: showWalk,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the counter: what the game has to say, and what else can be done.
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
                color: Palette.counter,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a pile to lick a stamp onto the letter. The '
                        'postage must come out to the penny: no change '
                        'given at this counter.',
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
                color: Palette.counter,
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
