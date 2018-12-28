:- dynamic attributes/1.
/* lecture d'un fichier .dot */
read_info_lignes(I, Str, att_graph(S, A)) :-
    /* Traitement début du fichier, extraction de la liste des labels,
    puis des labels associés à chaque sommet */
    read_string(Str, "\n", "\r", _, String),
    % write('Lecture ligne '),write(I),write('  = '),writeln(String),
    split_string(String, "=", " ;", L),
    % write("liste extraite = "),writeln(L),
    extract_info_ligne(I, L, Sommet),
    NI is I+1,
    (Sommet = [] ->
        % ligne de début de fichier, on passe
        read_info_lignes(NI, Str, att_graph(S, A));
        % ligne contenant un sommet et ses attributs
        (Sommet = sommet(X, Y) ->
            read_info_lignes(NI, Str, att_graph(NS, A)),
            S = [sommet(X, Y)|NS];
            % ligne décrivant une arête
            (Sommet = arete(X, Y) ->
                read_info_lignes(NI, Str, att_graph(S, NA)),
                A = [arete(X, Y)|NA];
                % lecture de la fin du graphe
                (Sommet = fin ->
                    S = [], A = []
                )
            )
        )
    ).

msubstring(S, SS) :- sub_string(S, _, _, _, SS).

/* extract_info_ligne(+NL,+L,-Term */
/* NL : numéro de ligne, L la chaîne de caractères lue, Term est le terme utile extrait */

/* Lecture des lignes de début de fichier, aucune information utile, on rend [] */
extract_info_ligne(1, L, []) :-
    member("Graph {", L).
extract_info_ligne(2, L, []) :-
    member(E, L),msubstring(E, "labelloc").
extract_info_ligne(3, L, []) :-
    member(E, L), msubstring(E, "fontsize").
/* Ici on lit la liste des labels admissibles pour les sommets, ils sont assertés dans save_labels (variable globale) */
extract_info_ligne(4, L, []) :-
    member(E, L), msubstring(E, "label"),
    save_labels(L).
/*  on lit } : fin de graphe */
extract_info_ligne(_, L, fin):-
    member("}", L).


/* Lecture des lignes contenant un identifiant de sommets  aucune information utile, on rend [] */
extract_info_ligne(N, L, Res) :-
    N>4,
    member(E, L),
    (msubstring(E, "label")->
        % on est dans le cas des labels de noeuds cette fois ci
        parse_labels(L, Res);
        (msubstring(E, "--")->
            parse_aretes(L, Res)
        )
    ).

save_labels([_, T]) :-
    split_string(T, ",", ", []\"", [_|L]), maplist(string_to_atom, L, LV),
    write("Liste valeurs attributs "), writeln(LV),
    assertz(attributes(LV)).

parse_labels([_, T], Term) :-
    split_string(T, ",[]", " \t\s\n[]\"", L),
    maplist(string_to_atom, L, LV),
    LV = [HLV|TLV], Term = sommet(HLV,TLV),
    write('Sommet extrait = '), writeln(Term).

parse_aretes([T], Term) :-
    split_string(T,"-", " -[]\t", A),
    maplist(string_to_atom, A, AL),
    Term =.. [arete|AL],
    write('Arete extraite '), writeln(Term).

/* read_dot_file(+NomFichier) avec NomFichier : chaine de caractères */
/* read_dot_file('mougel_bis.dot'). */


read_dot_file(NomF, att_graph(S,A)) :-
    retractall(attributes),
    open(NomF,read,Str),
    read_info_lignes(1,Str,att_graph(S,A)),
    close(Str),
    writeln(att_graph(S,A)),
    write('Nb sommets = '),length(S,NS),writeln(NS),
    write('Nb aretes = '),length(A,NA),writeln(NA).
