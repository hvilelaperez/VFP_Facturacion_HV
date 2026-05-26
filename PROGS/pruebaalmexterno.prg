
SET DELETED ON
SET DATE BRITISH


PUBLIC Varstop1,Mystring,My120

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    cmd2=SQLEXEC(lnHandle,"SELECT b.serieguia,b.numeroguia,b.fecha,b.pedido,b.salida,a.producto,c.nombre,a.lotefab,a.saldo,a.sale,a.nuevosaldo "+;
                          "FROM detaalmexterno a, masteralmexterno b,productos c WHERE "+;
                          " a.idmaster=b.id and a.producto=c.codigo and b.numeroguia=2342 order by a.producto","Mibase")                                                    
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT Mibase
BROWSE




