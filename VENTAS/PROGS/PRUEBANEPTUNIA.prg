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

    cmd2=SQLEXEC(lnHandle,"SELECT a.origen,a.producto,b.nombre,a.qing,a.qsaldov,a.qreserva,a.qstandby,a.qexterno, "+;
                          "a.qsaldov-(a.qreserva+a.qstandby+a.qexterno) as Disponible  "+;
                          " FROM vtalotes a ,productos b where a.producto=b.codigo and qexterno>0","Base")                                             
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT base
BROWSE


