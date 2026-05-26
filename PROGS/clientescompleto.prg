
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

    cmd2=SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE vendedor='OF' order by codigo ","C1")
    cmd3=SQLEXEC(lnHandle,"SELECT * FROM contactos where area='VE' order by cliente","C2")
    cmd4=SQLEXEC(lnHandle,"SELECT * FROM condicionpago ","C3")                                                     
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT a.codigo,a.nombre,a.ruc,a.telefono,a.fax,a.direccion,a.dpto,a.prov,a.dist,a.email,a.categoria,a.credito,;
       a.fechaingreso,a.vendedor,a.condipago,b.nombre as n1,b.telefono as t1,b.fax as f1,b.email as e1,c.nombre as x1;
       FROM c1 as a;
       LEFT JOIN c2 as b ON a.codigo=b.cliente;
       LEFT JOIN c3 as c ON a.condipago=c.codigo INTO CURSOR why

SELECT why
BROWSE
       


*SELECT c1
*INDEX on codigo TAG e1 
*SET ORDER TO tag e1


*SELECT c2
*INDEX on cliente TAG e2

*SELECT c1
*SET RELATION TO codigo INTO c2 






