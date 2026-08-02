#!/usr/bin/env bash
#
# Plays a board on the emulator the runner has already booted, and keeps the
# pictures.
#
# Two kinds of picture come out of a run. The ones the test asks the framework
# for are the point: each is taken at a chosen moment of a board the test
# played itself, so the one that matters is a board it cleared by reasoning.
# The ones sampled off the device screen while that happens are there to show
# the game really was running on a phone, and are allowed to fail without
# taking the job with them.
set -euo pipefail

device=emulator-5554
package=dev.cinderplot.cinderplot
shots=build/screenshots

mkdir -p "$shots/device"
adb wait-for-device

sample_the_screen() {
  # Building and installing takes minutes, and there is nothing to photograph
  # until the app is up, so wait for its process rather than guess at a delay.
  while ! adb -s "$device" shell pidof "$package" >/dev/null 2>&1; do
    sleep 5
  done
  for i in $(seq 0 39); do
    adb -s "$device" exec-out screencap -p \
      >"$shots/device/$(printf '%02d' "$i").png" || true
    sleep 2
  done
}

sample_the_screen &
sampler=$!
trap 'kill "$sampler" 2>/dev/null || true' EXIT

flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart \
  --device-id "$device" \
  --debug

kill "$sampler" 2>/dev/null || true

# The drive can pass while handing back nothing, so say so here rather than
# let the job go green with an empty artifact. Counted rather than named: the
# names differ from game to game and a list of them here is a list that goes
# stale the moment a picture is renamed.
count=$(find "$shots" -maxdepth 1 -name '*.png' | wc -l)
if [ "$count" -lt 3 ]; then
  echo "the drive finished leaving only $count pictures" >&2
  exit 1
fi
ls -l "$shots"
