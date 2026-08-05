// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'dart:io';

/// Checks that every picture any README points at is there and is committed.
///
/// Run with: dart tool/images.dart  (or `make images`)
///
/// It is in `make check`, and so behind the pre-push hook, because a broken
/// image is the one kind of rot that never shows up locally: the file is
/// sitting in the working copy, the README looks right on this machine, and
/// the page on GitHub has a hole in it. Twenty games with a logo each and
/// five screenshots each is a hundred and forty chances to get that wrong.
void main() {
  final tracked = _tracked();
  final readmes = <File>[];
  _find(Directory('.'), readmes);
  readmes.sort((a, b) => a.path.compareTo(b.path));

  var checked = 0;
  final missing = <String>[];

  for (final readme in readmes) {
    final here = readme.parent.path;
    final text = readme.readAsStringSync();

    for (final ref in _refs(text)) {
      if (ref.startsWith('http')) continue;
      checked++;
      final path = _tidy('$here/$ref');
      if (!File(path).existsSync()) {
        missing.add('${readme.path}: $ref is not there');
      } else if (!tracked.contains(path)) {
        missing.add('${readme.path}: $ref is not committed');
      }
    }
  }

  print('$checked pictures in ${readmes.length} READMEs');
  for (final gone in missing) {
    print('  MISSING $gone');
  }
  if (missing.isEmpty) {
    print('every one of them is there and committed');
    return;
  }
  exitCode = 1;
}

/// Both ways a README points at a picture: markdown and a plain img tag.
Iterable<String> _refs(String text) sync* {
  for (final match
      in RegExp(r'!\[[^\]]*\]\(([^)\s]+)').allMatches(text)) {
    yield match.group(1)!;
  }
  for (final match
      in RegExp(r'<img[^>]+src="([^"]+)"').allMatches(text)) {
    yield match.group(1)!;
  }
}

void _find(Directory where, List<File> found) {
  for (final thing in where.listSync(followLinks: false)) {
    if (thing is Directory) {
      final name = thing.uri.pathSegments[thing.uri.pathSegments.length - 2];
      if (name == '.git' || name == 'build' || name == '.dart_tool') continue;
      _find(thing, found);
    } else if (thing is File && thing.uri.pathSegments.last == 'README.md') {
      found.add(thing);
    }
  }
}

Set<String> _tracked() {
  final listed = Process.runSync('git', ['ls-files']);
  return {
    for (final line in (listed.stdout as String).split('\n'))
      if (line.isNotEmpty) line,
  };
}

/// A path with the leading ./ and any .. steps taken out, so it can be
/// compared against what git lists.
String _tidy(String path) {
  final parts = <String>[];
  for (final part in path.split('/')) {
    if (part.isEmpty || part == '.') continue;
    if (part == '..' && parts.isNotEmpty) {
      parts.removeLast();
      continue;
    }
    parts.add(part);
  }
  return parts.join('/');
}
