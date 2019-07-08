       program-id. SinistreParAssureAffich as "StatistiqueSinistresAssures.SinistreParAssureAffich".

       environment division.
       input-output section.
       file-control.

       select FichierMajMouvement assign to "C:\Users\Mohamed\Desktop\Stage\SinistresParAssure.csv"
                organization is line sequential access sequential.

       DATA DIVISION.
       FILE SECTION.

       FD FichierMajMouvement record varying from 0 to 255.
       01 Enr-FichierMajMouvement pic x(255).

       working-storage section.
       
       01 SinParAssure.
            10 NAssur      SQL CHAR-VARYING(5).
            10 NbrType1    pic 99.
            10 Monttype1   pic 9(8)V99.
            10 NbrType2    pic 99.
            10 Monttype2   pic 9(8)V99.
            10 NbrType3    pic 99.
            10 Monttype3   pic 9(8)V99.

      *---- Fichier Maj Mouvement
      *01 FichMajMouv pic x(27).
       
      **** FichierTranches de montant
       77 EofAffich       pic 9. 
       77 CouleurFond     pic 99 value 15.
       77 CouleurTexte    pic 99 value 0.
       77 OptionChoisie   pic 9.
       77 NoLigne1        pic 99.
       77 NoLigne2        pic 99.
       77 OptSuite        pic x.

       77  CNXDB STRING.
           EXEC SQL 
               INCLUDE SQLCA
           END-EXEC.
           EXEC SQL 
               INCLUDE SQLDA
           END-EXEC.

        screen section.

       01 M-ListeSin-Question background-color is 1 foreground-color is 15.
           10 line 2 col 1 value " Page [S]uivante - Retour au [M]enu :" background-color is CouleurTexte foreground-color is CouleurFond.

      **** Ecran vide
       01  Ecran-Blanc background-color is CouleurFond foreground-color is CouleurTexte.
           05 line  1 col  1 Blank Screen.
       01  blanc-Line.
           10 line 1 col 1 blank line pic X(80) value all spaces.

      *---- Tableau d'affichage Les mouvement faites sur le Fichier Cehicule.
       01  T-AfficheSin foreground-color is CouleurTexte background-color is CouleurFond.
           10 line 1  col 29 value "Les sinistres par assure".
           10 line NoLigne1  col 2 value "Numero Assure: ".
           10 line NoLigne1  col 18 from NAssur   of SinParAssure.
      *----- t(8)----n(19)--- M(34)
           10 line NoLigne2  col 8 value "Type       Nombre         Montant".

       01  T-AffichContent1 foreground-color is CouleurTexte background-color is CouleurFond.
           10 line noligne1  col 8  value "1".
           10 line NoLigne1  col 19 from Nbrtype1   of SinParAssure pic Z9.
           10 line NoLigne1  col 34 from Monttype1 of SinParAssure pic z(7)9V,99.
       01  T-AffichContent2 foreground-color is CouleurTexte background-color is CouleurFond.
           10 line noligne1  col 8  value "2".
           10 line NoLigne1  col 19 from Nbrtype2   of SinParAssure pic Z9.
           10 line NoLigne1  col 34 from Monttype2 of SinParAssure pic Z(7)9V,99.
       01  T-AffichContent3 foreground-color is CouleurTexte background-color is CouleurFond.
           10 line noligne1  col 8  value "3".
           10 line NoLigne1  col 19 from Nbrtype3   of SinParAssure pic Z9.
           10 line NoLigne1  col 34 from Monttype3 of SinParAssure pic Z(7)9V,99.

       procedure division.

      *----- Affichage des résultats Après Les Calculs
      *-----------------------------------------------------------------------------
*----- Annexe 3 - Affichage Fichier Mouvement apporté au Fichier Vehicule
      *-----------------------------------------------------------------------------
       AffichageMouvement.
           perform AfficheMouv-Init.
           perform AfficheMouv-Trt Until EofAffich = 1.
           perform AfficheMouv-Fin.

           AfficheMouv-Init.
               display Ecran-Blanc.
               move 3 to NoLigne1.
               move 4 to NoLigne2.
               Move 0 to EofAffich.
               open input FichierMajMouvement.
               read FichierMajMouvement.
           AfficheMouv-Trt.
          read FichierMajMouvement
               at end move 1 to EofAffich
                      display blanc-Line
                      display " Fin de la liste des sinistres par Assure : " line 1 col 1 with no advancing
                      accept OptionChoisie
               not at end
               if Enr-FichierMajMouvement not = " "
                   unstring Enr-FichierMajMouvement delimited by ";" or " " into
                       NAssur    of SinParAssure 
                       NbrType1  of SinParAssure 
                       Monttype1 of SinParAssure
                       NbrType2  of SinParAssure 
                       Monttype2 of SinParAssure
                       NbrType3  of SinParAssure 
                       Monttype3 of SinParAssure
                   end-unstring
                       divide Monttype1 by 100 giving Monttype1
                       divide Monttype2 by 100 giving Monttype2
                       divide Monttype3 by 100 giving Monttype3
                       perform Affich
               end-if
           end-read.

           AfficheMouv-Fin.
               close FichierMajMouvement.
               goback.
          
       Affich.
               display T-AfficheSin.
               add 2 to NoLigne1.
           if NbrType1 not = 0
               display T-AffichContent1
               add 1 to NoLigne1
           end-if.
           if NbrType2 not = 0
               display T-AffichContent2
               add 1 to NoLigne1
           end-if.
           if NbrType3 not = 0
               display T-AffichContent3
               add 1 to NoLigne1.

           add 1 to NoLigne1.
           add 1 to NoLigne1 giving NoLigne2.
           
* Si on est sur la dernière ligne, on demande si on passe à la page suivante
           if  NoLigne1 > 22 then
               move "S" to OptSuite
               display M-ListeSin-Question
               accept OptSuite line 2 col 39
               display Ecran-Blanc
               move 3 to NoLigne1
               move 4 to NoLigne2
               if OptSuite = "M" or OptSuite = "m" then move 1 to EofAffich
           end-if.
      *-----------------------------------------------------------------------------
*---- Fin Annexe 3  
      *-----------------------------------------------------------------------------
           
       end program SinistreParAssureAffich.
