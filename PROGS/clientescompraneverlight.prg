
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
                    
CREATE CURSOR pivote (producto c(7),nombre c(50),canti n(10,2),tipo c(2),mes n(2,0),namemes c(8),anio n(4,0))                    
                    
lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0  
    cmd1=SQLEXEC(lnHandle," SELECT a.producto,c.nombre,a.cantidad-a.cantidevuelta as Canti,mid(a.producto,1,2) as Tipo,MONTH(b.fecha) as Mes, "+;
                          " YEAR(b.fecha) as anio FROM detafacturas a,factura b,clientes c, productos d "+;
                          " WHERE a.unico=b.unico and b.codigoc=c.codigo and a.producto=d.codigo and (b.serie=1 or b.serie=4) and b.estado<>'AN' "+;
                          " and b.motivoguia=1 and b.fecha>=?Fback1 and b.fecha<=?hoy  and d.proveedor='F0' "+;
                          " order by 1 ","MiInfoD")  
                          
   cmd10=SQLEXEC(lnHandle," SELECT a.producto,c.nombre,a.cantidad-a.cantidevuelta as Canti,mid(a.producto,1,2) as Tipo,MONTH(b.fecha) as Mes, "+;
                          " YEAR(b.fecha) as anio FROM detaboletas a,boleta b,clientes c, productos d "+;
                          " WHERE a.unico=b.unico and b.codigoc=c.codigo and  a.producto=d.codigo and (b.serie=1 or b.serie=4) and b.estado<>'AN' "+;
                          " and b.motivoguia=1 and b.fecha>=?Fback1 and b.fecha<=?hoy and d.proveedor='F0' "+;
                          " order by 1 ","MiInfoD2")      
	                                                 
    SQLDISCONNECT(lnHandle)    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT pivote
ZAP IN pivote
APPEND FROM DBF("MiInfoD")
APPEND FROM DBF("MiInfoD2")
GO top

SELECT nombre,SUM(canti) as canti FROM pivote GROUP BY 1 ORDER BY 2 DESC INTO CURSOR piv1

SELECT piv1
GO top
SCAN
   Pos=RECNO()
   Mynom=Piv1.nombre
   SELECT pivote
   replace ALL nombre WITH TRANSFORM(pos,"@l 999")+' - '+Mynom FOR nombre=Mynom
ENDSCAN    

SELECT nombre,SUM(canti) as Cantidad FROM pivote GROUP BY 1 ORDER BY 2 DESC INTO CURSOR final

SELECT final
BROWSE  



