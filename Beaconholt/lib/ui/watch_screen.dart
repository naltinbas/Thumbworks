import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../watch/play.dart';
import '../watch/countries.dart';
import 'watchview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One round: call at every farm and get home.
class WatchScreen extends StatefulWidget {
  const WatchScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a country is watched, with how many beacons
  /// it took. Answers whether that beat what was written down before.
  final Future<bool> Function(int beacons)? onDone;

  @override
  State<WatchScreen> createState() => WatchScreenState();
}

class WatchScreenState extends State<WatchScreen> {
  static const countryKey = ValueKey('fen');

  late Watchland _land;
  late Play _play;

  var _pointing = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Watchland get land => _land;
  Play get play => _play;
  int get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(WatchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _land = Watchlands.at(widget.number);
    _play = Play.of(_land);
    _pointing = -1;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int hill) {
    if (hill < 0) return;
    final next = _play.turn(hill);
    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _pointing = -1;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the country has to say after a beacon goes up or comes down.
  ///
  /// How many hills are still dark, and one of them by name. There is nothing
  /// to work out to say it: a beacon lights its own hill and the hills it
  /// sees, so what is dark is what no beacon can see.
  String? _note(Play play) {
    if (play.isDone) return null;
    final dark = play.dark;
    if (dark.isEmpty) return null;
    if (dark.length == 1) {
      return 'Nothing can see ${_land.hills[dark.first].name}.';
    }
    return '${dark.length} hills are still dark, '
        '${_land.hills[dark.first].name} among them.';
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _pointing = -1;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  /// Asked. Points at a hill that has a beacon on it in one of the smallest
  /// sets. It is worked out from the country rather than from what is already
  /// up, so it is always a hill in some answer of that size.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = -1;
        _saying = 'Every hill in the answer already has a beacon on it.';
        return;
      }
      _pointing = next;
      _saying = '${_land.hills[next].name} has a beacon in one of the sets of '
          '${_land.fewest}.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.beacons.length).then((best) {
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
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _Country(
                    play: _play,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  onAgain: _again,
                  onShowMe: _showMe,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The line above the map: which round, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final fewest = play.watchland.fewest;
    final over = play.beacons.length > fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the countries',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.watchland.name,
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
                      ? 'every hill watched'
                      : '${play.dark.length} still dark',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone ? Palette.good : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.beacons.length} / $fewest',
            style: TextStyle(
              color: over ? Palette.bad : Palette.ink,
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

/// The map itself.
class _Country extends StatelessWidget {
  const _Country({
    required this.play,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.hillAt(touch.localPosition)),
            child: CustomPaint(
              key: WatchScreenState.countryKey,
              size: size,
              painter: WatchView(
                play: play,
                pointing: pointing,
                labels: const TextStyle(
                  color: Palette.inkDim,
                  fontFamily: 'Roboto',
                  fontSize: 11,
                ),
              ),
            ),
          );
        },
      );
}

/// Under the map: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.onAgain,
    required this.onShowMe,
  });

  final String? saying;
  final VoidCallback onAgain;
  final VoidCallback onShowMe;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Palette.moor,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a hill to light a beacon on it. It watches its own '
                        'hill and every hill it looks out on.',
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
                Expanded(
                  child: _Button(label: 'Again', dead: false, onTap: onAgain),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: _Button(label: 'Show me', dead: false, onTap: onShowMe),
                ),
              ],
            ),
          ],
        ),
      );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.dead,
    required this.onTap,
  });

  final String label;
  final bool dead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: dead ? null : onTap,
          child: ExcludeSemantics(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Palette.moor,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: dead ? Palette.line : Palette.edge,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: dead ? Palette.inkDim : Palette.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
