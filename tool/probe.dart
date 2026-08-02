// ignore_for_file: avoid_print
import 'package:chalkway/sim/levels.dart';

void main() {
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final answer = level.answer;
    final played = level.worldWith(answer).played;
    final bare = level.worldWith(answer.cleared).played;
    print('${i + 1} ${level.name.padRight(15)} '
        'answer=${played.ending.name.padRight(8)} '
        '${played.seconds.toStringAsFixed(1)}s  '
        'chalk ${answer.used.toStringAsFixed(1)}/${level.ink.toStringAsFixed(0)}  '
        'bare=${bare.ending.name}');
  }
}
