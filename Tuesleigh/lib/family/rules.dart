import 'frac.dart';

/// Families of two children, each a boy or a girl born under one of k
/// tags, days of the week say, all alike; told that at least one is a
/// boy born under the first tag, the chance both are boys.
class Rules {
  /// The tags run from one, no tag at all in effect, to [most].
  static const most = 30;

  static int get settings => most;

  /// Every family counted out: the elder and the younger each one of 2k
  /// kinds, boy or girl by tag, so 4k squared families alike; among
  /// those with a boy of the first tag, the share with two boys. The
  /// first voice.
  static Frac chanceByCounting(int k) {
    var told = 0, bothBoys = 0;
    for (var elder = 0; elder < 2 * k; elder++) {
      for (var younger = 0; younger < 2 * k; younger++) {
        // Kinds 0 to k - 1 are boys by tag, k to 2k - 1 girls by tag.
        final elderBoyTagged = elder == 0, youngerBoyTagged = younger == 0;
        if (!elderBoyTagged && !youngerBoyTagged) continue;
        told++;
        if (elder < k && younger < k) bothBoys++;
      }
    }
    return Frac.of(bothBoys, told);
  }

  /// The chance by the form: 2k - 1 families of two boys hold a boy of
  /// the first tag, out of 4k - 1 families that do. The second voice.
  static Frac chanceByForm(int k) => Frac.of(2 * k - 1, 4 * k - 1);

  /// The families the telling leaves: 4k - 1.
  static int told(int k) => 4 * k - 1;

  /// The families of two boys among them: 2k - 1.
  static int bothBoys(int k) => 2 * k - 1;

  /// The chance when told which child, the elder say, is the tagged boy:
  /// the other is a boy half the time whatever the tag.
  static Frac chanceToldWhich(int k) {
    var told = 0, bothBoys = 0;
    for (var younger = 0; younger < 2 * k; younger++) {
      told++;
      if (younger < k) bothBoys++;
    }
    return Frac.of(bothBoys, told);
  }

  static String tell(Frac f) => '$f';
}
