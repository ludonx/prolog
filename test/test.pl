 /*test(1,'mougel_bis.dot','pf_rockd3.dot'). */

 test(1,NomIn,NomOut) :-
 	read_dot_file(NomIn,G), graphe_induit(G,[rock],NG),
 	point_fixe(NG,deg(3),NNG),write_dot_file(NomOut,NNG).

 /*test(2,'mougel_bis.dot','pf_rocks5.dot'). */

 test(2,NomIn,NomOut) :-
 	read_dot_file(NomIn,G), graphe_induit(G,[rock],NG),
 	point_fixe(NG,star(5),NNG),write_dot_file(NomOut,NNG).

 /* Motif : liste d'attributs ([rock,blues]) */
 /* Prop : deg(K),star(K),cc(K),triangle,cp(c,p). */

 test(NomIn,NomOut,Motif,Prop) :-
 	read_dot_file(NomIn,G), graphe_induit(G,Motif,NG),
 	point_fixe(NG,Prop,NNG),write_dot_file(NomOut,NNG).


  % read_dot_file("mougel_bis.dot",G),graphe_induit(G,[rock],Gi),write_dot_file("Gi_test2.dot",Gi).
  % read_dot_file("deg.dot",G),graphe_induit(G,[rock],Gi),degre(Gi,Ga,2),write_dot_file("Ga_test3.dot",Ga).
  % read_dot_file("deg.dot",G),graphe_induit(G,[rock],Gi),triangle(Gi,Ga),write_dot_file("Ga_test_triangle.dot",Ga).
  % read_dot_file("deg.dot",G),graphe_induit(G,[rock],Gi),etoile(G,Ga,4),write_dot_file("Ga_test_etoile.dot",Ga).
  % read_dot_file("deg.dot",G),graphe_induit(G,[rock],Gi),etoile(G,Ga,3),write_dot_file("Ga_test_etoile.dot",Ga).
  % read_dot_file("deg.dot",G),etoile(G,Ga,4),write_dot_file("Ga_test_etoile.dot",Ga).
