import 'package:flutter/material.dart';

import '../best.dart';
import '../rota/play.dart';
import '../rota/rota.dart';
import '../rota/rules.dart';
import 'rotaview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One rota, filled shift by shift.
class RotaScreen extends StatefulWidget {
  const RotaScreen({super.key, required this.rota});

  final Rota rota;

  @override
  State<RotaScreen> createState() => RotaScreenState();
}

class RotaScreenState extends State<RotaScreen> {
  late Play play;

  /// The shift and hand the show-me points at, or null.
  (Shift, int)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.rota);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.rota.name));
      }
    });
  }

  void _tap(Shift? shift) {
    if (shift == null || play.isOver) return;
    setState(() {
      play = play.tap(shift);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.rota.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.rota.name);
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
            Text(
              whyWords(play),
              style: const TextStyle(
                  color: Palette.ink, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _again() {
    setState(() {
      play = Play.of(widget.rota);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Tap the ringed shift round to hand ${aim.$2}.';
    }
    if (play.isDone) {
      return 'Finished: every hand every station once, every day once.';
    }
    final clashes = play.clashes.length;
    if (clashes > 0) {
      return '$clashes shift${clashes == 1 ? '' : 's'} clash${clashes == 1 ? 'es' : ''}.';
    }
    final stuck = play.rules.stuck(play.filled);
    if (stuck != null) {
      return 'Day ${stuck.$1 + 1}, station ${stuck.$2 + 1} has no hand left.';
    }
    return 'Shifts open ${play.open}, no clash.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.rota.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a shift to turn its hand up, 1 to 4 and round to '
                  'none; the pinned shifts are fixed: ${widget.rota.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    onTapUp: (tap) => _tap(Metrics(
                      play,
                      Size(room.maxWidth, room.maxHeight),
                    ).under(tap.localPosition)),
                    child: CustomPaint(
                      key: const Key('board'),
                      painter: RotaView(
                        play: play,
                        pointing: pointing,
                        labels: const TextStyle(fontFamily: 'Roboto'),
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ),
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
                      'open ${play.open}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.clashes.isEmpty ? Palette.line : Palette.bad),
                    label: Text(
                      'clashes ${play.clashes.length}',
                      style: TextStyle(
                          color: play.clashes.isEmpty
                              ? Palette.inkDim
                              : Palette.bad,
                          fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.rules.stuck(play.filled) == null
                            ? Palette.line
                            : Palette.bad),
                    label: Text(
                      play.rules.stuck(play.filled) == null
                          ? 'no shift stuck'
                          : 'a shift stuck',
                      style: TextStyle(
                          color: play.rules.stuck(play.filled) == null
                              ? Palette.inkDim
                              : Palette.bad,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
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
