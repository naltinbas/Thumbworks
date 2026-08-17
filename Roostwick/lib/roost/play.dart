import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: where the birds are sitting, the taps so far, and
/// the go before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.pick,
    required this.taps,
    required this.seen,
    required this.before,
  });

  Play.of(this.level)
      : pick = Rules.opening,
        taps = 0,
        seen = const {},
        before = null;

  /// A go sitting at a seating, no taps counted: what the mark draws.
  const Play.sitting(this.level, this.pick)
      : taps = 0,
        seen = const {},
        before = null;

  final Level level;

  /// Which end of its tether each bird is at, a bit apiece.
  final int pick;

  final int taps;

  /// The seatings tried on a hopeless ask.
  final Set<int> seen;

  final Play? before;

  /// The taps a hopeless ask runs to before the wood admits it.
  static const gaveUpAt = 24;

  /// The seatings a hopeless ask lets the player try before the wood
  /// admits it.
  static const enough = 8;

  List<(int, int)> get birds => level.birds;

  /// Where each bird is sitting.
  List<int> get at => Rules.seats(birds, pick);

  /// The birds in each hollow, hollow by hollow.
  List<List<int>> get crowds => Rules.crowds(birds, pick);

  /// The hollows holding more than one bird.
  List<int> get crowded => [
        for (var h = 0; h < Rules.hollows; h++)
          if (crowds[h].length > 1) h,
      ];

  /// The hollow bird [i] would fly to.
  int across(int i) => Rules.across(birds, pick, i);

  /// Sends a bird along its tether to its other hollow.
  Play tap(int bird) {
    if (isOver || bird < 0 || bird >= birds.length) return this;
    final to = pick ^ (1 << bird);
    return Play._(
      level: level,
      pick: to,
      taps: taps + 1,
      seen: !level.winnable ? {...seen, to} : seen,
      before: this,
    );
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(pick);

  /// A hopeless ask, admitted: [enough] seatings tried, or [gaveUpAt]
  /// taps.
  bool get gaveUp =>
      !level.winnable && (seen.length >= enough || taps >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// The nearest seating that settles the wood, and the taps to it.
  (int, int)? get nearest => Rules.nearest(birds, pick);

  /// What the pointer says: the bird to tap. Null when there is nothing
  /// to point at.
  int? get next {
    if (isOver) return null;
    final near = nearest;
    if (near == null || near.$2 == 0) return null;
    // Every bird that is on the wrong end of its tether takes one tap
    // and shortens the walk by one, so the first will do.
    for (var i = 0; i < birds.length; i++) {
      if ((pick >> i) & 1 != (near.$1 >> i) & 1) return i;
    }
    return null;
  }

  /// The pointer's words.
  String pointed(int bird) =>
      'Tap bird ${bird + 1}, in hollow ${Rules.letter(at[bird])}. It flies '
      'across to ${Rules.letter(across(bird))}.';

  /// The set of hollows that holds more birds than it can seat, as a
  /// list of hollows. Empty when the wood settles.
  List<int> get overfull {
    final set = Rules.overfull(birds);
    if (set == null) return const [];
    return [
      for (var h = 0; h < Rules.hollows; h++)
        if (set >> h & 1 == 1) h,
    ];
  }

  /// The birds with both of their hollows inside [overfull], which are
  /// the ones that can never all be seated. Empty when the wood settles.
  List<int> get penned {
    final set = Rules.overfull(birds);
    if (set == null) return const [];
    return [
      for (var i = 0; i < birds.length; i++)
        if (set >> birds[i].$1 & 1 == 1 && set >> birds[i].$2 & 1 == 1) i,
    ];
  }
}

/// Why a wood settles or does not: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Every bird has two hollows and sits in one of them. Tap a bird '
      'and it flies to the other. The ask is always that no two birds '
      'end up in one hollow.\n\n'
      'Whether that can be done at all is settled by looking, and no '
      'seating has to be tried. Take any set of hollows and count the '
      'birds with both of their hollows inside it. If those birds ever '
      'outnumber the hollows, the wood cannot settle, because those '
      'birds can go nowhere else. If they never do, it always can. That '
      'is the whole rule, and it is an exact one rather than a rough '
      'guide.\n\n'
      'The easy way to read it is patch by patch. Follow the tethers and '
      'the hollows fall into patches. A patch with fewer birds than '
      'hollows settles, and the number of ways is the number of hollows '
      'it can leave empty. A patch with as many birds as hollows carries '
      'one ring, fills every hollow it touches, and settles two ways, '
      'the ring turning one way or the other. A patch with more birds '
      'than hollows settles no way at all. The wood\'s count is its '
      'patches multiplied together.\n\n'
      'Two hollows to an item is how cuckoo hashing works, which Pagh '
      'and Rodler published in 2001, and drawing the items as tethers '
      'between their two hollows gives the cuckoo graph. The rule above '
      'is that graph read for what it is.\n\n'
      'The wood counts everything twice before it says it. One voice '
      'walks all ${level.seatings} seatings of this board and counts the '
      'ones that settle. The other never writes a seating down: it finds '
      'the patches and multiplies. Both were run over every wood of six '
      'hollows and six or fewer birds, 12,204,240 of them, and they have '
      'never disagreed.\n\n'
      'This is ask $number, ${level.name}. ${level.note}';
}
