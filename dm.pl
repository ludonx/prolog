/*********************************Question 1************************/

/*
 *                           _       _____          _       _ _
 *                          | |     |_   _|        | |     (_) |
 *      __ _ _ __ __ _ _ __ | |__     | | _ __   __| |_   _ _| |_
 *     / _` | '__/ _` | '_ \| '_ \    | || '_ \ / _` | | | | | __|
 *    | (_| | | | (_| | |_) | | | |  _| || | | | (_| | |_| | | |_
 *     \__, |_|  \__,_| .__/|_| |_|  \___/_| |_|\__,_|\__,_|_|\__|
 *      __/ |         | |
 *     |___/          |_|
 *
 '
 */


/*graphe_induit(+G,+ListeMotif,-Gi)
+G : Graph donnée
+ListeMotif : liste contenant les motifs que l'on recherche
-LS : liste des sommets induit
-LA : liste des aretes induit
-LM : liste des Gouts musicaux du graph induit

?- read_dot_file("mougel_bis.dot",G),graphe_induit(G,[rock,blues],Gi),write_dot_file("Gi_rock_blues.dot",Gi).
Gi = att_graph([sommet(b, [rock, folk, blues, jazz]), sommet(e, [rock, folk, blues]), sommet(n, [rock, folk, pop, bl
ues]), sommet(r, [rock, folk, pop|...])], [arete(n, r)]) ;

*/
graphe_induit(G,ListeMotif,Gi) :-
 sommet_induitSi(G,ListeMotif,LS),
 arete_induit(G,ListeMotif,LA),
 Gi=att_graph(LS,LA).


/* donne la liste des sommets qui contient un liste de motif donnné
 sommet_induit(+G,+ListeMotif,-L)
 +G : Graph donnée
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

 */

 /* arete_induit(+G,+ListeMotif, -L)
 +G : Graph donnée
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


/*member_liste(+ListeMotif,+Liste)
permet de verifier si une liste de motif appartient a une autre Liste
exemple :
?- member_liste([a,b,c],[a,b,c,d,e]).
true ;
false.

on suppose ici qu a chaque fois on fournira les deux parametre et on
s interese uniquement à si la ListeMotif appartient a la liste
*/

member_liste([],_Liste).
member_liste([X|ListeMotif],Liste):-member(X,Liste),member_liste(ListeMotif,Liste).

/*union_gout_music(+LS,-LM)
+LS: liste des sommets
-LM: liste des Gouts musicaux liés à la liste de sommets
 permet de trouve la liste des Gouts musicaux sans doublons
 du graph a partir de la liste des sommets
 exemple :
 ?- union_gout_music([sommet(b,[rock,folk,blues,jazz]),sommet(e,[rock,folk,blues,a,r])],X).
 X = [a, r, rock, folk, blues, jazz] ;
 false.
*/
union_gout_music([X],Y):- X = sommet(_A,Y).
union_gout_music([TLS|LS],LM):-
  TLS=sommet(_X,ListeMotifDuSommetXTLS),
  union_gout_music(LS,L),
  union(ListeMotifDuSommetXTLS,L,LM).

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


/***
 *                   _ _            _       _      __ _ _
 *                  (_) |          | |     | |    / _(_) |
 *    __      ___ __ _| |_ ___   __| | ___ | |_  | |_ _| | ___
 *    \ \ /\ / / '__| | __/ _ \ / _` |/ _ \| __| |  _| | |/ _ \
 *     \ V  V /| |  | | ||  __/| (_| | (_) | |_  | | | | |  __/
 *      \_/\_/ |_|  |_|\__\___| \__,_|\___/ \__| |_| |_|_|\___|
 *                          ______           ______
 *                         |______|         |______|
 '
 */

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



/*  write_sommet(+NomGi,+LS).
permet d'ecrire dans un fichier la liste des sommets,
de façon à respecter la syntaxe des fichiers .dot
+NomGi : nom du fichier qui contient le graph
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
+NomGi : nom du fichier qui contient le graph
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


/*********************************Question 2************************/
/***
 *     _                   _         _                  _   _
 *    | |                 | |       | |                | | (_)
 *    | | ___  ___    __ _| |__  ___| |_ _ __ __ _  ___| |_ _  ___  _ __  ___
 *    | |/ _ \/ __|  / _` | '_ \/ __| __| '__/ _` |/ __| __| |/ _ \| '_ \/ __|
 *    | |  __/\__ \ | (_| | |_) \__ \ |_| | | (_| | (__| |_| | (_) | | | \__ \
 *    |_|\___||___/  \__,_|_.__/|___/\__|_|  \__,_|\___|\__|_|\___/|_| |_|___/
 *
 *
 '
 */

/***
 *         _
 *        | |
 *      __| | ___  __ _ _ __ ___  ___
 *     / _` |/ _ \/ _` | '__/ _ \/ __|
 *    | (_| |  __/ (_| | | |  __/\__ \
 *     \__,_|\___|\__, |_|  \___||___/
 *                 __/ |
 *                |___/

 */

 /*
 +LS : Liste des sommets
 +LA : liste des aretes
 -LSa : liste des sommets abstrait
 -LAa : Liste des aretes abstrait
 -LMa : Liste des motif du graphe abstrait
 +Deg : degres de comparaison : entier positif
 */

 /* degre(+Gi,-Ga,+Deg)
 +Gi :Graph induit
 -Ga: Graph abstrait
 +Deg: degres des sommets recherché
 permet de determiner les graph abstrait de degres >= Deg
 */

 degre(Gi,Ga,Deg):-
   Gi=att_graph(LS,LA),
   sommet_abstrait_degres(LS,LA,LSa,Deg),
   arete_abstrait(LSa,LA,LAa),
   Ga1=att_graph(LSa,LAa),
   (Gi=Ga1 -> Ga=Ga1;degre(Ga1,Ga,Deg)).


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

/*sommet_abstrait_degres(+LS,+LA,-LSa,+Deg)
permet d'obtenir la liste des aretes ayant un degres superieur a Deg
on extrait la liste des sommet de degre superieur a Deg
*/
sommet_abstrait_degres([],_LA,[],_Deg).
sommet_abstrait_degres(S,LA,LSa,Deg):-
  degre_sommet(S,LA,N),
  (N >= Deg -> append([S],[],LSa);append([],[],LSa) ).

sommet_abstrait_degres([S|LS],LA,LSa,Deg):-
  sommet_abstrait_degres(S,LA,LSa1,Deg),
  sommet_abstrait_degres(LS,LA,LSa2,Deg),
  append(LSa1,LSa2,LSa).

/*arete_abstrait(+LSa,+LA,-LAa)
permet d'obtenir la liste des aretes ayant ayant des sommet de degres superieur a Deg
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
                              LAa2=LAa % sinon arete abstrait = arete abstraite de la liste arete exclu le premier element
  ).




/***
 *     _        _                   _
 *    | |      (_)                 | |
 *    | |_ _ __ _  __ _ _ __   __ _| | ___
 *    | __| '__| |/ _` | '_ \ / _` | |/ _ \
 *    | |_| |  | | (_| | | | | (_| | |  __/
 *     \__|_|  |_|\__,_|_| |_|\__, |_|\___|
 *                             __/ |
 *                            |___/
 */

/* le cut pour eviter d avoir des solutions multiple pour un meme sommet */

/*
triangle(+G_in,-G_out)
+G_in: Graph en entrée
-G_out: Graph en sorti
Permet de determiner un graph donc tous les sommet appartient à un triangle
*/
triangle(G_in,G_out):-
  G_in=att_graph(LS,LA),
  sommet_abstrait_triangle(LS,LA,LSa),
  arete_abstrait(LSa,LA,LAa),
  G_out=att_graph(LSa,LAa),!.


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


  /***
   *           _           _  _
   *          | |         (_)| |
   *      ___ | |_   ___   _ | |  ___
   *     / _ \| __| / _ \ | || | / _ \
   *    |  __/| |_ | (_) || || ||  __/
   *     \___| \__| \___/ |_||_| \___|
   *
   *
   */

etoile(G_in,G_out,Deg):-
  G_in=att_graph(LS,LA),
  sommet_abstrait_degres(LS,LA,LSa,Deg),
  sommet_voisin(G_in,LSa,LSv),
  writeln("lsv-------"),
  writeln(LSv),
  union(LSa,LSv,LSe),
  writeln("lseeeee-------"),
  writeln(LSe),
  arete_abstrait(LSe,LA,LAa),
  G_out=att_graph(LSe,LAa).


sommet_voisin(G,S,LSv):-
  G=att_graph(LS,LA),
  findall(Sv,
    (
    member(S,LS),
    S=sommet(X,_LMX),
    (member(arete(X,Y),LA);member(arete(Y,X),LA)),
    Sv=sommet(Y,_LMY),
    member(Sv,LS) % pour recuperer la liste des motifs
    )
    ,LSv).
sommet_voisin(G,LSr,LSv):-
findall(Sv,
  (
  member(S,LSr),
  sommet_voisin(G,S,LSv1),
  member(Sv,LSv1)
  )
  ,L),
  retirer_dbl(L, LSv),!. % !!!! faire un cut si besoin

/* retirer_dbl(+List, -NewList):
   NewList Nouvelle liste sans les élements en double de List.

 regle le vide par le vide*/
retirer_dbl([], []).
/*
 regle si le premier element de la liste (Premier) appartient
 à Reste alors	 enleve le et appel,
 retirer_dbl avec le reste de la liste (Premier à disparu)*/

retirer_dbl([Premier | Reste], NReste) :-
    member(Premier, Reste),
    retirer_dbl(Reste, NReste).

/* regle si le Premier element de la liste n'est pas
 membre  du Reste, garde le car [Premier|Nreste] et appel
 retirer_dbl*/
retirer_dbl([Premier | Reste], [Premier | NReste]) :-
    not(member(Premier, Reste)),
    retirer_dbl(Reste, NReste).

/*
sommet_voisin(G,LS,LSv2),
sommet_voisin(G,S,LSv1),
union(LSv1,LSv2,LSv).
sommet_voisin([S|LS],LSv):-
  sommet_voisin(S,[Sv|LS],LA,LSv):-
    S=sommet(X,_LMX),
    (member(arete(X,Y),LA);member(arete(Y,X),LA)),
    (
    (Sv=sommet(Y,_LMY), append([S],[],LSv)),
    (sommet_voisin(S,LS,LA,LSv);append([],[],LSv))
    ).
  sommet_voisin(S,[],LA,[]).
  */
/* si le sommet est de deg superieur a Deg et qu il n est
pas encore dans la liste alors on ajout sinon on regarde
si il existe un sommet vosin qui respecte la condition et on l ajout */
/*
sommet_voisin(S,[Sv|LS],LA,LSv):-
  S=sommet(X,_LMX),
  (member(arete(X,Y),LA);member(arete(Y,X),LA)),
  (
  (Sv=sommet(Y,_LMY), append([S],[],LSv)),
  (sommet_voisin(S,LS,LA,LSv);append([],[],LSv))
  ).
sommet_voisin(S,[],LA,[]).

sommet_abstrait_etoile([],_LA,[],_Deg).
sommet_abstrait_etoile(S,LA,LSa,Deg):-
  degre_sommet(S,LA,N),
  (
  N >= Deg ->
          append([S],[],LSa1),
          sommet_voisin(S,LS,LA,LSv),
          union(LSa1,LSv,LSa)
          ;
          LSa=[]
  ).
sommet_abstrait_etoile([S|LS],LA,LSa,Deg):-
  (sommet_abstrait_etoile(S,LA,LSa1,Deg);LSa1=[]),
  (sommet_abstrait_etoile(LS,LA,LSa2,Deg);LSa2=[]),
  append(LSa1,LSa2,LSa).

arete_abstrait_etoile(_LSa,[],_LAa).
arete_abstrait_etoile(LSa,[A|LA],LAa):-
  (A=arete(X,Y);A=arete(Y,X)),
  member(S,LSa),
  S=sommet(X,_LM),
  append([A],[],LSa),
  arete_abstrait(LSa,LA,LAa).

etoile(G_in,G_out,Deg):-
    G_in=att_graph(LS,LA),
    sommet_abstrait_etoile(LS,LA,LSa,Deg),
    arete_abstrait_etoile(LSa,LA,LAa),
    G_out=att_graph(LSa,LAa).

sommet_abstrait_etoile(S,LA,LSa,Deg):-
  S=sommet(X,_LM),
  degre_sommet(S,LA,N),
  (N >= Deg -> append([S],[],LSa)).*/


/***
 *                                                     _
 *                                                    | |
 *      ___ ___  _ __ ___  _ __   ___  ___  __ _ _ __ | |_ ___    ___ ___  _ __  _ __   _____  _____
 *     / __/ _ \| '_ ` _ \| '_ \ / _ \/ __|/ _` | '_ \| __/ _ \  / __/ _ \| '_ \| '_ \ / _ \ \/ / _ \
 *    | (_| (_) | | | | | | |_) | (_) \__ \ (_| | | | | ||  __/ | (_| (_) | | | | | | |  __/>  <  __/
 *     \___\___/|_| |_| |_| .__/ \___/|___/\__,_|_| |_|\__\___|  \___\___/|_| |_|_| |_|\___/_/\_\___|
 *                        | |
 *                        |_|
 */






/***
*                                ______         _       _               _
*                                | ___ \       (_)     | |             (_)
*      ___ ___   ___ _   _ _ __  | |_/ /__ _ __ _ _ __ | |__   ___ _ __ _  ___
*     / __/ _ \ / _ \ | | | '__| |  __/ _ \ '__| | '_ \| '_ \ / _ \ '__| |/ _ \
*    | (_| (_) |  __/ |_| | |    | | |  __/ |  | | |_) | | | |  __/ |  | |  __/
*     \___\___/ \___|\__,_|_|    \_|  \___|_|  |_| .__/|_| |_|\___|_|  |_|\___|
*                                                | |
*                                                |_|
'
*/







/***
 *                   _         _             __  _
 *                  (_)       | |           / _|(_)
 *     _ __    ___   _  _ __  | |_         | |_  _ __  __  ___
 *    | '_ \  / _ \ | || '_ \ | __|        |  _|| |\ \/ / / _ \
 *    | |_) || (_) || || | | || |_         | |  | | >  < |  __/
 *    | .__/  \___/ |_||_| |_| \__|        |_|  |_|/_/\_\ \___|
 *    | |                           ______
 *    |_|                          |______|
 */

point_fixe(NG,deg(Deg),NNG):-degre(NG,NNG,Deg).
point_fixe(NG,triangle,NNG):-triangle(NG,NNG).
point_fixe(NG,star(Deg),NNG):-etoile(NG,NNG,Deg).
