import 'play.dart';
import 'reason.dart';

/// Says what a step means, in words.
///
/// The point of a hint here is not to be told where to click. It is to be
/// shown the sentence you could have said yourself — so it always names the
/// numbers it read and what it read off them.
String saying(Play play, Finding step) {
  final field = play.field;
  String number(int at) => '${field.countAt(at)}';

  switch (step.rule) {
    case Rule.counted:
      final clue = step.clue;
      final count = field.countAt(clue);
      if (step.safe.isNotEmpty) {
        return '${_many(count)} round this ${number(clue)} '
            '${count == 1 ? 'has' : 'have'} been found already, so the rest '
            'of its neighbours are clear.';
      }
      return 'This ${number(clue)} has ${step.mined.length} '
          '${step.mined.length == 1 ? 'square' : 'squares'} left and '
          '${step.mined.length} still to find. They are all mines.';

    case Rule.subset:
      final big = number(step.clue);
      final small = number(step.other);
      if (step.safe.isNotEmpty) {
        return 'Everything the $small can see, this $big can see too — and '
            'between them they want the same number of mines. So the squares '
            'only the $big can see are clear.';
      }
      return 'This $big wants ${step.mined.length} more than the $small does, '
          'and there are exactly ${step.mined.length} squares it can see that '
          'the $small cannot. Those are the mines.';

    case Rule.whole:
      if (step.clue == -1 && step.safe.isNotEmpty) {
        return 'List every way the mines could lie along the numbers, and '
            'none of them leaves a square ${step.safe.length == 1 ? 'here' : 'in these'} '
            'holding one.';
      }
      return 'List every way the mines could lie along the numbers. '
          '${step.mined.isNotEmpty ? 'These hold one in all of them.' : 'None of them puts one here.'}';
  }
}

String _many(int count) => switch (count) {
      1 => 'The one mine',
      2 => 'Both mines',
      _ => 'All $count mines',
    };
