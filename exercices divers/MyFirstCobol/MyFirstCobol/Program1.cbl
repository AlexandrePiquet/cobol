       program-id. Program1 as "MyFirstCobol.Program1".
       author. Alexandre Piquet

       environment division
       configuration section
       source-computer SFR-EN2-04.
       object-computer SFR-EN2-04.

       data division.
       file section.
       working-storage section.
       77 response pic X.

       procedure division.

       principal section.
           debut.
      *    ***début du traitement*** 

               display "My first Cobol !".
               accept response.
               stop run.
           
       end program Program1.
