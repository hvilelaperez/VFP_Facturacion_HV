IF APRINTERS(gaPrinters) > 0  
   CLEAR  && clear the current output window
   DISPLAY MEMORY LIKE gaPrinters && show the contents of the array
ELSE  
   WAIT WINDOW 'No printers found.'
ENDIF
 
CLEAR
cPrinter = GETPRINTER( ) 
WAIT WINDOW IIF(EMPTY(cPrinter), 'No printer chosen', cPrinter)
 
