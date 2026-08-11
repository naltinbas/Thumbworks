import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../charm/charms.dart';
import '../charm/play.dart';
import 'charmview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One charm: lay the coins until every line counts fifteen.
class CharmScreen extends StatefulWidget {
  const CharmScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the held charm, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<CharmScreen> createState() => CharmScreenState();
}

class CharmScreenState extends State<CharmScreen> {
  static const bedKey = ValueKey('bed');

  late Play _play;

  var _armed = -1;
  (int, int?)? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get armed => _armed;
  (int, int?)? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(CharmScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Charms.at(widget.number));
    _armed = -1;
    _pointing = null;
    _hints = 0;
    _saying = _play.charm.winnable
        ? null
        : 'No laying of the coins holds this charm, and the label '
            'said so. Lay them any way you like and watch a line '
            'break; ask why for the counting.';
    _told = false;
    _best = false;
  }

  void _touchedCell(int cell) {
    if (cell < 0 || _play.isDone) return;

    HapticFeedback.selectionClick();
    final coin = _play.laid[cell];
    if (_armed > 0 && coin == null) {
      final could = _play.broken.length;
      final next = _play.lay(cell, _armed);
      setState(() {
        _play = next;
        _armed = -1;
        _pointing = null;
        _saying = _note(next, could);
      });
      if (next.isDone) _finished();
      return;
    }
    if (coin != null) {
      if (_play.charm.isPinned(cell)) {
        setState(() {
          _saying = 'That coin is held fast.';
        });
        return;
      }
      setState(() {
        _play = _play.lift(cell);
        _armed = -1;
        _pointing = null;
        _saying = null;
      });
      return;
    }
    setState(() {
      _saying = 'Arm a coin from the tray first.';
    });
  }

  void _touchedTray(int worth) {
    if (_play.isDone) return;
    HapticFeedback.selectionClick();
    setState(() {
      _armed = _armed == worth ? -1 : worth;
      _pointing = null;
    });
  }

  String? _note(Play play, int couldBroken) {
    if (play.isDone) return null;
    final broken = play.broken;
    if (broken.length > couldBroken) {
      final (count, _) = play.lineCount(broken.last);
      return 'A line finished at $count, and every line must count '
          'fifteen. Lift something back.';
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

  /// Asked. The mend against the nearest charm.
  void _showMe() {
    final mend = _play.next;
    setState(() {
      _hints++;
      _armed = -1;
      if (_play.isDone) {
        _pointing = null;
        _saying = 'The charm holds.';
        return;
      }
      if (mend == null) {
        _pointing = null;
        _saying = 'There is nothing to show: no laying holds this '
            'charm, and the sweep tried every one. Ask why instead.';
        return;
      }
      _pointing = mend;
      final (cell, coin) = mend;
      _saying = coin == null
          ? 'Lift the coin at row ${cell ~/ 3 + 1}, column '
              '${cell % 3 + 1}: the nearest charm wants another '
              'there.'
          : 'Lay the $coin there: it stands so in the nearest charm '
              'the sweep counted.';
    });
  }

  /// Asked why. The counting, and the sweep.
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
        backgroundColor: Palette.hearth,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Bed(
                    play: _play,
                    armed: _armed,
                    pointing: _pointing,
                    onCell: _touchedCell,
                    onTray: _touchedTray,
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

/// The line above the bed: which charm, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final broken = play.broken.length;
    final dead = !play.charm.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the charms',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.charm.name,
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
                      ? 'every line counts fifteen'
                      : broken > 0
                          ? '$broken line${broken == 1 ? '' : 's'} '
                              'finished off the count'
                          : dead
                              ? 'no laying holds this charm'
                              : '${9 - play.tray.length} of 9 coins '
                                  'laid',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : broken > 0 || dead
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.moves} moved',
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

/// The bed itself.
class _Bed extends StatelessWidget {
  const _Bed({
    required this.play,
    required this.armed,
    required this.pointing,
    required this.onCell,
    required this.onTray,
  });

  final Play play;
  final int armed;
  final (int, int?)? pointing;
  final ValueChanged<int> onCell;
  final ValueChanged<int> onTray;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              final coin = metrics.trayCoinAt(touch.localPosition);
              if (coin > 0 && play.tray.contains(coin)) {
                onTray(coin);
                return;
              }
              final cell = metrics.cellAt(touch.localPosition);
              if (cell >= 0) onCell(cell);
            },
            child: CustomPaint(
              key: CharmScreenState.bedKey,
              size: size,
              painter: CharmView(
                play: play,
                armed: armed,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the bed: what the game has to say, and what else can be done.
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
                    'Arm a coin from the tray, then tap a bare cell '
                        'to lay it; tap a laid coin to lift it back. '
                        'Every row, column and crossway must count '
                        'fifteen.',
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
