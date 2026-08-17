import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: where the bounce sits, the slides made, and the go
/// before, so a slide can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.bounce,
    required this.slides,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : bounce = Level.opening,
        slides = 0,
        seen = const {},
        before = null;

  /// A go with the bounce set and no slides counted: what the mark
  /// draws.
  const Play.at(this.level, this.bounce)
      : slides = 0,
        seen = const {},
        before = null;

  final Level level;

  /// The peg of the mirror the light strikes.
  final int bounce;

  final int slides;

  /// The bounces tried on a hopeless ask.
  final Set<int> seen;

  final Play? before;

  /// The slides a hopeless ask runs to before the mirror admits it.
  static const gaveUpAt = 16;

  /// The bounces a hopeless ask lets the player try before the mirror
  /// admits it.
  static const enough = 7;

  /// The two squared legs of the path as it stands.
  (int, int) get legs =>
      Rules.legs(Level.lampX, Level.lampY, Level.eyeX, Level.eyeY, bounce);

  /// The whole number of paces the path comes to, or null when it is not
  /// a whole number.
  int? get paces {
    final (one, two) = legs;
    return Rules.paces(one, two);
  }

  /// Whether the angle the light comes in at matches the angle it leaves
  /// at.
  bool get even => Rules.anglesMatch(
      Level.lampX, Level.lampY, Level.eyeX, Level.eyeY, bounce);

  /// Whether the path is exactly the straight run to the folded eye,
  /// which is the same question asked without any angles.
  bool get straight {
    final (one, two) = legs;
    return Rules.equals(one, two, Level.folded);
  }

  /// Slides the bounce one peg towards [towards].
  Play slide(int towards) {
    if (isOver) return this;
    if (towards == bounce) return this;
    final to = towards > bounce ? bounce + 1 : bounce - 1;
    if (to < 0 || to >= Rules.mirror) return this;
    return Play._(
      level: level,
      bounce: to,
      slides: slides + 1,
      seen: !level.winnable ? {...seen, to} : seen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(bounce);

  /// A hopeless ask, admitted: [enough] bounces tried, or [gaveUpAt]
  /// slides.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || slides >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The nearest peg that lands the ask, and the slides to it.
  (int, int)? get nearest {
    int? best;
    var away = -1;
    for (final p in Rules.bounces) {
      if (!level.meets(p)) continue;
      final n = (p - bounce).abs();
      if (away < 0 || n < away) {
        away = n;
        best = p;
      }
    }
    return best == null ? null : (best, away);
  }

  /// What the pointer says: the peg to slide towards. Null when there is
  /// nothing to point at.
  int? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    return near.$1;
  }

  /// The pointer's words.
  String pointed(int aim) => aim > bounce
      ? 'Slide the bounce right, towards peg $aim.'
      : 'Slide the bounce left, towards peg $aim.';
}

/// Why the light goes the way it does: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'A mirror runs along the bottom of the board with a peg every '
      'pace, the lamp stands at ${Level.lampX} across and ${Level.lampY} '
      'up, and the eye at ${Level.eyeX} across and ${Level.eyeY} up. The '
      'light leaves the lamp, strikes the mirror at the bounce, and goes '
      'on to the eye. Sliding the bounce is the whole of the game.\n\n'
      'The path is two slanted legs, so its length is a root added to a '
      'root and almost never a whole number. Nothing here works one out. '
      'To ask whether a path comes within so many paces the board squares '
      'both sides, which leaves twice a root against a whole number, then '
      'squares again, and the question has become whole numbers only.\n\n'
      'Now fold the board along the mirror. The eye goes down to where '
      'its reflection would be, and the two legs of the path straighten '
      'into one bent path from the lamp to that folded eye. Every bounce '
      'gives such a path, and no bent path is shorter than the straight '
      'one. So the shortest path there can be is the straight run to the '
      'folded eye, which here is 8 down and 6 across, a run of '
      '${Level.least} paces exactly. It is reached at one bounce and no '
      'other.\n\n'
      'At that bounce the angle the light comes in at matches the angle '
      'it leaves at. Hero of Alexandria set this down in his Catoptrics: '
      'light takes the shortest way, and the shortest way off a mirror is '
      'the one with matching angles. The board settles it twice over, '
      'once by pacing and once by folding. The pacing asks whether the '
      'two legs added come to the straight run, in whole numbers. The '
      'folding asks whether the two angles match, by crossing a run with '
      'a rise, and never measures a length at all. On every one of the '
      '54,925 settings of lamp, eye and bounce the two agree, and on '
      'every one of them the path is at least the straight run.\n\n'
      'This is ask $number, ${level.name}. ${level.note}';
}
