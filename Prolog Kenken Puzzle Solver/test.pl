kenken_testcase(
  6,
  [
   +(11, [[1|1], [2|1]]),
   /(2, [1|2], [1|3]),
   *(20, [[1|4], [2|4]]),
   *(6, [[1|5], [1|6], [2|6], [3|6]]),
   -(3, [2|2], [2|3]),
   /(3, [2|5], [3|5]),
   *(240, [[3|1], [3|2], [4|1], [4|2]]),
   *(6, [[3|3], [3|4]]),
   *(6, [[4|3], [5|3]]),
   +(7, [[4|4], [5|4], [5|5]]),
   *(30, [[4|5], [4|6]]),
   *(6, [[5|1], [5|2]]),
   +(9, [[5|6], [6|6]]),
   +(8, [[6|1], [6|2], [6|3]]),
   /(2, [6|4], [6|5])
  ]
).

kenken_testcase2(
  3,
  [
   /(1, [1|3], [3|1]),
   *(18, [[1|1], [2|3], [3|3]])
  ]
).

    maplist(permutation(), T),
    maplist(permutation(), TT).

plain_constraint(_, +(0, [])).
plain_constraint(T, +(S, [Cur|Remain])) :-
    get_cur(Cur, T, X),
    Y is X - S,
    plain_constraint(T, +(Y, Remain)).

  
plain_constraint(_, *(1, [])).
plain_constraint(T, *(P, [Cur|Remain])) :-
    get_cur(Cur, T, X),
    Y is round(X / P),
    plain_constraint(T, *(Y, Remain)).

plain_constraint(T, -(D, J, K)) :-
    get_cur(J, T, A),
    get_cur(K, T, B),
    ((B =:= D + A, A =\= B); A =:= D + B).

plain_constraint(T, /(Q, J, K)) :-
    get_cur(J, T, A),
    get_cur(K, T, B),
    ((B =:= Q * A, A =\= B); A =:= Q * B).

plain_constraint(_, *(1, [])).
plain_constraint(T, *(P, [Cur|Remain])) :-
    get_cur(Cur, T, X),
    0 is P mod X, 
    Y is round(P / X),
    plain_constraint(T, *(Y, Remain)).

plain_helper(T, Y, P, []) :- Y is P.
plain_helper(T, Y, P, [[Cur|Nxt]| Remain]) :-
    nth(Cur, T, Z),
    nth(Nxt, Z, X),
    Yn is Y * X,
    plain_helper(T, Yn, P, Remain).
plain_constraint(T, *(P, L)) :-
    plain_helper(T, 1, P, L).


transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).

transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).
lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).