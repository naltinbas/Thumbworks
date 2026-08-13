import 'package:flutter/material.dart';

import '../best.dart';
import '../window/houses.dart';
import 'mark.dart';
import 'palette.dart';
import 'window_screen.dart';

/// The worth, house by house.
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
              const SizedBox(height: 200, child: Mark()),
              const Text(
                'Foursworth',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Text(
                  'Dial the windows and take the differences: '
                  'four always go dark, three circle for ever.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: Houses.count,
                  itemBuilder: (context, number) {
                    final house = Houses.at(number);
                    final fewest = Best.fewest(house.name);
                    return ListTile(
                      leading: Text(
                        '${number + 1}',
                        style: const TextStyle(
                            color: Palette.inkDim, fontSize: 18),
                      ),
                      title: Text(
                        house.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${house.task[0].toUpperCase()}${house.task.substring(1)}'
                        '${fewest == null ? '' : '. Fewest: $fewest'}',
                        style: const TextStyle(
                            color: Palette.inkDim, fontSize: 13),
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                WindowScreen(house: house),
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
