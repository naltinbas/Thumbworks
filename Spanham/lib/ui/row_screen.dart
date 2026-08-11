import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../row/levels.dart';
import '../row/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'rowview.dart';

/// One shelf: set every pair its own number apart.
class RowScreen extends StatefulWidget {
  const RowScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, when the shelf is set, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<RowScreen> createState() => RowScreenState();
}

class RowScreenState extends State<RowScreen> {
  static const shelfKey = ValueKey('shelf');

  late Play _play;

  var _pointing = -1;
  var _showSums = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get showSums => _showSums;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(RowScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Levels.at(widget.number));
    _pointing = -1;
    _showSums = false;
    _hints = 0;
    _saying = _play.level.possible
        ? null
        : 'No setting exists for this shelf, and the label said so. It is '
            'here for the why: arithmetic on the seat numbers, done on '
            'your fingers.';
    _told = false;
    _best = false;
  }

  void _touched(int seat) {
    if (seat < 0 || _play.isSet) return;

    if (!_play.mayPlace(seat)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'The ${_play.placing} pair wants this seat and the seat '
            '${_play.placing + 1} along, both free. It cannot sit there.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.canStill;
    final next = _play.place(seat);
    setState(() {
      _play = next;
      _pointing = -1;
      _showSums = false;
      _saying = _note(next, could);
    });
    if (next.isSet) _finished();
  }

  /// What the nursery has to say after a placement.
  String? _note(Play play, bool could) {
    if (play.isSet) return null;
    if (could && play.level.possible && !play.canStill) {
      return 'That placement strands the shelf: the pairs still in hand '
          'have nowhere left that works. Take it back.';
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
      _showSums = false;
      _saying = null;
    });
  }

  /// Asked. A seat that keeps the shelf settable.
  void _showMe() {
    final seat = _play.next;
    setState(() {
      _hints++;
      _showSums = false;
      if (_play.isSet) {
        _pointing = -1;
        _saying = 'The shelf is set.';
        return;
      }
      if (seat == null) {
        _pointing = -1;
        _saying = _play.level.possible
            ? 'No seat works from here. Take some back.'
            : 'There is nothing to show: no setting exists at all. Ask '
                'why instead.';
        return;
      }
      _pointing = seat;
      _saying = 'Seat ${seat + 1} for the ${_play.placing} pair: from '
          'there the rest can still be set, and the search has checked '
          'it.';
    });
  }

  /// Asked why. The arithmetic on the seat numbers.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _showSums = true;
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
        backgroundColor: Palette.floor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Shelf(
                    play: _play,
                    pointing: _pointing,
                    showSums: _showSums,
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

/// The line above the shelf: which level, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final stranded =
        play.level.possible && !play.isSet && !play.canStill;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the shelves',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.level.name,
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
                      ? 'every pair its number apart'
                      : stranded
                          ? 'the shelf is stranded'
                          : play.placing == 0
                              ? ''
                              : 'the ${play.placing} pair in hand',
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
            '${play.level.pairs - play.placing} / ${play.level.pairs}',
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

/// The shelf itself.
class _Shelf extends StatelessWidget {
  const _Shelf({
    required this.play,
    required this.pointing,
    required this.showSums,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool showSums;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.seatAt(touch.localPosition)),
            child: CustomPaint(
              key: RowScreenState.shelfKey,
              size: size,
              painter: RowView(
                play: play,
                pointing: pointing,
                showSums: showSums,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the shelf: what the game has to say, and what else can be done.
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
                color: Palette.toybox,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Palette.line, width: 1.1),
              ),
              child: Text(
                saying ??
                    'Tap the seat for the left block of the pair in hand; '
                        'its twin lands the pair\'s own number of seats '
                        'along. Biggest pairs first.',
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
                color: Palette.toybox,
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
