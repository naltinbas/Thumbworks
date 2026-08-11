import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../drive/fields.dart';
import '../drive/play.dart';
import 'fieldview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One drive: push the ewe to the pen before the pinder does.
class DriveScreen extends StatefulWidget {
  const DriveScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the player pens the ewe, with the pushes it took.
  /// Answers whether that beat what was written down before.
  final Future<bool> Function(int pushes)? onDone;

  @override
  State<DriveScreen> createState() => DriveScreenState();
}

class DriveScreenState extends State<DriveScreen> {
  static const fieldKey = ValueKey('field');

  late Play _play;

  (int, int)? _pointing;
  var _showRungs = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  (int, int)? get pointing => _pointing;
  bool get showRungs => _showRungs;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(DriveScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Fields.at(widget.number));
    _pointing = null;
    _showRungs = false;
    _hints = 0;
    _saying = _play.winnable
        ? null
        : 'She starts on a rung of the ladder. However she is driven, the '
            'pinder has an answer; this field is here to be felt, not won.';
    _told = false;
    _best = false;
  }

  void _touched((int, int)? square) {
    if (square == null || _play.isOver) return;
    final (east, north) = square;
    if (east == _play.east && north == _play.north) return;

    if (!_play.mayPush(east, north)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'A ewe gives ground away from you or along the wall: due '
            'west, due south, or the same paces of both. She cannot be '
            'pushed there.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final wasWinnable = _play.winnable;
    final next = _play.touch(east, north);
    setState(() {
      _play = next;
      _pointing = null;
      _showRungs = false;
      _saying = _note(next, wasWinnable);
    });
    if (next.isOver) _finished();
  }

  /// What the field has to say after an exchange.
  String? _note(Play play, bool wasWinnable) {
    if (play.isOver) return null;
    if (wasWinnable && !play.winnable) {
      return 'That push left her off the ladder, and the pinder answered '
          'onto it. The fee is his now, however she is driven. Take the '
          'push back.';
    }
    return null;
  }

  void _again() {
    setState(_set);
  }

  void _takeBack() {
    if (_play.made == 0) return;
    setState(() {
      _play = _play.back;
      _pointing = null;
      _showRungs = false;
      _saying = null;
    });
  }

  /// Asked. The winning push, when there is one.
  void _showMe() {
    final push = _play.next;
    setState(() {
      _hints++;
      _showRungs = false;
      if (_play.isOver) {
        _pointing = null;
        _saying = 'The drive is over.';
        return;
      }
      if (push == null) {
        _pointing = null;
        _saying = 'There is nothing to show: she stands on a rung, and '
            'every push from a rung lands off the ladder. Push and see '
            'what the pinder does with it.';
        return;
      }
      _pointing = push;
      _saying = push == (0, 0)
          ? 'Into the pen. The fee is yours.'
          : 'To ${push.$1} east, ${push.$2} north: the rung the pinder '
              'cannot answer.';
    });
  }

  /// Asked why. The ladder, drawn on the grass.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      _showRungs = true;
      _saying = 'The marked squares are the ladder, and the pen is its '
          'foot. From a rung, every push lands off the ladder; from off '
          'it, some push lands on. So whoever stands her on a rung has '
          'the drive: one rung in every row, every column and every '
          'slant, climbing by the golden ratio.';
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    if (!_play.won) return;
    widget.onDone?.call(_play.made).then((best) {
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
        backgroundColor: Palette.moor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _Field(
                    play: _play,
                    pointing: _pointing,
                    showRungs: _showRungs,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isOver)
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

/// The line above the field: which drive, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  String get _standing {
    if (play.isOver) {
      return play.won ? 'the ewe is penned' : 'the ewe is the pinder\'s';
    }
    if (!play.winnable) return 'the pinder holds the drive';
    return '${play.east} east, ${play.north} north of the pen';
  }

  @override
  Widget build(BuildContext context) {
    final lost = !play.winnable && !(play.isOver && play.won);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the fields',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.field.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _standing,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isOver && play.won
                        ? Palette.good
                        : lost
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            play.field.hopeless
                ? '${play.made} / none'
                : '${play.made} / ${play.field.fewest}',
            style: TextStyle(
              color: lost ? Palette.bad : Palette.ink,
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

/// The field itself.
class _Field extends StatelessWidget {
  const _Field({
    required this.play,
    required this.pointing,
    required this.showRungs,
    required this.onTouch,
  });

  final Play play;
  final (int, int)? pointing;
  final bool showRungs;
  final ValueChanged<(int, int)?> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.squareAt(touch.localPosition)),
            child: CustomPaint(
              key: DriveScreenState.fieldKey,
              size: size,
              painter: FieldView(
                play: play,
                pointing: pointing,
                showRungs: showRungs,
              ),
            ),
          );
        },
      );
}

/// Under the field: what the game has to say, and what else can be done.
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
                color: Palette.byre,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap a square due west, due south, or evenly southwest '
                        'of the ewe to push her there. The pinder pushes '
                        'back, and the push that pens her takes the fee.',
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
                color: Palette.byre,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.wall, width: 1.1),
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
