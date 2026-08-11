import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shunt/play.dart';
import '../shunt/trays.dart';
import 'palette.dart';
import 'result_card.dart';
import 'shuntview.dart';

/// One tray: slide the tiles home through the gap.
class ShuntScreen extends StatefulWidget {
  const ShuntScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at home, with the shunts used. Answers whether that
  /// beat what was written down before.
  final Future<bool> Function(int shunts)? onDone;

  @override
  State<ShuntScreen> createState() => ShuntScreenState();
}

class ShuntScreenState extends State<ShuntScreen> {
  static const trayKey = ValueKey('tray');

  late Play _play;

  var _pointing = -1;
  var _swindled = false;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get pointing => _pointing;
  bool get swindled => _swindled;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(ShuntScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Trays.at(widget.number));
    _pointing = -1;
    _swindled = false;
    _hints = 0;
    _saying = _play.tray.winnable
        ? null
        : 'This tray never comes home, and the label said so. Ask why '
            'to count the reversed pair with your own eyes.';
    _told = false;
    _best = false;
  }

  void _touched(int cell) {
    if (cell < 0 || _play.isHome) return;

    if (!_play.mayShunt(cell)) {
      HapticFeedback.selectionClick();
      setState(() {
        _saying = 'Only a tile beside the gap can shunt into it.';
      });
      return;
    }

    HapticFeedback.selectionClick();
    final could = _play.fewestFromHere;
    final next = _play.shunt(cell);
    setState(() {
      _play = next;
      _pointing = -1;
      _swindled = false;
      _saying = _note(next, could);
    });
    if (next.isHome) _finished();
  }

  String? _note(Play play, int? could) {
    if (play.isHome || !play.tray.winnable) return null;
    final now = play.fewestFromHere;
    if (could != null && now != null && now > could) {
      return 'That shunt wandered: the fewest from here rose to $now. '
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
      _swindled = false;
      _saying = null;
    });
  }

  /// Asked. One shunt off a shortest way home.
  void _showMe() {
    final cell = _play.next;
    setState(() {
      _hints++;
      _swindled = false;
      if (_play.isHome) {
        _pointing = -1;
        _saying = 'Every tile is home.';
        return;
      }
      if (cell == null) {
        _pointing = -1;
        _saying = 'There is nothing to show: no shunting brings this '
            'tray home, and it was so as it was dealt. Ask why instead.';
        return;
      }
      _pointing = cell;
      _saying = 'Shunt tile ${_play.tileAt(cell)}: it steps one nearer '
          'along a shortest way the walk has measured.';
    });
  }

  /// Asked why. The certificate: the walk's number, or the odd pair.
  void _why() {
    setState(() {
      _hints++;
      _pointing = -1;
      _swindled = !_play.tray.winnable;
      _saying = whyWords(_play);
    });
  }

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.shunts).then((best) {
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
        backgroundColor: Palette.bench,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Tray(
                    play: _play,
                    pointing: _pointing,
                    swindled: _swindled,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isHome)
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

/// The line above the tray: which one, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final dead = !play.tray.winnable;
    final out = _outOfPlace();

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the trays',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.tray.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isHome
                      ? 'every tile home'
                      : dead
                          ? 'this tray never comes home'
                          : '$out tile${out == 1 ? '' : 's'} out of place',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isHome
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
            '${play.shunts} shunted',
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

  int _outOfPlace() {
    var out = 0;
    for (var cell = 0; cell < play.board.length; cell++) {
      if (play.board[cell] != 0 &&
          play.board[cell] != play.rules.home[cell]) {
        out++;
      }
    }
    return out;
  }
}

/// The tray itself.
class _Tray extends StatelessWidget {
  const _Tray({
    required this.play,
    required this.pointing,
    required this.swindled,
    required this.onTouch,
  });

  final Play play;
  final int pointing;
  final bool swindled;
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
              key: ShuntScreenState.trayKey,
              size: size,
              painter: ShuntView(
                play: play,
                pointing: pointing,
                swindled: swindled,
                labels: const TextStyle(fontFamily: 'Roboto'),
              ),
            ),
          );
        },
      );
}

/// Under the tray: what the game has to say, and what else can be done.
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
                    'Tap a tile beside the gap to shunt it in. Bring '
                        'the tiles to their order, gap in the last '
                        'corner.',
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
