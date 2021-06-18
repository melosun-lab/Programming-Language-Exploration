(* Homework 1. Fixpoints and grammar filters *)
(* Chuhua Sun *)

(* 
  1. Write a function subset a b that returns true iff (i.e., if and only if) a⊆b, i.e., 
  if the set represented by the list a is a subset of the set represented by the list b. 
  Every set is a subset of itself. This function should be generic to lists of any type: 
  that is, the type of subset should be a generalization of 'a list -> 'a list -> bool.
*)
let rec subset a b = 
  match a with
    | [] -> true
    | _ -> 
      if List.exists (fun e -> e = List.hd a) b then subset (List.tl a) b
      else false;;


(* 
  2. Write a function equal_sets a b that returns true iff the represented sets are equal.
*)
let equal_sets a b =
  if subset a b && subset b a then true
  else false;;

(*
  3. Write a function set_union a b that returns a list representing a∪b.
*)
let rec set_diff a b = 
  match a with
    | [] -> []
    | _ ->
      if List.exists (fun e -> e = List.hd a) b then set_diff (List.tl a) b
      else List.append [List.hd a] (set_diff (List.tl a) b);;

let set_union a b = List.append a (set_diff b a);;

(*
  4. Write a function set_symdiff a b that returns a list representing a⊖b, 
  the symmetric difference of a and b, that is, the set of all members of a∪b 
  that are not also members of a∩b.
*)
let rec set_intersection a b = 
  match a with 
    | [] -> []
    | _ ->
      if not (List.exists (fun e -> e = List.hd a) b) then set_intersection (List.tl a) b
      else List.append [List.hd a] (set_intersection (List.tl a) b);;
let set_symdiff a b = set_diff (set_union a b) (set_intersection a b);;

(*
  5. Russell's Paradox involves asking whether a set is a member of itself. 
  Write a function self_member s that returns true iff the set represented 
  by s is a member of itself, and explain in a comment why your function is 
  correct; or, if it's not possible to write such a function in OCaml, explain 
  why not in a comment.
*)
(*
  We can apply Russell's type theory to consider this problem. In OCaml, we use a list
  to store a set, and every element present in the list is considered an element of the
  set. Also, everything in OCaml must have a type as OCaml has very strict rules for types.
  Therefore, the list we use to represent the set in OCaml should have a type like 'a list.
  For instance, we can have a string list or int list. Then, every element in this list must
  also have same type. Say, an element x in an int list must have an int type. In other words, an
  element could be considered in this set only if it has type int. However, for this entire set
  represented by a list in OCaml, we could never put this list as an element of itself
  because it has an int list type instead of an int type. So it is impossible to write such a
  function in OCaml.
*)

(*
  6. Write a function computed_fixed_point eq f x that returns the computed fixed 
  point for f with respect to x, assuming that eq is the equality predicate for f's domain.
  A common case is that eq will be (=), that is, the builtin equality predicate of OCaml; 
  but any predicate can be used. If there is no computed fixed point, your implementation 
  can do whatever it wants: for example, it can print a diagnostic, or go into a loop, or 
  send nasty email messages to the user's relatives.
*)
let rec computed_fixed_point eq f x =
  match x with
    | x when eq (f x) x = true -> x
    | x -> computed_fixed_point eq f (f x)

(* 
  7.OK, now for the real work. Write a function filter_reachable g that returns a copy 
  of the grammar g with all unreachable rules removed. This function should preserve the 
  order of rules: that is, all rules that are returned should be in the same order as the 
  rules in g.
*)

type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let rec matched_rules lfs rules = 
  match rules with
    | [] -> []
    | _ ->  if fst (List.hd rules) = lfs then List.append [(List.hd rules)] (matched_rules lfs (List.tl rules))
            else matched_rules lfs (List.tl rules);;

let rec get_nonterminals rhs = 
  match rhs with 
    | [] -> []
    | N head::tail -> List.append [head] (get_nonterminals tail)
    | T _::tail -> get_nonterminals tail;;

let rec unused_rules start unused used = 
  match start, unused, used with
    | start, unused, used when subset start used = true -> unused
    | start, unused, used -> 
      let cur_rules = matched_rules (List.hd start) unused in
      let cur_rhs = List.flatten (snd (List.split cur_rules)) in
      let unused_nonterminals = List.append (List.tl start) (set_diff (get_nonterminals cur_rhs) used) in 
      unused_rules unused_nonterminals (set_diff unused cur_rules) (List.append [List.hd start] used);;
let filter_reachable g = (fst g, set_diff (snd g) (unused_rules [fst g] (snd g) []));;