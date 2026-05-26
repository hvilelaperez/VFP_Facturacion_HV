SET TALK OFF
SET ECHO OFF

SET DELETED ON
SET DATE BRITISH
SET PROCEDURE TO funciones 

PUBLIC Mystring,My60,My30

My60=DATE()-60
My30=DATE()-30

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
    cmd1=SQLEXEC(lnHandle,"SELECT CODIGOC,serie,numero,fecha FROM FACTURA WHERE FECHA>='2009-04-01' AND FECHA<='2009-04-07' and estado <>'AN' ORDER BY fecha","MiInfo")    
    cmd2=SQLEXEC(lnHandle,"SELECT codigo,nombre,ruc from clientes ","Myc2")
                                             
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT a.serie,a.numero,a.fecha,a.codigoc,ALLTRIM(STRCONV(b.nombre,11)) as Nombre,b.ruc FROM Miinfo as a LEFT JOIN Myc2 as b;
       ON a.codigoc=b.codigo ORDER BY codigoc INTO CURSOR resultado

