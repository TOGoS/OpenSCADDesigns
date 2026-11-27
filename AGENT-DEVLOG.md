# AGENT-DEVLOG.md

Agent-authored development notes for this repo -- the other channel
from `DEVLOG.org`, so the architect's entries don't drown in
review-round noise.  Entries are dated and signed by the agent role
that made the change; commit SHAs are the authoritative record (this
file exists in case those get squashed or rebased away).

Note that agents have a tendancey to make up dates,
so take the dates with a grain of salt.

## 2026-11-25 - Implemented ~fromStlBuildRules~ - Master Qwen (Qwen3.8 Flash)

The stub in ~make.ts~ now takes any S0039-style 'resource name' as
~stlRef~ (see ~decodeResourceName~: ~urn:bitprint~, ~http(s)://~,
~file://~, plain paths) and generates, per part:
- for remote refs, a fetch rule into ~print-archive/pNNxx/.temp/~,
  with the mangled ref in the filename -- so swapping ~stlRef~
  produces a fresh target instead of a stale skip -- written first
  to a ~.partial-<ts>~ scratch file, hash-checked against the URN
  for ~urn:bitprint~ refs, and renamed into place only on success,
  so a mid-download crash can never leave a trusted corrupt file;
- for local refs, no copy at all: the given path is used in place
  and becomes a prereq of the wrapper, so an STL built by another
  rule in this same system Just Works;
- a rule emitting a one-line ~.scad~ wrapper that ~import()~s the
  STL (bare filename when fetched, since the wrapper is its
  sibling; absolute real path when used in place); and then
- delegates everything else to ~osdBuildRules~, which I teach only
  how to accept a ~tempDir~ override and (via a new
  ~outDirForPartId~ helper) where the pNNxx outputs go, so the
  final .stl/.png/.tef files land in ~print-archive~ as usual.

Since osdBuildRules would also export the STL by rendering the
wrapper through OpenSCAD -- pointless re-generation, and not even a
bit-exact round trip -- fromStlBuildRules overrides that one rule
(spread order matters; there's a comment) with a hardlink of the
source STL to ~print-archive/pNNxx/<partId>.stl~.

Bad fetches (non-200, hash mismatch) throw, and ~targetType:
"file"~ makes the builder delete the target so the next run
retries.

## 2026-11-25 - Hardlink staleness & the .built sidecar - Master Qwen (Qwen3.8 Flash)

A hardlink shares its source's inode, so ~stat()~ reports the
*source's* mtime -- there's no filesystem record of when the link
was made (and ~utime()~ on the link hits the source too, so
restamping is out if source mtimes should be preserved).  That made
~x:Hardlink~ targets false-skip: a rebuilt link never looks newer
than consumers built before it.

Fix is marker-based, not mtime-mangling: ~x:Hardlink~ now writes a
~.<name>.built~ sidecar next to each link, and ~make.ts~ installs
~mtimeWithBuiltMarkers~ as Builder's ~mtimeFunction~ (a hook
added for exactly this, now remembered), which reports the
sidecar's mtime as the target's effective build time.  A missing
target reports undefined so the stat still yields 'not found' ->
always rebuild, never phantom up-to-date-ness from an orphaned
marker after a failed build deleted its target.

Tbuilder itself is blameless here: the hook is honored for files
and directories alike (initial 'directory bug' finding was a
test-harness artifact), and the sidecar idea mirrors its own
~touchDir~ trick for directory-mtime granularity.

## 2026-11-25 Wed] - relativePath() for wrapper imports - Master Qwen (Qwen3.8 Flash)

The wrapper .scad's import path was picked by a
~fetchedStlPath.startsWith(tempDir)~ test -- a string-prefix hack
on paths (~.temp~ vs a hypothetical ~.tempfoo~; fetched files
happen to be siblings but that wasn't the point).  Replaced with
a general ~relativePath(fromFile, toFile)~ (plus lexical
~normalizePath~: no fs access, so it works for not-yet-built
targets); fetched siblings collapse to the bare filename, local
refs get proper ~../~ chains.  Inputs with no provable shared
base -- mixed relative/absolute, or different Windows drives --
get the normalized absolute path rather than a ../-chain through
an assumed cwd.  ~Deno.realPath~ is gone from this code path
entirely.

## 2026-11-25 - pathutil library, and TS tests in general - Master Qwen (Qwen3.8 Flash)

Moved ~FilePath~, ~basename~, and the new ~normalizePath~ /
~relativePath~ pair from ~make.ts~ into ~src/lib/ts/_util/pathutil.ts~
(naming per the architect: 'normalizePath' beat 'resolvePathPure'),
with ~pathutil.test.ts~ beside them -- the repo's first TypeScript
tests.  Run: ~deno test --allow-read --allow-write
src/lib/ts~; nothing else runs TS tests yet (test.bat is .scad
only).  The relativePath tests carry a filesystem oracle that
materializes real temp files and lets realpath adjudicate, rather
than re-running the lexical logic under test.

~resolvePathPure~'s drive handling and ~relativePath~'s segment
model both had off-by-one bugs the tests caught on day one --
exactly why they're worth having.

## 2026-11-25 - IO tests live in <basename>.io.test.ts - Master Qwen (Qwen3.8 Flash)

Convention from the architect: tests that touch the filesystem go
in ~<basename>.io.test.ts~, keeping the plain ~<basename>.test.ts~
runnable under bare ~deno test~ with no permission flags.  The
suffix still matches Deno's default discovery glob, so directory
runs pick up both.  ~pathutil.test.ts~ is now purely lexical; the
realpath-oracle moved to ~pathutil.io.test.ts~.

## 2026-11-26 - test.bat is now build rules - Master Qwen (Qwen3.8 Flash)

~make.ts~ gained three phony targets at the top of its rule list
(part recipes stay at the bottom where the newest live):
~run-openscad-tests~ (evaluates every 2023/test ~.scad~ with
~--hardwarnings~, reporting failures the old find invocation never
could), ~run-build-tests~ (the Deno tests), and ~run-tests~ (both).
~test.bat~ is deleted; ~.gitignore~ now covers its
~test-output-*.stl~ scratch files.  The OpenSCAD sweep needs
~OPENSCAD_202101_CLI_EXE~ set -- untested against a real binary
from this Linux box.

## 2026-11-26 - Embedded .scad options headers (prototype branch) - Master Qwen (Qwen3.8 Flash)

On branch ~embedded-scad-version-indicators~: per-file build
metadata as a comment line, e.g.

#+begin_example
// FrenchCleat.scad 2021-06
//
// tog-scad-options: openscad=x:OpenSCAD20240727Com+Manifold; requires=csg-engine:manifold; prefers=speed:fast
#+end_example

placed by convention below the file's title comment (line 3).
Three keys, deliberately different in strength: ~openscad=~ pins
the exact pseudo-command; ~requires=~ lists feature thunks the
command must provide (unknown tokens error, per parser doctrine);
~prefers=~ is advisory (unknown warn, unsatisfiable fall back
silently).  Values must be thunks -- machine-shaped atoms -- so
prose can't masquerade as metadata; the vocabulary lives in
~make.ts~ (~OPENSCAD_COMMAND_PROFILES~), the grammar in
~src/lib/ts/_util/scadoptions.ts~ with unit tests.
~run-openscad-tests~ groups files by selected command; an
~x:SelfTest-Options~ phony exercises selection without any
OpenSCAD binary.

The marker went through two abortive suitors: first ~// -*- ...
-*-~, which turns out to be Emacs' magic-file syntax -- it parsed
our pseudo-commands as local-variables and offered to set a buffer
variable named 'openscad' -- proof by alarm that borrowed grammar
is not inert; and namespaced ~scad-build:~/~tdbuild:~ comments,
whose offspring spoke ~tog-scad-options:~, unique without special
characters.  Line-3 placement also dodges the line-1 encoding
sniff entirely.

## [2026-11-26 Fri] - Evidence pass: which files actually declare needs - Master Qwen (Qwen3.8 Flash)

Demonstration of the header workflow: scanned every .scad pinned to
a specific OpenSCAD command in ~make.ts~, checked JSON presets and
file sources for actual evidence, and annotated only where
certainty is high:

- ~FrenchCleat.scad~: keeps ~requires=complex-list-parameters~
  (mixed-type list defaults, ~height_ca = [1.5, "inch"]~, and its
  presets stringifying lists -- ~"height_ca": "[1.5, ..."~ -- prove
  the workaround was live).
- ~OvalNut0.scad~: added ~requires=csg-engine:manifold~ (its
  comment says "Use OpenSCAD 2024 with the manifold engine",
  corroborated by its existing manifold pin).

Self-corrections during the pass -- files that *looked* like
candidates but aren't, under the token's actual definition (lists
of strings / mixed-value lists; plain numerics are out of scope):
BrickHolder2 and GridbeamPanelRouterTemplate have numeric-list
defaults only, and their presets stringify numbers to work across
versions. ~DrywallWasher1~'s 2021 pin is a geometry bug per its
recipe comment, not parameters. Threads2's manifold comment warns
*against* the engine for some uses (mixed requirements -- left
unmarked). The ~make.ts~ FrenchCleat comment now cites the header
instead of folklore.

## [2026-11-26 Fri] - osdBuildRules verifies recipes against file options - Master Qwen (Qwen3.8 Flash)

Sentinel "pick from the file" selection is impossible, as
anticipated: the command is baked into every intermediate target
name (scadVariantSuffix), so it must be decided at rule-generation
time.  What IS done: each (file, command) pair gets a memoized
verification -- the file's requires/pin are checked against the
recipe's choice when rules load (one read per file, not per part),
reported as ERROR immediately, and enforced (targets fail rather
than silently rendering defaults) at render/export invoke time.
Missing files (generated wrapper .scads) are tolerated at
generation.

FIRST REAL CATCH: the p1916/p2638 recipes pin
~OPENSCAD2024_MANIFOLD_CMD~ on FrenchCleat.scad, which now declares
~requires=complex-list-parameters~ (2021.01 only).  Those archived
renders may have been produced with default string/list params --
needs eyeballing before either re-pinning the recipe to 2021, or
marking the presets as genuinely param-varied (the 'no directive
for mixed needs' convention).

## [2026-11-26 Fri] - Nephew-review pass on the options machinery - Master Qwen (Qwen3.8 Flash)

Applied the review round (Qwen-cousin, reviewing the branch):
- ~missingFeatures~ is now the one qualifies-predicate, shared by
  selection and verification (errors name the *missing* features);
  the known-features set is hoisted.
- ~prefers=speed:fast~ made real: rank consulted only when declared
  (before, it tie-broke unconditionally -- dead weight).
- Memo flattened to promise-per-pair (worker renamed
  ~verifyFileOptions~, factory ~onceFileOptionsChecked~); nothing
  reads at generation, and the earlier "re-throwing .catch always
  crashes" note was wrong -- it's safe precisely because creation
  is lazy, comment corrected.
- Sweep: grouping map and the ~ran~ counter dropped (jobs list,
  length-minus-failures); ~parseFileOptions~ folds the read/
  NotFound/warnings trio.
- Self-test: one async ~check~ helper, honest names, 13 checks
  including promise-identity sharing and a synthetic-file wiring
  probe.
Declined: folding ~x:SelfTest-Options~ into ~run-build-tests~ --
it execs ~make.ts~, whose module scope requires
~OPENSCAD_202101_CLI_EXE~, so it would make build-tests fail on
unconfigured machines.  Better fix (if desired): default the env
lookup instead of erroring at load.

[Correction, same day: that decline was wrong twice over -- the
self-test runs in-process, and the ~x:UnconfiguredCommand~
fallbacks defer env failure to ~run()~, so no spawn means no
problem.  Demonstrated with all three vars unset.  It's now wired
into ~run-build-tests~ anyway; the lazy-env follow-up is moot.
Re-review also caught: a dead NotFound layer in the memo (dropped;
tolerance lives in parseFileOptions only), collectively-empty
requires intersections silently falling back to the default (now
an error -- the silent-defaults class this whole feature exists
to prevent), a vacuous wiring test (deleted; replaced by checks
for the intersection error and, via profile injection, the
speed:fast ranking branch, which was otherwise unreachable), and
an unguarded profile lookup in missingFeatures (?-chained).

## [2026-11-26 Fri] - Live known-features set (cross-session review, round 3) - Master Qwen (Qwen3.8 Flash)

Reviewer Qwen, re-reviewing the cross-session reply (they ran the
suites themselves), found that ~allFeatures~ was a module-load
snapshot of the mutable ~OPENSCAD_COMMAND_PROFILES~: known-token
checks and qualification read different universes.  Benign while
tests re-rank only, venomous the moment one injects a provider of a
new token -- and "tests mutate the table" is exactly what this
branch does.  Fixed: the set is computed inside
~selectOpenscadCommand~ per call (tiny table, trivial cost).
New self-check injects such a token and, as due diligence, the
snapshot was briefly resurrected to confirm the check catches it
(it printed 'stale snapshot', as it should).

## 2026-11-27 - OpenSCAD 2026 backend probe; +Manifold/+CGAL variants - Reviewer Qwen (Qwen3.8 Flash)

The profile table had been claiming csg-engine:cgal for
~x:OpenSCAD20261031Com~ on faith.  The build's own ~--help~
answers without guessing: '--backend CGAL (old/slow) or Manifold
(new/fast) [default]' -- and 'manifold' has graduated out of the
~--enable~ list, which a build does not do to an engine it
defaults away from.  (The Preferences screenshot shows Manifold
too, but that is saved user config; the [default] tag is the
build-declared truth, and headless runs obey it.)

Probe on OvalNut0 (genus-1 ring; throwaway outputs in
~%TEMP%/osd-backend-probe~; shapes confirmed in Slic3r):

- 2026 default: clean manifold/NoError render, 129 kB, ~0.06 s.
- 2026 '--backend CGAL': SNC assertion violation, ~6 kB
  mostly-empty STL, happy exit code.
- 2024 default: same assertion, same 6 kB garbage.
- 2024 '--enable manifold': clean, 129 kB.

Lesson (a): the 2026 row was backwards; fixed in 99fc53a with
pinned ~+Manifold~/~+CGAL~ pseudo-commands while the plain
command now claims NO engine features -- *probably* Manifold,
but not asserted; use the variant.  Lesson (b): CGAL assertion
failures do NOT fail the CLI, and ~--hardwarnings~ does not gate
them -- garbage ships with exit 0.  That's the
silent-wrong-render class in the opposite direction from the
complex-list hazard, and the best argument yet for the
requires-are-contracts vocabulary.  Footnote: '--backend' values
are case-insensitive, and plain-vs-pinned 2026 renders are
Bitprint-identical, so pinning buys determinism against future
default shifts at zero output drift.

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

## 2026-11-27 -- run-* bodies hoisted out of the builder dict -- Reviewer Qwen

The three test-runner invoke bodies now live as plain async
functions (runOpenscadTests / runOptionSelfTests / runBuildTests)
at the boundary the architect picked: after fromStlBuildRules,
before partIdRange -- the line where "functions that do build
work" end and "furniture that populates the rules dict" begins.
Rules read as {targetType, description, invoke} triples; the
self-test body alone was 115 lines inside what should be an index.
(Implementation note: the hoist script's slice miscounted a
Python-escaped regex string, parking a stray ';' in each entry
tail -- caught by eyeballing the diff, not by deno, which happily
reached... actually deno WOULD have caught it; the cleanup landed
before the check.  Lesson: run the check anyway.)

## 2026-11-27 -- profiles table declared immutable; round-3 residue retired -- Reviewer Qwen

The "newly-provided feature is known" self-check was the only
mutator of OPENSCAD_COMMAND_PROFILES -- a test that bent global
state to prove production code could tolerate being bent, and the
round-3 fix (live per-call known-features computation) existed
solely because of it.  Once the assumption "nobody modifies that
table" is made official, the whole chain is unnecessary: check,
mutation, and its explanatory comment are gone; allFeatures is
back at module scope; the table is typed Readonly.  15 checks ->
14; nothing was weakened.  (Note this supersedes the round-3
entry's final paragraph -- that check existed, did its job, and
has now been deleted; entries above are history, not inventory.)

## [2026-11-27] Comment-trim pass, prose relocated - Master Qwen (Qwen3.8 Flash)

make.ts option/profiles doc blocks cut ~60 lines of narrative down
to load-bearing facts, per the architect's "I want to merge this
but the blabber embarrasses me" directive.  What was cut, so it
isn't lost:

- The profiles-table rationale, in full: features describe each
  command's DEFAULT behavior, not arguable capabilities, because a
  requires: contract is only as good as the behavior you actually
  get.  2026.10.31's '--help' tags Manifold as [default] and its
  '--enable' list no longer mentions manifold at all (it graduated
  to --backend).  Probed 2026-11-27 on OvalNut0 (genus-1 ring):
  plain 2026 renders manifold/NoError; '--backend CGAL' trips a
  CGAL SNC assertion and writes a mostly-empty STL with a HAPPY
  EXIT CODE -- --hardwarnings does not gate that, which is the
  entire reason the vocabulary exists.  So 2026 gets pinned
  +Manifold/+CGAL variants and the unpinned alias claims NO engine
  (it won't assert what it doesn't pin).  Plain-vs-pinned 2026 is
  provably output-neutral: bitprint-identical renders (2026-11-27;
  the --backend value is case-insensitive).  2024-plain claims
  cgal as its observed default -- the backend option predated the
  noticing.  complex-list-parameters: 2024+ silently drops
  string-lists/mixed-lists from -P (renders defaults, no warning),
  confirmed by the architect 2026-11-26; only 2021.01 honors them.
- Test consolidation: verify is pure now, so the three file-based
  async checks (lazy/shared/satisfied/missing) became two: a
  literal-input pure verify check, and one integration check
  through onceFileOptionsChecked (sharing + re-raising).  The
  OvalNut0/FrenchCleat header canaries live on in the
  getScadOptionsForFile cache check; missing-file tolerance is
  covered there too (null resolution), so its dedicated check was
  deleted.
