import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../banns/parties.dart';
import '../banns/play.dart';
import 'bannsview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One party: wed everyone so nobody elopes.
class BannsScreen extends StatefulWidget {
  const BannsScreen({
    super.key,
    required this.number,
    required this.onLeave,
    required this.onNext,
    this.onDone,
  });

  final int number;
  final VoidCallback onLeave;
  final VoidCallback onNext;

  /// Called once, at the settling, with the askings used. Answers
  /// whether that beat what was written down before.
  final Future<bool> Function(int askings)? onDone;

  @override
  State<BannsScreen> createState() => BannsScreenState();
}

class BannsScreenState extends State<BannsScreen> {
  static const hallKey = ValueKey('hall');

  late Play _play;

  var _armed = -1;
  (int, int)? _pointing;
  var _hints = 0;

  String? _saying;
  var _told = false;
  var _best = false;

  Play get play => _play;
  int get armed => _armed;
  (int, int)? get pointing => _pointing;
  int get hints => _hints;
  String? get saying => _saying;

  @override
  void initState() {
    super.initState();
    _set();
  }

  @override
  void didUpdateWidget(BannsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) setState(_set);
  }

  void _set() {
    _play = Play.of(Parties.at(widget.number));
    _armed = -1;
    _pointing = null;
    _hints = 0;
    _saying = _play.party.winnable
        ? null
        : 'No pairing of this house settles, and the label said so. '
            'Wed them any way you like and watch it break; ask why for '
            'the whole story.';
    _told = false;
    _best = false;
  }

  void _touched(int who) {
    if (who < 0 || _play.isSettled) return;

    HapticFeedback.selectionClick();
    if (_armed < 0) {
      setState(() {
        _armed = who;
        _pointing = null;
      });
      return;
    }
    if (_armed == who) {
      setState(() => _armed = -1);
      return;
    }

    final one = _armed;
    final parted = _play.wedded[one] == who;
    final next = _play.wed(one, who);
    setState(() {
      _play = next;
      _armed = -1;
      _pointing = null;
      _saying = _note(next, one, who, parted);
    });
    if (next.isSettled) _finished();
  }

  String? _note(Play play, int one, int other, bool parted) {
    if (play.isSettled || parted) return null;
    final eloping = play.eloping;
    if (eloping.isEmpty) return null;
    final names = play.party.names;
    final (a, b) = eloping.first;
    return '${names[a]} and ${names[b]} would both rather have each '
        'other: the red cord says so, and a settled party has none.';
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

  /// Asked. A couple from a settled pairing the sweep found.
  void _showMe() {
    final couple = _play.next;
    setState(() {
      _hints++;
      _armed = -1;
      if (_play.isSettled) {
        _pointing = null;
        _saying = 'The party is settled.';
        return;
      }
      if (couple == null) {
        _pointing = null;
        _saying = 'There is nothing to show: no pairing of this house '
            'settles, and the sweep judged all three. Ask why instead.';
        return;
      }
      _pointing = couple;
      final names = _play.party.names;
      _saying = 'Wed ${names[couple.$1]} to ${names[couple.$2]}: the '
          'blue cord is a couple from a pairing the sweep judged '
          'settled.';
    });
  }

  /// Asked why. The certificate in words.
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
        backgroundColor: Palette.hall,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Ledger(play: _play, onLeave: widget.onLeave),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _Hall(
                    play: _play,
                    armed: _armed,
                    pointing: _pointing,
                    onTouch: _touched,
                  ),
                ),
              ),
              if (_play.isSettled)
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

/// The line above the hall: which party, and how it is going.
class _Ledger extends StatelessWidget {
  const _Ledger({required this.play, required this.onLeave});

  final Play play;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final eloping = play.eloping.length;
    final dead = !play.party.winnable;

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.arrow_back, color: Palette.inkDim),
            tooltip: 'Back to the parties',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  play.party.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Palette.ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  play.isSettled
                      ? 'all wed, and nobody would leave'
                      : eloping > 0
                          ? '$eloping pair${eloping == 1 ? '' : 's'} '
                              'would elope'
                          : dead
                              ? 'no pairing of this house settles'
                              : '${play.unwedded} still to wed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: play.isSettled
                        ? Palette.good
                        : dead || eloping > 0
                            ? Palette.bad
                            : Palette.inkDim,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${play.weddings} banns',
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

/// The hall itself.
class _Hall extends StatelessWidget {
  const _Hall({
    required this.play,
    required this.armed,
    required this.pointing,
    required this.onTouch,
  });

  final Play play;
  final int armed;
  final (int, int)? pointing;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, room) {
          final size = Size(room.maxWidth, room.maxHeight);
          final metrics = Metrics(play, size);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (touch) => onTouch(metrics.chipAt(touch.localPosition)),
            child: CustomPaint(
              key: BannsScreenState.hallKey,
              size: size,
              painter: BannsView(
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

/// Under the hall: what the game has to say, and what else can be done.
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
                    'Tap two people to wed them; tap a couple again to '
                        'part it. Under each name, who they would '
                        'have, best first. Wed everyone so no red '
                        'cord stands.',
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
