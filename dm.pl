
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
  NomF : nom du fichier qui contient le graph
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

*/

/*
https://stackoverflow.com/questions/46899153/making-a-union-of-two-lists-in-prolog

union de deux liste sans doublons
*/
union([],[],[]).
union(List1,[],List1).
union(List1, [Head2|Tail2], [Head2|Output]):-
    \+(member(Head2,List1)), union(List1,Tail2,Output).
union(List1, [Head2|Tail2], Output):-
    member(Head2,List1), union(List1,Tail2,Output).

/* permet de trouve la liste des Gouts musicaux sans doublons
 du graph a partir de la liste des sommet

exemple :
?- union_gout_music([sommet(b,[rock,folk,blues,jazz]),sommet(e,[rock,folk,blues,a,r])],X).
X = [a, r, rock, folk, blues, jazz] ;
false.
*/
union_gout_music([X],Y):- X = sommet(A,Y).
union_gout_music([TLS|LS],LM):-
  TLS=sommet(X,ListeMotifDuSommetXTLS),
  union_gout_music(LS,L),
  union(ListeMotifDuSommetXTLS,L,LM).

/*  write_sommet(NomGi,LS).
NomF : nom du fichier qui contient le graph
LS :
S=sommet(X,ListeMotifDuSommetX),
*/
write_sommet(NomGi,[]).
write_sommet(NomGi,[S|LS]):-
  S=sommet(X,ListeMotifDuSommetX),
  open(NomGi,append,Stream),
  write(Stream,"  "),
  write(Stream,X),
  write(Stream," [label="""),
  write(Stream,X),
  write(Stream," "),
  write(Stream,ListeMotifDuSommetX),
  writeln(Stream,"""];"),
  close(Stream),
  write_sommet(NomGi,LS).

/*write_arete(NomGi,LA)
NomF : nom du fichier qui contient le graph
LA:
A=arete(X,Y),
*/
write_arete(NomGi,[]).
write_arete(NomGi,[A|LA]):-
  A=arete(X,Y),
  open(NomGi,append,Stream),
  write(Stream,"  "),
  write(Stream,X),
  write(Stream," -- "),
  write(Stream,Y),
  writeln(Stream,";"),
  close(Stream),
  write_arete(NomGi,LA).

/*graph_induit(+NomF,+ListeMotif,+NomGi,-LS,-LA,-LM)
+NomF :
+ListeMotif :
+NomF : nom du fichier qui contient le graph
-LS :
-LA :
-LM :
*/
graph_induit(NomF,ListeMotif,NomGi,LS,LA,LM) :-
  sommet_induitSi(NomF,ListeMotif,LS),
  arete_induit(NomF,ListeMotif,LA),
  union_gout_music(LS,LM),


  open(NomGi,write,Stream),
  writeln(Stream,"Graph {"),
  writeln(Stream,"  labelloc=top;"),
  writeln(Stream,"  fontsize=18;"),
  write(Stream,"  label=""Gouts musicaux, "),
  write(Stream,LM),
  writeln(Stream,""";"),
  close(Stream),

  write_sommet(NomGi,LS),
  write_arete(NomGi,LA),

  open(NomGi,append,Stream2),
  writeln(Stream2,"}"),
  close(Stream2).
/*
?- graph_induit("mougel_bis.dot",[rock,blues],"G1.dot",LS,LA,LM).
LS = [sommet(b, [rock, folk, blues, jazz]), sommet(e, [rock, folk, blues]), sommet(n, [rock, folk, pop, blues]), sommet(r, [rock, folk, po
p, blues])],
LA = [arete(n, r)],
LM = [pop, rock, folk, blues, jazz] ;
false.


?- graph_induit("G1.dot",[rock,blues],"G2.dot",LS,LA,LM)
LS = [sommet(b, [rock, folk, blues, jazz])],
LA = [],
LM = [rock, folk, blues, jazz] ;
*/
