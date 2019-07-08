       program-id. SinPourMaj as "StatistiqueSinistresAssures.SinPourMaj".

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       
       01 Mouvement.
            10 NAssur      SQL CHAR-VARYING(5).
            10 NImma       sql char-varying(9).
            10 CodeMouv    pic x(1).
            10 Vrisque     pic 9.
            10 OptDom      pic 9.
            10 Puiss       Pic 99.
            10 MouvDate    SQL CHAR-VARYING(8).
            10 DateMouv    redefines MouvDate. 
               15 Annee    pic 9(4).
               15 Mois     pic 99.
               15 Jour     pic 99.

       77 EoDB pic 9.
       77 NoLigne pic 99.
       77 CouleurFond     pic 99 value 15.
       77 CouleurTexte    pic 99 value 0.
       77 OptionChoisie   pic 9.
       
       77  CNXDB STRING.
           EXEC SQL 
               INCLUDE SQLCA
           END-EXEC.
           EXEC SQL 
               INCLUDE SQLDA
           END-EXEC.

       SCREEN SECTION.
      *-------------- Ecran vide
       01  Ecran-Blanc background-color is CouleurFond foreground-color is CouleurTexte.
           05 line  1 col  1 Blank Screen.
             
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
           10 line NoLigne  col 51 from Jour of DateMouv.
           10 line NoLigne  col 53 value "/".
           10 line NoLigne  col 54 from Mois of DateMouv.
           10 line NoLigne  col 56 value "/".
           10 line NoLigne  col 57 from Annee of DateMouv.

       PROCEDURE DIVISION.
      *-------------------------------------------------------------------------------------   
*--- Enregsitrement des modifs apportées au Vehicule par Fichier Mouvement [Annexe 3]
      *-------------------------------------------------------------------------------------
       BilanMajVehicule.
           perform BilanMajVehicule-Init.
           perform BilanMajVehicule-Trt until EoDB = 1.
           perform BilanMajVehicule-Fin.

       BilanMajVehicule-Init.
           display Ecran-Blanc.
           move 3 to NoLigne.
           Move 0 to EoDB.
               exec sql
                   Declare Affich-Cursor cursor for
                   select MAssur,MImma,MCodeMouv, MRisq, MDom, MPuiss, MDate from Mouvement order by MAssur
               end-exec.
      **** Ouverture du curseur
           exec sql
               open Affich-Cursor
           end-exec.

       BilanMajVehicule-Trt.
               exec sql
                   fetch Affich-Cursor into :Mouvement.NAssur, :Mouvement.NImma, :Mouvement.CodeMouv, :Mouvement.VRisque,
                   :Mouvement.OptDom, :Mouvement.Puiss, :Mouvement.MouvDate
               end-exec.
               if SQLCODE=100 or SQLCODE=101
                   move 1 to EoDB
               else
                   add 1 to NoLigne
                   display T-AfficheMouv
                   perform MajBaseVehicule
               end-if.

       BilanMajVehicule-Fin.
               exec sql
                   close Affich-Cursor
               end-exec.
               accept OptionChoisie.
               goback.
           
       MajBaseVehicule.
               evaluate CodeMouv
                   when 'S'
                       exec sql
                           update  Vehicule set TypeModif = :Mouvement.CodeMouv,DateModif = :Mouvement.MouvDate 
                                             where VAssur = :Mouvement.NAssur and VImma = :Mouvement.NImma
                       end-exec
                   when 'A'
                       exec sql
                           update  Vehicule
                                   set TypeModif = :Mouvement.CodeMouv, DateModif = :Mouvement.MouvDate,
                                   VRisq = :Mouvement.VRisque, VDom = :Mouvement.OptDom, Vpuiss = :Mouvement.Puiss
                                   where VAssur = :Mouvement.NAssur and VImma = :Mouvement.NImma
                       end-exec
                   when 'M'
                       exec sql
                           update  Vehicule set TypeModif = :Mouvement.CodeMouv,DateModif = :Mouvement.MouvDate,
                                   VRisq = :Mouvement.VRisque, VDom = :Mouvement.OptDom
                                   where VAssur = :Mouvement.NAssur and VImma = :Mouvement.NImma
                       end-exec
               end-evaluate.

           
      *END PROGRAM MajVehicule.
           
       end program SinPourMaj.
