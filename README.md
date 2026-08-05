# Thumbworks

Twenty two games for phones, in Flutter, for Android and iOS. One repository,
one folder each, and every commit each of them was built with.

They have almost nothing in common as games — a nonogram, a siege, a rhythm
game, a minesweeper, a dice race — and one thing in common underneath, which
is why they live together. **Each one proves the thing it promises.**

| | | |
|---|---|---|
| <img src="Wirewend/assets/logo.png" width="64"> **[Wirewend](Wirewend)** | Turn the wire until the current reaches every lamp | Boards are built solvable rather than generated and hoped over |
| <img src="Slingwell/assets/logo.png" width="64"> **[Slingwell](Slingwell)** | Swing round a gravity well, let go at the right moment | Every well is reachable from the last one, checked by flying it |
| <img src="Latchword/assets/logo.png" width="64"> **[Latchword](Latchword)** | Drag a thumb across letters and spell what you can | A 44k word list, and a board that always holds enough of them |
| <img src="Tallyloom/assets/logo.png" width="64"> **[Tallyloom](Tallyloom)** | A nonogram: the numbers say the runs, you find the squares | No puzzle ships that its line-logic solver could not finish |
| <img src="Thornguard/assets/logo.png" width="64"> **[Thornguard](Thornguard)** | Twelve raiders against a king and four guards | The opening is balanced by self-play, not by feel |
| <img src="Emberlane/assets/logo.png" width="64"> **[Emberlane](Emberlane)** | Twenty waves down one winding lane, and you build beside it | Three written-down plans must finish, struggle and fail |
| <img src="Fanwright/assets/logo.png" width="64"> **[Fanwright](Fanwright)** | Patience with everything face up and four cells to park in | Every deal in the book has been solved before it shipped |
| <img src="Vaultline/assets/logo.png" width="64"> **[Vaultline](Vaultline)** | One button. Tap to hop, hold to go higher | A search over the button proves every stretch is passable |
| <img src="Chimefall/assets/logo.png" width="64"> **[Chimefall](Chimefall)** | Four lanes, notes falling, tap each one as it lands | The music and the chart are one list, and the audio is checked against it |
| <img src="Chalkway/assets/logo.png" width="64"> **[Chalkway](Chalkway)** | Draw a line in chalk and let the ball go | Every level ships a drawing that solves it, and it survives being nudged |
| <img src="Cinderplot/assets/logo.png" width="64"> **[Cinderplot](Cinderplot)** | Minesweeper | No board ever needs a guess, and the difficulty label is measured |
| <img src="Haulyard/assets/logo.png" width="64"> **[Haulyard](Haulyard)** | Shove every crate onto a mark | The par on each yard is the proven fewest shoves there are |
| <img src="Hazardwell/assets/logo.png" width="64"> **[Hazardwell](Hazardwell)** | Race to a hundred, roll as long as you dare | The house plays exactly optimally, and the table proves itself |
| <img src="Lockstead/assets/logo.png" width="64"> **[Lockstead](Lockstead)** | Find the code: right peg, or right colour in the wrong place | Five guesses is always enough, and the whole strategy tree says so |
| <img src="Rungwick/assets/logo.png" width="64"> **[Rungwick](Rungwick)** | One word to another, a letter at a time, every rung a word | The rungs are the shortest path across the whole word graph |
| <img src="Cairnfall/assets/logo.png" width="64"> **[Cairnfall](Cairnfall)** | Take stones off the cairns; take the last one and win | The opponent is a theorem, and a brute-force search checks it |
| <img src="Rookvale/assets/logo.png" width="64"> **[Rookvale](Rookvale)** | Every move a capture; leave one piece standing | Exactly one way through each board, and the whole tree says so |
| <img src="Wickfell/assets/logo.png" width="64"> **[Wickfell](Wickfell)** | Press a lamp; it and its neighbours turn. Put them all out | The fewest presses comes out of linear algebra, not a search |
| <img src="Skeinmoor/assets/logo.png" width="64"> **[Skeinmoor](Skeinmoor)** | Join each pair of ends, cross nothing, leave no cell bare | Exactly one way of filling each board, orderings and all |
| <img src="Packwold/assets/logo.png" width="64"> **[Packwold](Packwold)** | Fit the pentominoes into the ground you are given | Dancing links, and the published rectangle counts to prove it |
| <img src="Hollowmarch/assets/logo.png" width="64"> **[Hollowmarch](Hollowmarch)** | Jump a peg over its neighbour; leave one standing | An invariant rules out where you cannot finish, without searching |
| <img src="Warrenshaw/assets/logo.png" width="64"> **[Warrenshaw](Warrenshaw)** | You move along a path, then it does. Corner it | A theorem about maps and a table of every position agree exactly |

## The idea they share

A game that says "solvable" usually means somebody played a few and it seemed
fine. Every game here means it, and the proof is a test rather than a
paragraph:

- **Cinderplot** lays a minefield out, plays it through with a solver that
  only reasons, and throws it away if the reasoning ever runs out — *and*
  throws it away if it needed less thinking than the difficulty on the label
  promises. Nineteen boards in twenty go in the bin.
- **Haulyard** searches every yard for the shortest way through it, and a test
  fails if the par printed on the level is off by one.
- **Hazardwell** works out the exact chance of winning from all million
  positions in the game, then checks the answer is a fixed point of the rule
  that made it. That is the only proof there is that an optimal opponent is
  optimal.
- **Chalkway** ships an actual drawing with each level, not a note saying one
  exists — and requires it to still work when both ends move, because a line
  that only works at one exact position is a coincidence rather than an
  answer.
- **Lockstead** gives you exactly five guesses because every one of the 1296
  codes can be found in five — walked as one tree rather than sampled, and
  agreeing with Knuth's published result from 1977.
- **Rungwick** walks every four-letter word in the language outwards from the
  far end of each climb, so the number of rungs is the shortest path there is
  — and the same distances tell you the moment you have stepped off it.
- **Cairnfall** settles a row of cairns by one exclusive-or, and proves the
  theorem it rests on by walking the entire game tree of every small position
  and checking the two answers agree.
- **Rookvale** walks the entire tree of every board and throws away any with
  two ways through, so every capture is forced by something — and the same
  walk tells you the moment a capture has left no way through at all.
- **Wickfell** turns pressing lamps into a system of equations over two
  values, solves it, and tries the null space to get the *fewest* presses
  rather than merely some — then checks the whole thing against brute force on
  a board small enough to try every set of presses there is.
- **Skeinmoor** counts every way of filling a board — every route and every
  order of drawing them — and ships only the boards with one. Two boards in
  two hundred thousand survive it, and the count is taken under the rules the
  screen obeys rather than the cheaper ones the search would have preferred.
- **Packwold** is an exact cover problem, so its solver is Algorithm X with
  dancing links — and the check on it is that the twelve pentominoes come out
  at 2, 368, 1010 and 2339 packings of the four rectangles they fit, which are
  the figures everybody else has had for decades.
- **Hollowmarch** adds up the pegs in a field of four values, where three in a
  row carry a^k, a^(k+1) and a^(k+2) and a^k + a^(k+1) = a^(k+2). The sum is
  therefore the same after every jump ever made, so a hollow whose own sum
  does not match is a hollow no sequence of jumps can end in — proved rather
  than searched. On the 33 hole board it rules out 28 of the 33, and the
  search then reaches all five that are left.
- **Warrenshaw** settles every position of the chase backwards from the end,
  so the runner is the table read the other way up rather than an opponent
  somebody wrote. Then it answers the same question a second way that never
  looks at a move — rubbing places off the map until it does or does not come
  apart, which is a theorem from the early eighties — and holds the two
  against each other on three hundred maps made up at random.
- **Tallyloom**, **Fanwright**, **Vaultline** and **Wirewend** each do the
  same for their own shape of content: nothing reaches a player that a solver
  has not finished first.

The second half of that idea is that the proof is made the way a player would
find it false. Every game plays itself through its own screen in the tests —
real gestures, real widgets, real phone sizes — not just through its model.

## Some things learned the hard way

Written down because each one cost a rewrite:

- **Balance is a bug class unit tests cannot see.** Thornguard's first opening
  gave the raiders sixteen pieces and they won four games in five; the second
  gave them eight and they lost every one. Only self-play over hundreds of
  games found it.
- **Check that a harness measures the game.** Emberlane's first scripted plan
  bought one tower a wave and lost with twelve hundred embers unspent — it was
  measuring the schedule, not the game.
- **Ask the solver whether an option is ever right.** Hazardwell's two-dice
  move turned out to be mathematically identical to rolling one die twice, to
  fifteen decimal places, until a pair paid double. A button no correct player
  would ever press is a design bug only a solver finds.
- **Best-first beats depth-first badly on wide trees.** Fanwright's first
  solver won five deals in forty; the same code with a three-term heuristic
  wins ninety-nine in a hundred.
- **An external fact is worth more than any self-consistent test.** Fanwright
  checks deal 11982, the famously unwinnable FreeCell deal, which tests the
  shuffle, the numbering, the rules and the solver in one bit. Hazardwell's
  game value agrees with the published figure for the race it is based on;
  Lockstead's four-peg lock comes out at five guesses, which is Knuth's result
  from 1977.
- **Hand-drawn levels need a machine before they need a player.** Four of
  Haulyard's first twelve yards were impossible: a one-square doorway means
  the crate plugs its own way out.

## Running them

```
make check              # analyze and test every game; what the pre-push hook runs
make one GAME=Chalkway  # just that one
make deps               # flutter pub get, everywhere
make shots              # redraw every game's screens and logo
make list               # what each of them is
```

Each game's folder is a whole Flutter project and works on its own — `cd
Chalkway && make check` does what you would expect, and every game has its own
targets besides (`make levels`, `make odds`, `make pars`, `make audit`, and so
on) for the tool that generates or proves its content.

There is no CI. Everything runs on the machine doing the work, and a pre-push
hook refuses to push a tree where any of the twenty two is red. The device
screenshot drives in each game's `.github/scripts/` are started by hand on a
machine with a phone or a simulator attached.

## Where the pictures come from

Every image in this repository was drawn by the code it belongs to. The logos
come from each game's own painter, run in a test that writes the PNG; the
screenshots come from a test that renders the real screens at real phone sizes
and photographs them. Nothing was made in an image editor, and nothing was
downloaded.
