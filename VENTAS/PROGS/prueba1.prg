
SET DATE BRITISH
SET DELETED ON
SET TALK OFF
SET ECHO OFF

lcStringCnxRemoto = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=usuario;" + ;
                    "PWD=sqmuser;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"                                                                                                
        
SELECT 0
USE \\sqmserver\d\comercio\files\clmpquim SHARED

SELECT clmpccli,clmpndes FROM clmpquim INTO CURSOR clientes

SELECT clmpquim
USE

                                   
SQLSETPROP(0,"DispLogin" , 3 )
lnHandle = SQLSTRINGCONNECT(lcStringCnxRemoto)
IF lnHandle>0  

   SELECT clientes
   GO top   
   LOCAL xpas1
   SCAN 
   		xpas1=clientes.clmpccli    
   		xpas2=clientes.clmpndes        
   	*****	cmd1=SQLEXEC(lnHandle,"Call Insert_myclientes(?xpas1,?xpas2)") 
   ENDSCAN
   
   SQLDISCONNECT(lnHandle)
ELSE
   AERROR(laErr)
   MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF