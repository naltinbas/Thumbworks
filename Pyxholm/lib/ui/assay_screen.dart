import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../assay/boxes.dart';
import '../assay/play.dart';
import '../assay/pyx.dart';
import 'beamview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One box: find the wrong coin, and say which way it is wrong.
class AssayScreen extends StatefulWidget {
  const AssayScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, the first time a box is settled, with how many weighings it
  /// took. Answers whether that beat what was written down before.
  final Future<bool> Function(int weighings)? onDone;

  @override
  State<AssayScreen> createState() => AssayScreenState();
}

class AssayScreenState extends State<AssayScreen> {
  static const beamKey = ValueKey('beam');

  late Pyx _pyx;
  late Play _play;

  Weighing? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Pyx get pyx => _pyx;
  Play get play => _play;
  Weighing? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(AssayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _pyx = Boxes.at(widget.number);
    _play = Play.of(_pyx, Boxes.assayFor(widget.number));
    _pointing = null;
    _hints = 0;
    _saying = null;
    _told = false;
    _best = false;
  }

  void _touched(int coin) {
    if (coin < 0 || _play.isDone) return;
    if (_play.isCleared(coin)) {
      setState(() {
        _pointing = null;
        _saying = 'Coin ${coin + 1} is known to be sound. It can go on a pan '
            'as a makeweight, and it often should.';
      });
    }
    HapticFeedback.selectionClick();
    setState(() {
      _play = _play.move(coin);
      _pointing = null;
    });
  }

  void _weigh() {
    if (!_play.canWeigh) {
      setState(() => _saying = _play.onLeft.isEmpty
          ? 'Put some coins on the pans first.'
          : 'The pans need the same number of coins on them.');
      return;
    }
    HapticFeedback.mediumImpact();
    final next = _play.weigh();
    setState(() {
      _play = next;
      _pointing = null;
      _saying = _note(next);
    });
    if (next.isDone) _finished();
  }

  /// What the beam has to say after a weighing.
  ///
  /// How much is still to be told apart, which is the number the whole game
  /// turns on, and whether the box can still be settled in the weighings it
  /// takes. That second one is the same searching that answered the box,
  /// started from what is left rather than from the beginning.
  String? _note(Play play) {
    if (play.isDone) return null;
    final could = play.couldFinishIn;
    if (could > _pyx.fewest) {
      return '${play.standing.length} things it could still be, and the best '
          'this can be settled in now is $could weighings, which is '
          '${could - _pyx.fewest} more than the ${_pyx.fewest} it takes.';
    }
    return '${play.standing.length} things it could still be.';
  }

  void _again() {
    setState(() {
      _play = _play.again;
      _pointing = null;
      _saying = null;
      _told = false;
      _best = false;
    });
  }

  void _back() {
    if (_play.told.isEmpty) {
      if (_play.onLeft.isEmpty && _play.onRight.isEmpty) return;
      setState(() {
        _play = _play.clearPans;
        _saying = null;
      });
      return;
    }
    setState(() {
      _play = _play.back;
      _pointing = null;
      _saying = null;
    });
  }

  /// Asked. Lays out a weighing that still settles the box in as few more as
  /// it can now be settled in, and puts the coins on the pans.
  void _showMe() {
    final next = _play.next;
    setState(() {
      _hints++;
      if (next == null) {
        _pointing = null;
        _saying = 'There is nothing left to weigh.';
        return;
      }
      _pointing = next;
      var laid = _play.clearPans;
      for (final coin in next.left) {
        laid = laid.move(coin);
      }
      for (final coin in next.right) {
        laid = laid.move(coin).move(coin);
      }
      _play = laid;
      _saying = 'Coins ${_list(next.left)} against ${_list(next.right)}.';
    });
  }

  /// Asked why it takes what it takes. The beam has three answers, so k
  /// weighings tell at most 3^k things apart, and there are more things to
  /// tell apart than that when k is smaller. Counting settles the floor
  /// without anybody weighing anything.
  void _why() {
    setState(() {
      _hints++;
      _pointing = null;
      final short = _pyx.fewest - 1;
      var tells = 1;
      for (var go = 0; go < short; go++) {
        tells *= 3;
      }
      final floor = _pyx.countingSays;
      final counted = 'There are ${_pyx.verdicts} things to tell apart'
          '${_pyx.knownLight ? '' : ', a heavy one and a light one for every '
              'coin'}. The beam has three answers, so $short weighings tell '
          'at most $tells apart.';
      _saying = floor == _pyx.fewest
          ? '$counted That is why ${_pyx.fewest} is the fewest, and there is a '
              'way to do it in ${_pyx.fewest}.'
          : '$counted So $short might have done, by counting alone. It cannot: '
              'no first weighing splits ${_pyx.verdicts} into three parts '
              'small enough, and only searching every weighing there is shows '
              'that. It takes ${_pyx.fewest}.';
    });
  }

  String _list(List<int> coins) =>
      coins.map((coin) => '${coin + 1}').join(', ');

  void _finished() {
    HapticFeedback.mediumImpact();
    if (_told) return;
    _told = true;
    widget.onDone?.call(_play.weighings).then((best) {
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
              _Ledger(pyx: _pyx, play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Beam(
                    play: _play,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isDone)
                ResultCard(
                  pyx: _pyx,
                  play: _play,
                  best: _best,
                  onAgain: _again,
                  onNext: widget.onNext,
                  onLeave: widget.onLeave,
                )
              else
                _Tools(
                  saying: _saying,
                  canWeigh: _play.canWeigh,
                  onWeigh: _weigh,
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

/// The line above the beam: which box, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({
    required this.pyx,
    required this.play,
    required this.onLeave,
  });

  final Pyx pyx;
  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final over = play.weighings > pyx.fewest;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the boxes',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pyx.name,
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
                      ? 'coin ${play.answer!.coin + 1} is '
                          '${play.answer!.heavy ? 'heavy' : 'light'}'
                      : '${play.standing.length} things it could be',
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
            '${play.weighings} / ${pyx.fewest}',
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

/// The beam and the coins.
class _Beam extends StatelessWidget {
  const _Beam({
    required this.play,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final Weighing? pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.coinAt(touch.localPosition)),
            child: CustomPaint(
              key: AssayScreenState.beamKey,
              size: size,
              painter: BeamView(
                play: play,
                pointing: pointing,
                labels: const TextStyle(fontFamily: 'Roboto', fontSize: 13),
              ),
            ),
          );
        },
      );
}

/// Under the beam: what the game has to say, and what else can be done.
class _Tools extends StatelessWidget {
  const _Tools({
    required this.saying,
    required this.canWeigh,
    required this.onWeigh,
    required this.onBack,
    required this.onAgain,
    required this.onShowMe,
    required this.onWhy,
  });

  final String? saying;
  final bool canWeigh;
  final VoidCallback onWeigh;
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
                    'Tap a coin to put it on the left pan, again for the '
                        'right, again to take it off. The beam answers as '
                        'badly as it truthfully can.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: saying == null ? Palette.inkDim : Palette.ink,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Never dead: a tap on it when the pans do not match is worth
            // a word about why rather than nothing at all.
            _Button(
              label: 'Weigh',
              dead: false,
              quiet: !canWeigh,
              onTap: onWeigh,
              big: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Button(label: 'Take back', dead: false, onTap: onBack),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _Button(label: 'Again', dead: false, onTap: onAgain),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _Button(label: 'Show me', dead: false, onTap: onShowMe),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: _Button(label: 'Why', dead: false, onTap: onWhy),
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
    this.big = false,
    this.quiet = false,
  });

  final String label;
  final bool dead;
  final VoidCallback onTap;
  final bool big;

  /// Drawn as though it were dead, but still worth tapping.
  final bool quiet;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: dead ? null : onTap,
          child: ExcludeSemantics(
            child: Container(
              height: big ? 48 : 44,
              decoration: BoxDecoration(
                color: big && !dead && !quiet ? Palette.beam : Palette.verge,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: dead || quiet ? Palette.line : Palette.edge,
                  width: 1.1,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: dead || quiet
                        ? Palette.inkDim
                        : big
                            ? Palette.night
                            : Palette.ink,
                    fontSize: big ? 16 : 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
