
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
USE f:\comercio\files\rsmpquim SHARED

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
 SELECT rsmpquim
    SCAN FOR marca=1
     a1=pempsano
     a2=pempscor
     a3=pempccli
     a4=pempdfec
     a5=pempdres
     a6=fecter
     a7=STRCONV(pemphech,9)
     a8=STRCONV(pempatte,9)
     a9=STRCONV(pempobsv,9)
        
     ******* cmd3=SQLEXEC(lnHandle,"INSERT INTO reserva (anio,correlativo,cliente,fecha,fechaini,fechafin,hechopor,solicitante,observaciones,estado)"+;
                            " values (?a1,?a2,?a3,?a4,?a5,?a6,?a7,?a8,?a9,1)" ) 
            
    ENDSCAN 
                                             
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

