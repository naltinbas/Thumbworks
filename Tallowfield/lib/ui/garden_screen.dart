import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../garden/evenings.dart';
import '../garden/play.dart';
import 'gardenview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One evening: read the hedges and name the lantern the draught changed.
class GardenScreen extends StatefulWidget {
  const GardenScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the evening settles, with the slips and askings.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int slips)? onDone;

  @override
  State<GardenScreen> createState() => GardenScreenState();
}

class GardenScreenState extends State<GardenScreen> {
  static const gardenKey = ValueKey('garden');

  late Play _play;

  var _pointing = -1;
  var _showBeds = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get showBeds => _showBeds;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(GardenScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Evenings.at(widget.number));
    _pointing = -1;
    _showBeds = false;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int lamp) {
    if (lamp < 1 || _play.settled) return;
    _read(lamp);
  }

  /// Reads the garden as naming [lamp], nought for all's well.
  void _read(int lamp) {
    HapticFeedback.selectionClick();
    final next = _play.read(lamp);
    setState(() {
      final was = _play.slips;
      _play = next;
      _pointing = -1;
      _showBeds = false;
      if (next.settled) {
        _saying = null;
      } else if (next.slips > was) {
        _saying = _slip(lamp);
      }
    });
    if (next.settled) _finished();
  }

  /// Why that reading was wrong, said from the tallies.
  String _slip(int lamp) {
    final odd = _play.complaints;
    final which = [
      for (var hedge = 0; hedge < 3; hedge++)
        if (odd[hedge]) 'ABC'[hedge],
    ].join(' and ');
    if (lamp == 0) {
      return 'A hedge complains: the garden is not as the gardener left '
          'it. Somebody stands in ${which.isEmpty ? "nothing" : which}.';
    }
    if (_play.named == 0) {
      return 'No hedge complains of lamp $lamp or anything else: every '
          'count is even. All is well is the reading.';
    }
    return 'Not lamp $lamp: the complaints are $which, and lamp $lamp '
        'does not stand in exactly ${which.isEmpty ? "those" : which}. '
        'Find the bed inside the complaining hedges and no other.';
  }

  void _again() {
    setState(_set);
  }

  void _allsWell() {
    if (_play.settled) return;
    _read(0);
  }

  /// Asked. Where the tallies point.
  void _showMe() {
    setState(() {
      _hints++;
      _showBeds = false;
      if (_play.settled) {
        _pointing = -1;
        _saying = 'The evening is settled.';
        return;
      }
      if (_play.named == 0) {
        _pointing = -1;
        _saying = 'Every hedge is even: say all is well.';
        return;
      }
      _pointing = _play.named;
      _saying = 'The tallies point at lamp ${_play.named}: the bed inside '
          'the complaining hedges and no other.';
    });
  }

  /// Asked why. The rule, the reading, and the bed shaded.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showBeds = true;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.slips + _hints).then((best) {
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
                  padding: const EdgeInsets.all(6),
                  child: _Garden(
                    play: _play,
                    pointing: _pointing,
                    showBeds: _showBeds,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.settled)
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
                  onAllsWell: _allsWell,
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

/// The line above the garden: which evening, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final odd = play.complaints.where((complains) => complains).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the evenings',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.evening.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.settled
                      ? 'the evening is read'
                      : odd == 0
                          ? 'no hedge complains'
                          : '$odd hedge${odd == 1 ? '' : 's'} '
                              'complain${odd == 1 ? 's' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.settled
                        ? Palette.good
                        : odd == 0
                            ? Palette.inkDim
                            : Palette.complaint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            play.slips == 0 ? 'no slips' : '${play.slips} slip'
                '${play.slips == 1 ? '' : 's'}',
            style: TextStyle(
              color: play.slips == 0 ? Palette.ink : Palette.bad,
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
    required this.pointing,
    required this.showBeds,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showBeds;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(
            room.maxWidth,
            math.min(room.maxHeight, room.maxWidth * 1.12),
          );
          final metrics = Metrics(play, size);

          return Center(
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (touch) =>
                    onTouch(metrics.lampUnder(touch.localPosition)),
                child: CustomPaint(
                  key: GardenScreenState.gardenKey,
                  size: size,
                  painter: GardenView(
                    play: play,
                    pointing: pointing,
                    showBeds: showBeds,
                    labels: const TextStyle(fontFamily: 'Roboto'),
                  ),
                ),
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
    required this.onAllsWell,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final VoidCallback onAgain;
  final VoidCallback onAllsWell;
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
                color: Palette.wall,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'The draught has been at one lantern, or none. Read '
                        'the three tallies and tap the lantern they name, '
                        'or say all is well.',
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
                Expanded(
                  child: _Button(label: "All's well", onTap: onAllsWell),
                ),
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
                color: Palette.wall,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.edge, width: 1.1),
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
