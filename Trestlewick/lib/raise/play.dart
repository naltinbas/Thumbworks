import 'fewest.dart';
import 'frame.dart';

/// A frame part raised.
class Play {
  Play._(this.frame, this.raiser, this.answer, this.standing, this.today,
      this.day);

  factory Play.of(Frame frame, Raiser raiser, Raising answer) =>
      Play._(frame, raiser, answer, 0, const {}, 0);

  final Frame frame;

  /// The working out, kept for as long as the frame is open.
  final Raiser raiser;

  /// The fewest days and the floors under them, from an empty site.
  final Raising answer;

  /// What is standing, as bits.
  final int standing;

  /// What the crews are put to today, not yet raised.
  final Set<int> today;

  /// How many days have gone by.
  final int day;

  bool isUp(int timber) => standing & (1 << timber) != 0;

  bool isToday(int timber) => today.contains(timber);

  bool isReady(int timber) =>
      !isUp(timber) && frame.waitingOn(timber, standing).isEmpty;

  List<int> get ready => frame.readyFrom(standing);

  bool get isDone => standing == frame.whole;

  bool get isFewest => isDone && day <= answer.days;

  bool get canRaise => today.isNotEmpty;

  /// Puts a timber to the crews for today, or takes it off again.
  Play put(int timber) {
    if (isDone || timber < 0 || timber >= frame.count) return this;
    if (today.contains(timber)) {
      return Play._(
        frame,
        raiser,
        answer,
        standing,
        {...today}..remove(timber),
        day,
      );
    }
    if (!isReady(timber) || today.length >= frame.crews) return this;
    return Play._(frame, raiser, answer, standing, {...today, timber}, day);
  }

  /// Raises what the crews were put to, and the day is over.
  Play raise() {
    if (!canRaise) return this;
    var next = standing;
    for (final timber in today) {
      next |= 1 << timber;
    }
    return Play._(frame, raiser, answer, next, const {}, day + 1);
  }

  Play get clearToday =>
      today.isEmpty ? this : Play._(frame, raiser, answer, standing, const {}, day);

  Play get again => Play.of(frame, raiser, answer);

  /// The fewest days still to come from where the frame stands.
  int get daysLeft => raiser.daysFrom(standing);

  /// The best this frame can now be finished in, counting the days gone.
  int get couldFinishIn => day + daysLeft;

  /// Asked. The timbers to put the crews to today that still finish in as few
  /// days as the frame can now be finished in. Worked out from what is
  /// standing rather than read off a plan made before anybody started.
  List<int> get next => raiser.nextFrom(standing);
}
