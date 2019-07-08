       program-id. SinistreParAssure as "StatistiqueSinistresAssures.SinistreParAssure".
       
       environment division.
       input-output section.
       file-control.
       select FichierSinistresParAssure assign to "C:\Users\Mohamed\Desktop\Stage\SinistresParAssure.csv"
                organization is line sequential access sequential.

       data division.
       File Section.
       FD FichierSinistresParAssure record varying from 0 to 255.
       01 Enr-FichierSinistresParAssure  pic x(255).


       working-storage section.
       
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
       
      *---- Sinistres par assuré
       01 TotalSinistresAssure.
           05 NumAssure    sql char-varying(5).
           05 TypeSin Occurs 3 times.
                   10 NbreParSin   pic 9(3).
                   10 MontParSin   pic 9(6)V99.
       01 FichSinParAssure pic x(55).

       77 EoDB pic 9.
       77 NoLigne pic 99.

       77  CNXDB STRING.
           EXEC SQL 
               INCLUDE SQLCA
           END-EXEC.
           EXEC SQL 
               INCLUDE SQLDA
           END-EXEC.


       procedure division.
           	   
      *--------------------------------------------------------------------------
      *          Annexe 2: Calcule Nombre des Sinistres Par Type et Par Age
      *--------------------------------------------------------------------------
       CalculParAssure.
           perform CalculParAssure-Init.
           perform CalculParAssure-Trt until EoDB=1.
           perform CalculParAssure-Fin.

       CalculParAssure-Init.
           open output FichierSinistresParAssure.
           move 0 to NoLigne.
           move 0 to EoDB.
           initialize TotalSinistresAssure.
           
      **** Création du curseur
           exec sql
               Declare TotalSinistres-Cursor cursor for
                   select AAssur,STypeSin,SMontSin from Sinistre inner join Assure on AAssur = SNAssur order by AAssur
           end-exec.
      **** Ouverture du curseur
           exec sql
               open TotalSinistres-Cursor
           end-exec.
      *--- Chercher le 1er Assure
           exec sql
               fetch TotalSinistres-Cursor into :SinistreDonne.NAssur,:SinistreDonne.TypeSin,:SinistreDonne.MontSin
           end-exec.
           if SQLCODE=100 or SQLCODE=101
               move 1 to EoDB
               perform EnrFichier.
      *--- on enregistre le numéro d'assuré dans A-Assur of Assure pour comparer
           move NAssur of SinistreDonne to A-Assur of Assure.
      *--- On enregistre les infos pour le premier sinistre
           move NAssur of SinistreDonne to NumAssure of TotalSinistresAssure.
           perform EnrParTypeSin.

       CalculParAssure-Trt.
           exec sql
               fetch TotalSinistres-Cursor into :SinistreDonne.NAssur,:SinistreDonne.TypeSin,:SinistreDonne.MontSin
           end-exec.
           if SQLCODE=100 or SQLCODE=101
               move 1 to EoDB
      *---- Enregistrement les données pour le dernier assuré trouvé dans la table Sinistre:
               perform EnrFichier
           else perform CalParAssur
           end-if.

       CalculParAssure-Fin.
           exec sql
             close TotalSinistres-Cursor
           end-exec.
           close FichierSinistresParAssure.
           goback.

       
       CalParAssur.
           if NAssur of SinistreDonne = A-Assur of Assure
      **** Même assuré -> on remplit le tableau 
               perform EnrParTypeSin
           else
      *----- Enregistrement des données pour chaque assuré 
               perform EnrFichier
               move NAssur of SinistreDonne to A-Assur of Assure
      *----- initialiser les variables aprés l'écriture.
               initialize TotalSinistresAssure
               move "  " to FichSinParAssure 
			   move NAssur of SinistreDonne to NumAssure of TotalSinistresAssure

               perform EnrParTypeSin
           end-if.
      *---- Calcule Nombre de sinistres pour chaque assuré par type de sinistre: 
       EnrParTypeSin.
           evaluate TypeSin of SinistreDonne
               when 1
                   add 1 to NbreParSin of TypeSin(1) 
                   add MontSin of SinistreDonne to MontParSin of TypeSin(1)
               when 2
                   add 1 to NbreParsin of TypeSin(2) 
                   add MontSin of SinistreDonne to MontParsin of TypeSin(2) 
               when 3
                   add 1 to NbreParsin of TypeSin(3) 
                   add MontSin of SinistreDonne to MontParsin of TypeSin(3) 
           end-evaluate.

      *----- Fonction pour Enregistrer les données dans un fichier CSV:
       EnrFichier.
           add 1 to NoLigne.
           string 
               NumAssure       of TotalSinistresAssure
               ";"  NbreParSin of TypeSin(1) 
               ";"  MontParSin of TypeSin(1) 
               ";"  NbreParSin of TypeSin(2) 
               ";"  MontParSin of TypeSin(2) 
               ";"  NbreParSin of TypeSin(3) 
               ";"  MontParSin of TypeSin(3) 
               ";"   into FichSinParAssure
           end-string.
           write Enr-FichierSinistresParAssure from FichSinParAssure
                   after NoLigne.

      *-------------------------------------------------------------------------------------
*----- Fin de Calcul des sinistres par assuré et par type de sinistre [Annex 2]
      *-------------------------------------------------------------------------------------

           
       end program SinistreParAssure.
