# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: check deps test analyze shots counts boxes find apk ios clean

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
# logo and every app icon.
shots:
	flutter test test/showcase_test.dart test/mark_test.dart
	@ls -1 build/showcase assets

# The four rectangles the twelve pentominoes fit in, counted right through.
# The numbers are somebody else's, from long before this code: 2, 368, 1010
# and 2339. It takes about half a minute.
counts:
	dart run tool/counts.dart

# Walks every shipped box and counts the ways of packing it.
boxes:
	dart run tool/check_boxes.dart

# Looks for new boxes with exactly one packing:
#   make find ARGS="6 6 6 3"   # six pieces, scattered in a six by six, keep 3
find:
	dart run tool/find_boxes.dart $(ARGS)

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
