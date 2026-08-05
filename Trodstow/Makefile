# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)

.PHONY: check deps test analyze shots parishes find apk ios clean

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

# Walks every shipped parish: the cheapest network three ways, and whether
# every path in it is proved by the line it crosses.
parishes:
	dart run tool/check_parishes.dart

# Scatters hamlets about and keeps the parishes worth playing:
#   make find ARGS="8 1 0.42 41"
find:
	dart run tool/find_parishes.dart $(ARGS)

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
