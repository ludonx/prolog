
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

/* donne la liste des sommets qui contient le motif Motif
  sommet_induit(+NomF,+ListeMotif,-L)
  NomF : nom du fichier où se trouve le graph
  ListeMotif : liste de motif que l'on recherche
  L : liste des sommet induit
*/
sommet_induitX(NomF,ListeMotif,L) :-
    read_dot_file(NomF, att_graph(S,A)),
    findall(X,
      (
      member(Si,S),
      Si=sommet(X,ListeMotifDuSommetX),
      member_liste(ListeMotif,ListeMotifDuSommetX)
      )
      ,L),
      open('sommet.txt',write,Stream),
      write(Stream,L),  nl(Stream),
      close(Stream).

sommet_induitSi(NomF,ListeMotif,L) :-
    read_dot_file(NomF, att_graph(S,A)),
    findall(Si,
      (
      member(Si,S),
      Si=sommet(X,ListeMotifDuSommetX),
      member_liste(ListeMotif,ListeMotifDuSommetX)
      )
      ,L),
      open('sommetSi.txt',write,Stream),
      write(Stream,L),  nl(Stream),
      close(Stream).
/* remarque, si on remplace le 1er parametre de findall
par X,on obtient la liste des sommet L = [b, e, n, r]
par Si, on obtient L = [sommet(b, [rock, folk, blues, jazz]), sommet(e, [rock, folk, blues]), sommet(n, [rock, folk, pop, blues]), sommet(r, [rock, folk, pop,
blues])] ;*/
/*
exemple d'utilisation :
?- sommet_induit("mougel_bis.dot",[rock,blues],L).
L = [sommet(b, [rock, folk, blues, jazz]), sommet(e, [rock, folk, blues]), sommet(n, [rock, folk, pop, blues]), sommet(r, [rock, folk, pop,
blues])] ;
false.

*/

/* arete_induit(+NomF,+ListeMotif, -L)*/

arete_induit(NomF,ListeMotif,L) :-
  read_dot_file(NomF, att_graph(S,A)),
  findall(Ai,
    (
    member(Ai,A),
    Ai=arete(X, Y),
    sommet_induitX(NomF,ListeMotif,Ls),
    member(X,Ls),
    member(Y,Ls)
    )
    ,L),
    open('arete.txt',write,Stream),
    write(Stream,L),  nl(Stream),
    close(Stream).

/*
exemple :
?- arete_induit("mougel_bis.dot",[rock],L).
L = [arete(a, b), arete(a, c), arete(a, d), arete(a, e), arete(a, k), arete(a, r), arete(b, c), arete(b, d), arete(..., ...)|...]

arete_induit(NomF,ListeMotif, Ai,X,Y) :-
  read_dot_file(NomF, att_graph(S,A)),
  member(Ai,A),
  Ai=arete(X, Y),
  sommet_induit(NomF,ListeMotif,SX,X),
  sommet_induit(NomF,ListeMotif,SY,Y),
  open('hogwarts.txt',append,Stream),
  write(Stream,Ai),  nl(Stream),
  close(Stream).
*/

graph_induit(NomF,ListeMotif,NomGi,LS,LA) :-
  sommet_induitSi(NomF,ListeMotif,LS),
  arete_induit(NomF,ListeMotif,LA),
  open(NomGi,write,Stream),
  writeln(Stream,LS),  nl(Stream),
  writeln(Stream,LA),  nl(Stream),
  close(Stream).
/*?- graph_induit("mougel_bis.dot",[rock,blues],"Gi_rock,blues",LS,LA)*/
