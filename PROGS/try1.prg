

SET DELETED ON
SET DATE BRITISH

PUBLIC Mystring,My730
My730=DATE()-730


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
    cmd1=SQLEXEC(lnHandle,"SELECT Distinct cliente FROM cotizaciones WHERE anulada<>1 AND fecha>=?My730 order by 1","Resultado1")
    cmd2=SQLEXEC(lnHandle,"SELECT Distinct codigoc as cliente FROM factura WHERE estado<>'AN' AND fecha>=?My730 order by 1","Resultado2")
    cmd3=SQLEXEC(lnHandle,"SELECT Distinct codigoc as cliente FROM boleta WHERE estado<>'AN' AND fecha>=?My730 order by 1","Resultado3")
    cmd4=SQLEXEC(lnHandle,"SELECT * FROM clientes ","Base")
                                              
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT resultado1
APPEND FROM DBF('resultado2')
APPEND FROM DBF('resultado3')

SELECT resultado1


SELECT distinct cliente FROM resultado1 ORDER BY 1 INTO CURSOR final

SELECT b.vendedor , a.cliente,STRCONV(b.nombre,11) as nombre FROM final as a;
         LEFT JOIN base as b ON a.cliente=b.codigo INTO CURSOR Mydata ORDER by 1,2 READWRITE 

SELECT Mydata
DELETE FOR ISNULL(nombre) OR ISNULL(vendedor)
GO top
BROWSE










