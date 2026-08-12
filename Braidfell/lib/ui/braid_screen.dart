import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../braid/play.dart';
import '../braid/yards.dart';
import 'braidview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One yard: braid everything into one skein within the asking.
class BraidScreen extends StatefulWidget {
  const BraidScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at a met asking, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<BraidScreen> createState() => BraidScreenState();
}

class BraidScreenState extends State<BraidScreen> {
  static const yardKey = ValueKey('yard');

  late Play _play;

  var _armed = -1;
  (int, int)? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get armed => _armed;
  (int, int)? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(BraidScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Yards.at(widget.number));
    _armed = -1;
    _pointing = null;
    _hints = 0;
    _saying = _play.yard.winnable
        ? null
        : 'Fifty-nine is asked, and the label has said already '
            'that every order of this yard costs sixty or more. '
            'Braid it any way you like and watch the count; ask '
            'why for the sweep.';
    _told = false;
    _best = false;
  }

  void _touched(int? at) {
    if (at == null || _play.isDone) return;

    HapticFeedback.selectionClick();
    if (_armed < 0) {
      setState(() {
        _armed = at;
        _pointing = null;
        _saying = null;
      });
      return;
    }
    if (_armed == at) {
      setState(() => _armed = -1);
      return;
    }

    final one = _armed;
    final could = _play.floor;
    final next = _play.braid(one, at);
    setState(() {
      _play = next;
      _armed = -1;
      _pointing = null;
      _saying = _note(next, could);
    });
    if (next.isDone) _finished();
  }

  String? _note(Play play, int could) {
    if (play.isDone || !play.yard.winnable) return null;
    if (play.floor > play.yard.asked && could <= play.yard.asked) {
      return 'That braid costs the yard: the cheapest finish from '
          'here is ${play.floor}, over the asking of '
          '${play.yard.asked}. Back unpicks it.';
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
      _armed = -1;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. The two lightest bundles.
  void _showMe() {
    setState(() {
      _hints++;
      _armed = -1;
      if (_play.isDone) {
        _pointing = null;
        _saying = 'The skein is braided.';
        return;
      }
      final pair = _play.lightest;
      _pointing = pair;
      _saying = 'Braid the two lightest: the rule never does '
          'anything else, and the sweep finds nothing cheaper.';
    });
  }

  /// Asked why. The rule and the sweep in words.
  void _why() {
    setState(() {
      _hints++;
      _armed = -1;
      _pointing = null;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (_play.met) {
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
                            metrics.bundleUnder(touch.localPosition)),
                        child: CustomPaint(
                          key: BraidScreenState.yardKey,
                          size: size,
                          painter: BraidView(
                            play: _play,
                            armed: _armed,
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

/// The line above the yard: which one, and how the work stands.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.yard.winnable;

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
                      ? play.met
                          ? 'the skein is braided within the asking'
                          : dead
                              ? 'sixty, as the label said it must be'
                              : 'braided, but over the asking'
                      : dead
                          ? '${play.yard.task}: no order ever does'
                          : play.yard.task,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone && play.met
                        ? Palette.good
                        : dead || (play.isDone && !play.met)
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.work} of ${play.yard.asked}',
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
                    'Tap two bundles to braid them; the braid costs '
                        'their weights put together. One skein, '
                        'within the asking, is the whole task.',
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
