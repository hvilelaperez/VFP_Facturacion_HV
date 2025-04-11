SET DELETED ON
SET DATE BRITISH

SELECT 0 
USE F:\COMERCIO\FILES\GEMDQUIM SHARED

SELECT GEMPSNUM,GEMDTART+GEMDCPRV+"0"+GEMDCCOL+GEMDCVAR AS CODIGO,GEMDMCNE,CAST (0 AS N(10,2)) AS OTRO, "          " AS OTROORIGEN;
       FROM GEMDQUIM  WHERE GEMPDFEC>=CTOD("01/01/2008") INTO CURSOR AVER READWRITE 

SELECT GEMDQUIM 
USE 

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


mYFECHA=CTOD("01/01/2008")

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

  	                      
	cmd3=SQLEXEC(lnHandle,"SELECT UNICO,PRODUCTO,ORIGEN,COSTO FROM VTALOTES WHERE FINGRESO>=?mYFECHA","aVER2")
  	                                            
    
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT AVER
GO TOP
 SCAN
    A1=GEMPSNUM
    A2=CODIGO
    SELECT AVER2
    GO TOP
    LOCATE FOR UNICO=A1 AND PRODUCTO=A2    
     IF FOUND()
        X1=COSTO
        X2=ORIGEN
        SELECT AVER 
        REPLACE OTRO WITH X1
        REPLACE OTROORIGEN WITH X2
     ENDIF 
     SELECT AVER
 ENDSCAN 
        
SELECT AVER
BROWSE FOR GEMDMCNE<>OTRO
      









