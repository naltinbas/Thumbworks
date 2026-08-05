// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:handfast/hire/fair.dart';
import 'package:handfast/hire/most.dart';

/// Makes fairs up and keeps the ones worth playing.
///
/// A fair is worth keeping when working down the board and giving each job to
/// the first free hand who can take it on comes out short of the most, so the
/// day is about thinking rather than about being tidy. The shortfall it is
/// asked for decides how many jobs go undone whatever anybody does.
///
///   dart run tool/find_fairs.dart [jobs] [hands] [how many] [undone]
///                                 [density] [smallest shortfall]
void main(List<String> args) {
  final jobs = args.isNotEmpty ? int.parse(args[0]) : 7;
  final people = args.length > 1 ? int.parse(args[1]) : 7;
  final wanted = args.length > 2 ? int.parse(args[2]) : 3;
  final undone = args.length > 3 ? int.parse(args[3]) : 1;
  final density = args.length > 4 ? int.parse(args[4]) : 30;
  final leanest = args.length > 5 ? int.parse(args[5]) : 2;

  final random = Random(20260807);
  var kept = 0;
  var tried = 0;

  while (kept < wanted && tried < 300000) {
    tried++;
    final whoCan = [
      for (var job = 0; job < jobs; job++)
        <int>{
          for (var hand = 0; hand < people; hand++)
            if (random.nextInt(100) < density) hand,
        },
    ];
    if (whoCan.any((can) => can.isEmpty)) continue;
    // Every hand has to be worth standing there.
    final used = whoCan.expand((can) => can).toSet();
    if (used.length != people) continue;

    final fair = Fair(
      name: 'try',
      work: [for (var job = 0; job < jobs; job++) 'W$job'],
      hands: [for (var hand = 0; hand < people; hand++) 'H$hand'],
      whoCan: whoCan,
    );

    final hiring = Hirings.most(fair);
    if (hiring.undone != undone) continue;
    if (hiring.short.length < leanest) continue;
    if (whoCan.any((can) => can.length < 2) && leanest > 2) continue;
    final down = Hirings.byWorkingDown(fair).where((h) => h >= 0).length;
    if (down >= hiring.most) continue;

    kept++;
    print('');
    print('$kept  most ${hiring.most} of $jobs  '
        'working down gets $down  '
        'short ${hiring.short} have only ${hiring.onlyThese}  '
        '${fair.marks} crosses');
    for (final can in whoCan) {
      print('    {${(can.toList()..sort()).join(', ')}},');
    }
  }

  print('');
  print('$kept kept out of $tried tried');
}
