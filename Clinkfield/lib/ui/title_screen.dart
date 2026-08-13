import 'package:flutter/material.dart';

import '../best.dart';
import '../clink/feasts.dart';
import 'clink_screen.dart';
import 'mark.dart';
import 'palette.dart';

/// The field, feast by feast.
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
              const SizedBox(height: 175, child: Mark()),
              const Text(
                'Clinkfield',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Text(
                  'Clink round the feast: two guests always '
                  'count alike.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Palette.inkDim, fontSize: 14),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: Feasts.count,
                  itemBuilder: (context, number) {
                    final feast = Feasts.at(number);
                    final fewest = Best.fewest(feast.name);
                    return ListTile(
                      leading: Text(
                        '${number + 1}',
                        style: const TextStyle(
                            color: Palette.inkDim, fontSize: 18),
                      ),
                      title: Text(
                        feast.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${feast.task[0].toUpperCase()}${feast.task.substring(1)}'
                        '${fewest == null ? '' : '. Fewest: $fewest'}',
                        style: const TextStyle(
                            color: Palette.inkDim, fontSize: 13),
                      ),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ClinkScreen(feast: feast),
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
