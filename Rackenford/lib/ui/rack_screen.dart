import 'package:flutter/material.dart';

import '../best.dart';
import '../rack/pantry.dart';
import '../rack/play.dart';
import 'palette.dart';
import 'rackview.dart';
import 'result_card.dart';

/// One pantry, racked jar by jar.
class RackScreen extends StatefulWidget {
  const RackScreen({super.key, required this.pantry});

  final Pantry pantry;

  @override
  State<RackScreen> createState() => RackScreenState();
}

class RackScreenState extends State<RackScreen> {
  late Play play;

  /// The jar the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.pantry);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.pantry.name));
      }
    });
  }

  void _tap(int jar) {
    if (jar < 0 || play.isOver) return;
    setState(() {
      play = play.liftAt(jar);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.pantry.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.pantry.name);
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
      play = Play.of(widget.pantry);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the pantry says of itself, as it stands.
  String verdict() {
    if (pointing != null) {
      return 'Lift the ringed jar toward its height.';
    }
    if (play.isDone) {
      return 'Racked home: no jar stands above its divisor.';
    }
    final sore = play.quarrels.length;
    if (sore > 0) {
      return '$sore quarrel${sore == 1 ? '' : 's'} on the racks.';
    }
    return 'Jars racked ${play.racked} of '
        '${widget.pantry.top}, no quarrel yet.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.pantry.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a jar to lift it rack by rack and round '
                  'to the tray: ${widget.pantry.task}.',
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
                    ).jarUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: RackView(
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
                children: [
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.isDone
                            ? Palette.landed
                            : Palette.line),
                    label: Text(
                      'racked ${play.racked} of '
                      '${widget.pantry.top}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.quarrels.isEmpty
                            ? Palette.line
                            : Palette.quarrel),
                    label: Text(
                      'quarrels ${play.quarrels.length}',
                      style: const TextStyle(
                          color: Palette.inkDim, fontSize: 13),
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
                  onPantry: () => Navigator.of(context).pop(),
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
