import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../plot/play.dart';
import '../plot/plots.dart';
import 'palette.dart';
import 'plotview.dart';
import 'result_card.dart';

/// One plot: shade it until every tally is kept.
class PlotScreen extends StatefulWidget {
  const PlotScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the finished picture, with the askings used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<PlotScreen> createState() => PlotScreenState();
}

class PlotScreenState extends State<PlotScreen> {
  static const gardenKey = ValueKey('garden');

  late Play _play;

  (int, int)? _pointing;
  List<int>? _other;
  var _otherAt = -1;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  List<int>? get other => _other;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(PlotScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Plots.at(widget.number));
    _pointing = null;
    _other = null;
    _otherAt = -1;
    _hints = 0;
    _saying = switch (_play.plot.solutions) {
      0 => 'No shading keeps these tallies, and the label said so. '
          'Count them and see; ask why for the words.',
      1 => null,
      _ => 'These tallies fit more than one picture, and the label '
          'says so: shade any picture they accept.',
    };
    _told = false;
    _best = false;
  }

  void _touched(int row, int col) {
    if (_play.isDone) return;

    HapticFeedback.selectionClick();
    final fallenBefore =
        _play.fallenRows.length + _play.fallenCols.length;
    final next = _play.touch(row, col);
    setState(() {
      _play = next;
      _pointing = null;
      _other = null;
      _otherAt = -1;
      _saying = _note(next, fallenBefore);
    });
    if (next.isDone) _finished();
  }

  String? _note(Play play, int fallenBefore) {
    if (play.isDone) return null;
    final rows = play.fallenRows;
    final cols = play.fallenCols;
    if (rows.length + cols.length > fallenBefore) {
      final line = rows.isNotEmpty
          ? 'Row ${rows.first + 1}'
          : 'Column ${cols.first + 1}';
      return '$line fits nothing now, whatever the empty cells do. '
          'Take marks back.';
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
      _pointing = null;
      _other = null;
      _otherAt = -1;
      _saying = null;
    });
  }

  /// Asked. A cell one round of deduction settles from what stands.
  /// A dead plot gets the global answer, not a local deduction.
  void _showMe() {
    final offer = _play.plot.winnable ? _play.next : null;
    setState(() {
      _hints++;
      _other = null;
      _otherAt = -1;
      if (_play.isDone) {
        _pointing = null;
        _saying = 'The picture stands.';
        return;
      }
      if (offer == null) {
        _pointing = null;
        _saying = _play.fallenRows.isNotEmpty ||
                _play.fallenCols.isNotEmpty
            ? 'A tally has fallen: reason has nothing to build on. '
                'Take marks back.'
            : _play.plot.winnable
                ? 'Reason finds nothing new from what stands.'
                : 'There is nothing to show: no shading keeps these '
                    'tallies, and the stacking tried every one. Ask '
                    'why instead.';
        return;
      }
      final (row, col, shade) = offer;
      _pointing = (row, col);
      _saying = 'Every fitting of its row and column agrees: that '
          'cell is ${shade ? 'shaded' : 'bare'}.';
    });
  }

  /// Asked why. The certificate, and for the gardens each picture in
  /// turn.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      if (_play.plot.solutions > 1) {
        final all = _play.rules
            .solutionsOf(_play.plot.rowTallies, _play.plot.colTallies);
        _otherAt = (_otherAt + 1) % all.length;
        _other = all[_otherAt];
      }
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
        backgroundColor: Palette.paper,
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
                    pointing: _pointing,
                    other: _other,
                    onTouch: _touched,
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

/// The line above the garden: which plot, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final fallen =
        play.fallenRows.length + play.fallenCols.length;
    final dead = !play.plot.winnable;
    final cells = play.plot.wide * play.plot.high;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the plots',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.plot.name,
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
                      ? 'every tally kept'
                      : fallen > 0
                          ? '$fallen '
                              'tall${fallen == 1 ? 'y has' : 'ies have'} '
                              'fallen'
                          : dead
                              ? 'no shading keeps these tallies'
                              : '${play.decided} of $cells cells '
                                  'decided',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDone
                        ? Palette.good
                        : fallen > 0 || dead
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.marks} marked',
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

/// The garden itself.
class _Garden extends StatelessWidget {
  const _Garden({
    required this.play,
    required this.pointing,
    required this.other,
    required this.onTouch,
  });

  final Play play;
  final (int, int)? pointing;
  final List<int>? other;
  final void Function(int, int) onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) {
              final cell = metrics.cellAt(touch.localPosition);
              if (cell != null) onTouch(cell.$1, cell.$2);
            },
            child: CustomPaint(
              key: PlotScreenState.gardenKey,
              size: size,
              painter: PlotView(
                play: play,
                pointing: pointing,
                other: other,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the garden: what the game has to say, and what else can be
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
                    'Tap a cell to shade it, again to mark it bare, '
                        'again to clear it. Each tally is its line\'s '
                        'runs of shade, in order.',
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
