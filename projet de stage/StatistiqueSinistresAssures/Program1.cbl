       program-id. Program1 as "StatistiqueSinistresAssures.Program1".

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
       01 DateSinistre.
           10 Annee Pic 9(4).
           10 Mois Pic 99.
           10 Jour Pic 99.
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
       
       01 Mouvement.
            10 NAssur      SQL CHAR-VARYING(5).
            10 NImma       sql char-varying(9).
            10 CodeMouv    pic x(1).
            10 Vrisque       pic 9.
            10 OptDom      pic 9.
            10 Puiss       Pic 99.
            10 MouvDate    sql char-varying(8).


      *******************  Variables
       77 TrancheAgeSup pic 99.
       77 EofImport       pic 9.
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

      **** Ecran vide
       01  Ecran-Blanc background-color is CouleurFond foreground-color is CouleurTexte.
           05 line  1 col  1 Blank Screen.

      **** Menu d'entrée dans le programme

       01 MenuPrincipal background-color is CouleurFond foreground-color is CouleurTexte.
           05 line 01 col 33 display "Menu d'affichage".
           05 line 03 col 02 display "0- Quitter.".
           05 line 04 col 02 display "1- Sinistres par tranche d'age.".
           05 line 05 col 02 display "2- Sinistres Par Assure.".
           05 line 06 col 02 display "3- Fichier recapitulatif de la mise a jour du fichier des vehicules.".
           05 line 07 col 02 display "4- Cotisations de tous les assures.".
           05 line 11 col 02 display "Choix : ".
           05 line 24 col 35 from MessageErreur.

      *---- Tableau d'affichage Les mouvement faites sur le Fichier Cehicule.
       01  T-AfficheMouv foreground-color is CouleurTexte background-color is CouleurFond.
           10 line 1  col 17 value "Les mouvements faites sur le fichier vehicule".
           10 line 3  col 2 value "Numero Assure".
           10 line 3  col 18 value "Immatriculation".
           10 line 3  col 36 value "Modification".
           10 line 3  col 51 value "Date".
           10 line NoLigne  col 2  from NAssur   of Mouvement.
           10 line NoLigne  col 18 from NImma    of Mouvement.
           10 line NoLigne  col 36 from CodeMouv of Mouvement.
           10 line NoLigne  col 51 from MouvDate of Mouvement.


       procedure division.
      *********** Connexion à la base de données ***********************
           MOVE "Trusted_Connection=yes;Database=Assurance;server=MOHAMED-PC\SQLEXPRESS;factory=System.DATA.SqlClient;" to CNXDB.
           exec sql
               Connect using :CnxDb
           end-exec.
      ****** Choix de l'option Autocommit  *************************
           EXEC SQL
               SET AUTOCOMMIT ON
           End-EXEC.
      **************************************************************************************************************
      * En 1er:  Importation du fichier 
      **************************************************************************************************************
       ImportationFichier.
*-------------  1- Importations Fichier Sinistre:
           perform ImportSinistre-Init.
           perform ImportSinistre-Trt Until EofImport = 1.
           perform ImportSinistre-Fin.
      *---------------------------------------------------------------------------------------------
      * Initialisation de l'importation
      *---------------------------------------------------------------------------------------------  
       ImportSinistre-Init.
           Move 0 to EofImport.
           open input FichierSinistre.
      *    read FichierSinistre.
      *---------------------------------------------------------------------------------------------
      * Traitement d'une boucle de l'importation : lecture des lignes du fichier jusqu'à la fin
      *---------------------------------------------------------------------------------------------
       ImportSinistre-Trt.
           read FichierSinistre
               at end move 1 to EofImport
               not at end perform TrtLigneSin
           end-read.

      *---------------------------------------------------------------------------------------------
      * Fin de l'importation : on ferme le fichier
      *---------------------------------------------------------------------------------------------
       ImportSinistre-Fin.
           close FichierSinistre.
           Perform ImportationFichierMouv.
           
      *---------------------------------------------------------------------------------------------
      * Traitement d'une ligne du fichier
      *---------------------------------------------------------------------------------------------
           TrtLigneSin.
      * On sépare les informations de la ligne pour le Fichier Sinistre. 
           unstring EnrFichierSinistre delimited by ";" or " " into
               NSin    of SinistreDonne
               NAssur  of SinistreDonne    
               TypeSin of SinistreDonne
               NImma   of SinistreDonne
               DateSin of SinistreDonne
               MontSin of SinistreDonne
           end-unstring.
                 
      * Traitement du Montant de sinistre : on travaille en Centimes.
           Divide 100 into MontSin of SinistreDonne.
      * On crée l'enregistrement Sinistre : 
           exec sql
                INSERT INTO Sinistre
                    (SNSin,SNAssur,STypeSin,SNImma,SDateSin,SMontSin)
                VALUES
                    (:SinistreDonne.NSin,:SinistreDonne.NAssur,:SinistreDonne.TypeSin,
                     :SinistreDonne.NImma,:SinistreDonne.DateSin,:SinistreDonne.MontSin)
           end-exec.

*------------ 2- Importation Fichier Mouvement
       ImportationFichierMouv.
           perform ImportMouvement-Init.
           perform ImportMouvement-Trt Until EofImport = 1.
           perform ImportMouvement-Fin.
      *---------------------------------------------------------------------------------------------
*------------------------ Initialisation de l'importation
      *---------------------------------------------------------------------------------------------  
       ImportMouvement-Init.
           Move 0 to EofImport.
           open input FichierMouvement.
      *---------------------------------------------------------------------------------------------
* Traitement d'une boucle de l'importation : lecture des lignes du fichier jusqu'à la fin
      *---------------------------------------------------------------------------------------------
       ImportMouvement-Trt.
           read FichierMouvement
               at end move 1 to EofImport
               not at end perform TrtLigneMouv
           end-read.

        TrtLigneMouv.
* ---------- On sépare les informations de la ligne pour le Fichier Mouvement. 
           unstring EnrFichierMouvement delimited by ";" or " " into
               NAssur      of Mouvement
               NImma       of Mouvement    
               CodeMouv    of Mouvement
               Vrisque     of Mouvement
               OptDom      of Mouvement
               Puiss       of Mouvement
               MouvDate    of Mouvement
           end-unstring.
* -------- On crée l'enregistrement Mouvement : 
           evaluate CodeMouv
                   when 'S' 
                       exec sql
                           INSERT INTO Mouvement
                               (MAssur,MImma,MCodeMouv,MDate)
                           VALUES
                               (:Mouvement.NAssur,:Mouvement.NImma,:Mouvement.CodeMouv,:Mouvement.MouvDate)
                       end-exec
                   when 'M' 
                       exec sql
                        INSERT INTO Mouvement
                            (MAssur,MImma,MCodeMouv,MRisq,MDom,MDate)
                        VALUES
                            (:Mouvement.NAssur,:Mouvement.NImma,:Mouvement.CodeMouv,:Mouvement.VRisque,
                            :Mouvement.OptDom,:Mouvement.MouvDate)
                       end-exec
                   when 'A' 
                       exec sql
                            INSERT INTO Mouvement
                                (MAssur,MImma,MCodeMouv,MRisq,Mdom,MPuiss,MDate)
                            VALUES
                                (:Mouvement.NAssur,:Mouvement.NImma,:Mouvement.CodeMouv,:Mouvement.VRisque,
                                :Mouvement.OptDom,:Mouvement.Puiss,:Mouvement.MouvDate)
                       end-exec
           end-evaluate.

       ImportMouvement-Fin.
           close FichierMouvement.
           call "SinistreParAssure".

*------- Affichage de menu
       perform EnTroisieme.
      *-------------------------------------------------------------------------------    
*----- Appel des Sous Programmes pour les calculs
      *------------------------------------------------------------------------------- 
       CalculParTranche.
           call "SinistreParAge".

       CalculParAssureAffich.
           call "SinistreParAssureAffich".

       MajVehicule.
           call "SinPourMaj".


      *-------------------------------------------------------------------------------    
*----- 3eme On affiche le menu jusqu'à ce qu'une option valide a été choisie
      *-------------------------------------------------------------------------------  

       EnTroisieme.
           perform Menu-Init.
           perform Menu-Trt until OptionChoisie = 1.
           perform Menu-Fin.

       Menu-Init.
           move 0 to OptionChoisie.
       Menu-Trt.
           display Ecran-Blanc.
           display MenuPrincipal.
           accept Option line 11 col 10.
           move " " to MessageErreur.

           evaluate Option
               when 0
                   continue
               when 1
                   perform CalculParTranche
               when 2
                   perform CalculParAssureAffich
               when 3
                   PERFORM MajVehicule
               when 4
                   
               when 5
                   stop run
               when other
                   move "Choix invalide" to MessageErreur
           end-evaluate.

       Menu-Fin.
               stop run.
           
       end program Program1.
