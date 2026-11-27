# AGENT-DEVLOG.md

Agent-authored development notes for this repo -- the other channel
from `DEVLOG.org`, so the architect's entries don't drown in
review-round noise.  Entries are dated and signed by the agent role
that made the change; commit SHAs are the authoritative record (this
file exists in case those get squashed or rebased away).

## 2026-11-26 -- Cross-session review loop on the options machinery -- Reviewer Qwen

Round 1 (of `8d7a5c9`'s feature): dead `speedRank` semantics, a
duplicated qualifies-predicate, no-op casts, the double-layer memo
thunk.  Author's cleanup: `6062123` (net -21 lines).

Round 2: re-review found the author's refusal to wire `x:SelfTest`
into `run-build-tests` rested on two false premises ("it execs
make.ts", "env-dies at load") -- both checkable in one command;
plus a contract hole: known-but-collectively-unsatisfiable
`requires:` silently fell back to the default.  Author conceded
everything and, mid-fix, caught that a commit message had described
a fix the diff didn't contain (verified-by-grep verifying prose,
not patches -- a lesson both directions of this thread needed).
Fixes: `0835f44`, amended `045aece`.

Round 3: the `allFeatures` module-load snapshot vs. the now-mutated
profiles table -- a finding born from the test that fixed round 2.
Live computation + a positive-assertion regression check.  Thread
concluded: two agents, three rounds, one real bug each direction.

## 2026-11-27 -- 2026 backends -- Reviewer Qwen

Probe settled that 2026.10.31 *defaults* to Manifold (`--help`
[default] tag; 'manifold' graduated out of `--enable`), and that
the CGAL variant of OvalNut0 ships a 6 kB mostly-empty STL with a
happy exit code.  Full narrative in DEVLOG.org (8f68c93); code in
99fc53a: +Manifold/+CGAL pseudo-commands, plain-2026 claims no
engine, exhaustive `featureArgsFor` switch per base version, alias
resolution fixed in `run()` and the sweep (which had a latent
landmine: a pin of `x:OpenSCAD20240727Com+Manifold` would have
tried to spawn the `x:` string as an executable).

## 2026-11-27 -- Selection sorted, byOrder retired -- Reviewer Qwen

The order-vs-rank semantics quietly depended on `Object.keys`
insertion order of the profiles literal.  Spec-guaranteed, but a
fact no one should have to hold: a harmless-looking row reorder
would silently migrate part builds between engines.  `qualified` is
now `.sort()`ed -- picks depend on names and ranks only.  The
alphabetical-first qualifier happens to be the old declaration-order
winner ("x:OpenSCAD2024..." < "x:OpenSCAD2026..."), so every
assertion survived; that coincidence is itself a reason to pin it
with the existing two-assertion preference test rather than hope.

## 2026-11-27 -- run-option-self-tests (renamed from x:SelfTest-Options) -- Reviewer Qwen

The `x:` prefix marks pseudo-commands that resolve to an executable
via run()'s alias chain; a phony test target resolves to nothing,
and the convention asked for plain English.  Now spelled like its
siblings: run-openscad-tests, run-build-tests, run-tests.
