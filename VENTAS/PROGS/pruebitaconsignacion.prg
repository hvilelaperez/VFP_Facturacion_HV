SET DELETED ON
SET DATE BRITISH


PUBLIC Varstop1,Mystring,My120
My120=DATE()-120

Varstop1=0

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
     
      cmd3=SQLEXEC(lnHandle,"select a.producto as codigo,a.qing-a.devuelto as saldo,b.cliente,c.nombre "+;
                            "FROM vtalotes a, masteringresos b, clientes c WHERE a.unico=b.unico"+;
                            " and b.cliente=c.codigo and YEAR(b.fecha)>=2009 "+;
                            " and b.tipo='9' and b.consigpendiente=1 and a.xdevolver=1 ","Myconsig1")
                                                                                 
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

*SELECT SUM(saldo) as saldo ,codigo,cliente,nombre FROM Myconsig1 GROUP BY 2,3,4 ORDER BY 2 INTO CURSOR Myconsig2

*SELECT (a.saldo*-1) as Saldo,a.codigo,"Deuda SQM con :"+ALLTRIM(STRCONV(a.Nombre,11)) as Cadena,b.idsqm FROM ;
        Myconsig2 as a LEFT JOIN mibase as b ON a.codigo=b.codigo INTO CURSOR consignacion1 
        
*SELECT consignacion1

SELECT Myconsig1
BROWSE 
        