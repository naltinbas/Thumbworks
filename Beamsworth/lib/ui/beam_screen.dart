import 'package:flutter/material.dart';

import '../beam/play.dart';
import '../beam/worth.dart';
import '../best.dart';
import 'beamview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One worth, chosen weight by weight.
class BeamScreen extends StatefulWidget {
  const BeamScreen({super.key, required this.worth});

  final Worth worth;

  @override
  State<BeamScreen> createState() => BeamScreenState();
}

class BeamScreenState extends State<BeamScreen> {
  late Play play;

  /// The weight the show-me points at, or null.
  (int, bool)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.worth);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.worth.name));
      }
    });
  }

  void _tap(int weight) {
    if (weight < 0 || play.isOver) return;
    final turned = play.tapAt(weight);
    if (identical(turned, play)) return;
    setState(() {
      play = turned;
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.worth.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.worth.name);
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
      play = Play.of(widget.worth);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the yard says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$2
          ? 'Choose the ${aim.$1} pound weight.'
          : 'Put the ${aim.$1} pound weight back.';
    }
    if (play.isDone) {
      return 'Weighed clean: every parcel its own reading.';
    }
    final clash = play.balanced;
    if (clash != null) {
      final (left, right) = clash;
      return '${left.join(' and ')} balance'
          '${left.length == 1 && right.length == 1 ? 's' : ''} '
          '${right.join(' and ')}: put something back.';
    }
    final left = play.worth.choose - play.chosen.length;
    return '${play.chosen.length} chosen, $left to go; the beam '
        'hangs empty.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.worth.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a weight to choose it or put it back: '
                  '${widget.worth.task}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, room) => GestureDetector(
                    onTapUp: (tap) => _tap(Metrics(
                      Size(room.maxWidth, room.maxHeight),
                    ).weightUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: BeamView(
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
                    side: const BorderSide(
                        color: Palette.weightChosen),
                    label: Text(
                      'chosen ${play.chosen.length} of '
                      '${play.worth.choose}',
                      style: const TextStyle(
                          color: Palette.weightChosen,
                          fontSize: 13),
                    ),
                  ),
                  if (play.balanced != null)
                    Chip(
                      backgroundColor: Palette.board,
                      side: const BorderSide(color: Palette.clash),
                      label: const Text(
                        'the beam is level',
                        style: TextStyle(
                            color: Palette.clash, fontSize: 13),
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
                  onYard: () => Navigator.of(context).pop(),
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
