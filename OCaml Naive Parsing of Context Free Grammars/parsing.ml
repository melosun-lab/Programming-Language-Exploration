type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

(* 1. Convert Homework 1-style grammar to Homework 2-style grammar *)
let rec alternative_list rhs start = match rhs with
  | [] -> []
  | hd::tl ->
    if (fst hd) = start then List.append [snd hd] (alternative_list tl start)
    else alternative_list tl start 

let convert_grammar gram1 = (fst gram1, alternative_list (snd gram1))

(* 2. Traverse the parse tree left to right and yields a list of the leaves encountered. *)
let rec traverse cur = match cur with
  | [] -> []
  | hd::tl -> match hd with
    | Node (_, children) -> List.append (traverse children) (traverse tl)
    | Leaf terminal -> List.append [terminal] (traverse tl)
  
let parse_tree_leaves tree = traverse [tree]

type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num

(* Returns a matcher for the grammar gram. When applied to an acceptor accept and a fragment frag, 
the matcher must try the grammar rules in order and return the result of calling accept on the suffix 
corresponding to the first acceptable matching prefix of frag *)
let rec search_rules gram rules acceptor fragment = match rules with
  | [] -> None
  | hd::tl -> match search_rule gram hd acceptor fragment with
    | None -> search_rules gram tl acceptor fragment
    | Some ans -> Some ans
and search_rule gram rule acceptor fragment = match rule with
  | [] -> acceptor fragment
  | hd::tl -> match hd with 
    | N nonterminal -> search_rules gram ((snd gram) nonterminal) (search_rule gram tl acceptor) fragment
    | T terminal -> match fragment with
      | [] -> None
      | first::remain -> match first, remain with
        | first, remain when first = terminal -> search_rule gram tl acceptor remain
        | _, _ -> None
let make_matcher gram acceptor fragment = search_rules gram ((snd gram) (fst gram)) acceptor fragment

(* Returns a parser for the grammar gram. When applied to a fragment frag,
the parser returns an optional parse tree. *)
let rec parse_rules gram rules acceptor fragment = match rules with
  | [] -> None
  | hd::tl -> match parse_rule gram hd acceptor fragment with
    | None -> parse_rules gram tl acceptor fragment 
    | Some next -> Some (hd::next)
and parse_rule gram rule acceptor fragment = match fragment with
  | [] -> (match rule with 
    | []  -> acceptor []
    | _ -> None)
  | hd::tl -> match rule with
    | [] -> acceptor fragment
    | current::remain -> match current with
      | N start -> parse_rules gram ((snd gram) start) (parse_rule gram remain acceptor) fragment
      | T terminal -> match terminal with
        | terminal when terminal = hd -> parse_rule gram remain acceptor tl
        | _ -> None 


let acceptor fragment = match fragment with
  | [] -> Some []
  | _ -> None

let rec get_children tmp_rhs children = match tmp_rhs with
  | [] -> children
  | hd::tl -> match hd with 
    | N nonterminal -> get_children tl (children@[Node (nonterminal, [])])
    | T terminal -> get_children tl (children@[Leaf terminal])


let rec build path root = match path with
  | [] -> (path, root)
  | hd::tl -> match root with
    | Leaf _ -> (path, root)
    | Node (nonterminal, _) ->
        let children = get_children hd [] in
        let cur_children, traced = trace_rhs children tl in
        
        let cur_root = Node(nonterminal, cur_children) in
        traced, cur_root
and trace_rhs children rule = match children with
  | [] -> ([], rule)
  | hd::tl -> 
    let cur = build rule hd in
    let next = trace_rhs tl (fst cur) in
    (snd cur)::(fst next), snd next     

let make_parser gram frag = match frag with
  | [] -> None
  | _ -> match parse_rules gram ((snd gram) (fst gram)) acceptor frag with
    | None -> None
    | Some path -> match build path (Node ((fst gram), [])) with
      | ([], root) -> Some root
      | _ -> None
;;

(* let match_nucleotide nt frag accept = 
  match frag with
    | [] -> None
    | n::tail -> if n == nt then accept tail else None

let append_matchers matcher1 matcher2 frag accept =
  matcher1 frag (fun frag1 -> matcher2 frag1 accept)

let make_appended_matchers make_a_matcher ls =
  let rec mams = function
    |[] -> match_empty
    |head::tail -> append_matchers (make_a_matcher head) (mams tail)
in mams ls *)
