import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ferry/ferries.dart';
import '../ferry/play.dart';
import 'ferryview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One river: row everyone across.
class FerryScreen extends StatefulWidget {
  const FerryScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the landing, with the crossings rowed. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int crossings)? onDone;

  @override
  State<FerryScreen> createState() => FerryScreenState();
}

class FerryScreenState extends State<FerryScreen> {
  static const riverKey = ValueKey('river');

  late Play _play;

  var _pointing = const <int>[];
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  List<int> get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(FerryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Ferries.at(widget.number));
    _pointing = const [];
    _hints = 0;
    _saying = _play.ferry.winnable
        ? null
        : 'This ferry never lands everyone, and the label said so. '
            'Row as you like; ask why for the walk.';
    _told = false;
    _best = false;
  }

  void _touchedChip(int who) {
    if (_play.isDone) return;
    HapticFeedback.selectionClick();
    if (_play.isAboard(who)) {
      setState(() {
        _play = _play.disembark(who);
        _pointing = const [];
        _saying = null;
      });
      return;
    }
    if (!_play.mayBoard(who)) {
      setState(() {
        _saying = _play.onFar(who) == _play.boatFar
            ? 'The boat is full.'
            : 'The boat is on the other bank.';
      });
      return;
    }
    setState(() {
      _play = _play.board(who);
      _pointing = const [];
      _saying = null;
    });
  }

  void _touchedBoat() {
    if (_play.isDone) return;
    HapticFeedback.selectionClick();
    final refusal = _play.refusal;
    if (refusal != null) {
      setState(() {
        _saying = refusal;
      });
      return;
    }
    final could = _play.fewestFromHere;
    final next = _play.row();
    setState(() {
      _play = next;
      _pointing = const [];
      _saying = _note(next, could);
    });
    if (next.isDone) _finished();
  }

  String? _note(Play play, int? could) {
    if (play.isDone || !play.ferry.winnable) return null;
    final now = play.fewestFromHere;
    if (could != null && now != null && now > could) {
      return 'That crossing wandered: the landing is now $now '
          'crossings away. Back takes it off the count.';
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
      _pointing = const [];
      _saying = null;
    });
  }

  /// Asked. The load a nearing crossing carries.
  void _showMe() {
    final load = _play.nextLoad;
    setState(() {
      _hints++;
      if (_play.isDone) {
        _pointing = const [];
        _saying = 'Everyone is across.';
        return;
      }
      if (load == null) {
        _pointing = const [];
        _saying = 'There is nothing to show: no rowing lands '
            'everyone, and the walk stood on every arrangement. Ask '
            'why instead.';
        return;
      }
      _pointing = load;
      final names =
          load.map((who) => _play.rules.names[who]).join(' and ');
      _saying = 'Put $names aboard and row: the walk has measured '
          'every arrangement, and that crossing steps one nearer.';
    });
  }

  /// Asked why. The walk, in words.
  void _why() {
    setState(() {
      _hints++;
      _pointing = const [];
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.crossings).then((best) {
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
                  child: _River(
                    play: _play,
                    pointing: _pointing,
                    onChip: _touchedChip,
                    onBoat: _touchedBoat,
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

/// The line above the river: which ferry, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.ferry.winnable;
    final away = play.fewestFromHere;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the ferries',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.ferry.name,
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
                      ? 'everyone is across'
                      : dead
                          ? 'the far bank never fills'
                          : '$away crossing${away == 1 ? '' : 's'} '
                              'from the landing',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
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
            '${play.crossings} rowed',
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

/// The river itself.
class _River extends StatelessWidget {
  const _River({
    required this.play,
    required this.pointing,
    required this.onChip,
    required this.onBoat,
  });

  final Play play;
  final List<int> pointing;
  final ValueChanged<int> onChip;
  final VoidCallback onBoat;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              final who = metrics.chipAt(touch.localPosition);
              if (who != null) {
                onChip(who);
                return;
              }
              if (metrics.boatAt(touch.localPosition)) onBoat();
            },
            child: CustomPaint(
              key: FerryScreenState.riverKey,
              size: size,
              painter: FerryView(
                play: play,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the river: what the game has to say, and what else can be
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
                    'Tap a passenger to board the boat, tap the boat '
                        'to row. No bank may keep unsafe company, and '
                        'the boat refuses in words.',
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
