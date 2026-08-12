import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bead/play.dart';
import '../bead/rings.dart';
import 'beadview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ring: string every necklace the asking names.
class BeadScreen extends StatefulWidget {
  const BeadScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the filling, with the strings taken. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int strings)? onDone;

  @override
  State<BeadScreen> createState() => BeadScreenState();
}

class BeadScreenState extends State<BeadScreen> {
  static const stallKey = ValueKey('stall');

  late Play _play;

  List<int>? _ghost;
  int? _named;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  List<int>? get ghost => _ghost;
  int? get named => _named;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(BeadScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Rings.at(widget.number));
    _ghost = null;
    _named = null;
    _hints = 0;
    _saying = _play.ring.winnable
        ? null
        : 'Seven are asked, and the label has said already that '
            'this ring holds six. Fill the shelf and watch the '
            'seventh never come; ask why for the counting.';
    _told = false;
    _best = false;
  }

  void _touched(int? at) {
    if (at == null || _play.isOver) return;
    HapticFeedback.selectionClick();
    setState(() {
      _play = _play.dye(at);
      _named = null;
      _saying = null;
    });
  }

  void _stringIt() {
    if (_play.isOver) return;
    HapticFeedback.selectionClick();
    final before = _play.strung.length;
    final held = _play.alreadyAt;
    final next = _play.stringIt();
    setState(() {
      _play = next;
      _ghost = null;
      if (next.gaveUp) {
        _named = null;
        _saying = null;
      } else if (held != -1) {
        _named = held;
        _saying = 'That string is necklace ${held + 1} on the '
            'shelf, only turned: the ring makes them one.';
      } else {
        _named = null;
        _saying = next.strung.length > before && !next.isDone
            ? 'Strung: ${next.strung.length} of the '
                '${next.ring.asked} asked.'
            : null;
      }
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
      _ghost = null;
      _named = null;
      _saying = null;
    });
  }

  /// Asked. A necklace the shelf still lacks, shown in the beads.
  void _showMe() {
    setState(() {
      _hints++;
      _named = null;
      if (_play.isOver) {
        _ghost = null;
        _saying = 'The shelf is full.';
        return;
      }
      final missing = _play.missing;
      if (missing == null) {
        _ghost = null;
        _saying = 'There is nothing to show: the shelf holds every '
            'necklace this ring can make, and the counting knew '
            'how many that was. Ask why instead.';
        return;
      }
      _ghost = missing;
      _saying = 'Dye the beads to the small marks: that necklace '
          'is not on the shelf yet.';
    });
  }

  /// Asked why. The counting in words.
  void _why() {
    setState(() {
      _hints++;
      _ghost = null;
      _named = null;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (_play.isDone) {
      widget.onDone?.call(_play.strings).then((best) {
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
                            metrics.beadUnder(touch.localPosition)),
                        child: CustomPaint(
                          key: BeadScreenState.stallKey,
                          size: size,
                          painter: BeadView(
                            play: _play,
                            ghost: _ghost,
                            named: _named,
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
                  onString: _stringIt,
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

/// The line above the stall: which ring, and how the shelf stands.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.ring.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the rings',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.ring.name,
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
                      ? 'the shelf is full'
                      : play.gaveUp
                          ? 'six of seven, and six is the whole '
                              'ring'
                          : dead
                              ? '${play.ring.task}: the ring holds '
                                  '${play.ring.holds}'
                              : play.ring.task,
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
            '${play.strung.length} of ${play.ring.asked}',
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

/// Under the stall: the stringing, what the game has to say, and
/// what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onString,
    required this.onAgain,
    required this.onBack,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onString;
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
                    'Tap a bead to dye it onward, then string the '
                        'ring. Two strings are one necklace when a '
                        'turn maps them, and the shelf keeps one of '
                        'each.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              button: true,
              label: 'String it',
              child: GestureDetector(
                onTap: onString,
                child: ExcludeSemantics(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Palette.panel,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Palette.amber, width: 1.6),
                    ),
                    child: const Center(
                      child: Text(
                        'String it',
                        style: TextStyle(
                          color: Palette.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
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
