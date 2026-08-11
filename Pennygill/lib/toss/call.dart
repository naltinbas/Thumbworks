/// A call: three flips named in advance, heads or tails.
///
/// There are eight, and the whole game lives in the fact that they do not
/// line up from worst to best: every call has another that beats it, all
/// the way round a ring.
class Call {
  const Call(this.flips) : assert(flips >= 0 && flips < 8);

  /// Three flips as bits, the first flip the highest bit; set is heads.
  final int flips;

  static List<Call> get all => [for (var call = 0; call < 8; call++) Call(call)];

  bool head(int flip) => (flips >> (2 - flip)) & 1 == 1;

  /// The call as it is said: aitches and tees.
  String get said =>
      [for (var flip = 0; flip < 3; flip++) head(flip) ? 'H' : 'T'].join();

  /// The house's reply to this call, the old rule: the other side of the
  /// caller's middle flip, then the caller's first two.
  Call get beatenBy {
    final middle = (flips >> 1) & 1;
    return Call(((1 - middle) << 2) | (flips >> 1));
  }

  @override
  bool operator ==(Object other) => other is Call && other.flips == flips;

  @override
  int get hashCode => flips;

  @override
  String toString() => said;
}
