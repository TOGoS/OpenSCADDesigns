# Instructions for AI agents

(If other *people* ever work on this, some bits could be moved to
a more general CONTRUBUTING.md (or .org).  Until then,
this mixes general contribution guidelines with those that
apply to [presumably but not necessarily LLM-based] agentic coding tools.)

Follow the instructions at
[../../docs/TSoft40/AGENT-STARTER.md](https://github.com/TOGoS/TSoft40/blob/master/AGENT-STARTER.md)
(if that path is missing locally, fetch the GitHub URL), plus
[../../docs/TSoft40/2026/ai-coding/deno-style-guide.md](https://github.com/TOGoS/TSoft40/blob/master/2026/ai-coding/deno-style-guide.md)
for TypeScript work.

## Building

All building goes through `make.ts` (Deno 2.x; `make.bat` wraps it on Windows).

    deno run -A make.ts p1983            # build one part
    deno run -A make.ts run-tests        # OpenSCAD sweep + build tests
    deno run -A make.ts --list-targets   # what's buildable

Location of executables used by the build script is indicated by environemnt variables.
By design, the build script fails fast if a command it needs is undefined.

## Project-specific conventions

- **`print-archive/` is gitignored, append-mostly, and canonical.**
  Never hand-edit or delete archive outputs; rebuild via make.ts.
  Intermediates live in `print-archive/pNNxx/.temp/`.
- **Rebuild staleness is mtime-driven with sidecars.**
  `x:Hardlink` leaves `.<name>.built` markers, consulted via tbuilder's `mtimeFunction` hook;
  do not "fix" staleness by touching mtimes (`utime` on a hardlink restamps the shared inode).
  `x:Readonlify` marks crushed PNGs read-only: temp-tree outputs
  are treated as immutable once written, per the section above.
- **Bump the `*BuilderVersion` constants** (`b13xx`) in `make.ts`
  when a rule's *outputs* change meaning; leave them alone for
  comment/structure-only edits, since a bump invalidates the render chain.
  The `--skip-scad-reruns` / `--allow-scad-reruns` flags govern re-rendering
  of OpenSCAD outputs that already exist to avoid unintended churn.
- **`.scad` directives headers**:
  `// tog-scad-directives: openscad=x:...; requires=...; prefers=...`,
  often on line 3, below the title comment, if there is one.
  `requires` are contracts (the build rejects commands that cannot satisfy them);
  omit the header entirely when needs vary per parameter set.
- **STL sources are URIs or filenames**
  (bitprint URNs, URLs, `file:`/plain paths -- see `decodeResourceName`).
  URN refs are  fetched to a scratch name, hash-verified, then renamed into place.
  Part IDs are `p` + four digits (plus allowed `-suffix` variants),
  which determines their `pNNxx` archive bucket.
- **Tests**: `deno test --allow-read --allow-write --allow-env make.io.test.ts src/lib/ts`
  (or `make.ts run-build-tests`, which also runs the in-process options self-checks).
  Library helpers go in `src/lib/ts/_util/`, with I/O tests in `<basename>.io.test.ts`.

## Commits

Agent-made commits follow the TSoft40 attribution rules.

Do not rewrite history without explicit instruction to do so.
Use `--fixup` to fix recent mistakes, or just note messiness to the architect.

Never push to remotes.  Only the human user should ever run `git push`.

## Notes

Agents may keep notes amongst themselves in `AGENT-DEVLOG.org`.

Design rationale lives in `DEVLOG.org` (entry format:
`## ` + date + ` - ` + title + ` - ` + agent (model);
blank line after the header, wrong turns kept with dated corrections
(the archaeology is the point).

`2023/lib/` holds the OpenSCAD libraries; the shape-list
"TOGMod1" idiom is documented in `README.org`.

## Immutability should be the default assumption, even when not explicit in types

Most values in this codebase are effectively immutable whether or
not their types say so — `Readonly<...>` and `Object.freeze` are
used when the guarantee is *surprising*, not by default, because
annotating everything would clutter the code more than it protects.
Treat module-scope and top-level values as frozen at first use.

- Do not mutate objects you do not own (carried-over guideline, restated because it keeps earning its place):
  the current call's locals and return values are yours;
  objects that were constructed may be modified until made 'public'
  (by returning or by putting in a widely-visible slot).
  Objects reached through a parameter or module-scope binding should
  be considered off-limits for mutation unless modifying them
  is explicitly sanctioned, e.g. intra-process caches.
- Mutation is legitimate only as
  (a) explicit caching — memo maps like `dirsMade` and `fileOptionsChecks`,
  which exist precisely to be written — or
  (b) known, named hacks (e.g. the `--allow-scad-reruns` mode flags).
  Anything else deserves an uncomfortable conversation,
  starting with a why-comment on the mutating line itself.
- This goes for tests, too.
  Tests never temporarily mutate shared state.
  If a test needs unusual inputs, it builds its own literals or passes a parameter;
  it should not e.g. bend a global and restore it in `finally`.
  A test that mutates a constant to pin a workaround creates a
  permanent justification for a workaround that should not have
  existed (see the profiles-table saga, 2026-11-26/27: a test bent
  the table, production was changed to tolerate it, a comment
  explained the tolerance, and a regression check guarded the
  whole loop — four artifacts, one bad assumption).
- If you *are* the owner of an object that outlives the function
  it is created in, and that you will mutate, document the contract
  (mentioning `mutate` or `mutation` in the comment is probably
  good for greppability).
  No explicit documentation is needed for objects that do not escape a given scope.
  The scope itself, combined with our implicitly-understood
  'we don't mutate things we don't own' practice is sufficient.
