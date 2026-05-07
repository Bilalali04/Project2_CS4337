# Development Log

---

## 2026-05-07 - Session 1 Start

### Thoughts so far

This is Project 2 for CS4337 (Programming Language Paradigms). The goal is to implement a Prolog scheduling backend for a hypothetical webapp that assigns employees to workstations across three shifts: morning, evening, and night.

The core task is to implement `plan/1`, which must unify its argument with a `plan/3` structure. Each of the three arguments in `plan/3` is a list of `workstation/2` structures, where the first field is the workstation name and the second is the list of employees working that station during that shift.

The implementation must satisfy all of the following:
- Every employee is assigned to exactly one workstation for exactly one shift (no gaps, no duplicates).
- Each workstation in a given shift must have between its minimum and maximum number of employees.
- Workstations marked as idle for a given shift must not appear in that shift's schedule.
- No employee can be assigned to a workstation they are listed as avoiding.
- No employee can be assigned to a shift they are listed as avoiding.
- If no valid plan exists, `plan/1` must fail.

The input facts (employees, workstations, constraints) come from a separate file that is consulted alongside the implementation. No external libraries are allowed; the code must run on the cs1 and cs2 machines using standard SWI-Prolog.

### Plan for this session

1. Set up the git repository with an initial README.
2. Create `project2.pl` with the `plan/1` implementation and all supporting predicates.
3. Create `testing.pl` with the professor-provided testing predicates.
4. Write this devlog and a README describing the project structure and how to run it.
5. Commit and push everything.

### Design approach

The central insight is to treat the three shifts as a pipeline. All employees start in a single pool. The morning schedule draws some subset from that pool, and whoever is not assigned to morning passes to the evening pool. Evening draws from that, and whoever remains must fill the night schedule exactly (no leftover employees allowed). This ensures every employee is assigned exactly once.

For each workstation in a shift, I pick between Min and Max employees from the current pool using `between/3` to drive the count, and a recursive predicate `pick_n_eligible/6` to select employees in their original order while skipping those who avoid the station or shift. Skipped employees remain in the pool for subsequent workstations or shifts.

Idle workstations are excluded from a shift's station list via `\+ workstation_idle(W, Shift)` inside a `findall/3` call, so they never appear in the generated schedule.

---

## 2026-05-07 - Session 1 End

### Reflection

Session went smoothly. The pipeline design came together cleanly in Prolog. The three key predicates are:

- `plan/1`: entry point, threads employee pool through morning, evening, night.
- `fill_shift/4`: collects active stations for a shift, delegates to `fill_stations/5`.
- `fill_stations/5`: fills each station recursively, threading the remaining employee pool.
- `pick_n_eligible/6`: picks exactly N valid employees from the pool in original order; ineligible or unneeded employees pass through to the remainder.

Verified design against all five provided sample runs. Sample 2 correctly fails because workstation 5 has min=3 and max=1, making `between(3,1,N)` fail immediately. Sample 1 produces solutions matching the expected output ordering.

Next steps: none for this session. Implementation is complete and all files are committed.

---

## 2026-05-07 - Bug Fix: pick_n_eligible duplicate plans

### Thoughts so far

After reviewing the third clause of `pick_n_eligible/6`, a correctness problem was identified. The original clause had no guard beyond `N > 0`:

```prolog
pick_n_eligible(N, Station, Shift, [E|Es], Chosen, [E|Remaining]) :-
    N > 0,
    pick_n_eligible(N, Station, Shift, Es, Chosen, Remaining).
```

This clause fires for any employee, including those who are fully eligible to work the station and shift. Because the second clause (which picks the employee) and the third clause (which skips the employee) can both fire for the same eligible employee, Prolog generates multiple solutions that assign the same set of employees to the same workstations but arrive at those assignments via different skip/pick orderings. The result is structurally identical plans appearing as separate solutions.

### Fix applied

The third clause was updated to only fire when the employee actually cannot work the station or shift:

```prolog
pick_n_eligible(N, Station, Shift, [E|Es], Chosen, [E|Remaining]) :-
    N > 0,
    ( avoid_shift(E, Shift) ; avoid_workstation(E, Station) ),
    pick_n_eligible(N, Station, Shift, Es, Chosen, Remaining).
```

With this guard in place:
- An eligible employee (avoids neither the shift nor the station) can only be picked (clause 2). There is no longer a choice to skip an eligible employee for a given workstation.
- An ineligible employee can only be skipped (clause 3). Clause 2 fails on them because of the `\+` checks.

The remaining non-determinism in the scheduler now comes entirely from `between(Min, Max, N)`, which tries different headcounts for each workstation. Different headcounts lead to different employees being available for downstream workstations and shifts, producing genuinely distinct plans without duplicates.

### What changed

- `project2.pl`: third clause of `pick_n_eligible/6` now includes the guard `( avoid_shift(E, Shift) ; avoid_workstation(E, Station) )`.

---

## 2026-05-07 - Add example input files for testing

### Thoughts so far

The five example input files provided with the assignment were not yet in the repository. Adding them makes it straightforward to run the scheduler and verify correctness directly from the repo without needing any external files.

### What was added

- `example-input-1.pl`: 26 employees, 3 workstations, one idle station in morning, avoid constraints for ophelia and daniel.
- `example-input-2.pl`: 19 employees, 6 workstations. Workstation 5 has min=3 and max=1, which is impossible, so `plan/1` should fail.
- `example-input-3.pl`: 17 employees, 2 workstations, shift and workstation avoid constraints.
- `example-input-4.pl`: 21 employees, 4 workstations, multiple avoid constraints for workstations and shifts.
- `example-input-5.pl`: 13 employees, 1 workstation, one employee who avoids morning.

These files serve as the primary test suite. Each can be loaded with `swipl` alongside `project2.pl` and `testing.pl` to confirm correct behavior.
