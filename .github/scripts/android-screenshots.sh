#!/usr/bin/env bash
#
# Plays a game on the emulator the runner has already booted, and keeps the
# pictures.
#
# Two kinds of picture come out of a run. The ones the test asks the framework
# for are the point: each is taken at a chosen moment in a game the test
# played itself, so the one that matters has a man picked up and the squares
# he can reach lit. The ones sampled off the
# device screen while that happens are there to show the game really was
# running on a phone, and are allowed to fail without taking the job with
# them.
set -euo pipefail

device=emulator-5554
package=dev.thornguard.thornguard
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
# let the job go green with an empty artifact.
for name in 01-title 02-tracing 03-counted 04-summary; do
  if [ ! -s "$shots/$name.png" ]; then
    echo "the drive finished without leaving $name.png" >&2
    exit 1
  fi
done
ls -l "$shots"
