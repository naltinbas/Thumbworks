import 'package:flutter/material.dart';

import '../best.dart';
import '../hill/hill.dart';
import '../hill/play.dart';
import 'hillview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One hill, planted spot by spot.
class HillScreen extends StatefulWidget {
  const HillScreen({super.key, required this.hill});

  final Hill hill;

  @override
  State<HillScreen> createState() => HillScreenState();
}

class HillScreenState extends State<HillScreen> {
  late Play play;

  /// The spot the show-me points at, with the plant it wants.
  ((int, int), String)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.hill);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.hill.name));
      }
    });
  }

  void _tap((int, int)? spot) {
    if (spot == null || play.isOver) return;
    final turned = play.tapAt(spot);
    if (identical(turned, play)) return;
    setState(() {
      play = turned;
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.hill.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.hill.name);
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
      play = Play.of(widget.hill);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the hill says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return 'Plant the ringed spot with '
          '${Palette.plantNames[aim.$2]}.';
    }
    if (play.isDone) {
      return 'Planted: ${play.patches}, as asked.';
    }
    return '${play.patches} '
        'patch${play.patches == 1 ? '' : 'es'} show'
        '${play.patches == 1 ? 's' : ''}; '
        '${play.hill.asked} asked.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.hill.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a spot to swap its plant: '
                  '${widget.hill.task}.',
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
                    ).spotUnder(tap.localPosition)),
                    child: CustomPaint(
                      painter: HillView(
                        play: play,
                        pointing: pointing?.$1,
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
                  for (final plant in const ['A', 'B', 'C'])
                    Chip(
                      backgroundColor: Palette.board,
                      side: BorderSide(
                          color: Palette.plants[plant]!),
                      label: Text(
                        Palette.plantNames[plant]!,
                        style: TextStyle(
                            color: Palette.plants[plant],
                            fontSize: 13),
                      ),
                    ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: const BorderSide(color: Palette.patch),
                    label: Text(
                      'patches ${play.patches}',
                      style: const TextStyle(
                          color: Palette.patch, fontSize: 13),
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
                  onSide: () => Navigator.of(context).pop(),
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
