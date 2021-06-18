## Function 1. 
For this function, I traverse the rhs to construct the grammar with 
homework1-style to homework2-style, which is to use production function to
represent rules with respective to different starting symbols.

## Function 2.
For this function, I traverse the given tree and match each node of the tree
with Node type and Leaf type to find the values of all the terminals in 
a pre-order manner.

## Function 3.
For this function, I build two mutually recursive functions to match and the 
prefix of the given pattern and check if the suffix could be accepted. One of 
the two function is focusing on search all the rules from a specific start
point, while the other one is focusing on search all the items in a specific 
rule that passed in from the first function.

## Function 4.
For this function, I modified the logic of make_matcher from matching the prefix
of the given input to trace the entire path from the starting symbol until the
entire patten is perfectly matched. If it cannot be match, an None will be
returned.

## Function 3 & Function 4 Assessment.
For this part, I decide not to write make_parser in term of make matcher.
Even though the basic logics of make_parser and make matcher are very similar,
the exact output we want for these two parts are not the same. 
For make_matcher, We focus on checking whether we can match a prefix and accept
the suffix from the given pattern. On the other hand, for make_parser, we want
to check if the entire given pattern can be matched. More importantly, we have
to trace the path of rules of how we match the whole given pattern from the
start symbol. Although I think it is possible to alter the design of
make_matcher to enable make_parser to reuse it, I realized that such kind of 
modification would make the idea very abstract and lead to a reduction in 
readability. Moreover, if we re-design the make_matcher idea to fulfill the 
requirement of make_parser, I think it is very likely that we need to construct
some helper methods to achieve what we want for make_matcher. For the issue of
duplication, the recursing conditions for make_matcher and make_parser is
different. Moreover, the more important part of make_parser is actually how we
construct the tree. And there is no duplication for the entire tree
construction. For the weakness of my solution, as we mentioned, code
duplication is one of the issues as there should be some viable ways that we
could reuse make_matcher in the make_parser to avoid duplication for the
pattern matching process. Moreover, I believe it is also possible to match the
pattern and build the tree at the same time. If that is the case, that kind
of solution would be more efficient and concise than my solution, which is
based on the idea of finding the path of matching before constructing
the tree. Thus, duplication and efficiency could be two of the potential
weakness of my solution. From the aspect of intended application. My solution
will not work for some specific input grammar which would lead to an infinite
loop and cause stack overflow issue. To be more specific, if we have a rule
that has Expr as the left-hand side and N Expr, which is the same type, as
the first item of the right-hand side, then my algorithm will go from Expr
to Expr and to Expr in an infinite loop. There, my solution cannot reach a
correct solution for this specific kind of input grammar. Also, since cannot
throw any exception in my function, once such input is passed in, the program
will receive an error of stack overflow. Hence, the issue with processing
this specific kind of inputs another weakness of my solution. For future
improvement, I should focus on avoiding the issue of code duplication as we
discussed for the matching parts of make_matcher and make_parser. Moreover,
my solution would be more powerful it can process more special grammar such
as the one would lead to infinite loop. Also, my solution would be more safe
if I can handle some exception cases such as infinite looping. 