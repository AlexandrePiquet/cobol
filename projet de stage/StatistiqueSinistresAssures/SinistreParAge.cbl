       program-id. SinistreParAge.
      *as "StatistiqueSinistresAssures.SinistreParAge".

       environment division.
       input-output section.
       file-control.
       
       select FichierSinistre assign to "\home\utilisateur\Documents\emploi\book\cobol\projet de stage\fichiers\Sinistre.csv"
                organization is line sequential access sequential.

       select FichierMouvement assign to "\home\utilisateur\Documents\emploi\book\cobol\projet de stage\fichiers\Mouvement.csv"
                organization is line sequential access sequential.

        select FichierTranches assign to "\home\utilisateur\Documents\emploi\book\cobol\projet de stage\fichiers\tranches.csv"
                organization is line sequential access sequential.

       select FichierSinistresParTranche assign to "\home\utilisateur\Documents\emploi\book\cobol\projet de stage\fichiers\SinistresParTranche.csv"
                organization is line sequential access sequential.

       select FichierSinistresParAssure assign to "\home\utilisateur\Documents\emploi\book\cobol\projet de stage\fichiers\SinistresParAssure.csv"
                organization is line sequential access sequential.

       select FichierMajMouvement assign to "\home\utilisateur\Documents\emploi\book\cobol\projet de stage\fichiers\FichierMajMouvement.csv"
                organization is line sequential access sequential.

       DATA DIVISION.

       FILE SECTION.
       FD FichierSinistre record varying from 0 to 255.
       01 EnrFichierSinistre pic X(255).

       FD FichierMouvement record varying from 0 to 255.
       01 EnrFichierMouvement pic X(255).

       FD FichierTranches record varying from 0 to 255.
       01 Enr-FichierTranches  pic x(255).

       FD FichierSinistresParTranche record varying from 0 to 255.
       01 Enr-FichierSinistresParTranche  pic x(255).

       FD FichierSinistresParAssure record varying from 0 to 255.
       01 Enr-FichierSinistresParAssure  pic x(255).

       FD FichierMajMouvement record varying from 0 to 255.
       01 Enr-FichierMajMouvement pic x(255).

       working-storage section.

      ******************** Sinistre *********************
       01 SinistreDonne.
            10 NSin        sql char-varying(2).
            10 NAssur      SQL CHAR-VARYING(5).
            10 DAteNai pic 9(8).
            10 DateNaiRed Redefines DAteNai.
               15 DateATester-Annee pic 9(4).
               15 DateATester-Mois pic 9(2).
               15 DateATester-Jour pic 9(2).
            10 TypeSin     Sql char(1).
            10 NImma       sql char-varying(9).
            10 DateSin     sql char-varying(8).
            10 MontSin     Pic 9(8)V99.
       01 Assure.
            10 A-Assur     sql char-varying(5).
            10 A-Nom       sql char-varying(25).
            10 A-Prenom    sql char-varying(20).
       
      **** Sinistres par âge et par montant
       01 TableauSinistres.
           05 TrancheaAge Occurs 2 times.
               10 TrancheMontant Occurs 5 Times.
                   15 Nombre pic 9(3).
                   15 Montant pic 9(8)V99.
       01 DateActuelle.
           05 DateActuelle-Annee pic 9(4).
           05 DateActuelle-Mois pic 9(2).
           05 DateActuelle-Jour pic 9(2).

      *---- Sinistres par assuré
       01 TotalSinistresAssure.
           05 NumAssure    sql char-varying(5).
           05 TypeSin Occurs 3 times.
                   10 NbreParSin   pic 9(3).
                   10 MontParSin   pic 9(6)V99.
       01 FichSinParAssure pic x(55).

      *---- Fichier Maj Mouvement
      *01 FichMajMouv pic x(255).

      *******************  Varibles
       77 TrancheAgeSup pic 99.
       
      **** FichierTranches de montant
       77 NbrFichierTranches pic 9.
       77 Tranche1 pic 9(7).
       77 Tranche2 pic 9(7).
       77 Tranche3 pic 9(7).
       77 Tranche4 pic 9(7).
       77 IndexTranches pic 9.
       77 FinDeCalculs pic 9.
       77 EoDB pic 9.
       77 EofImport       pic 9.
       77 DerniereZone    pic x(8).  
       77 CouleurFond     pic 99 value 15.
       77 CouleurTexte    pic 99 value 0.
       77 MessageErreur   pic X(20).
       77 OptionChoisie   pic 9.
       77 Option          pic 9.
       77 NoLigne         pic 99.

      **** Var anexe 1:
       77 NombreTotalAgeInf pic 9(3).
       77 MontantTotalAgeInf pic 9(8)V99.

       77 NombreTotalAgeSup pic 9(3).
       77 MontantTotalAgeSup pic 9(8)V99.
       
       77  CNXDB STRING.
           EXEC SQL 
               INCLUDE SQLCA
           END-EXEC.
           EXEC SQL 
               INCLUDE SQLDA
           END-EXEC.

       screen section.
      *------------- Ecran vide
       01  Ecran-Blanc background-color is CouleurFond foreground-color is CouleurTexte.
           05 line  1 col  1 Blank Screen.
      *----------- Affichage Resultats Annexe1:
       01 SinistreMoins25 background-color is CouleurFond foreground-color is CouleurTexte.
          10 line 1   col 12 value "Nombre de sinistres par age et par tranche de montants".
          10 line 3   col 2  value "Moins de 25 ans".
          10 line 4   col 7  value "Nombre d'accidents: ".
          10 line 4   col 27 from  NombreTotalAgeInf pic z(2)9.
          10 line 5   col 7  value "Montat total des sinistres: ".
          10 line 5   col 35 from  MontantTotalAgeInf pic z(5)9V,99.
          10 line 7   col 7  value "Tranche            Nombre d'accidents".
          10 line 8   col 2  value "De 0 a      <10 000".
          10 line 8   col 25 from  Nombre(1,1) pic z(2)9.
          10 line 9   col 2  value "De 10 000 a <25 000".
          10 line 9   col 25 from  Nombre(1,2) pic z(2)9.
          10 line 10  col 2  value "De 25 000 a <40 000".
          10 line 10  col 25 from  Nombre(1,3) pic z(2)9.
          10 line 11  col 2  value "De 40 000 a <50 000".
          10 line 11  col 25 from  Nombre(1,4) pic z(2)9.
          10 line 12  col 2  value "            >50 000".
          10 line 12  col 25 from  Nombre(1,5) pic z(2)9.
      
       01 SinistrePlus25 background-color is CouleurFond foreground-color is CouleurTexte.
          10 line 14  col 2  value "Plus de 25 ans".
          10 line 15  col 7  value "Nombre d'accidents: ".
          10 line 15  col 27 from  NombreTotalAgeSup pic z(2)9.
          10 line 16  col 7  value "Montat total des sinistres: ".
          10 line 16  col 35 from  MontantTotalAgeSup pic z(5)9V,99.
          10 line 18  col 7  value "Tranche            Nombre d'accidents".
          10 line 19  col 2  value "De 0 a      <10 000".
          10 line 19  col 25 from  Nombre(2,1) pic z(2)9.
          10 line 20  col 2  value "De 10 000 a <25 000".
          10 line 20  col 25 from  Nombre(2,2) pic z(2)9.
          10 line 21  col 2  value "De 25 000 a <40 000".
          10 line 21  col 25 from  Nombre(2,3) pic z(2)9.
          10 line 22  col 2  value "De 40 000 a <50 000".
          10 line 22  col 25 from  Nombre(2,4) pic z(2)9.
          10 line 23  col 2  value "            >50 000".
          10 line 23  col 25 from  Nombre(2,5) pic z(2)9.
          10 line 24  col 55 value "Menu: Cliquer Sur Enree".

       procedure division.
           perform age-init.
           perform age-trt until eodb=1.
           perform age-fin.

       age-init.
               move 0 to NoLigne.
               move 0 to EoDB.
               initialize NombreTotalAgeInf, MontantTotalAgeInf, MontantTotalAgeSup, NombreTotalAgeSup.
               Initialize TableauSinistres.
*---------------- Récupération de la valeur des limites de tranches ------------
           open input FichierTranches.
           read FichierTranches.
           unstring Enr-FichierTranches delimited by ";" or " " into
               NbrFichierTranches
               Tranche1
               Tranche2
               Tranche3
               Tranche4
           end-unstring.
           close FichierTranches.
*--------------- Récuperer La date Actuelle:----------------------
               STRING FUNCTION  CURRENT-DATE (1:4)                   
                      FUNCTION  CURRENT-DATE (5:2)                   
                      FUNCTION  CURRENT-DATE (7:2) DELIMITED BY '\' 
               INTO DateActuelle.
      **** Création du curseur
           exec sql
               Declare S-Cursor cursor for
                   select AAssur,ADateNai,SMontSin from Sinistre INNER JOIN Assure ON Sinistre.SNAssur = Assure.AAssur  order by AAssur
           end-exec.
      **** Ouverture du curseur
           exec sql
               open S-Cursor
           end-exec.

       age-trt.
           move 0 to TrancheAgeSup.
      **** Détermination de l'âge de l'assuré (-25) ou (25 et +25)
      **** On utilise le curseur pour récupérer un sinistre
           exec sql
               fetch S-Cursor into :SinistreDonne.NAssur,:SinistreDonne.DAteNai,:SinistreDonne.MontSin
           end-exec.
           if sqlcode = 100 or SQLCODE = 101 then
               move 1 to EoDB
           else
               perform Age_TrtLigne
               perform Calcule_Montants.

       Age-fin.
               exec sql
                   close S-Cursor
               end-exec.
      *** Calcule le nombre total des sinistres:
           add Nombre(2,1) Nombre(2,2) Nombre(2,3) Nombre(2,4) Nombre(2,5) to NombreTotalAgeSup.
           add Nombre(1,1) Nombre(1,2) Nombre(1,3) Nombre(1,4) Nombre(1,5) to NombreTotalAgeInf.
           add Montant(2,1) Montant(2,2) Montant(2,3) Montant(2,4) Montant(2,5) to MontantTotalAgeSup.
           add Montant(1,1) Montant(1,2) Montant(1,3) Montant(1,4) Montant(1,5) to MontantTotalAgeInf.
      ******************************************************
      * Ecran blanc
      ******************************************************
           perform varying NoLigne from 1 by 1 until NoLigne = 24 display Ecran-Blanc.
           display SinistreMoins25.
           display SinistrePlus25.
           accept OptionChoisie.
           goback.
               
       Age_TrtLigne.
           if  DateActuelle-Annee - DateATester-Annee > 25
               move 1 to TrancheAgeSup
           else
                if DateActuelle-Annee -  DateATester-Annee = 25
                   if DateActuelle-Mois > DateATester-Mois
                       move 1 to TrancheAgeSup
                   else
                       if DateActuelle-Mois = DateATester-Mois
                           if DateActuelle-Jour >= DateATester-Jour
                               move 1 to TrancheAgeSup
                           end-if
                       end-if
                   end-if
                end-if
           end-if.
      *------ Calculs Montants:
           Calcule_Montants.
               Evaluate true
                   when MontSin < Tranche1
                       if TrancheAgeSup=1 
                           add 1 to Nombre(2,1)
                           add MontSin to Montant (2,1)
                       else
                           add 1 to Nombre (1,1)
                           add MontSin to Montant (1,1)
                       end-if
                   when MontSin < Tranche2
                       if TrancheAgeSup=1
                           add 1 to Nombre(2,2)
                           add MontSin to Montant(2,2)
                       else
                           add 1 to Nombre(1,2)
                           add MontSin to Montant(1,2)
                       end-if
                   when MontSin < Tranche3
                       if TrancheAgeSup=1
                           add 1 to Nombre(2,3)
                           add MontSin to Montant(2,3)
                       else
                           add 1 to Nombre(1,3)
                           add MontSin to Montant(1,3)
                       end-if
                   when MontSin < Tranche4
                       if TrancheAgeSup=1
                           add 1 to Nombre(2,4)
                           add MontSin to Montant(2,4)
                       else
                           add 1 to Nombre(1,4)
                           add MontSin to Montant(1,4)
                       end-if
                   when other
                       if TrancheAgeSup=1
                           add 1 to Nombre(2,5)
                           add MontSin to Montant(2,5)
                       else
                           add 1 to Nombre(1,5)
                           add MontSin to Montant(1,5)
                       end-if
               end-evaluate.

       end program SinistreParAge.
