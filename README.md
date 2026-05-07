# Project2_CS4337

CS4337 - Programming Language Paradigms  
Project 2: Prolog Work Schedule Planner

---

## Files

| File | Role |
|------|------|
| `project2.pl` | Main implementation. Contains `plan/1` and all supporting predicates. This is the file submitted for grading. |
| `testing.pl` | Professor-provided testing predicates: `works_at/4`, `has_work/2`, `no_work/2`, `double_work/2`. Consult alongside `project2.pl` to run verification queries. |
| `devlog.md` | Development log tracking all sessions, design decisions, and progress. |
| `README.md` | This file. |

Five example input files are included for testing (see table below). Any input file must define `employee/1`, `workstation/3`, `workstation_idle/2`, `avoid_workstation/2`, and `avoid_shift/2` facts for a specific scenario.

| File | Description |
|------|-------------|
| `example-input-1.pl` | 26 employees, 3 workstations, one station idle in morning, avoid constraints for two employees. Expected: valid plans exist. |
| `example-input-2.pl` | 19 employees, 6 workstations. Workstation 5 has min=3 and max=1 (impossible), so `plan/1` fails. |
| `example-input-3.pl` | 17 employees, 2 workstations, shift and workstation avoid constraints. Expected: valid plans exist. |
| `example-input-4.pl` | 21 employees, 4 workstations, multiple avoid constraints. Expected: valid plans exist. |
| `example-input-5.pl` | 13 employees, 1 workstation, one employee avoiding morning. Expected: valid plans exist. |

---

## How to Run

### Interactive session in SWI-Prolog

From the command line, load the input file, the implementation, and optionally the testing predicates:

```
swipl example-input-1.pl project2.pl testing.pl
```

Then query the scheduler:

```prolog
?- plan(Plan).
```

Press `;` to see additional solutions, or `.` to stop.

### Verification queries (requires testing.pl)

Check that every employee has been assigned:

```prolog
?- plan(Plan), no_work(Plan, Who).
```

This should return `false` for a valid plan.

Check that no employee appears more than once:

```prolog
?- plan(Plan), double_work(Plan, Who).
```

This should also return `false`.

Check where a specific employee was assigned:

```prolog
?- plan(Plan), works_at(Plan, Shift, alice, Station).
```

### Non-interactive (batch) use

```
swipl -g "consult('example-input-1.pl'), consult('project2.pl'), plan(Plan), write(Plan), nl, halt" -t halt
```

---

## Requirements

- SWI-Prolog (version available on cs1 and cs2)
- No external libraries needed
- Input file must define all required facts before loading `project2.pl`
