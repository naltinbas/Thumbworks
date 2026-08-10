import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../wath/bridges.dart';
import '../wath/fewest.dart';
import '../wath/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'wathview.dart';

/// One night: everybody over the bridge in the fewest minutes.
class WathScreen extends StatefulWidget {
  const WathScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time everybody is over, with the minutes it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int minutes)? onDone;

  @override
  State<WathScreen> createState() => WathScreenState();
}

class WathScreenState extends State<WathScreen> {
  static const wathKey = ValueKey('wath');

  static final _tables = <int, Crossings>{};

  late Play _play;

  var _pointing = 0;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

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
  void didUpdateWidget(WathScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(
      Bridges.at(widget.number),
      _tables.putIfAbsent(widget.number, () => Crossings(Bridges.at(widget.number))),
    );
    _pointing = 0;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int walker) {
    if (walker < 0 || _play.isDone) return;

    if (_play.onFar(walker) != _play.lampFar) {
      setState(() {
        _pointing = 0;
        _saying = 'The lantern is on the other bank. '
            '${_play.bridge.walkers[walker].name} cannot cross in the dark.';
      });
      return;
    }

    final next = _play.pick(walker);
    if (identical(next, _play)) {
      setState(() {
        _pointing = 0;
        _saying = 'The bridge carries two at most.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    setState(() {
      _play = next;
      _pointing = 0;
      _saying = null;
    });
  }

  void _cross() {
    if (_play.chosen == 0) {
      setState(() => _saying = 'Pick somebody to carry the lantern first.');
      return;
    }
    HapticFeedback.mediumImpact();
    final cost = _play.chosenMinutes;
    final next = _play.cross();
    setState(() {
      _play = next;
      _pointing = 0;
      _saying = _note(next, cost);
    });
    if (next.isDone) _finished();
  }

  /// What the night has to say after a crossing.
  String? _note(Play play, int cost) {
    if (play.isDone) return null;
    final could = play.couldFinishIn;
    if (could > play.bridge.fewest) {
      return 'That crossing took $cost. The fewest this night can now be is '
          '$could minutes, which is ${could - play.bridge.fewest} more than '
          'the ${play.bridge.fewest} it takes.';
    }
    return 'That crossing took $cost minutes. ${play.left} more see '
        'everybody over.';
  }

  void _again() {
    setState(_set);
  }

  void _back() {
    if (_play.done.isEmpty) return;
    setState(() {
      _play = _play.back;
      _pointing = 0;
      _saying = null;
    });
  }

  /// Asked. Points at the party to send next on a fewest way from here.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = 0;
        _saying = 'Everybody is over.';
        return;
      }
      _pointing = next;
      final names = <String>[];
      for (var walker = 0; walker < _play.bridge.count; walker++) {
        if ((next & (1 << walker)) != 0) {
          names.add(_play.bridge.walkers[walker].name);
        }
      }
      _saying = names.length == 1
          ? '${names.first} takes the lantern ' 
              '${_play.lampFar ? 'back' : 'over'}.'
          : '${names.join(' and ')} cross together.';
    });
  }

  /// Asked why. The pairing insight, or its absence, told with this bridge's
  /// own numbers.
  void _why() {
    setState(() {
      _hints++;
      _pointing = 0;
      final bridge = _play.bridge;
      final crossings = _play.crossings;
      final ferried = crossings.byFerrying();

      if (bridge.count <= 3) {
        _saying = 'With ${bridge.count == 2 ? 'two' : 'three'} walkers there '
            'is only one shape a night can take, so ferrying with the '
            'fastest is the fewest by default: $ferried minutes.';
        return;
      }

      final sorted = [...bridge.walkers]
        ..sort((one, other) => one.minutes.compareTo(other.minutes));
      final pairSaves = ferried > bridge.fewest;
      _saying = pairSaves
          ? 'Ferrying everybody with ${sorted.first.name} costs $ferried. '
              'Sending the two slowest together buries '
              '${sorted[sorted.length - 2].minutes} inside '
              '${sorted.last.minutes}, at the price of a second walker '
              'coming back, and here that trade wins: ${bridge.fewest} '
              'against $ferried.'
          : 'The same trade that saves the famous four buys nothing here: '
              'burying the second slowest costs a second walker coming back, '
              'and on this bridge the two come out even. Ferrying with '
              '${sorted.first.name} is already the fewest, $ferried minutes, '
              'and the label on the way in said so.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.spent).then((best) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Wath(
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
                  play: _play,
                  onCross: _cross,
                  onBack: _back,
                  onAgain: _again,
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

/// The line above the wath: which night, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.couldFinishIn > play.bridge.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the bridges',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.bridge.name,
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
                      ? 'everybody over'
                      : play.chosen != 0
                          ? 'the next crossing takes ${play.chosenMinutes}'
                          : 'the lantern is on the '
                              '${play.lampFar ? 'far' : 'near'} bank',
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
            '${play.spent} / ${play.bridge.fewest}',
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

/// The wath itself.
class _Wath extends StatelessWidget {
  const _Wath({
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
            onTapUp: (touch) => onTouch(metrics.walkerAt(touch.localPosition)),
            child: CustomPaint(
              key: WathScreenState.wathKey,
              size: size,
              painter: WathView(
                play: play,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the wath: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.play,
    required this.onCross,
    required this.onBack,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final Play play;
  final VoidCallback onCross;
  final VoidCallback onBack;
  final VoidCallback onAgain;
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
                color: Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Pick one or two on the lantern side, then send them '
                        'over. Two cross at the slower pace, and the lantern '
                        'goes with every crossing.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Never dead: a tap with nobody picked is worth a word.
            _Button(
              label: play.chosen == 0
                  ? 'Cross'
                  : 'Cross, ${play.chosenMinutes} minutes',
              quiet: play.chosen == 0,
              onTap: onCross,
              big: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Button(label: 'Take back', onTap: onBack),
                ),
                const SizedBox(width: 7),
                Expanded(child: _Button(label: 'Again', onTap: onAgain)),
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
  const _Button({
    required this.label,
    required this.onTap,
    this.big = false,
    this.quiet = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool big;

  /// Drawn as though it were dead, but still worth tapping.
  final bool quiet;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: ExcludeSemantics(
            child: Container(
              height: big ? 48 : 44,
              decoration: BoxDecoration(
                color: big && !quiet ? Palette.chosen : Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: quiet ? Palette.line : Palette.edge,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: quiet
                        ? Palette.inkDim
                        : big
                            ? Palette.night
                            : Palette.ink,
                    fontSize: big ? 15 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
