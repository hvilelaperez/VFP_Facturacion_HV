
SET DATE BRITISH
SET DELETED ON
SET TALK OFF
SET ECHO OFF

lcStringCnxRemoto = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"                                                                                                
        

Mydato=STRCONV('Año',9)
                                   
SQLSETPROP(0,"DispLogin" , 3 )
lnHandle = SQLSTRINGCONNECT(lcStringCnxRemoto)
IF lnHandle>0  

     
   	*** cmd1=SQLEXEC(lnHandle," Insert into testcompatible (Micampo) values (?Mydato)") && Comando Inicial
   	
   	cmd1=SQLEXEC(lnHandle,"Select micampo from testcompatible limit 1","Mytest")
    
   SQLDISCONNECT(lnHandle)
ELSE
   AERROR(laErr)
   MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Mytest
GO top
IF ALLTRIM(STRCONV(Mytest.micampo,11))='Año'
    WAIT ' Todo Bien ' WINDOW NOWAIT 
ELSE

    WAIT ' Todo Mal ' WINDOW NOWAIT 
ENDIF         

