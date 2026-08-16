import 'package:flutter/material.dart';

import '../best.dart';
import '../ones/level.dart';
import '../ones/play.dart';
import '../ones/rules.dart';
import 'onesview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the dial set to it.
class OnesScreen extends StatefulWidget {
  const OnesScreen({super.key, required this.level});

  final Level level;

  @override
  State<OnesScreen> createState() => OnesScreenState();
}

class OnesScreenState extends State<OnesScreen> {
  late Play play;

  /// What the show-me points at, or null: the wind to take.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.level);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.level.name));
      }
    });
  }

  void _wind(int by) {
    if (play.isOver) return;
    setState(() {
      play = play.wind(by);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.level.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.level.name);
          });
        }
      });
    }
  }

  void _back() {
    if (play.before == null) return;
    setState(() {
      play = play.back;
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  void _show() {
    setState(() => pointing = play.next);
  }

  void _why() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.board,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why',
              style: TextStyle(
                color: Palette.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  whyWords(play),
                  style: const TextStyle(
                      color: Palette.ink, fontSize: 14, height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _again() {
    setState(() {
      play = Play.of(widget.level);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) return Play.pointed(aim);
    final p = play.exponent, row = play.row;
    if (play.gaveUp) return 'Every composite length shows a factor: the row of its smallest prime factor divides it, and no such row is prime.';
    final String head;
    if (p == 2) {
      head = '2 ones are 3, prime, the smallest of Mersenne\'s numbers, below the reach of the chain.';
    } else if (play.rowIsPrime) {
      head = '$p ones are ${Rules.commas(row)}, prime: no factor to ${_root(row)}, and the Lucas-Lehmer chain ends at 0.';
    } else if (play.exponentIsPrime) {
      head = '$p ones are ${Rules.commas(row)}, ${Rules.commas(play.factor)} times ${Rules.commas(row ~/ play.factor)}: a prime length, but no prime row.';
    } else {
      final a = Rules.smallestExponentFactor(p);
      head = '$p ones are ${Rules.commas(row)}, ${Rules.commas(play.factor)} times ${Rules.commas(row ~/ play.factor)}: $p is $a times ${p ~/ a}, and the row of $a ones divides.';
    }
    return play.isDone ? 'As asked. $head' : head;
  }

  String _root(BigInt n) {
    var k = 0;
    while (BigInt.from(k + 1) * BigInt.from(k + 1) <= n) {
      k++;
    }
    return Rules.commas(BigInt.from(k));
  }

  Widget _winder(int by) {
    final lit = pointing == by;
    return OutlinedButton(
      key: Key('wind${by > 0 ? '+' : ''}$by'),
      onPressed: () => _wind(by),
      style: OutlinedButton.styleFrom(
        foregroundColor: lit ? Palette.shown : Palette.ink,
        side: BorderSide(color: lit ? Palette.shown : Palette.line),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: const Size(46, 36),
        visualDensity: VisualDensity.compact,
      ),
      child: Text('${by > 0 ? '+' : ''}$by'),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.level.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Wind the length up or down, by one or by ten a tap, and '
                  'see the row of ones told prime or not: ${widget.level.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  key: const Key('board'),
                  painter: OnesView(
                    play: play,
                    labels: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              if (!play.isOver)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _winder(-10),
                      const SizedBox(width: 4),
                      _winder(-1),
                      SizedBox(
                        width: 64,
                        child: Text(
                          '${play.exponent}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Palette.number, fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ),
                      _winder(1),
                      const SizedBox(width: 4),
                      _winder(10),
                    ],
                  ),
                ),
              if (!play.isOver)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'length ${play.exponent}, ${play.exponentIsPrime ? 'prime' : 'composite'}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      play.rowIsPrime ? 'row prime' : 'row composite',
                      style: TextStyle(
                          color: play.rowIsPrime ? Palette.one : Palette.oneRust, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.line),
                    label: Text(
                      'taps ${play.moves}',
                      style: const TextStyle(
                          color: Palette.inkDim, fontSize: 13),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 2),
                child: Text(
                  verdict(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: pointing != null
                        ? Palette.shown
                        : play.isDone
                            ? Palette.good
                            : Palette.ink,
                    fontSize: 14,
                  ),
                ),
              ),
              if (play.isOver)
                ResultCard(
                  play: play,
                  fewest: fewest,
                  isRecord: isRecord,
                  onAgain: _again,
                  onSham: () => Navigator.of(context).pop(),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: play.before == null ? null : _back,
                      child: const Text('Back'),
                    ),
                    TextButton(
                      onPressed: play.isOver ? null : _show,
                      child: const Text('Show me'),
                    ),
                    TextButton(
                      onPressed: _why,
                      child: const Text('Why'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
