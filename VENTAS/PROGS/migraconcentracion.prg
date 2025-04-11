
SET DELETED ON
SET DATE BRITISH

SET DEFAULT TO f:\ventas
SET PATH TO DATA,PROGS,FORMULARIOS,INFORMES
SET PROCEDURE TO FUNCIONES


OPEN DATABASE f:\newcompras\data\sqm.dbc SHARED
SELECT 0
USE productos SHARED

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"



SELECT codigo,upreciocarg,upreciocont FROM productos ORDER BY 1 INTO CURSOR milista READWRITE 

SELECT milista
GO top

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0      
    SCAN   
       a1=ALLTRIM(Milista.codigo)
       a2=Milista.upreciocarg
       a3=Milista.upreciocont
                                                
       cmd1=SQLEXEC(lnHandle,"UPDATE productos SET upreciocarg=?a2,upreciocont=?a3 Where TRIM(codigo)=?a1")
    ENDSCAN    
                          						      					       
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT productos
USE





