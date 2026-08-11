import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../weave/meshes.dart';
import '../weave/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'weaveview.dart';

/// One mesh: weave combs until every grist riddles clean.
class WeaveScreen extends StatefulWidget {
  const WeaveScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the clean riddle, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<WeaveScreen> createState() => WeaveScreenState();
}

class WeaveScreenState extends State<WeaveScreen> {
  static const frameKey = ValueKey('frame');

  late Play _play;

  var _armed = -1;
  (int, int)? _ghost;
  var _showFoul = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get armed => _armed;
  (int, int)? get ghost => _ghost;
  bool get showFoul => _showFoul;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(WeaveScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Meshes.at(widget.number));
    _armed = -1;
    _ghost = null;
    _showFoul = false;
    _hints = 0;
    _saying = _play.mesh.winnable
        ? null
        : 'No weave of ${_play.mesh.combs} combs riddles '
            '${_play.mesh.strands} strands, and the label said so. '
            'Place them any way you like and watch a grist run foul; '
            'ask why for the proofs.';
    _told = false;
    _best = false;
  }

  void _touched(int strand) {
    if (strand < 0 || _play.isClean) return;

    HapticFeedback.selectionClick();
    if (_armed < 0) {
      if (_play.room == 0) {
        setState(() {
          _saying = 'Every comb is placed. Lift some back out.';
        });
        return;
      }
      setState(() {
        _armed = strand;
        _ghost = null;
      });
      return;
    }
    if (_armed == strand) {
      setState(() => _armed = -1);
      return;
    }

    final could = _play.canStill;
    final next = _play.comb(_armed, strand);
    setState(() {
      _play = next;
      _armed = -1;
      _ghost = null;
      _showFoul = false;
      _saying = _note(next, could);
    });
    if (next.isClean) _finished();
  }

  String? _note(Play play, bool could) {
    if (play.isClean) return null;
    if (play.outOfCombs) {
      final foul = play.unsettled.length;
      return 'Every comb is placed and $foul grist'
          '${foul == 1 ? '' : 's'} still run'
          '${foul == 1 ? 's' : ''} foul. '
          '${play.mesh.winnable ? 'Lift some back out.' : 'So it goes, '
              'every time: ask why.'}';
    }
    if (could && play.mesh.winnable && !play.canStill) {
      return 'That comb wasted the frame: no filling of the rest '
          'riddles clean. Lift it back out.';
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
      _ghost = null;
      _showFoul = false;
      _saying = null;
    });
  }

  /// Asked. A comb the search has checked keeps the riddle in reach.
  void _showMe() {
    final comb = _play.next;
    setState(() {
      _hints++;
      _armed = -1;
      _showFoul = false;
      if (_play.isClean) {
        _ghost = null;
        _saying = 'The riddle runs clean.';
        return;
      }
      if (comb == null) {
        _ghost = null;
        _saying = _play.mesh.winnable
            ? 'No comb from here keeps a clean riddle in reach. Lift '
                'some back out.'
            : 'There is nothing to show: no weave of this frame '
                'riddles, and the suite holds two proofs of it. Ask '
                'why instead.';
        return;
      }
      _ghost = comb;
      _saying = 'Comb strands ${comb.$1 + 1} and ${comb.$2 + 1}: from '
          'there a clean riddle stays in reach, and the search has '
          'followed everything the rest can leave.';
    });
  }

  /// Asked why. The foul grist run in beads, and the words.
  void _why() {
    setState(() {
      _hints++;
      _armed = -1;
      _ghost = null;
      _showFoul = !_play.isClean;
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
        backgroundColor: Palette.shed,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Frame(
                    play: _play,
                    armed: _armed,
                    ghost: _ghost,
                    showFoul: _showFoul,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isClean)
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

/// The line above the frame: which mesh, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final clean = play.mesh.grists - play.unsettled.length;
    final dead = !play.mesh.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the meshes',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.mesh.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isClean
                      ? 'every grist runs clean'
                      : dead
                          ? 'no weave of this frame riddles'
                          : '$clean of ${play.mesh.grists} grists run '
                              'clean',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isClean
                        ? Palette.good
                        : dead
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.placed} / ${play.mesh.combs}',
            style: TextStyle(
              color: play.outOfCombs ? Palette.bad : Palette.ink,
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

/// The frame itself.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.play,
    required this.armed,
    required this.ghost,
    required this.showFoul,
    required this.onTouch,
  });

  final Play play;
  final int armed;
  final (int, int)? ghost;
  final bool showFoul;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) =>
                onTouch(metrics.strandAt(touch.localPosition)),
            child: CustomPaint(
              key: WeaveScreenState.frameKey,
              size: size,
              painter: WeaveView(
                play: play,
                armed: armed,
                ghost: ghost,
                showFoul: showFoul,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the frame: what the game has to say, and what else can be done.
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
                    'Tap two strands to weave a comb between them: '
                        'whatever is heavier drops to the lower '
                        'strand. Riddle every grist clean within the '
                        'frame\'s combs.',
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
