
SET DELETED ON
SET DATE TO BRITISH 

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

SELECT 0
USE f:\comercio\files\rsmdquim SHARED

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
 SELECT rsmdquim
    SCAN FOR xsit=1
     a1=pemdtart+pemdcprv+"0"+pemdccol+pemdcvar
     a2=pemdcant
     a3=pemdqsal
     a4=xsit
     a5=pemdmopu
     a6=pempscor
     a7=pempsano
        
     ******** cmd3=SQLEXEC(lnHandle,"INSERT INTO detareservas (unico,producto,cantidad,despachado,estado,precio,xanio,xcorrelativo) "+;
                            " values (?a6,?a1,?a2,?a3,?a4,?a5,?a7,?a6)" ) 
            
    ENDSCAN 
                                             
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT rsmdquim 
USE 
