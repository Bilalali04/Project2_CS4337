% testing.pl
%
% Some predicates you can use to test the result of your project.
% When querying plan/1, you can include one of the predicates below as a goal.
%
%   ?- plan(Plan), no_work(Plan, Person).
%
% This will succeed if you successfully generate a plan, but there is someone
% that has not been assigned to a workstation.

works_at([], _, _) :- fail.
works_at([workstation(Station, Workers)|_], Worker, Station) :-
    member(Worker, Workers), !.
works_at([_|T], Worker, Station) :-
    works_at(T, Worker, Station).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% works_at(Plan, Shift, Worker, Station)
%
% Succeeds if Worker is assigned to
% Station during Shift.
works_at(plan(Morning, _, _), morning, Worker, Station) :-
    works_at(Morning, Worker, Station).
works_at(plan(_, Evening, _), evening, Worker, Station) :-
    works_at(Evening, Worker, Station).
works_at(plan(_, _, Night), night, Worker, Station) :-
    works_at(Night, Worker, Station).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% has_work(Plan, Worker)
%
% Succeeds if Worker is assigned to
% a workstation during some shift.
has_work(plan(Morning, _, _), Worker) :-
    works_at(Morning, Worker, _).
has_work(plan(_, Evening, _), Worker) :-
    works_at(Evening, Worker, _).
has_work(plan(_, _, Night), Worker) :-
    works_at(Night, Worker, _).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% no_work(Plan, Worker)
%
% Succeeds if Worker is not assigned
% to any workstation.
no_work(Plan, Worker) :-
    employee(Worker),
    \+ has_work(Plan, Worker).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% double_work(Plan, Worker)
%
% Succeeds if Worker is assigned to
% more than one workstation or shift.
double_work(Plan, Worker) :-
    employee(Worker),
    works_at(Plan, Shift1, Worker, Station1),
    works_at(Plan, Shift2, Worker, Station2),
    different_work(Shift1, Shift2, Station1, Station2).

different_work(Shift1, Shift2, _, _) :- Shift1 \= Shift2.
different_work(_, _, Station1, Station2) :- Station1 \= Station2.
