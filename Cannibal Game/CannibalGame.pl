% available moves
% 1) get two or one demon to left
 
moveL(s(DR,AR,DL,AL),s(DR2,AR,DL2,AL)):- 
DR>1,
DR2 is DR-2,
DL2 is DL+2.

moveL(s(DR,AR,DL,AL),s(DR2,AR,DL2,AL)):- 
DR>0,
DR2 is DR-1,
DL2 is DL+1.

% 2) get two or one angle to left
moveL(s(DR,AR,DL,AL),s(DR,AR2,DL,AL2)):-
AR>1, 
AR2 is AR-2,
AL2 is AL+2.

moveL(s(DR,AR,DL,AL),s(DR,AR2,DL,AL2)):- 
AR>0,
AR2 is AR-1,
AL2 is AL+1.

% 3) get one angle and one demon to left
moveL(s(DR,AR,DL,AL),s(DR2,AR2,DL2,AL2)):- 
AR>0,
DR>0,
AR2 is AR-1,
AL2 is AL+1,
DR2 is DR-1,
DL2 is DL+1.

% 4) get two or one demon back to right
moveR(s(DR,AR,DL,AL),s(DR2,AR,DL2,AL)):- 
DL>1,
DL2 is DL-2,
DR2 is DR +2.

moveR(s(DR,AR,DL,AL),s(DR2,AR,DL2,AL)):- 
DL>0,
DL2 is DL-1,
DR2 is DR +1.

% 5) get two or one angle back to right
moveR(s(DR,AR,DL,AL),s(DR,AR2,DL,AL2)):- 
AL>1,
AL2 is AL-2,
AR2 is AR +2.

moveR(s(DR,AR,DL,AL),s(DR,AR2,DL,AL2)):- 
AL>0,
AL2 is AL-1,
AR2 is AR +1.

% 6) get one angle and one demon to right
moveR(s(DR,AR,DL,AL),s(DR2,AR2,DL2,AL2)):-
AL>0,
DL>0, 
DL2 is DL-1,
DR2 is DR +1,
AL2 is AL-1,
AR2 is AR +1.
%A game aims to move 3 men & 3 demons from right bank side to left bank side based on some constrains.
unsafe(s(DR,AR,DL,AL)):-
AR\=0,
DR>AR.

unsafe(s(DR,AR,DL,AL)):-
AL\=0,
DL>AL.


game(S,B):-
path(S,B,[S],[S],[S],G),!,printList(G).


printList([]).
printList([Head|Tail]):-
printList(Tail),
write(Head), nl.

%base case: 3 angles & 3 demons are on the left
path(s(0,0,3,3),1,Visited1,Visited2,Visited,Visited).

path(State,0,Visited1,Visited2,Visited,G):-
moveL(State,NextState),
not(unsafe(NextState)),
not(member(NextState,Visited1)),
NewB =1,
path(NextState,NewB,[NextState|Visited1],Visited2,[NextState|Visited],G).

path(State,1,Visited1,Visited2,Visited,G):-
moveR(State,NextState),
not(unsafe(NextState)),
not(member(NextState,Visited2)),
NewB =0,
path(NextState,NewB,Visited1,[NextState|Visited2],[NextState|Visited],G).
