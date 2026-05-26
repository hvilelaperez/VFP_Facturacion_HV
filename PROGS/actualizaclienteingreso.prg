SET DELETED ON
SET DATE TO brit


SELECT 0
USE f:\comercio\files\clmpquim SHARED
SELECT * FROM clmpquim  INTO CURSOR clientes
SELECT clmpquim
USE
                                                  
Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"     
          
SQLSETPROP(0,"DispLogin" , 3 )
lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    SELECT clientes
      GO top
      SCAN
         v1=clmpccli
         v2=clmpfing
                                            
         cmd = SQLEXEC(lnHandle,"update clientes set fechaingreso=?v2 where codigo=?v1")
         
      ENDSCAN               
 
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
     MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF
