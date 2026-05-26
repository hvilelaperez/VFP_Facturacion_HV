

SET TALK OFF
SET ECHO OFF
SET DELETED ON
SET DATE BRITISH


Myini=DATE()-360

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd2=SQLEXEC(lnHandle,"SELECT  codigoc,SUM(neto) From factura WHERE estado<>'AN' and fecha>=?Myini group by 1 order by 2 desc ","Mydatai")
    cmd3=SQLEXEC(lnHandle,"SELECT codigo,nombre from clientes","Myclientes")
                           
   IF cmd2>0
   
   ELSE
       AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
   ENDIF     
                                                    
   SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT a.codigoc as codigo,b.nombre FROM Mydatai as a LEFT JOIN Myclientes as b ON a.codigoc=b.codigo ORDER BY 1 INTO CURSOR final READWRITE 

SELECT final

replace ALL nombre WITH STRCONV(nombre,11)

GO top
REPORT FORM listaclientes NOCONSOLE TO PRINTER PROMPT 
