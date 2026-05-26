
SET DELETED ON
SET DATE BRITISH

SET DEFAULT TO f:\ventas
SET PATH TO DATA,PROGS,FORMULARIOS,INFORMES
SET PROCEDURE TO FUNCIONES

*** igualar amarres de Mysql en data de productos dbf*********

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

Mifecha=DATE()-7

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

	cmd1=SQLEXEC(lnHandle,"SELECT * FROM clases ","Base03") 
    cmd2=SQLEXEC(lnHandle,"SELECT codigo,nombre,idsqm FROM productos WHERE activo=1","Base01") 
    cmd2=SQLEXEC(lnHandle,"SELECT producto,SUM(qsaldov) as Stock FROM vtalotes where qsaldov>0 group by 1","Base02") 
                                                       
    cmd7=SQLEXEC(lnHandle,"SELECT a.producto,SUM(a.cantidad) as Cantidad FROM detaguiasremision a ,guiasremision b "+;
    					 "WHERE a.unico=b.unico and b.anulada<>1 and b.motivoguia=1 and b.fecha>?Mifecha "+;
    					 "group by 1 order by 1 ","Consumo")   
    
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

     					  
SELECT CAST(a.producto as c(7)) as Producto,SUBSTR(STRCONV(b.nombre,11),1,55) as nombre,CAST(b.idsqm as c(5)) as idsqm,;
       ROUND(a.cantidad/7,2) as Prom7dias,c.stock as Stock,DATE() as Hoy, CAST(CTOD("  /  /  ") as d) as Fllegada,;
       CAST(00 as n(2,0)) as difdias, ROUND(c.stock/ROUND(a.cantidad/7,2),2) as Rendimiento,CAST('  ' as c(2)) as Transp, ;
       CAST('  ' as c(2)) as Origen FROM Consumo as a;
       LEFT JOIN Base01 as b ON a.producto=b.codigo;
       LEFT JOIN Base02 as c ON a.producto=c.producto;
       ORDER BY 1,3 INTO CURSOR Final1 READWRITE 


SELECT distinct idsqm,CAST("" as c(50)) as Nombre, CAST(0.00 as n(10,2)) as Prom7dias,CAST(0.00 as n(10,2)) as stock,DATE() as Hoy,;
       CAST(CTOD("  /  /  ") as d) as Fllegada,CAST(00 as n(2,0)) as difdias, CAST(0.00 as n(10,2)) as rendimiento,CAST('  ' as c(2)) as Transp ,;
       CAST('  ' as c(2)) as Origen FROM final1 WHERE !EMPTY(idsqm) INTO CURSOR false READWRITE 
       
 
SELECT false
SCAN 
    a1x=False.idsqm
   
    SELECT SUM(a.cantidad) as cantidad,b.idsqm FROM consumo as a ;
    LEFT JOIN Base01 as b ON a.producto=b.codigo WHERE b.idsqm=a1x GROUP BY 2 INTO CURSOR beta
    
    SELECT beta
    a2x=ROUND(beta.cantidad/7,2)
    
    SELECT false
    replace false.Prom7dias WITH a2x 
    
    
    lnHandle = SQLSTRINGCONNECT(Mystring)
	IF lnHandle > 0
    
		cmd7=SQLEXEC(lnHandle," SELECT b.idsqm,SUM(a.qsaldov) as Stock FROM vtalotes a, Productos b "+;
		                      " WHERE a.producto=b.codigo and b.idsqm=?a1x and qsaldov>0 group by 1 ","Alfa")      
	    SQLDISCONNECT(lnHandle)        
	ELSE
    	AERROR(laErr)
	    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	ENDIF    
	
	SELECT Alfa
	a3x=Alfa.stock
	
    SELECT false
    replace false.Stock WITH a3x 	
    replace rendimiento WITH ROUND(stock/Prom7dias,2)
                  
ENDSCAN 
 
 
      
SELECT final1
SCAN FOR ISNULL(stock)
     replace stock WITH 0
     replace rendimiento WITH 0
endscan     

OPEN DATABASE f:\newcompras\data\sqm.dbc SHARED
SELECT 0
USE f:\newcompras\data\pedidoimp.dbf SHARED
SELECT 0
USE f:\newcompras\data\detallepedido.dbf SHARED
SELECT 0
USE f:\newcompras\data\iembarque.dbf SHARED
SELECT 0
USE f:\newcompras\data\proveedores.dbf SHARED



SELECT false
GO TOP 
SCAN 
  as1=false.idsqm
  
	 SELECT d.idsqm,a.codigo,a.saldo,a.um,b.fechapedido,b.fechaalmacen,b.tipopedido,;
      	   IIF(b.tipoembarque="C","C0NTAINER",IIF(b.tipoembarque="P","Parcial","Consolidado")) as Emba;
	       FROM detallepedido as a ;
    	   LEFT JOIN pedidoimp as b ON a.codigo=b.codigo;
    	   LEFT JOIN base01 as c ON a.producto=c.codigo ;
    	   LEFT JOIN base03 as d ON c.idsqm=d.idsqm ; 
	       WHERE d.idsqm=as1 AND b.anulado<>.t. AND b.terminado<>.t. AND a.saldo<>0 ;
	       ORDER BY fechaalmacen INTO CURSOR CBB READWRITE 
	       
	 SELECT CBB      
	 IF RECCOUNT()>0
	    GO top
	    xfac1=fechaalmacen
	    xfac2=tipopedido
	    xfac3=Emba
	    xfac4=SUBSTR(codigo,3,2)
	    SELECT False
	    replace Fllegada WITH xfac1+diastramite(ALLTRIM(xfac3),xfac1,xfac2) 
	    replace transp WITH xfac2	     
	    replace origen WITH xfac4
	 ENDIF 
     SELECT False
     IF False.fllegada>hoy
      replace difdias WITH fllegada-hoy
     ELSE 
      replace difdias WITH 0
     ENDIF 
     
ENDSCAN 


SELECT final1
GO TOP 
SCAN 
  as1=Final1.producto
  
	 SELECT a.producto,a.codigo,a.saldo,a.um,b.fechapedido,b.fechaalmacen,b.tipopedido,;
      	   IIF(b.tipoembarque="C","C0NTAINER",IIF(b.tipoembarque="P","Parcial","Consolidado")) as Emba;
	       FROM detallepedido as a ;
    	   LEFT JOIN pedidoimp as b ON a.codigo=b.codigo;
	       WHERE  a.producto=as1 AND b.anulado<>.t. AND b.terminado<>.t. AND a.saldo<>0 ;
	       ORDER BY fechaalmacen INTO CURSOR BBC READWRITE 
	 SELECT BBC      
	 IF RECCOUNT()>0
	    GO top
	    xfac1=fechaalmacen
	    xfac2=tipopedido
	    xfac3=Emba
	    SELECT Final1
	    replace Fllegada WITH xfac1+diastramite(ALLTRIM(xfac3),xfac1,xfac2) 	     
	    replace transp WITH xfac2
	 ENDIF 
     SELECT Final1
     
     IF Final1.fllegada>hoy
      replace difdias WITH fllegada-hoy
     ELSE 
      replace difdias WITH 0
     ENDIF  

ENDSCAN 

SELECT Proveedores
USE
SELECT iembarque
USE
SELECT detallepedido
USE
SELECT pedidoimp
USE

SELECT false
GO top
SCAN 
    au1=idsqm
    SELECT Base03
    LOCATE FOR base03.idsqm=au1
    IF FOUND()
       au2=ALLTRIM(Base03.clase)
       SELECT false
       replace nombre WITH STRCONV(au2,11)
    ENDIF
    SELECT false
       
ENDSCAN        
    

SELECT final1 
DELETE FOR !EMPTY(idsqm)
DELETE FOR VAL(SUBSTR(producto,1,2))>12

APPEND FROM DBF("false")

GO top
*BROWSE FOR (rendimiento<difdias) OR (difdias=0 AND rendimiento<=30)
REPORT FORM FLASH FOR (rendimiento<difdias) OR stock=0 OR (difdias=0 AND rendimiento<=30 AND EMPTY(fllegada)) PREVIEW 
REPORT FORM FLASH FOR (rendimiento<difdias) OR stock=0 OR (difdias=0 AND rendimiento<=30 AND EMPTY(fllegada)) NOCONSOLE TO PRINTER PROMPT 

**OR (difdias=0 AND rendimiento<=30)

    					      					   					      					  
    					   