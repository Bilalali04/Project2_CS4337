% project2.pl
%
% CS4337 Project 2 - Work Schedule Planner
%
% Implements plan/1, which unifies its argument with a plan/3 structure
% representing morning, evening, and night shift schedules.
%
% Consult this file together with an input facts file, for example:
%   ?- consult('example-input-1.pl'), consult('project2.pl').
%   ?- plan(Plan).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plan(?Plan)
%
% Unifies Plan with plan(Morning, Evening, Night) where each shift is a list
% of workstation(Station, Workers) structures. Every employee is assigned to
% exactly one workstation for exactly one shift. Fails if no valid plan exists.
plan(plan(Morning, Evening, Night)) :-
    findall(E, employee(E), AllEmployees),
    fill_shift(morning, AllEmployees, Morning, AfterMorning),
    fill_shift(evening, AfterMorning, Evening, AfterEvening),
    fill_shift(night, AfterEvening, Night, []).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fill_shift(+Shift, +Employees, -Schedule, -Remaining)
%
% Builds a schedule for Shift by assigning employees to each active workstation.
% Remaining is the list of employees not assigned during this shift.
fill_shift(Shift, Employees, Schedule, Remaining) :-
    findall(W, (workstation(W, _, _), \+ workstation_idle(W, Shift)), Stations),
    fill_stations(Stations, Shift, Employees, Schedule, Remaining).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fill_stations(+Stations, +Shift, +Employees, -Schedule, -Remaining)
%
% Recursively assigns employees to each station in the list.
% Remaining threads through and holds whoever is not yet assigned.
fill_stations([], _, Remaining, [], Remaining).
fill_stations([S|Stations], Shift, Employees, [workstation(S, Workers)|Schedule], Remaining) :-
    workstation(S, Min, Max),
    between(Min, Max, N),
    pick_n_eligible(N, S, Shift, Employees, Workers, RestEmployees),
    fill_stations(Stations, Shift, RestEmployees, Schedule, Remaining).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pick_n_eligible(+N, +Station, +Shift, +Available, -Chosen, -Remaining)
%
% Picks exactly N employees from Available who do not avoid Station or Shift.
% Employees are chosen in the order they appear in Available. Skipped employees
% are kept in Remaining for use in later workstations or shifts.
pick_n_eligible(0, _, _, Rest, [], Rest).
pick_n_eligible(N, Station, Shift, [E|Es], [E|Chosen], Remaining) :-
    N > 0,
    \+ avoid_shift(E, Shift),
    \+ avoid_workstation(E, Station),
    N1 is N - 1,
    pick_n_eligible(N1, Station, Shift, Es, Chosen, Remaining).
pick_n_eligible(N, Station, Shift, [E|Es], Chosen, [E|Remaining]) :-
    N > 0,
    ( avoid_shift(E, Shift) ; avoid_workstation(E, Station) ),
    pick_n_eligible(N, Station, Shift, Es, Chosen, Remaining).
