import 'frac.dart';
import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: the first two gaps on their dials, the third what
/// is left of the hour, the taps taken, and the go before, so a tap can
/// be taken back.
class Play {
  const Play._({
    required this.level,
    required this.first,
    required this.second,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : first = 10,
        second = 20,
        moves = 0,
        before = null;

  /// A go standing at a timetable, no taps counted: what the mark draws.
  Play.standing(this.level, this.first, this.second)
      : moves = 0,
        before = null;

  final Level level;

  /// The first two gaps.
  final int first, second;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The taps a hopeless ask runs to before the sham admits it, if the
  /// player never reaches the fair timetable.
  static const gaveUpAt = 24;

  int get third => Rules.hour - first - second;

  List<int> get gaps => [first, second, third];

  Frac get wait => Rules.waitByGaps(gaps);

  /// The wait by the minutes, the second voice.
  Frac get waitByMinutes => Rules.waitByMinutes(gaps);

  /// How far the wait stands over the fair.
  Frac get over => wait - Rules.fairWait;

  int get longest => Rules.longest(gaps);

  /// Steps [which], 'g1' or 'g2', by [by], if the hour still holds three
  /// gaps of a minute or more.
  Play step(String which, int by) {
    if (isOver) return this;
    final a = which == 'g1' ? first + by : first, b = which == 'g2' ? second + by : second;
    if (!Rules.valid([a, b, Rules.hour - a - b])) return this;
    return Play._(level: level, first: a, second: b, moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(gaps);

  /// A hopeless ask, admitted: the fair timetable reached, as low as the
  /// wait goes, or [gaveUpAt] taps gone.
  bool get gaveUp => !level.winnable && (wait == Rules.fairWait || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: ('g1' or 'g2', by), the first gap towards
  /// the aim's while it can move, then the second; null when there is
  /// nothing to point at.
  (String, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    if (first != aim[0]) {
      final by = aim[0] > first ? 1 : -1;
      if (Rules.valid([first + by, second, Rules.hour - first - by - second])) return ('g1', by);
    }
    if (second != aim[1]) {
      final by = aim[1] > second ? 1 : -1;
      if (Rules.valid([first, second + by, Rules.hour - first - second - by])) return ('g2', by);
    }
    return null;
  }

  /// The pointer's words.
  static String pointed((String, int) aim) => 'Step the ${aim.$1 == 'g1' ? 'first' : 'second'} gap ${aim.$2 > 0 ? 'up' : 'down'}.';
}

/// Why the wait is never under the fair: the words behind the Why
/// button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Three buses an hour, and the gaps between them add to sixty '
      'minutes. A passenger comes to the stop at any minute of the hour, each '
      'as likely, and waits for the next bus. With the gaps equal, twenty '
      'apiece, the average wait is 9 1/2 minutes, half a gap less half a '
      'minute; bunch the buses and it grows, up to 27 11/20 with two buses a '
      'minute apart, though the buses are three an hour still, since a wide '
      'gap catches more passengers and keeps each of them longer. Feller set '
      'the paradox down in 1966. It never runs the other way: the waiting in '
      'an hour adds up gap by gap to half of each gap squared less half the '
      'gap, and the average of squares is never below the square of the '
      'average, so three gaps adding to sixty square to 1,200 at least and '
      'the waiting comes to 570 minutes at least, equal gaps alone touching '
      'it.\n\n'
      'The game takes every timetable, 1,711, and finds the average wait '
      'twice, once gap by gap from the sum of each gap\'s waits and once '
      'minute by minute, the wait at every minute of the hour averaged; the '
      'two agree on all 1,711, and none is under 9 1/2.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every timetable of three buses, '
      'waited out in full.';
}
