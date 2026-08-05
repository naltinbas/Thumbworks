import 'package:flutter/material.dart';

import '../best.dart';
import '../churn/dairies.dart';
import '../churn/fewest.dart';
import 'mark.dart';
import 'palette.dart';

/// The way in: pick a morning.
class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key, required this.best, required this.onPlay});

  final Best? best;
  final ValueChanged<int> onPlay;

  @override
  Widget build(BuildContext context) {
    final done = best?.done ?? 0;

    return Scaffold(
      backgroundColor: Palette.night,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            children: [
              const SizedBox(width: 104, height: 104, child: Mark()),
              const SizedBox(height: 20),
              const Text(
                'Churnwick',
                style: TextStyle(
                  color: Palette.ink,
                  fontSize: 36,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Measure an exact churn of milk out of churns that are all the '
                'wrong sizes. There is nothing to measure with but the churns.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.inkDim,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              const _Note(),
              const SizedBox(height: 20),
              for (var i = 0; i < Mornings.count; i++) ...[
                _Pick(
                  number: i,
                  morning: Mornings.at(i),
                  goes: best?.goesFor(Mornings.at(i).name),
                  onPlay: () => onPlay(i),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 4),
              Text(
                done == 0
                    ? '${Mornings.count} mornings'
                    : '$done of ${Mornings.count} measured',
                style: const TextStyle(color: Palette.inkDim, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The one thing worth saying about the game before somebody plays it.
class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Palette.verge,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.line, width: 1.1),
        ),
        child: const Column(
          children: [
            Text(
              'Some amounts cannot be measured at all',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.ink,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Filling puts a churnful in, emptying takes a churnful out, and '
              'pouring moves milk from one to another without losing any. So '
              'whatever stands in a churn is a whole number of churnfuls '
              'added and taken away, and out of a six and a ten nothing odd '
              'can ever stand anywhere. Why says which amounts a dairy can '
              'reach.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Palette.inkDim,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
}

class _Pick extends StatelessWidget {
  const _Pick({
    required this.number,
    required this.morning,
    required this.goes,
    required this.onPlay,
  });

  final int number;
  final Morning morning;

  /// The fewest goes this morning has been measured out in, or null.
  final int? goes;

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final done = goes != null;
    final tight = goes == morning.fewest;
    final dairy = morning.dairy;
    final step = Pouring.stepOf(dairy.churns);

    return Semantics(
      button: true,
      label: '${morning.name}, ${dairy.want} gallons',
      child: GestureDetector(
        onTap: onPlay,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Palette.verge,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: done ? Palette.good : Palette.line,
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 26,
                child: Text(
                  '${number + 1}',
                  style: const TextStyle(
                    color: Palette.inkDim,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      morning.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Palette.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${dairy.churns.join(' and ')} · '
                      '${dairy.want} wanted'
                      '${step > 1 ? ' · nothing but ${step}s' : ''}',
                      style: const TextStyle(
                        color: Palette.inkDim,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    done ? '$goes' : '${morning.fewest}',
                    style: TextStyle(
                      color: tight
                          ? Palette.good
                          : done
                              ? Palette.ink
                              : Palette.inkDim,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    done ? 'goes' : 'to beat',
                    style: const TextStyle(
                      color: Palette.inkDim,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
