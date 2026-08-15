import 'package:flutter/material.dart';

import '../best.dart';
import '../wedge/levels.dart';
import 'mark.dart';
import 'palette.dart';
import 'wedge_screen.dart';

/// The sham, ask by ask.
class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  @override
  void initState() {
    super.initState();
    Best.ready().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.night,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const SizedBox(height: 185, child: Mark()),
              const Text(
                'Wedgeworth',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Text(
                  'The five regular solids, corner by corner: faces round a '
                  'point close only when their angles come under a full turn, '
                  'and Euler\'s count of corners, edges and faces agrees on '
                  'exactly the five.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: Levels.count,
                  itemBuilder: (context, number) {
                    final level = Levels.at(number);
                    final fewest = Best.fewest(level.name);
                    return ListTile(
                      leading: Text(
                        '${number + 1}',
                        style: const TextStyle(
                            color: Palette.inkDim, fontSize: 18),
                      ),
                      title: Text(
                        level.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${level.task[0].toUpperCase()}${level.task.substring(1)}'
                        '${fewest == null ? '' : '. Fewest: $fewest'}',
                        style: const TextStyle(
                            color: Palette.inkDim, fontSize: 13),
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                WedgeScreen(level: level),
                          ),
                        );
                        if (mounted) setState(() {});
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
