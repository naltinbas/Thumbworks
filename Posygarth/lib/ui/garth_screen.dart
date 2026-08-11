import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../garden/garths.dart';
import '../garden/play.dart';
import 'garthview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One garth: arm a posy at the bench, and plant every bed.
class GarthScreen extends StatefulWidget {
  const GarthScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the garth blooms, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<GarthScreen> createState() => GarthScreenState();
}

class GarthScreenState extends State<GarthScreen> {
  static const garthKey = ValueKey('garth');

  late Play _play;

  var _armedFlower = -1;
  var _armedColour = -1;
  var _pointing = -1;
  var _showPlanting = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get armedFlower => _armedFlower;
  int get armedColour => _armedColour;
  int get pointing => _pointing;
  bool get showPlanting => _showPlanting;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(GarthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Garths.at(widget.number));
    _armedFlower = -1;
    _armedColour = -1;
    _pointing = -1;
    _showPlanting = false;
    _hints = 0;
    _saying = _play.garth.possible
        ? null
        : 'No planting of this garth exists, and the label said so. It '
            'is here for the why: the sweep is small enough to watch.';
    _told = false;
    _best = false;
  }

  void _touched((String, int)? what) {
    if (what == null || _play.isBloomed) return;
    final (kind, at) = what;

    if (kind == 'flower') {
      HapticFeedback.selectionClick();
      setState(() {
        _armedFlower = _armedFlower == at ? -1 : at;
        _pointing = -1;
        _showPlanting = false;
        _saying = null;
      });
      return;
    }
    if (kind == 'colour') {
      HapticFeedback.selectionClick();
      setState(() {
        _armedColour = _armedColour == at ? -1 : at;
        _pointing = -1;
        _showPlanting = false;
        _saying = null;
      });
      return;
    }

    // A bed.
    if (_armedFlower < 0 || _armedColour < 0) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'Arm a posy first: one flower and one colour from the '
            'bench below.';
      });
      return;
    }
    if (!_play.isEmpty(at)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = _play.isSeeded(at)
            ? 'That bed was seeded before you came, and stays.'
            : 'That bed is planted. Back digs the last posy up.';
      });
      return;
    }
    final clash = _play.clashAt(at, _armedFlower, _armedColour);
    if (clash != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'It cannot go there: $clash.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.canStill;
    final next = _play.plant(at, _armedFlower, _armedColour);
    setState(() {
      _play = next;
      _pointing = -1;
      _showPlanting = false;
      _saying = _note(next, could);
    });
    if (next.isBloomed) _finished();
  }

  String? _note(Play play, bool could) {
    if (play.isBloomed) return null;
    if (could && play.garth.possible && !play.canStill) {
      return 'That posy strands the garth: no way to finish honours it. '
          'Take it back.';
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
      _pointing = -1;
      _showPlanting = false;
      _saying = null;
    });
  }

  /// Asked. A planting the search has checked through, armed for you.
  void _showMe() {
    final posy = _play.next;
    setState(() {
      _hints++;
      _showPlanting = false;
      if (_play.isBloomed) {
        _pointing = -1;
        _saying = 'The garth is bloomed.';
        return;
      }
      if (posy == null) {
        _pointing = -1;
        _saying = _play.garth.possible
            ? 'No posy works from here. Take some back.'
            : 'There is nothing to show: no planting exists at all. Ask '
                'why instead.';
        return;
      }
      _armedFlower = posy.$2;
      _armedColour = posy.$3;
      _pointing = posy.$1;
      _saying = 'That bed, with the armed posy: from there the garth '
          'still blooms, and the search has checked it.';
    });
  }

  /// Asked why. The planting as ghosts, or the sweep owned.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showPlanting = _play.garth.possible;
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
        backgroundColor: Palette.dusk,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Garden(
                    play: _play,
                    armedFlower: _armedFlower,
                    armedColour: _armedColour,
                    pointing: _pointing,
                    showPlanting: _showPlanting,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isBloomed)
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

/// The line above the garden: which garth, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final stranded =
        play.garth.possible && !play.isBloomed && !play.canStill;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the garths',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.garth.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isBloomed
                      ? 'every pairing fresh, every line fair'
                      : stranded
                          ? 'the garth is stranded'
                          : 'no repeats in a line, no pairing twice',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isBloomed
                        ? Palette.good
                        : stranded
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.planted} / ${play.garth.beds}',
            style: TextStyle(
              color: stranded ? Palette.bad : Palette.ink,
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

/// The garden itself.
class _Garden extends StatelessWidget {
  const _Garden({
    required this.play,
    required this.armedFlower,
    required this.armedColour,
    required this.pointing,
    required this.showPlanting,
    required this.onTouch,
  });

  final Play play;
  final int armedFlower;
  final int armedColour;
  final int pointing;
  final bool showPlanting;
  final ValueChanged<(String, int)?> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.at(touch.localPosition)),
            child: CustomPaint(
              key: GarthScreenState.garthKey,
              size: size,
              painter: GarthView(
                play: play,
                armedFlower: armedFlower,
                armedColour: armedColour,
                pointing: pointing,
                showPlanting: showPlanting,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the garden: what the game has to say, and what else can be done.
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
                color: Palette.bench,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Arm a flower and a colour at the bench, then tap a '
                        'bed. Each line takes each flower once and each '
                        'colour once, and no pairing repeats anywhere.',
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
                color: Palette.bench,
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
