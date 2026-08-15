import 'package:flutter/material.dart';

import '../best.dart';
import '../mere/lighting.dart';
import '../mere/play.dart';
import '../mere/rules.dart';
import 'mereview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One lighting, set lantern by lantern.
class MereScreen extends StatefulWidget {
  const MereScreen({super.key, required this.lighting});

  final Lighting lighting;

  @override
  State<MereScreen> createState() => MereScreenState();
}

class MereScreenState extends State<MereScreen> {
  late Play play;

  /// What the show-me points at, or null.
  (String, Spot)? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.lighting);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.lighting.name));
      }
    });
  }

  void _tap(Spot? spot) {
    if (spot == null || play.isOver) return;
    setState(() {
      play = play.tap(spot);
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.lighting.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.lighting.name);
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
      play = Play.of(widget.lighting);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the sham says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      return aim.$1 == 'douse'
          ? 'Douse the ringed lantern: it is off the picture.'
          : 'Light the ringed spot.';
    }
    if (play.isDone) {
      return 'Still: nothing lights and nothing goes out.';
    }
    if (play.lit.isEmpty) {
      return 'Nothing lit yet; ${play.lighting.count} lanterns asked.';
    }
    final b = play.births.length, d = play.deaths.length;
    if (b == 0 && d == 0) {
      return 'Still as it stands, ${play.lit.length} of ${play.lighting.count} lit.';
    }
    return 'Next turn $b spot${b == 1 ? '' : 's'} light${b == 1 ? 's' : ''} '
        'and $d lantern${d == 1 ? '' : 's'} go${d == 1 ? 'es' : ''} out.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.lighting.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Tap a spot to light or douse a lantern; the rings and '
                  'crosses show the next turn: ${widget.lighting.task}.',
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
                      painter: MereView(
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
                      'lit ${play.lit.length} of ${widget.lighting.count}',
                      style: const TextStyle(
                          color: Palette.ink, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.births.isEmpty ? Palette.line : Palette.willLight),
                    label: Text(
                      'will light ${play.births.length}',
                      style: const TextStyle(
                          color: Palette.inkDim, fontSize: 13),
                    ),
                  ),
                  Chip(
                    backgroundColor: Palette.board,
                    side: BorderSide(
                        color: play.deaths.isEmpty ? Palette.line : Palette.bad),
                    label: Text(
                      'will go out ${play.deaths.length}',
                      style: TextStyle(
                          color: play.deaths.isEmpty ? Palette.inkDim : Palette.bad,
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
