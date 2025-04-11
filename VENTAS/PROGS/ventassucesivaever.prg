SET DELETED ON
SET DATE BRITISH
SET DEFAULT TO f:\ventas
SET PATH TO DATA,PROGS,FORMULARIOS,INFORMES
SET PROCEDURE TO FUNCIONES
SET SAFETY OFF

LOCAL Hoy,Fback1

Fback1=CTOD("01/01/2012")
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
    cmd1=SQLEXEC(lnHandle," SELECT * FROM clientes ","Misclix")
    
    SQLDISCONNECT(lnHandle)    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF



OPEN DATABASE F:\NEWCOMPRAS\DATA\sqm.dbc SHARED

SELECT 0
USE pedidoimp SHARED

SELECT 0
USE detallepedido SHARED


SELECT c.nombre,SUM(a.cantidad) FROM pedidoimp as b ;
    left join detallepedido as a ON a.codigo=b.codigo ;
    left join misclix as c ON b.vscliente=c.codigo ;    
	WHERE YEAR(b.fechapedido)=2012 AND b.proveedor='F0' AND b.vsucesiva=1 AND b.anulado<>.t. GROUP BY 1 ORDER BY 2 DESC ;
	INTO CURSOR Sucesiva
	
	
SELECT Sucesiva
BROWSE 	