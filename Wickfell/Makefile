# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: check deps test analyze shots sizes pick apk ios clean

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

# What each size of board is like: how many sets of presses change nothing,
# and so what share of its boards can be turned off at all.
sizes:
	dart run tool/boards.dart

# Finds boards of a size that take a given number of presses:
#   make pick ARGS="5 5 12"
pick:
	dart run tool/pick.dart $(ARGS)

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
