import 'package:flutter/material.dart';

import '../best.dart';
import '../drive/fields.dart';
import 'mark.dart';
import 'palette.dart';

/// The front of the game: the mark, and the fields to choose from.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Palette.moor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              const Center(
                child: SizedBox(width: 132, height: 132, child: Mark()),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pinderwell',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 34),
                child: Text(
                  'Drive the stray ewe to the pen. The last push takes the '
                  'fee.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Palette.inkDim,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 18),
                  itemCount: Fields.count,
                  separatorBuilder: (context, gap) => const SizedBox(height: 9),
                  itemBuilder: (context, number) => _FieldRow(
                    number: number,
                    pushes: best?.pushesFor(Fields.at(number).name),
                    onPlay: () => onPlay(number),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.number,
    required this.pushes,
    required this.onPlay,
  });

  final int number;

  /// The fewest pushes this field's fee has been won on, or null.
  final int? pushes;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final field = Fields.at(number);
    final won = pushes;
    final atPar = won != null && won <= (field.fewest ?? 0);

    return Semantics(
      button: true,
      label: '${field.name}, the ewe ${field.east} east ${field.north} north',
      child: GestureDetector(
        onTap: onPlay,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
            decoration: BoxDecoration(
              color: Palette.byre,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: atPar ? Palette.good : Palette.line,
                width: 1.1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.name,
                        style: const TextStyle(
                          color: Palette.ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        field.hopeless
                            ? 'she starts on a rung: the pinder cannot be '
                                'beaten'
                            : 'the ewe ${field.east} east, ${field.north} '
                                'north, the fee in ${field.fewest}',
                        style: TextStyle(
                          color: field.hopeless
                              ? Palette.pinder
                              : Palette.inkDim,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (won != null)
                  Text(
                    'won on $won',
                    style: TextStyle(
                      color: atPar ? Palette.good : Palette.inkDim,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: Palette.inkDim,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
