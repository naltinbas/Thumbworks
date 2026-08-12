import 'package:flutter/material.dart';

import '../best.dart';
import '../mill/grind.dart';
import '../mill/play.dart';
import 'millview.dart';
import 'palette.dart';
import 'result_card.dart';

/// One grind, wound turn by turn.
class MillScreen extends StatefulWidget {
  const MillScreen({super.key, required this.grind});

  final Grind grind;

  @override
  State<MillScreen> createState() => MillScreenState();
}

class MillScreenState extends State<MillScreen> {
  late Play play;

  /// The winding the show-me points at, or null.
  int? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.grind);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.grind.name));
      }
    });
  }

  void _wind(int by) {
    final turned = play.windBy(by);
    if (identical(turned, play)) return;
    setState(() {
      play = turned;
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.grind.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.grind.name);
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
      play = Play.of(widget.grind);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the mill says of itself, as it stands.
  String verdict() {
    if (pointing != null) {
      return 'Wind the mill to $pointing.';
    }
    if (play.isDone) {
      return 'Ground: ${play.noughts} '
          'nought${play.noughts == 1 ? '' : 's'}, as asked.';
    }
    return '${play.wound} factorial ends in ${play.noughts} '
        'nought${play.noughts == 1 ? '' : 's'}; '
        '${play.grind.asked} asked.';
  }

  Widget _winder(String label, int by) => OutlinedButton(
        onPressed: play.isOver ? null : () => _wind(by),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
        ),
        child: Text(label),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.grind.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${widget.grind.task[0].toUpperCase()}'
                  '${widget.grind.task.substring(1)}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: CustomPaint(
                  painter: MillView(
                    play: play,
                    pointing: pointing,
                    labels: const TextStyle(fontFamily: 'Roboto'),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _winder('-10', -10),
                  const SizedBox(width: 6),
                  _winder('-1', -1),
                  const SizedBox(width: 18),
                  _winder('+1', 1),
                  const SizedBox(width: 6),
                  _winder('+10', 10),
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
                  onMill: () => Navigator.of(context).pop(),
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
