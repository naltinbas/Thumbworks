/// Numbers the simulation keeps to itself that the view still has to draw.
///
/// world.dart holds these privately because nothing inside the simulation
/// needs to publish them. The view does need them: a player has to see where
/// the walls are, how close a well catches from, and which part of a well is
/// solid enough to kill. They are copied here rather than reached for, and a
/// change to the simulation has to be carried across by hand. That is a real
/// cost, and it is smaller than the alternative, which is a picture that
/// quietly lies about the rules. playfield_test.dart plays the simulation and
/// checks each of these against what it actually does.
abstract final class Playfield {
  /// How far to either side the craft may drift before the run ends.
  static const edgeX = 7.0;

  /// How far from a well's centre the craft rides while it is held.
  static const tether = 2.0;

  /// How far outside its radius a well still catches.
  static const catchBand = 1.35;

  /// The share of a well's radius that is solid rather than catching.
  static const coreShare = 0.42;

  /// How far below the high point of the run the craft may fall.
  static const fallBehind = 9.0;
}
