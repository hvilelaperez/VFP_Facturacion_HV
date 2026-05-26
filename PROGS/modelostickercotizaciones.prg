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

  cmd2=SQLEXEC(lnHandle,"SELECT distinct a.cliente,b.nombre,a.atencion from cotizaciones a,clientes b where a.cliente=b.codigo and anio=2009 "+;
                          " and correlativo>=1384 and correlativo<=1493 order by a.cliente","Mydatalabel")

    
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT ALLTRIM(STRCONV(nombre,11)) as Cliente,ALLTRIM(STRCONV(atencion,11)) as Nombre FROM Mydatalabel INTO CURSOR Yaesta
SELECT yaesta

LABEL FORM labelcotizaciones NOCONSOLE TO PRINTER prompt



