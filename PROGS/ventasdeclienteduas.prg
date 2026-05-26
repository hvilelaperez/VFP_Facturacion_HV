
SET TALK OFF
SET ECHO OFF

SET DELETED ON
SET DATE BRITISH
SET PROCEDURE TO funciones 

PUBLIC Mystring,My60,My30,My365

My60=DATE()-60
My30=DATE()-30

My365=CTOD("01/04/2009")
Hoy=DATE()

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
    cmd1=SQLEXEC(lnHandle," SELECT a.producto,cantidad as Canti FROM detafacturas a,factura b "+;
                          " WHERE a.unico=b.unico and b.codigoC='C004' and b.serie=1 and b.estado<>'AN' and "+;
                          " fecha>=?My365 and fecha<=?hoy order by 1 ","MiInfoD")    
    cmd2=SQLEXEC(lnHandle," select * from productos ","BaseProd")

                                             
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF



SELECT a.producto,ALLTRIM(STRCONV(b.nombre,11)) as Nombre ,a.canti FROM Miinfod as a LEFT JOIN BaseProd as b ON a.producto=b.codigo INTO CURSOR Final

