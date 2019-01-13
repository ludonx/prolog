/*********************************Question 1************************/
/*member_liste(+ListeMotif,+Liste)
permet de verifier si une liste de motif appartient a une autre Liste
exemple :
?- member_liste([a,b,c],[a,b,c,d,e]).
true ;
false.

on suppose ici qu'a chaque fois on fournira les deux parametre et on
s'interese uniquement à si la ListeMotif appartient a la liste
*/
member_liste([],_Liste).
member_liste([X|ListeMotif],Liste):-member(X,Liste),member_liste(ListeMotif,Liste).

/* donne la liste des sommets qui contient un liste de motif donnné
  sommet_induit(+NomF,+ListeMotif,-L)
  +NomF : nom du fichier qui contient le graph
  +ListeMotif : liste contenant les motifs que l'on recherche
  -L : liste des sommets induit
*/
sommet_induitX(G,ListeMotif,L) :-
    G=att_graph(S,_A),
    findall(X,
      (
      member(Si,S),
      Si=sommet(X,ListeMotifDuSommetX),
      member_liste(ListeMotif,ListeMotifDuSommetX)
      )
      ,L).

sommet_induitSi(G,ListeMotif,L) :-
    G=att_graph(S,_A),
    findall(Si,
      (
      member(Si,S),
      Si=sommet(_X,ListeMotifDuSommetX),
      member_liste(ListeMotif,ListeMotifDuSommetX)
      )
      ,L).
/* remarque, si on remplace le 1er parametre de findall
par X,on obtient la liste des sommet L = [b, e, n, r]
par Si, on obtient L = [sommet(b, [rock, folk, blues, jazz]), sommet(e, [rock, folk, blues]), sommet(n, [rock, folk, pop, blues]), sommet(r, [rock, folk, pop,
blues])] ;

exemple d'utilisation :
?- sommet_induit("mougel_bis.dot",[rock,blues],L).
L = [sommet(b, [rock, folk, blues, jazz]), sommet(e, [rock, folk, blues]), sommet(n, [rock, folk, pop, blues]), sommet(r, [rock, folk, pop,
blues])] ;
false.

*/

/* arete_induit(+NomF,+ListeMotif, -L)
+NomF : nom du fichier qui contient le graph
+ListeMotif : liste contenant les motifs que l'on recherche
-L : liste des aretes induit

*/

arete_induit(G,ListeMotif,L) :-
  G=att_graph(_S,A),
  findall(Ai,
    (
    member(Ai,A),
    Ai=arete(X, Y),
    sommet_induitX(G,ListeMotif,Ls),
    member(X,Ls),
    member(Y,Ls)
    )
    ,L).

/*
exemple :
?- arete_induit("mougel_bis.dot",[rock],L).
L = [arete(a, b), arete(a, c), arete(a, d), arete(a, e), arete(a, k), arete(a, r), arete(b, c), arete(b, d), arete(..., ...)|...]

*/

/*graph_induit(+NomF,+ListeMotif,+NomGi,-LS,-LA,-LM)
+NomF : nom du fichier qui contient le graph
+ListeMotif : liste contenant les motifs que l'on recherche
+NomGi : nom du fichier qui contiendra le graph induit
-LS : liste des sommets induit
-LA : liste des aretes induit
-LM : liste des Gouts musicaux du graph induit
*/
graph_induit(G,ListeMotif,Gi) :-
  sommet_induitSi(G,ListeMotif,LS),
  arete_induit(G,ListeMotif,LA),
  Gi=att_graph(LS,LA).

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

/*union_gout_music(+LS,-LM)
+LS: liste des sommets
-LM: liste des Gouts musicaux liés à la liste de sommets
 permet de trouve la liste des Gouts musicaux sans doublons
 du graph a partir de la liste des sommets

*/
union_gout_music([X],Y):- X = sommet(_A,Y).
union_gout_music([TLS|LS],LM):-
  TLS=sommet(_X,ListeMotifDuSommetXTLS),
  union_gout_music(LS,L),
  union(ListeMotifDuSommetXTLS,L,LM).

/*
exemple :
?- union_gout_music([sommet(b,[rock,folk,blues,jazz]),sommet(e,[rock,folk,blues,a,r])],X).
X = [a, r, rock, folk, blues, jazz] ;
false.
*/

/*union(+L1,+L2,-LM).
LM=L1+L2
union de deux liste sans doublons
https://stackoverflow.com/questions/46899153/making-a-union-of-two-lists-in-prolog

*/
union([],[],[]).
union(List1,[],List1).
union(List1, [Head2|Tail2], [Head2|Output]):-
    \+(member(Head2,List1)), union(List1,Tail2,Output).
union(List1, [Head2|Tail2], Output):-
    member(Head2,List1), union(List1,Tail2,Output).



/*  write_sommet(+NomGi,+LS).
permet d'ecrire dans un fichier la liste des sommets,
de façon à respecter la syntaxe des fichiers .dot
+NomF : nom du fichier qui contient le graph
+LS : liste des sommets que l'on veux ecrire dans le fichier
*/
write_sommet(_NomGi,[]).
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

/*write_arete(+NomGi,+LA)
permet d'ecrire dans un fichier la liste des aretes,
de façon à respecter la syntaxe des fichiers .dot
+NomF : nom du fichier qui contient le graph
+LA : liste des aretes que l'on veux ecrire dans le fichier
*/
write_arete(_NomGi,[]).
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

/*write_dot_file(+NomGi,+LS,+LA,+LM)
permet d'ecrire un graph dans un fichier
*/
write_dot_file(NomGi,G):-
  G=att_graph(LS,LA),
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



/*********************************Question 2************************/
/* ----------------------- DEGRE -------------------- */
/* degre_sommet(+S,+LA,-N)
+S: un sommets du graphe
+LA : la liste d'arete du graph
-N : le nombre d'arete sortante et entrante dans la sommet S

degre d'un sommet S conaissant la liste d'arete LA
?- degre_sommet(sommet(a, [rock, folk, jazz]),[arete(a, b), arete(a, c), arete(a, d), arete(b, c), arete(b, d), arete(c, d), arete(c, g)],N).
N = 3 ;
false.

remarque:
(X = X1 , X = X2) -> N=2 dans le cas d'une arete sur un meme sommet
ex: arete(a,a)
*/
degre_sommet(_S,[],N):- N=0.
degre_sommet(S,A,N):-
  S=sommet(X,_ListeMotifDuSommetX),
  A=arete(X1,X2),
  ((X = X1 , X = X2) -> N = 2;(X = X1 ; X = X2) -> N=1;N=0).
degre_sommet(S,[A|LA],N):-
  degre_sommet(S,A,N1),
  degre_sommet(S,LA,N2),
  N is N1+N2.

/*sommet_abstrait(+LS,+LA,-LSa,+Deg)
permet d'obtenir la liste des aretes ayant un degres superieur a Deg
+LS : Liste des sommets
+LA : Liste des aretes
-LSa : Liste des sommets abstrait : sommets avec un degres superieur à Deg
+Deg:  degres de comparaison : entier positif

on extrait la liste des sommet de degre superieur a Deg
ex:
?- sommet_abstrait([sommet(a, [rock, folk, jazz]),sommet(c, [rock, folk, jazz])],[arete(a, b), arete(a, c), arete(a, d), arete(b, c), aret
e(b, d), arete(c, d), arete(c, g)],LSa,2).

LSa = [sommet(a, [rock, folk, jazz]), sommet(c, [rock, folk, jazz])] ;
false.
*/
sommet_abstrait([],_LA,[],_Deg).
sommet_abstrait(S,LA,LSa,Deg):-
  degre_sommet(S,LA,N),
  (N >= Deg -> append([S],[],LSa);append([],[],LSa) ).
sommet_abstrait([S|LS],LA,LSa,Deg):-
  sommet_abstrait(S,LA,LSa1,Deg),
  sommet_abstrait(LS,LA,LSa2,Deg),
  append(LSa1,LSa2,LSa).

/*arete_abstrait(+LSa,+LA,-LAa)

permet d'obtenir la liste des aretes ayant ayant des sommet de degres superieur a Deg
+LSa : Liste des sommets abstrait
+LA : Liste des aretes
-LAa : Liste des aretes abstraits: aretes avec un degres superieur à Deg
+Deg:  degres de comparaison : entier positif


?- arete_abstrait([sommet(a, [rock, folk, jazz]),sommet(c, [rock, folk, jazz])],[arete(a, b), arete(a, c), arete(a, d), arete(b, c), arete
(b, d), arete(c, d), arete(c, g)],LAa).
LAa = [arete(a, c)] ;
false.

ex:
?- arete_abstrait([sommet(a,[rock,folk,jazz]),sommet(b,[rock,folk,blues,jazz]),sommet(c,[rock,folk,jazz]),sommet(d,[rock,folk,jazz])]
,[arete(a,b),arete(a,c),arete(a,d),arete(f,d),arete(b,c)]
,LAa).
[arete(b,c)]
[arete(a,d)]
[arete(a,c)]
[arete(a,b)]
LAa = [arete(a, b), arete(a, c), arete(a, d), arete(b, c)] ;
false.
*/
arete_abstrait(_LSa,[],[]).
arete_abstrait(LSa,A,LAa):-
  A=arete(X,Y),
  member(Sa1,LSa),
  member(Sa2,LSa),
  Sa1 \= Sa2,
  ((Sa1=sommet(X,_LMX),Sa2=sommet(Y,_LMY));(Sa1=sommet(Y,_LMX2),Sa2=sommet(X,_LMY2))),
  append([A],[],LAa),!.

arete_abstrait(LSa,[A|LA],LAa):-
  (arete_abstrait(LSa,A,LAa1) ->
                              arete_abstrait(LSa,LA,LAa2),
                              append(LAa1,LAa2,LAa)
                              ;
                              arete_abstrait(LSa,LA,LAa2),
                              LAa2=LAa
  ).


/*graph_abstrait_deg(NomFichG,ListeMotif,NomFichGi,NomFichGa,Deg)
graph_abstrait_deg('deg.dot',[rock],'degi.dot','dega.dot',2)

?- graph_abstrait_deg('mougel_bis.dot',[rock,bleus],'Gi.dot','Ga.dot',2).


Nb sommets = 6
Nb aretes = 8
[sommet(a,[rock,folk,jazz]),sommet(b,[rock,folk,blues,jazz]),sommet(c,[rock,folk,jazz]),sommet(d,[rock,folk,jazz]),sommet(f,[rock,folk,pop
,jazz])]
[arete(a,b),arete(a,c),arete(a,d),arete(b,c),arete(f,d)]
false.

sommet_abstrait([sommet(a,[rock,folk,jazz]),sommet(b,[rock,folk,blues,jazz]),sommet(c,[rock,folk,jazz]),sommet(d,[rock,folk,jazz]),sommet(f,[rock,folk,pop
,jazz])]
,[arete(a,b),arete(a,c),arete(a,d),arete(b,c),arete(f,d)]
,LSa,2).

arete_abstrait([sommet(a,[rock,folk,jazz]),sommet(b,[rock,folk,blues,jazz]),sommet(c,[rock,folk,jazz]),sommet(d,[rock,folk,jazz])]
,[arete(a,b),arete(a,c),arete(a,d),arete(b,c),arete(f,d)]
,LAa)
*/


/*graph_abstrait_deg("deg.dot",[rock],"degi.dot","dega.dot",2)

*/
/*graph_abstrait_deg_S_A_M(+LS,+LA,-LSa,-LAa,-LMa,+Deg,NomFichGa)
+LS : Liste des sommets
+LA : liste des aretes
-LSa : liste des sommets abstrait
-LAa : Liste des aretes abstrait
-LMa : Liste des motif du graphe abstrait
+Deg : degres de comparaison : entier positif
+NomFichGa : nom du fichier ou sera sauvegarde le graphe abstrait
*/
degre(Gi,Ga,Deg):-
  Gi=att_graph(LS,LA),
  sommet_abstrait(LS,LA,LSa,Deg),
  arete_abstrait(LSa,LA,LAa),
  Ga1=att_graph(LSa,LAa),
  (Gi=Ga1 -> Ga=Ga1;degre(Ga1,Ga,Deg)).

/*------------------ TRIANGLE ------------------ */
/* le cut pour eviter d'avoir des solutions multiple pour un meme sommet */

sommet_abstrait_triangle([],_LA,[]).
sommet_abstrait_triangle(S,LA,LSa):-
  S=sommet(X,_LM),
  (member(arete(X,Y),LA);member(arete(Y,X),LA)),
  (member(arete(Y,Z),LA);member(arete(Z,Y),LA)),
  (member(arete(Z,X),LA);member(arete(X,Z),LA)),
  !,
  append([S],[],LSa).

sommet_abstrait_triangle([S|LS],LA,LSa):-
  (
    sommet_abstrait_triangle(S,LA,LSa1);
    sommet_abstrait_triangle([],LA,LSa1)
  ),
  sommet_abstrait_triangle(LS,LA,LSa2),
  append(LSa1,LSa2,LSa).

triangle(G_in,G_out):-
  G_in=att_graph(LS,LA),
  sommet_abstrait_triangle(LS,LA,LSa),
  arete_abstrait(LSa,LA,LAa),
  G_out=att_graph(LSa,LAa),!.

/*------------------ ETOILE ------------------ */
/* si le sommet est de deg superieur a Deg et qu'il n'est
pas encore dans la liste alors on ajout sinon on regarde
si il existe un sommet vosin qui respecte la condition et on l'ajout */
sommet_abstrait_etoile([],_LA,[],_Deg).
sommet_abstrait_etoile([S|LS],LA,LSa,Deg):-
  not(member(S,LSa)),
  degre_sommet(S,LA,N),
  (N >= Deg -> append([S],[],LSa)
               ;
               S=sommet(X,_LM),
               (arete(X,Y);arete(Y,X)),
               SY=sommet(Y,_LMY),
               degre_sommet(SY,LA,NY),
               NY >= Deg,
               append([S],[],LSa)
  ).
sommet_abstrait_etoile([S|LS],LA,LSa,Deg):-
  sommet_abstrait(S,LA,LSa1,Deg),
  sommet_abstrait(LS,LA,LSa2,Deg),
  append(LSa1,LSa2,LSa).
