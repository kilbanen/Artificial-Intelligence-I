arc([H|T],Node,Cost,KB) :- member([H|B],KB), append(B,T,Node),
                           length(B,L), Cost is 1+ L/(L+1).

extendPair(OldPair,NewPair,KB) :-
                      OldPair = [Path,OldCost],
                      Path = [PHead|_],
                      arc(PHead,Node,ArcCost,KB),
                      NewPath = [Node|Path],
                      NewCost is OldCost + ArcCost,
                      NewPair = [NewPath,NewCost].

heuristic(Node,H) :- length(Node,H).

goal([]).

add2frontier(Children,Frontier,NewFrontier) :- add2frontier(Children,Frontier,[],NewFrontier).

add2frontier([],[],Acc,RevAcc) :- reverse(Acc,RevAcc).
add2frontier(Children,Frontier,Acc,NewFrontier) :-
                      Children = [CHead|CTail],
                      Frontier = [FHead|FTail],
                      ( less-than(CHead,FHead)
                      -> add2frontier(CTail,Frontier,[CHead|Acc],NewFrontier)
                      ;  add2frontier(Children,FTail,[FHead|Acc],NewFrontier)
                      ).
add2frontier(Children,Frontier,Acc,NewFrontier) :-
                      Children = [CHead|CTail],
                      Frontier = [],
                      add2frontier(CTail,Frontier,[CHead|Acc],NewFrontier).
add2frontier(Children,Frontier,Acc,NewFrontier) :-
                      Children = [],
                      Frontier = [FHead|FTail],
                      add2frontier(Children,FTail,[FHead|Acc],NewFrontier).
                      
search([Pair|_],Path,Cost,_) :- 
                      Pair = [Path,Cost],
                      Path = [Node|_],
                      goal(Node).
search([Pair|More],FinalPath,FinalCost,KB) :-
                      findall(NewPair,extendPair(Pair,NewPair,KB),Children),
                      add2frontier(Children,More,New),
                      search(New,FinalPath,FinalCost,KB).

less-than([[Node1|_],Cost1],[[Node2|_],Cost2]) :-
  heuristic(Node1,Hvalue1), heuristic(Node2,Hvalue2),
  F1 is Cost1+Hvalue1, F2 is Cost2+Hvalue2,
  F1 =< F2.

astar(Node,Path,Cost,KB) :- search([[[Node],0]],ReversePath,Cost,KB), reverse(ReversePath, Path).
