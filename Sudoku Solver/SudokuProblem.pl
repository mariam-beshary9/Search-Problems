% It is a program that solves Sudoku game, implemented using Breadth First search. I have implemented it with help of Eng. Sarah Elnady, her email: s.elnady@fci-cu.edu.eg

board([x,2,6,x,x,x,8,1,x,
	 3,x,x,7,x,8,x,x,6,
	 4,x,x,x,5,x,x,x,7,
	 x,5,x,1,x,7,x,9,x,
	 x,x,3,9,x,5,1,x,x,
	 x,4,x,3,x,2,x,5,x,
	 1,x,x,x,3,x,x,x,2,
	 5,x,x,2,x,4,x,x,9,
	 x,3,8,x,x,x,4,6,x]).


validRow(9,_,_,_):-!.

validRow(Num,Value,BaseIndex,Board):-
	not(nth0(BaseIndex,Board, Value)),
	BaseIndex2 is BaseIndex +1,
	Num2 is Num+1,
	validRow(Num2,Value,BaseIndex2,Board).

validateRow(Board,Index,Value):-
	BaseIndex is (Index-(Index mod 9)),
	validRow(0,Value,BaseIndex,Board).
	
validCol(9,_,_,_):-!.

validCol(Counter,Value,BaseIndex,Board):-
	not(nth0(BaseIndex,Board, Value)),
	BaseIndex2 is BaseIndex+9,
	Counter2 is Counter+1,
	validCol(Counter2,Value,BaseIndex2,Board).

validateCol(Board,Index,Value):-
	BaseIndex is Index mod 9,
	validCol(0,Value,BaseIndex,Board).


validBox(Board,Row,Col,Value):-
	Index1 is (Row*9)+Col,
	Index2 is ((Row+1)*9)+Col,
	Index3 is ((Row+2)*9)+Col,

	Index4 is (Row*9)+Col+1,
	Index5 is ((Row+1)*9)+Col+1,
	Index6 is ((Row+2)*9)+Col+1,

	Index7 is (Row*9)+Col+2,
	Index8 is ((Row+1)*9)+Col+2,
	Index9 is ((Row+2)*9)+Col+2,

	not(nth0(Index1 ,Board, Value)),
	not(nth0(Index2 ,Board, Value)),
	not(nth0(Index3 ,Board, Value)),

	not(nth0(Index4,Board, Value)),
	not(nth0(Index5 ,Board, Value)),
	not(nth0(Index6 ,Board, Value)),

	not(nth0(Index7,Board, Value)),
	not(nth0(Index8 ,Board, Value)),
	not(nth0(Index9 ,Board, Value)).


validateBox(Board,Index,Value):-
	Col is Index mod 9,
	Row is Index//9,
	BasicRow is (Row //3)*3,
	BasicCol is Col-(Col mod 3),
	validBox(Board,BasicRow,BasicCol,Value).


checkValidChild(Board,Index,Value):-
	%printList(Board),nl,
	validateRow(Board,Index,Value),
	validateCol(Board,Index,Value),
	validateBox(Board,Index,Value).

appending([],L,L).
appending([H|T],L,[H|Z]):- appending(T,L,Z).

% generateChild return a new list contains all valid new  states 
generateChildren(Num,_,_, States ,States):-
	Num = 10,!.

generateChildren(Num,HeadList, TailList, States ,NewStates):-
	
	appending(HeadList,[Num],NewList_ ),
	appending(NewList_ ,TailList,NewList),

	appending(HeadList,[x],OldList_ ),
	appending(OldList_ ,TailList,OldList),

	% NewList represents the board after modification
	length(HeadList, N ),
	checkValidChild(OldList,N,Num),
	not(member(NewList,States)),
	NewNum is Num+1,
	appending(States,[NewList],NewStatesList),!,
	generateChildren(NewNum,HeadList, TailList,NewStatesList ,NewStates).

generateChildren(Num,HeadList, TailList, States,NewStates):-
        appending(HeadList,[Num],NewList_ ),
	appending(NewList_ ,TailList,NewList),

	appending(HeadList,[x],OldList_ ),
	appending(OldList_ ,TailList,OldList),
	length(HeadList, N ),
	(member(NewList,States) ,!; not(checkValidChild(OldList,N,Num))),
	NewNum is Num+1,
	generateChildren(NewNum,HeadList, TailList,States,NewStates).


printList(_,[]).
printList(Counter,[Head|Tail]):-
	Counter<9,
	write(Head),write(' '),
	Counter2 is Counter +1,
	printList(Counter2,Tail).

printList(Counter,[Head|Tail]):-
	Counter2 is 0,
	write(' '),nl,
	printList(Counter2,[Head|Tail]).
	
% base case if did not find x in the board => now we finish the program
allChildren(HeadList,[],States,NewStates):-
	!,%printList(HeadList),nl,
	NewStates =[HeadList|HeadList].

% base case if we found x
allChildren(HeadList,[Head|TailList],States,NextState):-
	Head = x,!,
	generateChildren(1,HeadList, TailList, States ,Children),
	NextState = Children.
	
allChildren(HeadList,[Head|TailList],States,NewStates):-
	not(Head=x),
	appending(HeadList,[Head],NewHeadList), 
	allChildren(NewHeadList,TailList,States,NewStates).

state(_,Remainder,[Head|Tail]):-
	not(member(x,Head)),!,write('Solution is:'),nl,
	printList(0,Head),nl.

state(HeadList,[Head|TailList],States):-
	%it gets new states of each parent
	allChildren(HeadList,[Head|TailList],[],NewStates),
	% adding children to original list( contains parent and uncles)
	appending(States,NewStates,[AllStatesHead|AllStatesTail]),
	% to remove the parent
	[NewAllStatesHead|NewAllStatesTail] = AllStatesTail,% printList(NewAllStatesHead),nl,
	state([],NewAllStatesHead,AllStatesTail).
	
% run the program with this rule	
sudoku():-
	board(X),
	state([],X,[X]).
