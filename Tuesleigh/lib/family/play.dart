import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the tags dialled, the taps taken to wind them, and
/// the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.tags,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : tags = opening,
        moves = 0,
        before = null;

  /// A go standing at a tag count, no taps counted: what the mark draws.
  Play.standing(this.level, this.tags)
      : moves = 0,
        before = null;

  final Level level;

  /// How many tags a child may be born under.
  final int tags;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// Where every ask opens: two tags.
  static const opening = 2;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never winds to the dial's end.
  static const gaveUpAt = 15;

  /// The chance of two boys, by counting the families, the first voice.
  Frac get chance => Rules.chanceByCounting(tags);

  /// The chance by the form, the second voice.
  Frac get chanceByForm => Rules.chanceByForm(tags);

  /// The chance told which child is the tagged boy.
  Frac get chanceToldWhich => Rules.chanceToldWhich(tags);

  int get told => Rules.told(tags);
  int get bothBoys => Rules.bothBoys(tags);
  int get families => 4 * tags * tags;

  /// Winds the tags by [by], ten or one either way, stopping at the
  /// dial's ends; a wind that cannot move is not a tap.
  Play wind(int by) {
    if (isOver || by == 0) return this;
    final t = (tags + by).clamp(1, Rules.most);
    if (t == tags) return this;
    return Play._(level: level, tags: t, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(tags);

  /// A hopeless ask, admitted: the dial is at its end, as near a half as
  /// it comes, or [gaveUpAt] taps are gone.
  bool get gaveUp => !level.winnable && (tags == Rules.most || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: the wind to take, ten or one either way,
  /// towards the aim; null when there is nothing to point at.
  int? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final gap = aim - tags;
    if (gap == 0) return null;
    if (gap.abs() >= 10) return gap.sign * 10;
    return gap.sign;
  }

  /// The pointer's words.
  static String pointed(int by) => 'Wind ${by > 0 ? 'up' : 'down'} by ${by.abs()}.';
}

/// Why a Tuesday changes the odds: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A family has two children. Told that one of them is a boy, the '
      'chance that both are boys is not a half but a third: boy-boy, '
      'boy-girl and girl-boy are three families alike with a boy in them, '
      'and one has two. Told that one of them is a boy born on a Tuesday, the '
      'chance is 13 in 27: with seven days each child is one of fourteen '
      'kinds, 196 families alike, twenty-seven have a Tuesday boy, and '
      'thirteen of those are two boys, since two boys are two chances of a '
      'Tuesday. With k tags in place of the seven days the chance is 2k - 1 '
      'in 4k - 1, always a half less one part in twice 4k - 1, and never a '
      'half; told which child is the tagged boy, it is exactly a half.\n\n'
      'The game counts every family out for every tag count from one to '
      '${Rules.most}, 4k squared families each, and sets the count against '
      'the form 2k - 1 in 4k - 1; the two agree on all ${Rules.settings}, and '
      'the count told which child comes to a half every time.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every tag count on the dial, its '
      'families counted out in full.';
}
