       program-id. Program1 as "EtatCivil.Program1".
       author. Alexandre Piquet

       environment division.
       configuration section.
       source-computer. SFR-EN2-04.
       object-computer. SFR-EN2-04.

       data division.
       file section.
       working-storage section.
      
      01 Adresse.
          10 Rue.
              20 Numero pic 999 value 61.
              20 filler pic X.
              20 TypeRue pic X(8) value "Avenue".
              20 NomRue pic X(20) value "Colmar".
          10 Ville.
              20 CodePostal pic X(5) value "67100".
              20 filler pic X.
              20 NomVille pic X(20) value "Strasbourg".
          10 Pays.
              20 NomPays pic X(20) value "France".
      
      01 Adresse-imprimee.
          10 Rue.
              20 Numero pic ZZ9.
              20 filler pic X.
              20 TypeRue pic X(8).
              20 filler pic X(4) value " de ".
              20 NomRue pic X(20).
          10 Ville.
              20 CodePostal pic X(5).
              20 espace pic X.
              20 NomVille pic X(20).
          10 Pays.
              20 NomPays pic X(20).

       01 Etat-civil.
           10 Intitule pic X(8) value "Monsieur".
           10 Nom pic x(30) value "Piquet".
           10 Prenom pic X(20) value "Alexandre".
           



       77 Trait pic X(80) value all "-".
       77 response pic X.
       77 Etat-civil-imprime pic x(79).

       procedure division.

       principal section.
           debut.
          ***début du traitement***
     
              display "Numero ?".
              accept Numero.
              display space.
              display "Rue ?".
              accept NomRue.
              display space.
              display Trait.
              display "Numero et rue ?".
              accept Rue.
              display space.
              display "Ville ?".
              accept NomVille.
              display space.
              display "CodePostal ?".
              accept CodePostal.
              display space.
              display "Pays ?".
              accept NomPays.
              display space.
              display Trait.
              display Adresse.
      
              display space.
              display Trait.
              display Rue.
              display Numero.
              display NomRue.
              display Ville.
              display NomPays.

              move corresponding Adresse to Adresse-imprimee.
      
              display Rue.
              display Ville.
              display NomPays.
      
              display space.
              display Trait.
      
              display Adresse.
      
              display space.
              display Trait.
      
              display Adresse-imprimee.
      
              display Rue of Adresse-imprimee.
              display Ville of Adresse-imprimee.
              display Pays of Adresse-imprimee.

               display Etat-civil.

               string
                 Intitule delimited by " "
                 space  delimited by size
                 Prenom delimited by " "
                 space  delimited by size
                 Nom delimited by " "
                 into Etat-civil-imprime
               end-string.

               display Etat-civil-imprime.

               display Trait.

               move "à remplir" to Etat-civil.

               display Etat-civil.
               display Intitule.
               display Prenom.
               display Nom.

               display Trait.


               unstring Etat-civil-imprime
                 delimited by " "
                 into Intitule
               Prenom
               Nom
               end-unstring.

               display Intitule with no advancing.
               display "*".
               display Prenom with no advancing.
               display "*".
               display Nom with no advancing.
               display "*".

               accept response.
               stop run.
           
       end program Program1.

