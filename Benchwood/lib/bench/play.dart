import 'level.dart';
import 'levels.dart';
import 'rules.dart';

/// One go at an ask: where the card stands, what is on the bench, the
/// walks taken, and the go before, so a carry can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.at,
    required this.bench,
    required this.walks,
    required this.before,
  });

  factory Play.of(Level level) => Play._(
        level: level,
        at: 0,
        bench: const [],
        walks: 0,
        before: null,
      )._settle();

  /// A go standing part way down the card, no walks counted beyond what
  /// getting there took: what the mark draws.
  factory Play.standing(Level level, List<int> carries) {
    var play = Play.of(level);
    for (final slot in carries) {
      play = play.carry(slot);
    }
    return play;
  }

  final Level level;

  /// Which call the card stands at.
  final int at;

  /// The tools on the bench, slot by slot.
  final List<int> bench;

  /// The walks to the store so far.
  final int walks;

  final Play? before;

  List<int> get card => level.card;

  /// Whether the card has been worked to the end.
  bool get finished => at >= card.length;

  /// The tool the card is calling for, or null at the end.
  int? get wanted => finished ? null : card[at];

  /// Whether the bench is full and the tool called for is not on it, so
  /// something has to go back.
  bool get waiting =>
      !finished && !bench.contains(card[at]) && bench.length >= level.slots;

  bool get isDone => finished && level.meets(walks);

  /// The run is over and the ask was not landed.
  bool get gaveUp => finished && !isDone;

  bool get isOver => finished;

  /// How many walks the ask allows.
  int get allowed => level.walks;

  /// Where the card next calls for the tool in [slot].
  int nextCall(int slot) => Rules.nextCall(card, bench[slot], at);

  /// The slot Belady's rule would carry back, or null when there is no
  /// choice to make.
  int? get next => waiting ? Rules.furthest(card, bench, at) : null;

  /// The fewest walks left from here, however it is played.
  int get leftAtBest {
    if (finished) return 0;
    final rest = card.sublist(at);
    // The bench as it stands is worth keeping: work the rest of the
    // card from it.
    return _fewestFrom(rest, List.of(bench), level.slots);
  }

  static int _fewestFrom(List<int> rest, List<int> bench, int slots) {
    final seen = <String, int>{};

    int go(int at, List<int> hold) {
      if (at == rest.length) return 0;
      final key = '$at:${(List.of(hold)..sort()).join(',')}';
      final held = seen[key];
      if (held != null) return held;
      final want = rest[at];
      int got;
      if (hold.contains(want)) {
        got = go(at + 1, hold);
      } else if (hold.length < slots) {
        got = 1 + go(at + 1, [...hold, want]);
      } else {
        var best = rest.length + 1;
        for (var slot = 0; slot < hold.length; slot++) {
          final walks = 1 + go(at + 1, List.of(hold)..[slot] = want);
          if (walks < best) best = walks;
        }
        got = best;
      }
      seen[key] = got;
      return got;
    }

    return go(0, bench);
  }

  /// Works the card on while there is nothing to choose: free grabs and
  /// tools that go down on an empty slot.
  Play _settle() {
    var here = this;
    while (!here.finished) {
      final want = here.card[here.at];
      if (here.bench.contains(want)) {
        here = Play._(
          level: here.level,
          at: here.at + 1,
          bench: here.bench,
          walks: here.walks,
          before: here.before,
        );
        continue;
      }
      if (here.bench.length < here.level.slots) {
        here = Play._(
          level: here.level,
          at: here.at + 1,
          bench: [...here.bench, want],
          walks: here.walks + 1,
          before: here.before,
        );
        continue;
      }
      break;
    }
    return here;
  }

  /// Carries the tool in [slot] back to the store and fetches the one
  /// the card is calling for.
  Play carry(int slot) {
    if (!waiting || slot < 0 || slot >= bench.length) return this;
    final next = Play._(
      level: level,
      at: at + 1,
      bench: List.of(bench)..[slot] = card[at],
      walks: walks + 1,
      before: this,
    );
    return next._settle();
  }

  Play get back => before ?? this;

  /// What the pointer says.
  static String pointed(int tool) =>
      'Carry ${Rules.tellTool(tool)} back to the store.';
}

/// Why Belady's rule cannot be beaten: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'The bench holds a few tools and the job card calls for them one at '
      'a time. A tool already down is a free grab; anything else is a walk to '
      'the store, and a full bench means carrying something back first. The '
      'only choice in the game is which tool goes back.\n\n'
      'Laszlo Belady showed in 1966 that one rule cannot be beaten: carry '
      'back the tool whose next call is furthest off. The argument is an '
      'exchange. Take any way of playing the card and the first place it '
      'differs from that rule; change that one carry to the furthest-off '
      'tool and mend the rest, and the walks never go up. Do it again and '
      'again and you arrive at the rule itself, so nothing beats it. It is a '
      'rule that needs the whole card in advance, which is why a real bench '
      'cannot follow it.\n\n'
      'A bench that carries back whatever has been down longest can even get '
      'worse when it gets bigger. On the card of ask 3 it walks nine times '
      'with three slots and ten with four, while Belady\'s rule walks seven '
      'and six. Belady, Nelson and Shedler wrote that up in 1969.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The counts in this note come from playing this ask\'s own card every '
      'way it can go, worked in full before the sham was built.';
}
