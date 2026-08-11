import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../wick/play.dart';
import '../wick/wicks.dart';
import 'palette.dart';
import 'result_card.dart';
import 'wickview.dart';

/// One board: press the lamps dark.
class WickScreen extends StatefulWidget {
  const WickScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at dark, with the presses used. Answers whether that
  /// beat what was written down before.
  final Future<bool> Function(int presses)? onDone;

  @override
  State<WickScreen> createState() => WickScreenState();
}

class WickScreenState extends State<WickScreen> {
  static const boardKey = ValueKey('board');

  late Play _play;

  var _pointing = -1;
  var _answer = 0;
  var _quiet = 0;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  int get answer => _answer;
  int get quiet => _quiet;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(WickScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Wicks.at(widget.number));
    _pointing = -1;
    _answer = 0;
    _quiet = 0;
    _hints = 0;
    _saying = _play.wick.winnable
        ? null
        : 'No pressing darkens this board, and the label said so. Ask '
            'why for the quiet pattern it stands odd against.';
    _told = false;
    _best = false;
  }

  void _touched(int cell) {
    if (cell < 0 || _play.isDark) return;

    HapticFeedback.selectionClick();
    final could = _play.fewestFromHere;
    final next = _play.press(cell);
    setState(() {
      _play = next;
      _pointing = -1;
      _answer = 0;
      _quiet = 0;
      _saying = _note(next, could);
    });
    if (next.isDark) _finished();
  }

  String? _note(Play play, int? could) {
    if (play.isDark || !play.wick.winnable) return null;
    final now = play.fewestFromHere;
    if (could != null && now != null && now > could) {
      return 'That press wandered: the fewest from here rose to $now. '
          'Back takes it off the count.';
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
      _answer = 0;
      _quiet = 0;
      _saying = null;
    });
  }

  /// Asked. One press off a lightest answer from here.
  void _showMe() {
    final cell = _play.next;
    setState(() {
      _hints++;
      _answer = 0;
      _quiet = 0;
      if (_play.isDark) {
        _pointing = -1;
        _saying = 'The board is dark.';
        return;
      }
      if (cell == null) {
        _pointing = -1;
        _saying = 'There is nothing to show: no press-set darkens this '
            'board, and it was so before a finger touched it. Ask why '
            'instead.';
        return;
      }
      _pointing = cell;
      _saying = 'Press there: it sits in a lightest answer from here, '
          'worked out from the crosses and executed before it shipped.';
    });
  }

  /// Asked why. The certificate: an answer's rims, or the quiet pattern.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      if (_play.wick.winnable) {
        _answer = _play.rules.lightest(_play.board) ?? 0;
        _quiet = 0;
      } else {
        _answer = 0;
        _quiet = _play.oddAgainst ?? 0;
      }
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.pressed).then((best) {
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
                  child: _Board(
                    play: _play,
                    pointing: _pointing,
                    answer: _answer,
                    quiet: _quiet,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDark)
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

/// The line above the board: which wick, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.wick.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the wicks',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.wick.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isDark
                      ? 'the board is dark'
                      : dead
                          ? 'no pressing darkens this board'
                          : '${play.lamps} lamp${play.lamps == 1 ? '' : 's'}'
                              ' lit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isDark
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
            '${play.pressed} pressed',
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

/// The board itself.
class _Board extends StatelessWidget {
  const _Board({
    required this.play,
    required this.pointing,
    required this.answer,
    required this.quiet,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final int answer;
  final int quiet;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.cellAt(touch.localPosition)),
            child: CustomPaint(
              key: WickScreenState.boardKey,
              size: size,
              painter: WickView(
                play: play,
                pointing: pointing,
                answer: answer,
                quietPattern: quiet,
              ),
            ),
          );
        },
      );
}

/// Under the board: what the game has to say, and what else can be done.
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
                    'A press flips its lamp and the four beside it. '
                        'Press until every lamp is dark.',
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
