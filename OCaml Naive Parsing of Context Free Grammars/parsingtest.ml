type jungler_nonterminals = 
  | Farm | Invade | Gank | Trap | Area

let jungle_grammar = 
  (Farm,
    function
      | Farm -> 
        [[T "Standby"; N Farm];
          [N Gank];
          [N Area; N Invade; N Farm];
          [N Area; N Farm];
          [N Trap]]
      | Invade -> 
        [[T "Jug"]]
      | Trap ->
        [[T "Baron"];
        [T "Dragon"]]
      | Gank -> 
        [[T "Active"; N Area];
          [T "Counter"; N Area]]
      | Area ->
        [[T "Top"];
          [T "Mid"];
          [T "Bot"];
          [T "Jug"]]
  )
let accept_all string = Some string
let small_jungle_frag = ["Standby"; "Mid"; "Jug"; "Counter"; "Top"]

let make_matcher_test = 
  ((make_matcher jungle_grammar accept_all ["Standby"; "Mid"; "Jug"; "Counter"; "Top"; "Baron"]) = Some ["Baron"])
let make_parser_test = 
  match make_parser jungle_grammar small_jungle_frag with
    | Some tree -> parse_tree_leaves tree = small_jungle_frag
    | _ -> false
