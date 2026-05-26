SET DELETED ON
SET DATE BRITISH

SET DEFAULT TO f:\ventas
SET PATH TO DATA,PROGS,FORMULARIOS,INFORMES
SET PROCEDURE TO FUNCIONES

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"



lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

	cmd1=SQLEXEC(lnHandle,"SELECT a.cliente,b.nombre,a.producto,c.nombre as Descripcion,a.preciocontado FROM "+;
	                      "preciostockclientes a, clientes b, productos c WHERE a.cliente =b.codigo "+;
	                      "AND a.producto=c.codigo AND a.preciocontado>0 ORDER BY a.cliente, a.producto","Base03") 
 
    
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT Base03
BROWSE


