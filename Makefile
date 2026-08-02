.PHONY: deps test analyze shots levels answer apk ios clean

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

# Says how every level ends, with its own drawing and with none. Both columns
# matter: a level nobody can solve is broken, and so is one that solves itself.
levels:
	dart run tool/probe.dart

# Looks for a drawing that solves a level, for when a new one needs an answer.
# Takes a level number, or tries them all.
answer:
	dart run tool/find_answer.dart $(LEVEL)

apk:
	flutter build apk --release

ios:
	flutter build ios --release --no-codesign

clean:
	flutter clean
