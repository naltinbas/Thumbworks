/// One timber: what it is called and where it lies in the frame.
class Timber {
  const Timber(this.name, this.fromX, this.fromY, this.toX, this.toY,
      {this.stout = 1.0});

  final String name;

  /// Where it runs, from 0 to 1 across and down. The drawing scales these to
  /// whatever glass it is given, so a frame is written down once and looks
  /// right on every phone.
  final double fromX;
  final double fromY;
  final double toX;
  final double toY;

  /// How thick it is drawn, against the ordinary timber.
  final double stout;
}

/// A frame waiting to be raised: the timbers, and what each one rests on.
///
/// A timber cannot go up until everything it rests on is already standing.
/// That is the only rule, and everything the game is about follows from it and
/// from there being fewer crews than timbers.
class Frame {
  Frame({
    required this.name,
    required List<Timber> timbers,
    required List<Set<int>> rests,
    required this.crews,
    required this.days,
  })  : timbers = List.unmodifiable(timbers),
        rests = List.unmodifiable([
          for (final on in rests) Set<int>.unmodifiable(on),
        ]);

  final String name;
  final List<Timber> timbers;

  /// For each timber, what has to be standing before it can go up.
  final List<Set<int>> rests;

  /// How many timbers can go up in one day.
  final int crews;

  /// The fewest days it takes. Written down here as well as worked out, so a
  /// test can hold the two against each other.
  final int days;

  int get count => timbers.length;

  /// Everything standing, as bits.
  int get whole => (1 << count) - 1;

  /// The timbers that could go up next, given what is standing.
  List<int> readyFrom(int standing) => [
        for (var timber = 0; timber < count; timber++)
          if (standing & (1 << timber) == 0 && _restsAreUp(timber, standing))
            timber,
      ];

  bool _restsAreUp(int timber, int standing) {
    for (final on in rests[timber]) {
      if (standing & (1 << on) == 0) return false;
    }
    return true;
  }

  /// What a timber is still waiting on, given what is standing.
  List<int> waitingOn(int timber, int standing) => [
        for (final on in rests[timber])
          if (standing & (1 << on) == 0) on,
      ];

  /// Whether the frame hangs together: nothing rests on itself, nothing rests
  /// on something that comes to rest on it, and every timber can be reached.
  bool get isSound {
    var standing = 0;
    for (var round = 0; round <= count; round++) {
      final ready = readyFrom(standing);
      if (ready.isEmpty) break;
      for (final timber in ready) {
        standing |= 1 << timber;
      }
    }
    return standing == whole;
  }
}
