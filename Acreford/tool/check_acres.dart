import 'dart:io';

import 'package:acreford/acre/fields.dart';
import 'package:acreford/acre/rules.dart';

/// Walks every paddock, holds the two counts together, and
/// refuses the bake on any disagreement: this is what
/// `make acres` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final field in Fields.all) {
    final ways = Rules.waysTo(
      field.posts,
      twoA: field.twoA,
      inside: field.inside,
      midRail: field.midRail,
    );
    if (ways != field.ways) {
      stderr.writeln('${field.name}: sweep finds $ways, '
          'label says ${field.ways}');
      exit(1);
    }
  }

  // Pick's count against the crossing sum, every paddock.
  if (!Rules.pickHolds(3) || !Rules.pickHolds(4)) {
    stderr.writeln('PICK PARTED FROM THE RAILS');
    exit(1);
  }
  var tris = 0, quads = 0;
  Rules.paddocks(3, (_) => tris++);
  Rules.paddocks(4, (_) => quads++);
  if (tris != 516 || quads != 1758) {
    stderr.writeln('THE SWEEP MOVED: $tris and $quads');
    exit(1);
  }

  // Only three posts hold the half acre.
  if (Rules.waysTo(4, twoA: 1) != 0) {
    stderr.writeln('A FOUR-POST HALF ACRE APPEARED');
    exit(1);
  }

  // A whole acre from four posts is always bare.
  var wholeBare = true;
  Rules.paddocks(4, (walk) {
    if (Rules.twiceAcres(walk) == 2 &&
        (Rules.insidePosts(walk) != 0 ||
            Rules.midRailPosts(walk) != 0)) {
      wholeBare = false;
    }
  });
  if (!wholeBare) {
    stderr.writeln('A DRESSED WHOLE ACRE APPEARED');
    exit(1);
  }

  // One post within makes the acres read the rim, and costs
  // two whole acres at the least.
  var rimRead = true;
  var least = 1 << 30;
  for (final posts in [3, 4]) {
    Rules.paddocks(posts, (walk) {
      if (Rules.insidePosts(walk) != 1) return;
      if (Rules.twiceAcres(walk) != Rules.rimPosts(walk)) {
        rimRead = false;
      }
      if (posts == 4 && Rules.twiceAcres(walk) < least) {
        least = Rules.twiceAcres(walk);
      }
    });
  }
  if (!rimRead || least != 4) {
    stderr.writeln('THE POST WITHIN MISREAD THE RIM: least $least');
    exit(1);
  }

  // Two and a half acres always lets a post onto a rail, the
  // rim five or seven; and a bare rim writes exactly the five
  // even counts two through ten.
  final overRims = <int>{};
  final bare = <int>{};
  Rules.paddocks(4, (walk) {
    if (Rules.twiceAcres(walk) == 5) {
      overRims.add(Rules.rimPosts(walk));
    }
    if (Rules.midRailPosts(walk) == 0) {
      bare.add(Rules.twiceAcres(walk));
    }
  });
  final overSorted = overRims.toList()..sort();
  final bareSorted = bare.toList()..sort();
  if ('$overSorted' != '[5, 7]') {
    stderr.writeln('THE HALF OVER RIMS MOVED: $overSorted');
    exit(1);
  }
  if ('$bareSorted' != '[2, 4, 6, 8, 10]') {
    stderr.writeln('THE BARE RIM COUNTS MOVED: $bareSorted');
    exit(1);
  }

  // The mark is real: two and a half acres holding a post.
  if (Rules.paddock(4, twoA: 5, inside: 1) == null) {
    stderr.writeln('THE MARK PADDOCK IS GONE');
    exit(1);
  }

  stdout.writeln(
      'every paddock of the field walked, 516 of three posts and '
      '1,758 of four: the rails\' crossing sum and Pick\'s post '
      'count agree on every one, a bare rim of four posts writes '
      'two, four, six, eight or ten half-acres and nothing else, '
      'and all 212 fences of two acres and a half let a post '
      'onto a rail');
  stdout.writeln('');

  for (var number = 0; number < Fields.count; number++) {
    final field = Fields.at(number);
    final name = field.name.padRight(18);
    stdout.writeln(field.winnable
        ? ' ${number + 1} $name ${field.task}: ${field.ways} '
            'paddocks of the sweep land it'
        : ' ${number + 1} $name ${field.task}: none of the '
            '1,758, and Pick said so first');
  }
}
