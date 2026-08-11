import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../moor/moors.dart';
import '../moor/play.dart';
import 'moorview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One moor: raise every mill where the wind stays its own.
class MoorScreen extends StatefulWidget {
  const MoorScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the last mill goes up, with the askings used.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<MoorScreen> createState() => MoorScreenState();
}

class MoorScreenState extends State<MoorScreen> {
  static const moorKey = ValueKey('moor');

  late Play _play;

  (int, int)? _pointing;
  var _showBuilt = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  bool get showBuilt => _showBuilt;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(MoorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Moors.at(widget.number));
    _pointing = null;
    _showBuilt = false;
    _hints = 0;
    _saying = _play.moor.possible
        ? null
        : 'No setting exists on this moor, and the label said so. It is '
            'here for the why: the cases, walked by hand.';
    _told = false;
    _best = false;
  }

  void _touched((int, int)? plot) {
    if (plot == null || _play.isSet) return;
    final (file, row) = plot;

    if (_play.rows[file] >= 0) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'That file has its mill already. Back takes the last '
            'one down.';
      });
      return;
    }
    final thief = _play.thiefAt(file, row);
    if (thief != null) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'The mill in file ${thief.$1 + 1}, row ${thief.$2 + 1} '
            'steals that plot\'s wind: they share a row, a file, or a '
            'slant.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.canStill;
    final next = _play.raise(file, row);
    setState(() {
      _play = next;
      _pointing = null;
      _showBuilt = false;
      _saying = _note(next, could);
    });
    if (next.isSet) _finished();
  }

  String? _note(Play play, bool could) {
    if (play.isSet) return null;
    if (could && play.moor.possible && !play.canStill) {
      return 'That mill strands the moor: some file has no windproof '
          'plot left. Take it down.';
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
      _showBuilt = false;
      _saying = null;
    });
  }

  /// Asked. A plot the search has checked through.
  void _showMe() {
    final plot = _play.next;
    setState(() {
      _hints++;
      _showBuilt = false;
      if (_play.isSet) {
        _pointing = null;
        _saying = 'The moor is set.';
        return;
      }
      if (plot == null) {
        _pointing = null;
        _saying = _play.moor.possible
            ? 'No plot works from here. Take some down.'
            : 'There is nothing to show: no setting exists at all. Ask '
                'why instead.';
        return;
      }
      _pointing = plot;
      _saying = 'File ${plot.$1 + 1}, row ${plot.$2 + 1}: from there the '
          'rest can still be set, and the search has checked it.';
    });
  }

  /// Asked why. The built rows, raised as ghosts.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _showBuilt = _play.moor.possible;
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
        backgroundColor: Palette.sky,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _Heath(
                    play: _play,
                    pointing: _pointing,
                    showBuilt: _showBuilt,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isSet)
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

/// The line above the moor: which moor, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final stranded =
        play.moor.possible && !play.isSet && !play.canStill;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the moors',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.moor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isSet
                      ? 'every mill keeps its wind'
                      : stranded
                          ? 'the moor is stranded'
                          : 'a mill in every file, no wind shared',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isSet
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
            '${play.standing} / ${play.moor.size}',
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

/// The heath itself.
class _Heath extends StatelessWidget {
  const _Heath({
    required this.play,
    required this.pointing,
    required this.showBuilt,
    required this.onTouch,
  });

  final Play play;
  final (int, int)? pointing;
  final bool showBuilt;
  final ValueChanged<(int, int)?> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.plotAt(touch.localPosition)),
            child: CustomPaint(
              key: MoorScreenState.moorKey,
              size: size,
              painter: MoorView(
                play: play,
                pointing: pointing,
                showBuilt: showBuilt,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the moor: what the game has to say, and what else can be done.
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
                color: Palette.barn,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a plot to raise a mill. Two mills steal each '
                        'other\'s wind along a row, a file, or a slant: '
                        'one mill in every file, no wind shared.',
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
                color: Palette.barn,
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
