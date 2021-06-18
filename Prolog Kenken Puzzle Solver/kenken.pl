kenken(N,C,T) :-
    length(T, N),
    maplist(length_row(N), T),
    maplist(maplist(#=<(1)), T),
    maplist(maplist(#>=(N)), T),
    transpose(T, TT),
    maplist(fd_all_different, T),
    maplist(fd_all_different, TT),
    add_constraints(C, T),
    maplist(fd_labeling, T).

plain_kenken(N, C, T) :-
    length(T, N),
    maplist(length_row(N), T),
    transpose(T, TT),
    get_list(N, L),
    maplist(permutation(L), T),
    maplist(permutation(L), TT),
    plain_add_constraints(C, T).

get_list(N, L) :- 
    get_list_helper(N, [], L).

get_list_helper(0, L, L) :- 
    !.
get_list_helper(N, R, L) :- 
    N > 0, 
    N1 is N-1, 
    get_list_helper(N1, [N|R], L).

length_row(N, Row) :- length(Row, N).

getColumn1([], [], []).

getColumn1([[X|R] | Z], [X|Xs], [R|Rs]):-
	getColumn1(Z, Xs, Rs).

transpose([[] | _], []).

transpose(M, [R|Rs]):-
	getColumn1(M, R, Z),
	transpose(Z, Rs).

get_cur([R|C], T, N) :-
    nth(R, T, Row),
    nth(C, Row, N).

constraint(_, +(0, [])).
constraint(T, +(S, [Cur|Remain])) :-
    get_cur(Cur, T, X),
    S #= X + Y,
    constraint(T, +(Y, Remain)).

constraint(T, -(D, J, K)) :-
    get_cur(J, T, A),
    get_cur(K, T, B),
    ((D + A #= B, A #\= B); D + B #= A).

constraint(_, *(1, [])).
constraint(T, *(P, [Cur|Remain])) :-
    get_cur(Cur, T, X),
    P #= X * Y,
    constraint(T, *(Y, Remain)).

constraint(T, /(Q, J, K)) :-
    get_cur(J, T, A),
    get_cur(K, T, B),
    ((Q * A #= B, A #\= B); Q * B #= A).

plain_constraint(_, +(0, [])).
plain_constraint(T, +(S, [Cur|Remain])) :-
    get_cur(Cur, T, X),
    Y is S - X,
    plain_constraint(T, +(Y, Remain)).

plain_constraint(T, -(D, J, K)) :-
    get_cur(J, T, A),
    get_cur(K, T, B),
    ((B =:= D + A, A =\= B); A =:= D + B).

plain_constraint(_, *(1, [])).
plain_constraint(T, *(P, [Cur|Remain])) :-
    get_cur(Cur, T, X),
    0 is P mod X, 
    Y is round(P / X),
    plain_constraint(T, *(Y, Remain)).

plain_constraint(T, /(Q, J, K)) :-
    get_cur(J, T, A),
    get_cur(K, T, B),
    ((B is Q * A), A =\= B; A is Q * B).

add_constraints(C, T) :-
    maplist(constraint(T), C).

plain_add_constraints(C, T) :-
    maplist(plain_constraint(T), C).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% measure performance and compare %%%%%%

%% test case

%% kenken_testcase(
%%   4,
%%   [
%%    +(3, [[1|1], [2|1]]),
%%    /(1, [1|2], [2|3]),
%%    *(8, [[1|1],  [2|2], [3|3]]),
%%    -(2, [3|1], [3|2]),
%%    -(1, [4|1], [4|2]),
%%    *(6, [[3|1], [3|3]])
%%   ]
%% ).


%%%% command run %%%

%% | ?- statistics(cpu_time, [SinceStart, SinceLast]).

%% SinceLast = 907
%% SinceStart = 907

%% yes
%% | ?- kenken_testcase(N,C), plain_kenken(N,C,T).

%% C = [3+[[1|1],[2|1]],/(1,[1|2],[2|3]),8*[[1|1],[2|2],[3|3]],-(2,[3|1],[3|2]),-(1,[4|1],[4|2]),6*[[3|1],[3|3]]]
%% N = 4
%% T = [[2,4,3,1],[1,2,4,3],[3,1,2,4],[4,3,1,2]] ? 

%% (410 ms) yes
%% | ?- statistics(cpu_time, [SinceStart, SinceLast]).

%% SinceLast = 412
%% SinceStart = 1319

%% (1 ms) yes
%% | ?- kenken_testcase(N,C), kenken(N,C,T).

%% C = [3+[[1|1],[2|1]],/(1,[1|2],[2|3]),8*[[1|1],[2|2],[3|3]],-(2,[3|1],[3|2]),-(1,[4|1],[4|2]),6*[[3|1],[3|3]]]
%% N = 4
%% T = [[2,4,3,1],[1,2,4,3],[3,1,2,4],[4,3,1,2]] ? 

%% yes
%% | ?- statistics(cpu_time, [SinceStart, SinceLast]).

%% SinceLast = 2
%% SinceStart = 1321

%% yes
%% | ?- 

% We can see that plain_kenken takes 412 milliseconds
% and kenken takes 2 milliseconds.
% Thus, we can see that kenken is much faster than plain_kenken for
% more than 100 times.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% no-op KenKen %%%%%%

% noop_kenken(N, C, T, O)

% N is the grid size

% C is a list of constraints with following form
%    (S, L)
%    S is the target number
%    L is the list of squares
%    S is the result applying the operation +, *, - or / 
%      on the L.

% T a list of list of integers. All the lists have length N. 
% this represents the N×N grid.

% O is list of operations. 
%  Each operation in O is one of +, *, -, /
%  ith operation in O corresponds to ith constraint in C


% noop_kenken_testcase(
% 4,
%  [
%   (3, [[1|1], [2|1]]),
%   (1, [[1|2], [2|3]]),
%   (8, [[1|1],  [2|2], [3|3]]),
%   (2, [[3|1], [3|2]]),
%   (1, [[4|1], [4|2]]),
%   (6, [[3|1], [3|3]])
%  ]
% ).

%% example call

%% ?- fd_set_vector_max(255), noop_kenken_testcase(N,C), noop_kenken_testcase(N,C,T,O).

%% One of the solution is:
% T = [[2,4,3,1],[1,2,4,3],[3,1,2,4],[4,3,1,2]]
% O = [+, /, *, -, -, *]