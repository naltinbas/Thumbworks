/// Where the music has got to.
///
/// The player reports its position a few times a second, which is nowhere near
/// often enough to fall a note down a screen by. So this carries the last
/// report forward with the wall clock between reports, and corrects itself
/// when the next one arrives.
///
/// It matters more here than it looks. A rhythm game judged against a clock
/// that is not the music is a rhythm game that is wrong by however far the two
/// have drifted — and they always drift, because starting a sound takes a
/// moment the game does not get told about. Reading the position out of the
/// player and interpolating between readings is the only way the tap and the
/// note are being judged against the same thing.
class Beat {
  Beat();

  Duration _position = Duration.zero;
  Duration _wall = Duration.zero;
  bool _running = false;

  /// How far a reading may be from where this thought it was before it is
  /// taken as a jump rather than as drift.
  ///
  /// Under this, the difference is eased away over the next few frames so
  /// nothing on screen visibly hops. Over it, something real happened — a
  /// seek, a stall, a restart — and the right answer is to believe the player
  /// at once.
  static const _snapAfter = Duration(milliseconds: 80);

  /// How much of a small difference to take on each reading.
  static const _ease = 0.35;

  bool get running => _running;

  /// A reading from the player, and the wall time it arrived at.
  void reported(Duration position, Duration wall) {
    if (!_running) {
      _position = position;
      _wall = wall;
      _running = true;
      return;
    }

    final thought = _carried(wall);
    final apart = position - thought;

    _position = apart.abs() >= _snapAfter
        ? position
        : thought + apart * _ease;
    _wall = wall;
  }

  /// Where the music is now, in seconds.
  double at(Duration wall) =>
      _running ? _carried(wall).inMicroseconds / 1000000 : 0;

  /// Stops carrying anything forward. Used when the music stops.
  void stopped() {
    _running = false;
    _position = Duration.zero;
    _wall = Duration.zero;
  }

  Duration _carried(Duration wall) => _position + (wall - _wall);
}
