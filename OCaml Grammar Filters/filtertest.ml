let my_subset_test0 = subset [] [1;2;3;4]
let my_subset_test1 = subset [2;4] [4;1;3;2]
let my_subset_test2 = not (subset [1;2;3;4] [1;2;3])

let my_equal_sets_test0 = equal_sets [] []
let my_equal_sets_test1 = equal_sets [3;4;5] [5;4;3]
let my_equal_sets_test2 = not (equal_sets [2;4;6] [4;6;1])

let my_set_union_test0 = equal_sets (set_union [] [1;2;3;4]) [1;2;3;4]
let my_set_union_test1 = equal_sets (set_union [1;2;3;4] [1;2;5;6]) [1;2;3;4;5;6]
let my_set_union_test2 = equal_sets (set_union [1;2;3;4] [1;2;3;4]) [1;2;3;4]

let my_set_symdiff_test0 = equal_sets (set_symdiff [] []) []
let my_set_symdiff_test1 = equal_sets (set_symdiff [1;2;3] [3]) [1;2]
let my_set_symdiff_test2 = equal_sets (set_symdiff [1;2;3;4] [4;1;2;5]) [3;5]

let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> if x - 2 < 0 then 0 else x - 2) 100 = 0
let my_computed_fixed_point_test1 = computed_fixed_point (=) (abs) (-10) = 10
let my_computed_fixed_point_test2 = computed_fixed_point (fun x y -> x + y > 10) (fun x -> x + 1) 1 = 5

type jungler_nonterminals = 
  | Farm | Invade | Gank | Trap | Area

let jungler_rules = 
  [ Farm, [T "Standby"; N Farm];
    Farm, [N Gank];
    Farm, [N Farm; N Invade; N Farm];
    Farm, [N Area; N Farm];
    Farm, [N Trap];
    Invade, [T "Jug"; N Farm];
    Trap, [T "Baron"];
    Trap, [T "Dragon"];
    Gank, [T "Active"; N Area];
    Gank, [T "Counter"; N Area];
    Area, [T "Top"];
    Area, [T "Mid"];
    Area, [T "Bot"];
    Area, [T "Jug"]]

let jungler_grammar = Farm, jungler_rules

let my_filter_reachable_test0 = 
  filter_reachable jungler_grammar = jungler_grammar

let my_filter_reachable_test1 = 
  filter_reachable (Farm, List.tl jungler_rules) = (Farm, List.tl jungler_rules)

let my_filter_reachable_test2 = 
  filter_reachable (Invade, jungler_rules) = (Invade, jungler_rules)

  let my_filter_reachable_test3 = 
    filter_reachable (Gank, jungler_rules) = 
    (Gank, 
      [
        Gank, [T "Active"; N Area];
        Gank, [T "Counter"; N Area];
        Area, [T "Top"];
        Area, [T "Mid"];
        Area, [T "Bot"];
        Area, [T "Jug"]]
    )

let my_filter_reachable_test4 = 
  filter_reachable (Farm, List.tl (List.tl (List.tl jungler_rules))) =
  (Farm,
    [ Farm, [N Area; N Farm];
      Farm, [N Trap];
      Trap, [T "Baron"];
      Trap, [T "Dragon"];
      Area, [T "Top"];
      Area, [T "Mid"];
      Area, [T "Bot"];
      Area, [T "Jug"]]
  )
;;
(* #use "hw1.ml";;
#use "hw1test.ml";; *)