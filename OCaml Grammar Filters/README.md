## 1: 
Traverse each element of set a and check if it is in the set b. If it is, check the next element. Otherwise, return false. If all the elements are also in b, return true.

## 2: 
Two sets a b are equal if and only if a is a subset of b and b is a subset of a. Return true for this function if both subset a b and subset b a return true. Otherwise, return false.

## 3: 
Define a helper function set_diff to get the set b - a with elements in b but not a. Append b - a to set a to get the set a + b, which is the union of sets a and b.

## 4: 
Define a helper function set_intersection, which returns the intersection of a and b. Use the set_union function to get the union of a and b. Use the set_diff function to get the set of all members of a union b that are not also members of a intersect b.

## 5: 
Since list is homogenous in OCaml, we can't put an 'a list as an element of an 'a list.

## 6: 
Use recursion to compute the fixed point. At each recursive call, check if eq (f x) x returns true, which means f(x) and x achieve the desired relation. If it returns true, return x as the fixed point. Otherwise, pass f(x) as x to the next recursive call until we find the fixed point.

## 7: 
Find the set of unreachable rules and return members of the set of rules that are not also members of unreachable rules. Pass a set of non-terminals as possible start points, a set of unused rules, and a set of used rules to the helper function unused_rules to recursively update the used and unused rule sets until we use all the non-terminals as start points. Define a helper function matched_rules takes in a non-terminal and a rule set to find rules that have that non-terminal as the left-hand side. Define a helper function get_nonterminals to see all the non-terminals in a given rule set. My initial idea is to traverse each rule and check if it can be reached. I rejected this idea because it is too computationally costly. This idea's weakness could be its space complexity since I use three sets to do recursion.