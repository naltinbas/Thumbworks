import 'dart:io';

import 'package:tussockmere/mere/fields.dart';
import 'package:tussockmere/mere/play.dart';
import 'package:tussockmere/mere/rules.dart';

/// Reads every filling of both marshes, solves the game to its end,
/// and refuses the bake on any disagreement: this is what
/// `make fields` runs, and the README quotes its ledger verbatim.
void main() {
  // Every filled marsh carries exactly one crossing.
  for (final size in const [3, 4]) {
    if (!Rules(size).everyFillingCarriesOne()) {
      stderr.writeln('A FILLING BROKE THE CROSSING on $size');
      exit(1);
    }
  }

  // The solves, and the opening books.
  final three = Rules(3);
  final four = Rules(4);
  if (three.winner(List.filled(9, 0), 1) != 1 ||
      four.winner(List.filled(16, 0), 1) != 1) {
    stderr.writeln('THE FIRST CHAIR LOST A SOLVE');
    exit(1);
  }
  final threeBook = three.strongOpenings();
  final fourBook = four.strongOpenings();
  if ('$threeBook' != '[1, 2, 4, 6, 7]' ||
      '$fourBook' != '[3, 6, 9, 12]') {
    stderr.writeln('AN OPENING BOOK CHANGED: '
        '$threeBook and $fourBook');
    exit(1);
  }
  // The four-field book is the short diagonal itself.
  for (final at in fourBook) {
    if (at ~/ 4 + at % 4 != 3) {
      stderr.writeln('A STRONG OPENING OFF THE SHORT DIAGONAL');
      exit(1);
    }
  }

  // The pie verdicts, walked through the play itself.
  final pie = Play.of(Fields.at(2));
  if (pie.next != 'take' ||
      pie.takePie().standing != 1 ||
      pie.declinePie().standing != 2) {
    stderr.writeln('THE PIE JUDGED WRONG');
    exit(1);
  }
  final humble = Play.of(Fields.at(3));
  if (humble.next != 'decline' ||
      humble.declinePie().standing != 1 ||
      humble.takePie().standing != 2) {
    stderr.writeln('THE HUMBLE PIE JUDGED WRONG');
    exit(1);
  }
  final chair = Play.of(Fields.at(4));
  if (chair.standing != 2 || chair.next != null) {
    stderr.writeln('THE SECOND CHAIR FOUND A WAY');
    exit(1);
  }

  stdout.writeln(
      'every filled marsh carries exactly one crossing, never both '
      'and never neither, all 512 fillings of the three-field and '
      '65,536 of the four swept; the game is solved to its end, '
      'the first chair winning both marshes, and only the short '
      'diagonal of the four-field survives a perfect reply');
  stdout.writeln('');

  for (var number = 0; number < Fields.count; number++) {
    final field = Fields.at(number);
    final play = Play.of(field);

    if (field.winnable) {
      final way = play.next;
      if (way == null) {
        stderr.writeln('${field.name}: no way after all');
        exit(1);
      }
    } else if (play.next != null) {
      stderr.writeln('${field.name}: a way stood');
      exit(1);
    }

    final name = field.name.padRight(17);
    stdout.writeln(field.winnable
        ? ' ${number + 1} $name ${field.size} by ${field.size}  '
            '${field.task}: right play links the banks'
        : ' ${number + 1} $name ${field.size} by ${field.size}  '
            '${field.task}: every line of yours loses');
  }
}
