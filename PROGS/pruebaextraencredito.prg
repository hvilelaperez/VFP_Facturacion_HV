SET DELETED ON
SET DATE BRITISH


fec1=CTOD("01/08/2009")
fec2=CTOD("18/08/2009")
sncr1=1
sncr2=1
Mycli="M047"

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd3=SQLEXEC(lnHandle,"SELECT '03' as tipo,a.serie,a.numero,a.fecha,a.total,a.saldo,a.moneda,"+;
                          "a.tipodoc,a.serief,a.numerof,CAST(00.000 as decimal(10,3)) as tc From ncredito a,clientes b "+;
                          " WHERE fecha>=?fec1 and fecha<=?fec2 and serie>=?sncr1 and "+;
                          " serie<=?sncr2 and codigoc=?Mycli and a.estado<>'AN' order by serie,numero" ,"Mycredito1")
    
   IF cmd3>0
   
   ELSE
       AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
   ENDIF     
       
                                             
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Mycredito1
BROWSE



