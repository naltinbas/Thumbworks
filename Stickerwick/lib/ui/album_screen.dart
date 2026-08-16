import 'package:flutter/material.dart';

import '../best.dart';
import '../album/level.dart';
import '../album/play.dart';
import '../album/rules.dart';
import 'albumview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One ask, the album and the packets set to it.
class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key, required this.level});

  final Level level;

  @override
  State<AlbumScreen> createState() => AlbumScreenState();
}

class AlbumScreenState extends State<AlbumScreen> {
  late Play play;

  /// What the show-me points at, or null: (dial, way).
  (int, int)? pointing;

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

  void _turn(int which, int by) {
    if (play.isOver) return;
    setState(() {
      play = play.set(which, by);
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
    if (play.gaveUp) return 'Sixty packets and the album is full with chance ${Rules.decimal(play.chance)}, not 1: the same sticker could come every time.';
    final head = 'A set of ${play.stickers} takes ${play.average} packets on average, ${Rules.decimal(play.average)}; full after ${play.packets} with chance ${play.chance == Frac.one ? '1, certain' : Rules.decimal(play.chance)}.';
    return play.isDone ? 'As asked. $head' : head;
  }

  Widget _winder(int by) {
    final lit = pointing == (1, by);
    return OutlinedButton(
      key: Key('packets${by > 0 ? '+' : ''}$by'),
      onPressed: () => _turn(1, by),
      style: OutlinedButton.styleFrom(
        foregroundColor: lit ? Palette.shown : Palette.ink,
        side: BorderSide(color: lit ? Palette.shown : Palette.line),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        minimumSize: const Size(44, 34),
        visualDensity: VisualDensity.compact,
      ),
      child: Text('${by > 0 ? '+' : ''}$by'),
    );
  }

  Widget _dial(int which, String name, int at) {
    Widget button(int by, IconData icon) {
      final lit = pointing == (which, by);
      return IconButton(
        key: Key('$name${by > 0 ? '+1' : '-1'}'),
        onPressed: () => _turn(which, by),
        icon: Icon(icon, color: lit ? Palette.shown : Palette.ink),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        visualDensity: VisualDensity.compact,
        style: IconButton.styleFrom(
          side: BorderSide(color: lit ? Palette.shown : Palette.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(-1, Icons.remove),
        SizedBox(
          width: 78,
          child: Text(
            '$name $at',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Palette.ink, fontSize: 13),
          ),
        ),
        button(1, Icons.add),
      ],
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
                  'Set the stickers in the set and the packets bought, and see '
                  'the average and the chance of a full album: '
                  '${widget.level.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  key: const Key('board'),
                  painter: AlbumView(
                    play: play,
                    pointing: pointing,
                    labels: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              if (!play.isOver)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _dial(0, 'stickers', play.stickers),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _winder(-10),
                          const SizedBox(width: 3),
                          _winder(-1),
                          SizedBox(
                            width: 84,
                            child: Text(
                              'packets ${play.packets}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Palette.ink, fontSize: 13),
                            ),
                          ),
                          _winder(1),
                          const SizedBox(width: 3),
                          _winder(10),
                        ],
                      ),
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
                      'average ${Rules.decimal(play.average)}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone ? Palette.good : Palette.line),
                    label: Text(
                      'full ${Rules.decimal(play.chance)}',
                      style: TextStyle(
                          color: play.chance.compareTo(Frac.of(1, 2)) >= 0 ? Palette.bar : Palette.ink, fontSize: 13),
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
