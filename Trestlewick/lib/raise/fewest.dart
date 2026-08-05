import 'frame.dart';

/// The fewest days a frame takes, and the two reasons it cannot be fewer.
class Raising {
  const Raising({
    required this.days,
    required this.eachDay,
    required this.chain,
    required this.byWork,
  });

  /// The fewest days.
  final int days;

  /// One way of doing it: the timbers that go up on each day.
  final List<List<int>> eachDay;

  /// The longest run of timbers where each one rests on the one before it.
  ///
  /// No two of these can go up on the same day, since each is waiting on the
  /// one before, so the frame cannot be raised in fewer days than there are
  /// timbers in this run. It is a floor anybody can check by following the
  /// timbers with a finger.
  final List<int> chain;

  /// The other floor: how few days the crews could do the work in even if
  /// nothing rested on anything at all.
  final int byWork;

  /// The bigger of the two floors, which is what the frame is up against.
  int get floor => chain.length > byWork ? chain.length : byWork;

  /// Whether the floors account for the answer, so the frame carries its own
  /// proof rather than asking to be taken on trust.
  bool get floorSaysSo => floor == days;

  bool get chainIsTight => chain.length == days;
  bool get workIsTight => byWork == days;
}

/// Works out the fewest days a frame takes, and keeps what it works out.
///
/// Each day, some of the timbers that are ready go up, and no more of them
/// than there are crews. That leaves a state that is nothing but the set of
/// timbers standing, so the whole thing is worked out over sets of timbers and
/// each set is answered once and read thereafter. One of these belongs to a
/// frame and lives as long as it does, so asking again from part way through
/// costs nothing.
class Raiser {
  Raiser(this.frame)
      : _best = List.filled(1 << frame.count, -1),
        _took = List<List<int>>.filled(1 << frame.count, const []);

  final Frame frame;

  final List<int> _best;
  final List<List<int>> _took;

  static const _never = 1 << 20;

  /// The fewest days from where the frame stands.
  int daysFrom(int standing) {
    if (standing == frame.whole) return 0;
    if (_best[standing] >= 0) return _best[standing];

    // Marked while it is being worked out, so a frame that cannot be raised at
    // all does not go round for ever.
    _best[standing] = _never;

    final ready = frame.readyFrom(standing);
    var fewest = _never;
    var chosen = const <int>[];

    void tryTaking(List<int> taking, int at) {
      if (taking.isNotEmpty) {
        var next = standing;
        for (final timber in taking) {
          next |= 1 << timber;
        }
        final after = daysFrom(next) + 1;
        if (after < fewest) {
          fewest = after;
          chosen = List.of(taking);
        }
      }
      if (taking.length == frame.crews) return;
      for (var pick = at; pick < ready.length; pick++) {
        tryTaking([...taking, ready[pick]], pick + 1);
      }
    }

    tryTaking(const [], 0);
    _best[standing] = fewest;
    _took[standing] = chosen;
    return fewest;
  }

  /// The timbers to raise next that still finish in as few days as the frame
  /// can now be finished in.
  List<int> nextFrom(int standing) {
    daysFrom(standing);
    return _took[standing];
  }

  /// One whole way through, a day at a time.
  List<List<int>> eachDayFrom(int standing) {
    final days = <List<int>>[];
    var where = standing;
    while (where != frame.whole) {
      final taking = nextFrom(where);
      if (taking.isEmpty) break;
      days.add(taking);
      for (final timber in taking) {
        where |= 1 << timber;
      }
    }
    return days;
  }
}

/// The two floors, and the answer, for a whole frame.
class Raisings {
  const Raisings._();

  static Raising forFrame(Frame frame) => withRaiser(Raiser(frame));

  static Raising withRaiser(Raiser raiser) {
    final frame = raiser.frame;
    return Raising(
      days: raiser.daysFrom(0),
      eachDay: raiser.eachDayFrom(0),
      chain: longestChain(frame),
      byWork: (frame.count + frame.crews - 1) ~/ frame.crews,
    );
  }

  /// The longest run of timbers where each rests on the one before.
  static List<int> longestChain(Frame frame) {
    final longest = List.filled(frame.count, const <int>[]);

    List<int> upTo(int timber) {
      if (longest[timber].isNotEmpty) return longest[timber];
      var best = const <int>[];
      for (final on in frame.rests[timber]) {
        final run = upTo(on);
        if (run.length > best.length) best = run;
      }
      longest[timber] = [...best, timber];
      return longest[timber];
    }

    var best = const <int>[];
    for (var timber = 0; timber < frame.count; timber++) {
      final run = upTo(timber);
      if (run.length > best.length) best = run;
    }
    return best;
  }

  /// What somebody gets by raising whatever is ready, in the order the timbers
  /// were written down, as many a day as there are crews. It is what anybody
  /// does and it is not always the fewest days.
  static int byOrder(Frame frame) {
    var standing = 0;
    var days = 0;
    while (standing != frame.whole && days <= frame.count) {
      final ready = frame.readyFrom(standing);
      if (ready.isEmpty) return frame.count + 1;
      for (final timber in ready.take(frame.crews)) {
        standing |= 1 << timber;
      }
      days++;
    }
    return days;
  }
}
