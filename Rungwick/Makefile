# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: check deps test analyze shots words ladders apk ios clean

# Everything that has to be green. What the pre-push hook runs, because there
# is no CI here: nothing leaves this machine unless it analyzes and the tests
# pass.
check: analyze test

deps:
	flutter pub get

test:
	flutter test

analyze:
	flutter analyze

# Renders the game at real phone sizes into build/showcase, and redraws the
# logo and the app icon.
shots:
	flutter test test/showcase_test.dart test/mark_test.dart
	@ls -1 build/showcase assets

# Rebuilds the word lists from the one Latchword ships. Two word games in one
# collection disagreeing about what a word is would be worse than either of
# them being wrong.
words:
	dart run tool/build_words.dart ../Latchword/lib/game/words.dart

# Looks for pairs of words that make a good climb, with the shortest way
# through printed out so somebody can judge whether every rung is a word
# anybody would think of.
ladders:
	dart run tool/find_ladders.dart 20

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
