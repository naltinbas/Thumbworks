import 'package:flutter/material.dart';

import '../best.dart';
import '../stack/boxset.dart';
import '../stack/play.dart';
import 'palette.dart';
import 'result_card.dart';
import 'stackview.dart';

/// One stack, turned box by box.
class StackScreen extends StatefulWidget {
  const StackScreen({super.key, required this.set});

  final BoxSet set;

  @override
  State<StackScreen> createState() => StackScreenState();
}

class StackScreenState extends State<StackScreen> {
  late Play play;

  /// The box the show-me points at, with its wanted walls.
  (int, (String, String, String, String))? pointing;

  int? fewest;
  bool isRecord = false;
  bool _counted = false;

  @override
  void initState() {
    super.initState();
    play = Play.of(widget.set);
    Best.ready().then((_) {
      if (mounted) {
        setState(() => fewest = Best.fewest(widget.set.name));
      }
    });
  }

  void _turn(Play turned) {
    if (play.isOver) return;
    setState(() {
      play = turned;
      pointing = null;
    });
    if (play.isDone && !_counted) {
      _counted = true;
      Best.landed(widget.set.name, play.moves).then((record) {
        if (mounted) {
          setState(() {
            isRecord = record;
            fewest = Best.fewest(widget.set.name);
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
      play = Play.of(widget.set);
      pointing = null;
      _counted = false;
      isRecord = false;
    });
  }

  /// What the stack says of itself, as it stands.
  String verdict() {
    final aim = pointing;
    if (aim != null) {
      final (box, wants) = aim;
      return 'Box ${box + 1} wants '
          '${Palette.paintNames[wants.$1]} forward, '
          '${Palette.paintNames[wants.$2]} to the right.';
    }
    if (play.isDone) {
      return 'Settled: every wall shows every paint once.';
    }
    final wrong = play.clashes.map((c) => c.$1).toSet().length;
    if (wrong > 0) {
      return '$wrong wall${wrong == 1 ? '' : 's'} still '
          'double${wrong == 1 ? 's' : ''} a paint.';
    }
    return 'No wall doubles yet; keep turning.';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        appBar: AppBar(
          backgroundColor: Palette.night,
          foregroundColor: Palette.ink,
          title: Text(widget.set.name),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Spin turns a box\'s walls; tip stands it on '
                  'another sleeve. '
                  '${widget.set.task[0].toUpperCase()}'
                  '${widget.set.task.substring(1)}.',
                  style: const TextStyle(
                      color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CustomPaint(
                        painter: StackView(
                          play: play,
                          pointing: pointing?.$1,
                          labels:
                              const TextStyle(fontFamily: 'Roboto'),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var box = 0;
                                box < widget.set.count;
                                box++)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4),
                                child: Column(
                                  children: [
                                    OutlinedButton(
                                      onPressed: play.isOver
                                          ? null
                                          : () => _turn(
                                              play.spinAt(box)),
                                      style:
                                          OutlinedButton.styleFrom(
                                        minimumSize:
                                            const Size(72, 30),
                                        padding: EdgeInsets.zero,
                                        visualDensity:
                                            VisualDensity.compact,
                                      ),
                                      child: Text('Spin ${box + 1}'),
                                    ),
                                    const SizedBox(height: 2),
                                    OutlinedButton(
                                      onPressed: play.isOver
                                          ? null
                                          : () =>
                                              _turn(play.tipAt(box)),
                                      style:
                                          OutlinedButton.styleFrom(
                                        minimumSize:
                                            const Size(72, 30),
                                        padding: EdgeInsets.zero,
                                        visualDensity:
                                            VisualDensity.compact,
                                      ),
                                      child: Text('Tip ${box + 1}'),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
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
                  onHolt: () => Navigator.of(context).pop(),
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
