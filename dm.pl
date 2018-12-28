
/*
conc([],L,L).
conc([X,L1],L2,[X,L3]) :- conc(L1,L2,L3).
*/

/*

sommet_induit(NomF, Si,Motif) :-
    read_dot_file(NomF, att_graph(S,A)),
    member(Si,S),
    Si=sommet(X,Lm),
    member(Motif,Lm).

sommet_induit(NomF, Si,Motif1,Motif2) :-
    read_dot_file(NomF, att_graph(S,A)),
    member(Si,S),
    Si=sommet(X,Lm),
    member(Motif1,Lm),
    member(Motif2,Lm).

    Si = sommet(b, [rock, folk, blues, jazz]) ;
    Si = sommet(e, [rock, folk, blues]) ;
    Si = sommet(n, [rock, folk, pop, blues]) ;
    Si = sommet(r, [rock, folk, pop, blues]) ;

*/
/*member_liste(+ListeMotif,+Liste)
permet de verifier si une liste de motif appartient a une autre Liste
exemple :
?- member_liste([a,b,c],[a,b,c,d,e]).
true ;
false.

on suppose ici qu'a chaque fois on fournira les deux parametre et on
s'interese uniquement à si la ListeMotif appartient a la liste
*/
member_liste([],Liste).
member_liste([X|ListeMotif],Liste):-member(X,Liste),member_liste(ListeMotif,Liste).
liste(X,L, [X | L]).
/* donne la liste des sommets qui contient le motif Motif
  sommet_induit(+NomF, -Si,+Motif)
*/
sommet_induit(NomF, Si,ListeMotif) :-
    read_dot_file(NomF, att_graph(S,A)),
    member(Si,S),
    Si=sommet(X,ListeMotifDuSommetX),
    member_liste(ListeMotif,ListeMotifDuSommetX).
sommet_induit(NomF, Si,ListeMotif,[Si|Liste_Si]) :-
    read_dot_file(NomF, att_graph(S,A)),
    member(Si,S),
    Si=sommet(X,ListeMotifDuSommetX),
    member_liste(ListeMotif,ListeMotifDuSommetX).
/*
exemple :
?- sommet_induit("mougel_bis.dot",Si,[rock,blues])
Si = sommet(b, [rock, folk, blues, jazz]) ;
Si = sommet(e, [rock, folk, blues]) ;
Si = sommet(n, [rock, folk, pop, blues]) ;
Si = sommet(r, [rock, folk, pop, blues]) ;

*/

/* arete_induit(+NomF, -Ai)
arete_induit(NomF, Ai) :-
  read_dot_file(NomF, att_graph(S,A)),
  sommet_induit(NomF, Si,ListeMotif)
  member(Ai,A),
  Si=sommet(X,ListeMotifDuSommetX),
  member_liste(ListeMotif,ListeMotifDuSommetX).
  */