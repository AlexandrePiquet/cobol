       program-id. Program1 as "gestionbanque.Program1".
       author. Alexandre Piquet

       environment division.
       configuration section.
       source-computer. SFR-EN2-04.
       object-computer. SFR-EN2-04.
       input-output section.
           select FichierClient assign to "C:\Users\Utilisateur\Documents\Cobol\Client.csv" organization is line sequential access sequential.

       data division.
       file section.
      ****
      * Fichier compte.csv
      ****
       FD FichierClient record varying from 0 to 255.
       01 ligne-client-input pic X(255).

       working-storage section.

       01 DateSysteme.
           10 Annee pic 99.
           10 Mois pic 99.
           10 Jour pic 99.

       01 Compte.
           10 CodeBanque SQL CHAR(5).
           10 CodeGuichet SQL CHAR(5).
           10 RacineCompte SQL CHAR(9).
           10 TypeCompte SQL CHAR(2).
           10 CleRib SQL CHAR(2).
           10 SoldeCrediteur pic 9(7)V99.
           10 SoldeDebiteur pic 9(7)V99.
           10 CodeCLient pic X(36).
           10 NumeroCompte pic 9(16).
       
       01 CompteVerif.
           10 CodeBanque pic 9(5).
           10 CodeGuichet pic 9(5).
           10 RacineCompte pic 9(9).
           10 TypeCompte pic 9(2).
           10 CleRibMemoire pic 9(2).
           10 CleRibCalcule pic 9(2).
           10 NumeroCompte pic 9(11).

       01 Client.
           10 CodeClient pic X(36).
           10 Intitule SQL CHAR-VARYING(10).
           10 Prenom SQL CHAR-VARYING(50).
           10 Nom SQL CHAR-VARYING(50).
           10 NomPrenom SQL CHAR-VARYING(112).
           10 CodePostal SQL CHAR-VARYING(5).
           10 Ville SQL CHAR-VARYING(50).

       01 Banque.
           10 CodeBanque SQL CHAR(5).
           10 NomBanque SQL CHAR-VARYING(200).
       
       77 CalculRib1 pic 9(14).
       77 CalculRib2 pic 9(14).
       77 CalculRib3 pic 9(14).
       77 CalculRib4 pic 9(14).
       77 CalculRib5 pic 9(14).
       77 CalculRib6 pic 99.
       77 Ligne pic 99.
       77 testRib pic 9(17).
       77 LigneAffichageCompte pic 99.
       77 LigneAffichageBanque pic 99.
       77 BanqueAffichage pic X(78).
       77 PageBanques pic 99.
       77 DerniereLigne pic 9.
       77 DernierChamp pic X(30).
       77 ChoixMenuPrincipal pic 9.
       77 ChoixAction pic 9.
       77 ChoixPage pic X.
       77 FinDeFichier pic 9.
       77 CouleurFond pic 99 value 15.
       77 CouleurCaractere pic 99 value 0.
       77 response pic X.

       77 CNXDB STRING.
           EXEC SQL
               INCLUDE SQLCA 
           END-EXEC.
           EXEC SQL
               INCLUDE SQLDA
           END-EXEC.

       screen section.

      ****
      * Menu principal
      ****

       01 MenuPrincipal background-color CouleurFond Foreground-color CouleurCaractere.  
           10 line 1 col 1 blank screen.
           10 line 3 col 31 value "Gestion de la banque".
           10 line 5 col 2 value "Date systeme :".
           10 line 5 col 17 from Jour of DateSysteme.
           10 line 5 col 19 value "/".
           10 line 5 col 20 from Mois of DateSysteme.
           10 line 5 col 22 value "/".
           10 line 5 col 23 from Annee of DateSysteme.
           10 line 5 col 70 value "Option : ".
           10 line 5 col 79 from ChoixMenuPrincipal.
           10 line 8 col 4 value "- 1 - Importation des comptes .......................................:".
           10 line 9 col 4 value "- 2 - Liste des banques .............................................:".
           10 line 10 col 4 value "- 3 - Liste des comptes .............................................:".
           10 line 11 col 4 value "- 4 - Controle des cles RIB .........................................:".
           10 line 12 col 4 value "- 5 - Gestion des cliens ............................................:".
           10 line 14 col 4 value "- 0 - Retour au menu appelant .......................................:".

      ****
      * Menu Importation
      ****

       01 MenuImportation background-color CouleurFond Foreground-color CouleurCaractere.  
           10 line 1 col 1 blank screen.
           10 line 1 col 1 value space pic X(80) background-color CouleurCaractere Foreground-color CouleurFond.
           10 line 3 col 31 value "Importation des comptes".
           10 line 5 col 2 value "Date systeme :".
           10 line 5 col 17 from Jour of DateSysteme.
           10 line 5 col 19 value "/".
           10 line 5 col 20 from Mois of DateSysteme.
           10 line 5 col 22 value "/".
           10 line 5 col 23 from Annee of DateSysteme.
           10 line 5 col 70 value "Option : ".
           10 line 5 col 36 from ChoixAction.


      ****
      * Menu Liste des banques
      ****

       01 MenuListeBanque.
           10 line 1 col 1 blank screen.
           10 line 1 col 1 value "Page [S]uivante - Retour au [M]enu" background-color CouleurCaractere Foreground-color CouleurFond.
           10 line 3 col 31 value "Liste des banques" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 2 value "Code" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 8 value "Nom de la banque" background-color CouleurFond Foreground-color CouleurCaractere.

      ****
      * Liste des banques
      ****
       01 ListeBanque background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 2 from BanqueAffichage.
           10 line 1 col 36 from ChoixPage.

      ****
      * Menu Liste des comptes
      ****

       01 MenuListeCompte.
           10 line 1 col 1 blank screen.
           10 line 1 col 1 value space pic X(80) background-color CouleurCaractere Foreground-color CouleurFond.
           10 line 1 col 1 value "Page [S]uivante - Retour au [M]enu" background-color CouleurCaractere Foreground-color CouleurFond.
           10 line 3 col 31 value "Liste des comptes" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 2 value "Nom" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 21 value "Banque" background-color CouleurFond Foreground-color CouleurCaractere.
      *    10 line 5 col 38 value "Code" background-color CouleurFond Foreground-color CouleurCaractere.
      *    10 line 5 col 44 value "Racine" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 35 value "Compte" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 49 value "Type" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 53 value "RIB" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 59 value "Debit" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 72 value "Credit" background-color CouleurFond Foreground-color CouleurCaractere.


      ****
      * Liste des comptes
      ****
       01 ListeCompte.
           10 line Ligne col 2 from NomPrenom of Client pic X(20) background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 21 from NomBanque of Banque pic X(12) background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 35 from CodeGuichet of Compte background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 40 from RacineCompte of Compte background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 50 from TypeCompte of Compte background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 53 from CleRib of Compte background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 55 from SoldeDebiteur of Compte pic Z(9)9V,99 background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 68 from SoldeCrediteur of Compte pic Z(9)9V,99  background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 1 col 36 from ChoixPage background-color CouleurFond Foreground-color CouleurCaractere.

      ****
      * Menu Liste des RIB
      ****

       01 MenuListeRib.
           10 line 1 col 1 blank screen.
           10 line 1 col 1 value space pic X(80) background-color CouleurCaractere Foreground-color CouleurFond.
           10 line 1 col 1 value "Page [S]uivante - Retour au [M]enu" background-color CouleurCaractere Foreground-color CouleurFond.
           10 line 3 col 31 value "Liste des RIB modifi�s" background-color CouleurFond Foreground-color CouleurCaractere.
      *    10 line 5 col 2 value "Nom" background-color CouleurFond Foreground-color CouleurCaractere.
      *    10 line 5 col 21 value "Banque" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 35 value "Compte" background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 5 col 55 value "RIB" background-color CouleurFond Foreground-color CouleurCaractere.


      ****
      * Liste des RIB
      ****
       01 ListeRib.
      *    10 line Ligne col 2 from NomPrenom of Client pic X(20) background-color CouleurFond Foreground-color CouleurCaractere.
      *    10 line Ligne col 21 from NomBanque of Banque pic X(12) background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 35 from CodeGuichet of CompteVerif background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 40 from NumeroCompte of CompteVerif background-color CouleurFond Foreground-color CouleurCaractere.
           10 line Ligne col 55 from CleRibCalcule of CompteVerif background-color CouleurFond Foreground-color CouleurCaractere.
           10 line 1 col 36 from ChoixPage background-color CouleurFond Foreground-color CouleurCaractere.


       procedure division.


      ****
      * Affichage du menu principal
      ****

       AffichageMenu.
           perform AffichageMenu-Init.
           perform AffichageMenu-Trt until ChoixMenuPrincipal = 0.
           perform AffichageMenu-Fin.  

       AffichageMenu-Init.
           move 6 to ChoixMenuPrincipal.
           accept DateSysteme from date.

           move "Trusted_Connection=yes;Database=Cigales;server=SRF-EN2-04\SQLEXPRESS;factory=System.Data.SqlClient;" to CNXDB.
             exec sql
               Connect using :CnxDb
             end-exec.

      * autocommit

           EXEC SQL
               SET AUTOCOMMIT ON
           End-EXEC.

       AffichageMenu-Trt.
           move 0 to ChoixMenuPrincipal.
           display MenuPrincipal.
           accept ChoixMenuPrincipal line 5 col 79.
           evaluate ChoixMenuPrincipal
               when 1 perform ImportationComptes
               when 2 perform ImportationBanques
               when 3 perform ListeComptes
               when 4 perform ControleRib
               when 5 continue
           end-evaluate.

       AffichageMenu-Fin.
           stop run.

      ****
      * Importation des comptes
      ****

       ImportationComptes.
           perform ImportationComptes-Init.
           perform ImportationComptes-Trt.
           perform ImportationComptes-Fin.
            
       ImportationComptes-Init.
           continue.

       ImportationComptes-Trt.
           display MenuImportation.
           perform LectureListingComptes.

       ImportationComptes-Fin.
           stop run.

      ****
      * Lecture du listing des comptes
      ****

       LectureListingComptes.
           perform LectureListingComptes-Init.
           perform LectureListingComptes-Trt until FinDeFichier = 1.
           perform LectureListingComptes-Fin.
            
       LectureListingComptes-Init.
      ****
      * Ouverture du fichier client.csv
      ****
           move 0 to FinDeFichier.
           open input FichierClient.
           read FichierClient.


       LectureListingComptes-Trt.
      ****
      * R�cup�ration de la n-i�me ligne
      ****
           read FichierClient
               at end move 1 to FinDeFichier
               not at end perform Trt-ligne
           end-read.

      ****
      * Traitement de la n-i�me ligne
      ****

       Trt-ligne.
           unstring ligne-client-input
           delimited by ";" into
               CodeBanque of Compte
               CodeGuichet of Compte
               RacineCompte of Compte
               TypeCompte of Compte
               CleRib of Compte
               Intitule of Client
               Prenom of Client
               Nom of Client
               DernierChamp
           end-unstring.

           unstring DernierChamp
           delimited by "-" or " " into
               SoldeCrediteur
               SoldeDebiteur
           end-unstring.

      * On divise par 100

           Divide 100 into SoldeDebiteur of Compte.
           Divide 100 into SoldeCrediteur of Compte.

           exec sql
               select newid() into :Client.CodeClient
           end-exec.

           exec sql
               INSERT INTO Client
                   (CodeClient
                   ,Intitule
                   ,Prenom
                   ,Nom)
               VALUES
                   (:Client.CodeClient
                   ,:Client.Intitule
                   ,:Client.Prenom
                   ,:Client.Nom)
           end-exec.

           exec sql
               INSERT INTO Compte
                   (CodeClient
                   ,CodeBanque
                   ,CodeGuichet
                   ,RacineCompte
                   ,TypeCompte
                   ,CleRib
                   ,SoldeCrediteur
                   ,SoldeDebiteur)
               VALUES
                   (:Client.CodeClient
                   ,:Compte.CodeBanque
                   ,:Compte.CodeGuichet
                   ,:Compte.RacineCompte
                   ,:Compte.TypeCompte
                   ,:Compte.CleRib
                   ,:Compte.SoldeCrediteur
                   ,:Compte.SoldeDebiteur)
           end-exec.

      

       LectureListingComptes-Fin.
      ****
      * Fermeture du fichier
      ****
           close FichierClient.
           stop run.

      ****
      * Importation de la liste des banques
      ****

       ImportationBanques.
           perform ImportationBanques-Init.
           perform ImportationBanques-Trt until sqlcode = 100 or sqlcode = 101.
           perform ImportationBanques-Fin.
            
       ImportationBanques-Init.
           exec sql
               declare listeBanques cursor for
               select CodeBanque, NomBanque from Banque order by NomBanque
           end-exec.
           exec sql
               open listeBanques
           end-exec.
           display MenuListeBanque.
           move 1 to LigneAffichageBanque.
           move 6 to Ligne.

       ImportationBanques-Trt.
           exec sql
               fetch listeBanques into :Banque.CodeBanque, :Banque.NomBanque
           end-exec.
           if sqlcode = 100 or sqlcode = 101 then
               add 1 to Ligne
               display "fin de la liste des banques" line Ligne col 10
           else
               perform ListeBanque-Affichage
               add 1 to Ligne
           end-if.
       


       ListeBanque-Affichage.
      * Affichage de la ligne
           if Ligne < 25 then
               string
                   CodeBanque of Banque delimited " "
                   " "
                   NomBanque of Banque delimited by size
                   into BanqueAffichage
               end-string

               display ListeBanque
           else
               move "s" to ChoixPage
               accept ChoixPage line 1 col 36
               display MenuListeBanque

               if ChoixPage = "s" then
                   add 20 to LigneAffichageBanque
                   move 5 to Ligne
               end-if
           end-if.

       ImportationBanques-Fin.
           exec sql
               close listeBanques
           end-exec.
           accept response.

      ****
      * Importation de la liste des comptes
      ****

       ListeComptes.
           perform ListeComptes-Init.
           perform ListeComptes-Trt until sqlcode = 100 or sqlcode = 101.
           perform ListeComptes-Fin.
            
       ListeComptes-Init.
           exec sql
               declare listeCompte cursor for
               select NomBanque, CodeGuichet, RacineCompte, TypeCompte, CleRib, SoldeCrediteur, SoldeDebiteur, NomPrenom from ListeCompte order by NomBanque
           end-exec.
           exec sql
               open listeCompte
           end-exec.
           display MenuListeCompte.
           move 1 to LigneAffichageCompte.
           move 6 to Ligne.

       ListeComptes-Trt.
           exec sql
               fetch listeCompte into :Banque.NomBanque, :Compte.CodeGuichet, :Compte.RacineCompte, :Compte.TypeCompte, :Compte.CleRib, :Compte.SoldeCrediteur, :Compte.SoldeDebiteur, :Client.NomPrenom
           end-exec.
           if sqlcode = 100 or sqlcode = 101 then
               add 1 to Ligne
               display "fin de la liste des comptes" line Ligne col 10
           else
               perform ListeCompte-Affichage
               add 1 to Ligne
           end-if.
       


       ListeCompte-Affichage.
      * Affichage de la ligne
           if Ligne < 24 then
               display ListeCompte
           else
               move "s" to ChoixPage
               accept ChoixPage line 1 col 36
               display MenuListeCompte

               if ChoixPage = "s" then
                   add 20 to LigneAffichageCompte
                   move 5 to Ligne
               end-if
           end-if.

       ListeComptes-Fin.
           exec sql
               close listeCompte
           end-exec.
           accept response.


       ControleRib.
           perform ControleRib-Init.
           perform ControleRib-Trt until sqlcode = 100 or sqlcode = 101.
           perform ControleRib-Fin.

       ControleRib-Init.
           exec sql
               declare listeRib cursor
               for select CodeBanque, CodeGuichet, NumeroCompte, CleRib from Compte
           end-exec.
           exec sql
               open listeRib
           end-exec.
           display MenuListeRib.
           move 1 to LigneAffichageCompte.
           move 6 to Ligne.
           
       ControleRib-Trt.
           exec sql
               fetch listeRib into :CompteVerif.CodeBanque, :CompteVerif.CodeGuichet, :CompteVerif.NumeroCompte, :CompteVerif.CleRibMemoire
           end-exec.
           if sqlcode = 100 or sqlcode = 101 then
               add 1 to Ligne
               display "fin de la v�rification des RIB" line Ligne col 10
           else
               perform ListeRib-Affichage
           end-if.

       ControleRib-Fin.
           exec sql
               close listeRib
           end-exec.
           accept response.

      * calcul : 
      * cl� = 97 - ((89 * CodeBanque + 15 * CodeGuichet + 3 * NumeroCompte) modulo 97);

       ListeRib-Affichage.

           multiply 89 by CodeBanque of CompteVerif giving CalculRib1.
           multiply 15 by CodeGuichet of CompteVerif giving CalculRib2.
           multiply 3 by NumeroCompte of CompteVerif giving CalculRib3.

           add CalculRib1 CalculRib2 CalculRib3 giving CalculRib4.

      *    function mod (CalculRib4 97) giving CalculRib5.
           divide CalculRib4 by 97 giving CalculRib5 remainder CalculRib6

           subtract CalculRib6 from 97 giving CleRibCalcule.

           if CleRibMemoire <> CleRibCalcule then
               move CleRibCalcule to CleRibMemoire
           end-if.

      * Affichage de la ligne
           if Ligne < 24 then
      *        if CleRibCalcule <> CleRibMemoire then
                   display ListeRib
                   add 1 to Ligne
      *        end-if
           else
               move "s" to ChoixPage
               accept ChoixPage line 1 col 36
               display MenuListeRib

               if ChoixPage = "s" then
                   add 20 to Ligne
                   move 5 to Ligne
               end-if
           end-if.

           

       end program Program1.
