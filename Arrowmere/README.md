# Arrowmere

<img src="assets/logo.png" width="120" align="right" alt="Arrowmere">

A village of places joined by streets, and every street to be made
one-way. Tap a street and its arrow turns about; the ask is that every
place can still be reached from every other once all the arrows are
set. Some villages take it and some cannot, and Robbins' theorem, from
Herbert Robbins in 1939, says exactly which: a joined village can be
made one-way throughout when no street is a bridge, a street whose
closing would cut the village in two. One side of that is plain to
see. Point a bridge and the side it leaves can never be got back to.
The other side is the work of the theorem. The game holds five
villages, from a square of four places to a cube of eight, and it
points every street of each of them every way it can be pointed, 8,400
orientations, counting the ones that work twice over.

## The asks

1. **The Green** - point every street of the green, leaving every place reachable from every other
2. **The Square** - the same of the square
3. **The House** - the same of the house
4. **The Two Rings** - the same of the two rings
5. **The Toll Lane** - the same of the toll lane

The green is nine places in three rows with twelve streets between
them, and 78 of its 4,096 orientations work. The square is the plainest
case: only two of its sixteen work, the two that send you round and
round, and every other leaves a place you can enter and never leave or
leave and never enter. The house is a square with a roof, two rounds
sharing a street, and six of its 64 work: the shared street may point
either way, and once it does the two rounds must run with it. The two
rings are the graph of a cube, an outer ring of four places and an
inner one with four streets between them, and 426 of its 4,096 work,
more than any other village here. The Toll Lane is washed red on the
board rather than gold: two hamlets of three places each, joined by
one lane. Point that lane whichever way you like and the far hamlet
can be reached and never left, so nine of the thirty ordered pairs go
one way only and 21 is the most any orientation gets. The sham admits
it once three orientations have got that far, or after fourteen turns.

## Two voices

Every number the game says out loud is one it worked out, and the
count of orientations that work is worked out two ways:

* **The walk** points the streets and tries. For each of the 8,400
  orientations it follows the arrows out of every place in turn and
  counts the ordered pairs it can get between; the orientation works
  when all of them are open. On every one that works it also checks
  that each street lies on a round trip, so what one street leaves can
  be come back to by others.
* **The polynomial** never points a street. It works the village's
  Tutte polynomial out by deleting and contracting one street at a
  time, and reads the count off at (0, 2), which counts the
  orientations leaving every street on a round trip. The two agree on
  all five villages and on rings of every length from three to eight,
  and on the toll lane both give nought, which is Robbins' theorem in
  arithmetic: the polynomial at (0, 2) vanishes exactly when a street
  is a bridge.

The bridges are found twice as well, once by closing each street in
turn and asking whether the village falls apart, and once by the
depth-first walk that keeps the earliest place each branch can climb
back to. They agree on all five villages, and only the toll lane has
one.

`tool/check_ways.dart` runs the lot and refuses the bake on any
disagreement.

## The checker's ledger

What `dart run tool/check_ways.dart` printed for the build this README
shipped with, word for word:

```
every way of pointing every street of all five villages tried, 8,400 orientations in all, and the ones that leave every place reachable from every other counted twice, once by walking the arrows out of each place in turn and once by the village's Tutte polynomial at (0, 2), which never points a street: the two agree on all five, 78 of the green's 4,096, 2 of the square's 16, 6 of the house's 64, 426 of the two rings' 4,096, none of the toll lane's 128; on every working orientation every street lies on a round trip, so what is left by one street can be come back to by others; the toll lane is the only village with a bridge, the lane C to D, found both by closing each street in turn and by the depth-first walk that keeps the earliest place a branch can climb back to, and 21 of its 30 ordered pairs is the most any orientation gets, the nine across the lane going one way only; a ring of any length from three to eight works two ways and no more, by both counts; The Green opens 5 turns from the nearest answer, The Square opens 2 turns from the nearest answer, The House opens 2 turns from the nearest answer, The Two Rings opens 4 turns from the nearest answer, and the pointer takes each of them in that many, never more

 1 The Green     point every street of the green, leaving every place reachable from every other: 78 of the 4,096 orientations land it, the fewest 5 turns from the opening
 2 The Square    point every street of the square, leaving every place reachable from every other: 2 of the 16 orientations land it, the fewest 2 turns from the opening
 3 The House     point every street of the house, leaving every place reachable from every other: 6 of the 64 orientations land it, the fewest 2 turns from the opening
 4 The Two Rings point every street of the two rings, leaving every place reachable from every other: 426 of the 4,096 orientations land it, the fewest 4 turns from the opening
 5 The Toll Lane point every street of the toll lane, leaving every place reachable from every other: none of the 128, and the lane says so on a finger
```

## Screenshots

| The sham | The green, all ways round | The toll lane admitted |
| --- | --- | --- |
| ![the sham](docs/sham.png) | ![the green](docs/green.png) | ![the toll lane](docs/toll.png) |

| The square | The house | The two rings | Midway, on the small phone | Show me | The why |
| --- | --- | --- | --- | --- | --- |
| ![the square](docs/square.png) | ![the house](docs/house.png) | ![the two rings](docs/rings.png) | ![midway](docs/midway.png) | ![show me](docs/showme.png) | ![the why](docs/why.png) |

Screenshots are drawn by `test/showcase_test.dart` at real phone sizes
with the app's own painter, then copied into `docs/` as they came out;
every arrow turned in them was turned by a tap on that street, so no
village pictured is pointed a way the game could not point it. The
logo and every launcher icon come out of `test/mark_test.dart`, drawn
by the same painter: the mark is the house pointed the way the village
lists it, one of the six orientations that leave every place reachable
from every other.

## Building

```
flutter test          # 42 tests, the sweeps among them
dart run tool/check_ways.dart
flutter build apk     # or: flutter build ios
```
