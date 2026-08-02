# Flutter is not on the shell's path in this container, so the targets put it
# there once rather than each one spelling out the full path.
export PATH := /opt/flutter/bin:$(PATH)
export JAVA_HOME ?= /usr/lib/jvm/java-17-openjdk-arm64

.PHONY: all deps analyze test apk shots clean

# What CI's first job runs, and the pair worth running before a commit.
all: analyze test

deps:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test

apk:
	flutter build apk --debug

shots:
	@echo 'Rendering the game at phone sizes into build/showcase.'
	flutter test test/showcase_test.dart
	@ls -1 build/showcase
	@echo
	@echo 'These are the real widget tree at real phone dimensions, drawn by'
	@echo 'the same engine the app uses, at moments the test plays its way to:'
	@echo 'the title, a round with words found, a word being traced, the moment'
	@echo 'one counts, a trace that spells nothing, the last seconds, and the'
	@echo 'card at the end of a round.'
	@echo
	@echo 'The round is seeded, so these are the board a phone deals on that'
	@echo 'seed rather than a board that only exists in a test.'
	@echo
	@echo 'Pictures of the game running ON a phone come from CI: this machine'
	@echo 'is aarch64, where no Android emulator is published, and iOS needs a'
	@echo 'Mac. The shots-android and shots-ios jobs boot a real emulator and a'
	@echo 'real simulator, play a round on the same seeded board, and upload'
	@echo 'what they photograph.'

clean:
	flutter clean
