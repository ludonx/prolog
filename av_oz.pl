% Auteur:  Yannis Slaouti-Jégou & Oussennan Anass
% Date: 30/12/2018

/*concatenation*/
append([], L, L).
append([H|T], L, [H|R]) :-
    append(T, L, R).

/*not_member pour tester si un element n'est pas membre d'une liste*/
not_member(Element, Liste):- (member(Element, Liste)-> false; true).


/*concatenation en evitant les duplicats*/
append_dupl([], L, L).
append_dupl([H|T], L, R) :- append_dupl(T, L, R), member(H, R).
append_dupl([H|T], L, [H|R]) :- append_dupl(T,L,R), not_member(H, R).


/*Les deux fonctions suivantes ont un intérêt limité mais on les garde pour que le code soit plus clair*/
/*Quand on ne veut etudier que les sommets du graphe*/
prendre_sommets(att_graph(S, _), R) :- R = S.

/*Quand on ne veut etudier que les aretes du graphe*/
prendre_aretes(att_graph(_, A), R) :- R = A.

/*recherche de motif dans le graphe*/
recherche_motif(G, M, R) :- prendre_sommets(G, S), recherche_motif_liste(S,M,R).
    
/*recherche des motifs dans la liste des sommets*/
/*N pour le 'nom' d'un sommet, E pour étiquette, M pour motif et RS pour l'ensemble des sommets dont l'etiquette comprend le motif*/

recherche_motif_liste([],_,[]).
recherche_motif_liste([sommet(N,E)|T], M, RS):- (liste_incluse(M,E)-> append([sommet(N,E)],S,RS) , recherche_motif_liste(T,M,S) ; recherche_motif_liste(T,M,RS)).

/*test pour voir si une liste est incluse dans une autre*/
liste_incluse([],_) :- true.
liste_incluse([A|R],L) :- member(A,L), liste_incluse(R,L).


/*Pour permettre de récupérer que les 'noms' des sommets à partir du format initial des sommets dans un graphe (sommet(nom,etiquette))*/
nom_sommets([],[]).
nom_sommets([sommet(N,_)|T], NEWR) :- append([N],OLDR,NEWR), nom_sommets(T, OLDR).

/*On a la liste des sommets qui comprennent le motif, on prend alors la liste des aretes correspondant au graphe induit par ces sommets*/
aretes_g_induit(G,S,R):- prendre_aretes(G,A), nom_sommets(S, NS), aretes_liste_induit(A,NS,R).

/*On cherche ces aretes directement dans la liste des aretes du graphe (et on les met au format du graphe [arete(X,Y),arete(X1,Y1)|...])*/
aretes_liste_induit([],_,[]).
aretes_liste_induit([arete(X, Y)|R], S, NEWR) :- (member(X, S), member(Y, S) -> append([arete(X, Y)], OLDR, NEWR), aretes_liste_induit(R,S,OLDR); aretes_liste_induit(R,S,NEWR)).


/*création du sous-graphe induit par le motif*/
graphe_induit(G,M,R) :- recherche_motif(G,M,S), aretes_g_induit(G,S,A), R = att_graph(S, A).


%*********************************************************************************************************************************************************************************

/*liste des sommets dans la liste des aretes (de la forme [a,b,a,c,a,d,a,e,a,i|...])*/
liste_sommets([], []).
liste_sommets([arete(X,Y)|T], NEWL) :- append([X,Y], OLDL, NEWL), liste_sommets(T, OLDL).

/*recuperer le degre de chaque sommet*/
degre_sommet([], _, []).
degre_sommet([sommet(A,Etiquette)|T], L, NEWR):- findall(X, (member(X, L), X=A), Listeconnexions), length(Listeconnexions, Degre), append(['Deg'(sommet(A,Etiquette),Degre)], OLDR, NEWR), degre_sommet(T, L, OLDR).




/*Abstraction deg(y>=K)*/
abstr_deg(G, K , NewGraphe) :- prendre_aretes(G, A), prendre_sommets(G,S), liste_sommets(A, L), degre_sommet(S, L, DegreListe), %On créé une liste associant chaque sommet de G a son degre.
 findall(X, (member('Deg'(X,Y), DegreListe), Y >= K), NEWS),                                                                    %On cherche tous les sommets de degre sup a K.
 aretes_g_induit(G, NEWS,NEWA),                                                                                                 %On cherche alors les aretes correspondants au graphe induit par ces sommets
 (length(DegreListe, Long1), length(NEWS, Long2), Long1 == Long2 ->  NewGraphe = att_graph(NEWS,NEWA);  abstr_deg(att_graph(NEWS,NEWA), K, NewGraphe) ).  %Si apres l'abstraction on a autant de sommets qu'avant, alors
                                                                                                                                           %on a la solution, sinon on fait une abstraction sur le nouveau graphe.
                                                                                                                                           
                                                                                                                                           
                                                                                                                                           
                                                                                                                                           
/*Liste des voisins d'un sommet*/
liste_voisins([],_,[]).
liste_voisins([arete(X,Y)|T], Sommet, NewListeVoisins) :- (X == Sommet -> append([Y], OldListeVoisins, NewListeVoisins), liste_voisins(T, Sommet, OldListeVoisins);
 ( Y == Sommet -> append([X], OldListeVoisins, NewListeVoisins), liste_voisins(T, Sommet, OldListeVoisins); liste_voisins(T, Sommet, NewListeVoisins) )  ).

/*Recuperer les etiquettes de sommets dans une liste a partir de leurs noms*/
etiquette_sommet([],_,[]).
etiquette_sommet([sommet(S,E)|T], ListeSommets, ListeAvecEtiquette) :- (member(S, ListeSommets) -> append([sommet(S,E)], OldListe, ListeAvecEtiquette), etiquette_sommet(T, ListeSommets, OldListe);
 etiquette_sommet(T, ListeSommets, ListeAvecEtiquette)).

/*Rechercher et supprimer elements d'une liste sans duplicats*/
rech_suppr_elem([], _, []).
rech_suppr_elem([A|T], E, NewListe):- (member(A,E) ->  rech_suppr_elem(T, E, NewListe); append([A], OldListe, NewListe), rech_suppr_elem(T, E, OldListe)).

 
 
 
/*composante_connexe, cet abstraction ne demande pas a etre reiteree pour trouver un point fixe, juste une fois suffit*/
abstr_cc(G,K,NewGraphe) :- prendre_sommets(G,LS), nom_sommets(LS, NS), prendre_aretes(G,A), abstr_cc_rec(K, NS, A, NewListeSommet),
 etiquette_sommet(LS, NewListeSommet, NEWS), aretes_g_induit(G, NEWS, NEWA), NewGraphe = att_graph(NEWS, NEWA).

abstr_cc_rec(_, [], _, []).
abstr_cc_rec(K, [A|T], Aretes, NewListe) :- parc(Aretes, [], [A], Liste), length(Liste, Longueur_cc), (Longueur_cc>=K -> append(Liste, OldListe, NewListe), rech_suppr_elem(T, Liste, NewT), abstr_cc_rec(K, NewT, Aretes, OldListe);
  rech_suppr_elem(T, Liste, NewT), abstr_cc_rec(K, NewT, Aretes, NewListe)).
 
 
 
/*Parcours du graphe*/
parc(_,Visite,[],Visite).
parc(Aretes, Visite, [Sommet|R], NewParcours):- (member(Sommet, Visite) -> parc(Aretes, Visite, R, NewParcours);
  liste_voisins(Aretes, Sommet, Voisins),append(R, Voisins, ResteAVisiter), append([Sommet], Visite, CeQuiEstVisite), parc(Aretes, CeQuiEstVisite, ResteAVisiter, NewParcours)  ).
  
  
  
  
/*Abstraction des triangles*/
abstr_triangle(G, NewGraphe) :- prendre_sommets(G,LS), nom_sommets(LS, NS), prendre_aretes(G,A), abstr_triangle_rec(NS, A, NewListeSommet),
 etiquette_sommet(LS, NewListeSommet, NEWS), aretes_g_induit(G, NEWS, NEWA), NewGraphe = att_graph(NEWS, NEWA).

abstr_triangle_rec([], _, []). %dans Resultat il y a soit [] soit [X,Y,X1,X2,...] les triangles (Sommet,X,Y) qui contiennent Sommet
abstr_triangle_rec([Sommet|T], Aretes, NewListeSommet) :- liste_voisins(Aretes, Sommet, Voisins), is_in_triangle(Aretes, Voisins, Resultat), rech_suppr_elem(T, Resultat, NewT),
 abstr_triangle_rec(NewT, Aretes, ListeSommet), (ListeSommet == [] -> ListeARajouter = []; ListeARajouter = [Sommet|ListeSommet]), append_dupl(Resultat , ListeARajouter, NewListeSommet).




/*Trouver tous les triangles incluant un sommet a partir de la liste de ses voisins*/
is_in_triangle([], _, []).
is_in_triangle([arete(X,Y)|T], Voisins, NewRes):- ( member(X, Voisins), member(Y,Voisins) -> is_in_triangle(T, Voisins, Res), append_dupl([X,Y], Res, NewRes); is_in_triangle(T, Voisins, NewRes) ).




/*Obtenir la liste des voisins d'une liste de sommets (sans duplicats)*/
liste_voisins_liste(_, _, [], []).
liste_voisins_liste(Aretes, SommetsDegreSupAK, [Sommet|T], NewRes) :- liste_voisins(Aretes, Sommet, VoisinsDeSommet), rech_suppr_elem(VoisinsDeSommet, SommetsDegreSupAK, ListeARajouter),
  liste_voisins_liste(Aretes, SommetsDegreSupAK, T, Res), append_dupl(ListeARajouter, Res, NewRes).




/*Abstraction etoile*/
abstr_etoile(G, K, NewGraphe) :- prendre_aretes(G, A), prendre_sommets(G,S), liste_sommets(A, L), degre_sommet(S, L, DegreListe),

 /*On recupere les sommets de degre >= C puis leurs voisins en excluant les deg >= C s'ils sont voisins l'un de l'autre*/
 findall(X, (member('Deg'(X,Y), DegreListe), Y >= K), Sommets_Degre_Sup_K), nom_sommets(Sommets_Degre_Sup_K, Noms_Sommets_Degre_Sup_K),
 liste_voisins_liste(A, Noms_Sommets_Degre_Sup_K, Noms_Sommets_Degre_Sup_K, ListeDesVoisins),    %On utilise deux fois NEWS comme parametre car on veut parcourir la liste et aussi l'avoir dans son entierete
 
 /*On concatene les deux liste sans duplicats et on retourne le graphe induit par ces sommets si on est a un point fixe*/
 append(Noms_Sommets_Degre_Sup_K, ListeDesVoisins, ListeSommetsQuiRestent),  etiquette_sommet(S, ListeSommetsQuiRestent, NEWS),
 aretes_g_induit(G, NEWS, NEWA),
 
 /*Test pour savoir si on a un point fixe ie. l'abstraction est complete*/
 (length(S, Long1), length(NEWS, Long2), Long1 == Long2 ->  NewGraphe = att_graph(NEWS,NEWA);
 abstr_etoile(att_graph(NEWS,NEWA), K, NewGraphe) ).
 
 
 
 
/*Liste des voisins de degre sup a P d'un sommet*/
liste_voisins_deg_p([],_, _,[]).
liste_voisins_deg_p([arete(X,Y)|T], Sommet, SommetsDegreSupP, NewListeVoisins) :- ( member(Y, SommetsDegreSupP), X == Sommet ->  append([Y], OldListeVoisins, NewListeVoisins), liste_voisins_deg_p(T, Sommet, SommetsDegreSupP, OldListeVoisins);
 ( member(X, SommetsDegreSupP), Y == Sommet -> append([X], OldListeVoisins, NewListeVoisins), liste_voisins_deg_p(T, Sommet, SommetsDegreSupP, OldListeVoisins);  liste_voisins_deg_p(T, Sommet, SommetsDegreSupP, NewListeVoisins) )  ).

 
 
 
/*Obtenir la liste des voisins d'une liste de sommets (la liste des voisins peut contenir ces sommets)*/
liste_coeur_et_peripherie(_, [], _, []).
liste_coeur_et_peripherie(Aretes, [Sommet|T], SommetsDegreSupP, NewRes) :- liste_voisins_deg_p(Aretes, Sommet, SommetsDegreSupP, VoisinsDeSommet),
  (VoisinsDeSommet == [] -> liste_coeur_et_peripherie(Aretes, T, SommetsDegreSupP, NewRes); liste_coeur_et_peripherie(Aretes, T, SommetsDegreSupP, Res), append_dupl([Sommet|VoisinsDeSommet], Res, NewRes) ).

 
 

/*Abstraction CoeurPeripherie*/
abstr_peripherie(G, C, P, NewGraphe) :- C >= P, prendre_aretes(G, A), prendre_sommets(G,S), liste_sommets(A, L), degre_sommet(S, L, DegreListe),

 /*On recupere les sommets de degre >= C, ceux de degre >= P, puis on garde les sommets etant coeurs ou en peripherie*/
 findall(X, (member('Deg'(X,Y), DegreListe), Y >= C), Sommets_Degre_Sup_C), nom_sommets(Sommets_Degre_Sup_C, Noms_Sommets_Degre_Sup_C),
 findall(X, (member('Deg'(X,Y), DegreListe), Y >= P), Sommets_Degre_Sup_P), nom_sommets(Sommets_Degre_Sup_P, Noms_Sommets_Degre_Sup_P),
 liste_coeur_et_peripherie(A, Noms_Sommets_Degre_Sup_C, Noms_Sommets_Degre_Sup_P,  ListeSommetsQuiRestent),
 
 /*On prend le sous-graphe induit par ces sommets*/
 etiquette_sommet(S, ListeSommetsQuiRestent, NEWS), aretes_g_induit(G, NEWS, NEWA),
 
 /*Test pour savoir si on a un point fixe ie. l'abstraction est complete*/
 (length(S, Long1), length(NEWS, Long2), Long1 == Long2 ->  print("nope"), NewGraphe = att_graph(NEWS,NEWA); print("we are there actually"),
 abstr_peripherie(att_graph(NEWS,NEWA), C, P, NewGraphe)).
