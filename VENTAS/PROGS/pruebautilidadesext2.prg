
SET ECHO OFF 
SET TALK OFF
SET DELETED ON
SET DATE BRITISH

PUBLIC autil1,autil2

a1=CTOD("01/08/2010")
b1=CTOD("31/08/2011")

autil1=a1
autil2=b1

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


CREATE CURSOR Master (name c(15),serie n(1,0),numero n(6,0),fecha d,moneda c(2),total n(10,2),saldo n(10,2),vendedor c(2),codigoc c(4),nombre c(80),producto c(7),nproducto c(80),origen c(11),um c(2),cantidad n(10,2),precio n(10,2),subtotal n(10,2),costo n(10,2),subcosto n(10,2),utilidad n(10,2),factor n(10,2) NULL ,estado c(5),motivoguia n(2,0),tip c(2))

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd0=SQLEXEC(lnHandle,"select * FROM clientes ","BaseCli")
    cmd10=SQLEXEC(lnHandle,"select * FROM grupodeclientes ","Migrupo1")

    cmd1=SQLEXEC(lnHandle,"SELECT 'FACTURA' as Name,a.serie,a.numero,a.fecha,a.moneda,a.vendedor,a.codigoc,a.total,a.saldo,c.nombre,b.producto,d.origen,e.nombre as Nproducto,b.um,b.cantidad,"+;
    					  " b.precio,b.subtotal,d.costo,ROUND(b.cantidad*d.costo,2) as SubCosto,"+;
    					  " b.subtotal-ROUND(b.cantidad*d.costo,2) as Utilidad, ROUND(b.subtotal/ROUND(b.cantidad*d.costo,2),2) as Factor,"+;
    					  " a.estado,a.motivoguia "+;
                          " FROM factura a,detafacturas b,clientes c,vtalotes d,productos e WHERE a.unico=b.unico and a.codigoc=c.codigo and "+;
                          " b.idorigen=d.id and b.producto=e.codigo and a.fecha>=?a1 and a.fecha<=?b1 and (a.serie=1 OR a.serie=4) and a.estado<>'AN' "+;
                          " and a.motivoguia=1 order by a.serie,a.numero ","MydatitoF")
                          
    cmd2=SQLEXEC(lnHandle,"SELECT 'BOLETA' as Name,a.serie,a.numero,a.fecha,a.moneda,a.vendedor,a.codigoc,a.total,a.saldo,IF(a.clientesvarios=1,a.especialname,c.nombre) as Nombre,b.producto,d.origen,e.nombre as Nproducto,b.um,b.cantidad,"+;
    					  " b.precio,b.subtotal,d.costo,ROUND(b.cantidad*d.costo,2) as SubCosto,"+;
    					  " b.subtotal-ROUND(b.cantidad*d.costo,2) as Utilidad, ROUND(b.subtotal/ROUND(b.cantidad*d.costo,2),2) as Factor,"+;
    					  " a.estado,a.motivoguia "+;
                          " FROM boleta a,detaboletas b,clientes c,vtalotes d,productos e WHERE a.unico=b.unico and a.codigoc=c.codigo and "+;
                          " b.idorigen=d.id and b.producto=e.codigo and a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 "+;
                          " and a.estado<>'AN' and a.motivoguia=1 order by a.serie,a.numero ","MydatitoB")

    cmd3=SQLEXEC(lnHandle,"SELECT a.tipo,a.serie,a.numero,a.fecha,a.moneda,a.codigoc,a.total,a.saldo,c.nombre,b.producto,d.origen,f.nombre as nproducto,b.um,b.cantaplicada,"+;
    					  " d.costo,e.precio as Preciofactura,b.nuevoprecio,b.subtotal,a.estado "+;
                          " FROM ncredito a,detallencredito b,detafacturas e,clientes c,vtalotes d ,productos f WHERE "+;
                          " a.unico=b.unico and a.codigoc=c.codigo and b.idorigen=e.id and e.idorigen=d.id"+;
                          " and b.producto=f.codigo and a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 "+;
                          " and a.estado<>'AN' order by a.serie,a.numero ","MydatitoC")

                          
    cmd4=SQLEXEC(lnHandle,"SELECT * from Factura a where a.fecha>=?a1 and a.fecha<=?b1 and (a.serie=1 or a.serie=4) order by a.serie,a.numero","FxFactura")                       
    cmd5=SQLEXEC(lnHandle,"SELECT * from Boleta a where a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 order by a.serie,a.numero","FxBoleta")
    cmd6=SQLEXEC(lnHandle,"SELECT * from ncredito a where a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 order by a.serie,a.numero","FxCredito")
                                                                                                                   
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

******************** COMPROBANDo AJUSTANDO DATOS DE FACTURAS************************************************

SELECT FxFactura  && Veo si estan todas las facturas
GO top
SCAN
    a1=serie
    a2=numero
    a3=estado
    a4=codigoc
    a5=moneda
    a6=fecha
    a7=saldo 
    a8=total
    
    SELECT Mydatitof
    GO top
    LOCATE FOR Mydatitof.serie=a1 AND Mydatitof.numero=a2
    IF !FOUND() && sino estan las inserto para el informe (asumo que estan anuladaas o no afectan el costo..asegurarse!!)
        APPEND BLANK
        replace name WITH "FACTURA"
        replace serie WITH a1
        replace numero WITH a2
        replace estado WITH a3        
        replace fecha WITH a6
        IF a3<>"AN" && si no está anulada completa los otros datos
           SELECT Basecli
           LOCATE FOR a4=codigo
           IF FOUND()
              anombre=nombre
           ENDIF
           SELECT Mydatitof
           replace nombre WITH anombre
           replace moneda WITH a5
           replace total WITH a8
           replace saldo WITH a7 
        ENDIF                       
    ENDIF 
    SELECT FxFactura
ENDSCAN 


SELECT MydatitoF
GO top
SCAN FOR estado='AN'
     replace subtotal WITH 0
     replace costo WITH 0
     replace subcosto WITH 0
     replace utilidad WITH 0
     replace factor WITH 0
ENDSCAN      
GO TOP      

SELECT * FROM Mydatitof ORDER BY serie,numero INTO CURSOR Mydatitofone READWRITE 

************************************************************************************************************

******************** COMPROBANDo AJUSTANDO DATOS DE BOLETAS*************************************************

SELECT FxBoleta  && Veo si estan todas las boletas
GO top
SCAN
    a1=serie
    a2=numero
    a3=estado
    a4=codigoc
    a5=moneda
    a6=fecha
    a7=saldo 
    a8=total
    
    SELECT Mydatitob
    GO top
    LOCATE FOR Mydatitob.serie=a1 AND Mydatitob.numero=a2
    IF !FOUND() && sino estan las inserto para el informe (asumo que estan anuladaas o no afectan el costo..asegurarse!!)
        APPEND BLANK
        replace name WITH "BOLETA"
        replace serie WITH a1
        replace numero WITH a2
        replace estado WITH a3        
        replace fecha WITH a6
        IF a3<>"AN" && si no está anulada completa los otros datos
           SELECT Basecli
           LOCATE FOR a4=codigo
           IF FOUND()
              anombre=nombre
           ENDIF
           SELECT Mydatitob
           replace nombre WITH anombre
           replace moneda WITH a5
           replace total WITH a8
           replace saldo WITH a7 
        ENDIF                       
    ENDIF 
    SELECT FxBoleta
ENDSCAN 

SELECT MydatitoB
GO top
SCAN FOR motivoguia=10
     replace utilidad WITH subcosto*-1
     replace factor WITH 0
ENDSCAN 
GO top
SCAN FOR estado='AN'
     replace subtotal WITH 0
     replace costo WITH 0
     replace subcosto WITH 0
     replace utilidad WITH 0
     replace factor WITH 0
ENDSCAN      
GO TOP      

SELECT * FROM Mydatitob ORDER BY serie,numero INTO CURSOR Mydatitobone READWRITE 
************************************************************************************************************************

******************** COMPROBANDo AJUSTANDO DATOS DE NOTA DE CREDITO    *************************************************

SELECT 'CREDITO' as Name,serie,numero,fecha,moneda,codigoc,total,saldo,nombre,producto,nproducto,origen,um,cantaplicada as cantidad, ;
       IIF(tipo=2,(preciofactura-nuevoprecio),preciofactura) as Precio,;
       IIF(tipo=2,ROUND(cantaplicada*(preciofactura-nuevoprecio),2)*-1,ROUND(cantaplicada*preciofactura,2)*-1) as Subtotal,;
       costo,CAST(0.00 as n(10,2)) as Subcosto,;
       IIF(tipo=2,ROUND(cantaplicada*(preciofactura-nuevoprecio),2)*-1,(ROUND(cantaplicada*preciofactura,2)-ROUND(cantaplicada*costo,2))*-1) as Utilidad,;       
       CAST(0.00 as n(10,2)) as Factor,estado,tipo as Motivoguia,CAST('  ' as c(2)) as Vendedor;
       FROM Mydatitoc INTO CURSOR Mydatitoc2 READWRITE 
       
SELECT Mydatitoc
USE


SELECT FxCredito  && Veo si estan toda LAS nc
GO top
SCAN
    a1=serie
    a2=numero
    a3=estado
    a4=codigoc
    a5=moneda
    a6=fecha
    a7=saldo 
    a8=total
    
    SELECT Mydatitoc2
    GO top
    LOCATE FOR Mydatitoc2.serie=a1 AND Mydatitoc2.numero=a2
    IF !FOUND() && sino estan las inserto para el informe (asumo que estan anuladaas o no afectan el costo..asegurarse!!)
        APPEND BLANK
        replace name WITH "CREDITO"
        replace serie WITH a1
        replace numero WITH a2
        replace estado WITH a3        
        replace fecha WITH a6
        IF a3<>"AN" && si no está anulada completa los otros datos
           SELECT Basecli
           LOCATE FOR a4=codigo
           IF FOUND()
              anombre=nombre
           ENDIF
           SELECT Mydatitoc2
           replace nombre WITH anombre
           replace moneda WITH a5
           replace total WITH a8
           replace saldo WITH a7 
        ENDIF                       
    ENDIF 
    SELECT FxCredito
ENDSCAN 
       
SELECT MydatitoC2
GO top
SCAN 

    IF estado='AN' 
     replace subtotal WITH 0
     replace costo WITH 0
     replace subcosto WITH 0
     replace utilidad WITH 0
     replace factor WITH 0
    ENDIF  
    
     axx1=serie
     axx2=numero
     
	lnHandle = SQLSTRINGCONNECT(Mystring)
	IF lnHandle > 0
    	cmd0=SQLEXEC(lnHandle,"select tipodoc,serief,numerof from ncredito Where serie=?axx1 and numero=?axx2","Temp01")     
	    SQLDISCONNECT(lnHandle)        
	ELSE
    	AERROR(laErr)
    	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	ENDIF
	
    SELECT Temp01
    IF RECCOUNT()=1
       ayy1=ALLTRIM(Temp01.tipodoc)
       ayy2=Temp01.serief
       ayy3=Temp01.numerof
       
       IF EMPTY(ayy1) OR ayy1='F'
  			     
       			lnHandle = SQLSTRINGCONNECT(Mystring)
				IF lnHandle > 0
			    	cmd0=SQLEXEC(lnHandle,"Select vendedor From Factura where serie=?ayy2 and numero=?ayy3","Temp02")     
				    SQLDISCONNECT(lnHandle)        
				ELSE
				   	AERROR(laErr)
				   	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
				ENDIF
				
				SELECT Temp02
				IF RECCOUNT()=1
				   avv1=ALLTRIM(Temp02.vendedor)
				   SELECT MydatitoC2
				   replace vendedor WITH avv1				  
				ELSE
				   SELECT MydatitoC2
				   replace vendedor WITH 'NN'				   
				ENDIF 
				
       ELSE 
		   SELECT MydatitoC2
		   replace vendedor WITH 'NN'				                     
       ENDIF    
       
    ELSE 
	   SELECT MydatitoC2
	   replace vendedor WITH 'NN'				                                   
    ENDIF 
                 
  SELECT Mydatitoc2    
ENDSCAN      
GO TOP           

SELECT * FROM MydatitoC2 ORDER BY serie,numero INTO CURSOR MydatitoC2one READWRITE 
********************************************************************************************************************

SELECT Master 
APPEND FROM DBF("Mydatitobone")
APPEND FROM DBF("Mydatitoc2one")
APPEND FROM DBF("Mydatitofone")

GO top
SCAN FOR ALLTRIM(moneda)="M1"
     as=fecha
     
     lnHandle = SQLSTRINGCONNECT(Mystring)
       IF lnHandle > 0       
           SQLEXEC(lnHandle,"SELECT venta FROM tcoficial WHERE fecha BETWEEN ?as AND ?as ","MyTcUtil")
           SQLDISCONNECT(lnHandle)    
	   ELSE
    		AERROR(laErr)
		    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	   ENDIF        
	 SELECT MyTcUtil
	 Vartc=MyTcUtil.venta
	 SELECT Master
	 replace moneda WITH "M2"
	 replace total WITH ROUND((total/Vartc),2)
	 replace saldo WITH ROUND((saldo/Vartc),2)
	 replace precio WITH ROUND((precio/Vartc),2)
	 replace subtotal WITH ROUND((subtotal/Vartc),2)  
	 replace costo WITH ROUND((costo/Vartc),2)  
	 replace subcosto WITH ROUND((subcosto/Vartc),2)  
	 replace utilidad WITH subtotal-subcosto  
	 
ENDSCAN 


SCAN
  IF ALLTRIM(master.name)="BOLETA"
     IF motivoguia=10
        replace tip WITH 'MG'
     ENDIF
  ENDIF
  
  IF ALLTRIM(master.name)="CREDITO"
     IF MOTIVOGUIA=2
        REPLACE TIP WITH 'DP'
     ELSE 
        REPLACE TIP WITH 'DV'   
     ENDIF 
  ENDIF 

  IF ISNULL(FACTOR)
     REPLACE FACTOR WITH 0  
  ENDIF 
  
  REPLACE NOMBRE WITH STRCONV(NOMBRE,11)
  REPLACE NPRODUCTO WITH STRCONV(NPRODUCTO,11)   
ENDSCAN

SELECT MASTER
GO TOP
SCAN FOR TIP='DV'
     REPLACE SUBCOSTO WITH ROUND((COSTO*CANTIDAD)*-1,2)
ENDSCAN

GO TOP
     
   

PUBLIC Rk01,Rk02,Rk03,Rk04,Rk05,Rk06,Rk07,Rk08,Rk09
SUM ALL subtotal TO Rk01
SUM ALL subcosto TO Rk02
SUM ALL utilidad TO Rk03
Rk04=ROUND(Rk01/Rk02,2)

SELECT codigoc,SUM(subtotal) as Totalvta,SUM(subcosto) as totalcosto,SUM(utilidad) as Totalutil ;
       FROM master  GROUP BY 1 ORDER BY 4 DESC  INTO CURSOR resumen


SELECT a.codigoc,b.grupo,SUBSTR(STRCONV(b.nombre,11),1,50) as nombre,b.vendedor,a.totalvta,ROUND((a.totalvta/rk01)*100,2) as f1,;
       a.totalcosto,ROUND((a.totalcosto/rk02)*100,2) as f2,;
       a.totalutil,ROUND((a.totalutil/rk03)*100,2) as f3 FROM resumen as a;
       LEFT JOIN Basecli as b ON a.codigoc=b.codigo INTO CURSOR base01 READWRITE 
         
SELECT base01
SUM ALL totalvta TO xxx1
SUM ALL totalcosto TO xxx2
SUM ALL totalutil TO xxx3
Rk05=ROUND(xxx1/xxx2,2)
GO top
DELETE FOR ISNULL(grupo)

SELECT grupo,vendedor,SUM(totalvta) as Totalvta,SUM(f1) as F1,SUM(totalcosto) as Totalcosto,;
       SUM(f2) as F2, SUM(totalutil) as Totalutil, SUM(f3) as F3 FROM base01 WHERE LEN(ALLTRIM(grupo))>0;
       GROUP BY 1,2 ORDER BY grupo INTO CURSOR base02 
       
SELECT base01
DELETE FOR LEN(ALLTRIM(grupo))>0 

SELECT a.grupo as codigoc,a.grupo,b.grupo as nombre,a.vendedor,a.totalvta,a.f1,a.totalcosto,a.f2,;
       a.totalutil,a.f3 FROM base02 as a;
       LEFT JOIN Migrupo1 as b ON a.grupo=b.codigo INTO CURSOR base03
       
SELECT base01
APPEND FROM DBF("base03")

SELECT a.*,CAST(00 as n(4,0)) as Rank,CAST(00 as n(10,2)) as Xsub,CAST(00 as n(10,2)) as XUtil,CAST(00 as n(10,2)) as XTot ;
       FROM base01 as a ORDER BY totalutil DESC  INTO CURSOR base01x READWRITE 

SELECT codigo,grupo,nombre,vendedor,activo,CAST(0 as n(1,0)) as ok FROM basecli WHERE origen<>'C' ORDER BY 1 INTO CURSOR wall READWRITE 

SELECT base01x
GO top
SCAN
  a1=ALLTRIM(codigoc)
  a2=ALLTRIM(grupo)
  
  IF LEN(a2)>0
     SELECT wall
     GO top
     SCAN FOR ALLTRIM(grupo)=a2
          replace ok WITH 1
     ENDSCAN 
  ELSE
     SELECT wall
     GO top
     SCAN FOR ALLTRIM(codigo)=a1
          replace ok WITH 1
     ENDSCAN      
  ENDIF 
  SELECT base01x          
ENDSCAN 

SELECT wall
SCAN FOR ok=0 AND activo=1 && clientes que no estan en ranking aporte 0 a los totales
     x1=codigo
     x2=nombre
     x3=vendedor
     SELECT base01x
     APPEND BLANK
     replace codigoc WITH x1
     replace nombre WITH STRCONV(x2,11)
     replace vendedor WITH x3
     replace f1 WITH 0
     replace f2 WITH 0
     replace f3 WITH 0
     replace totalvta WITH 0
     replace totalcosto WITH 0
     replace totalutil WITH 0
     
     SELECT wall      
ENDSCAN 


****************** UTILIDADES pedido directo Orden Utilidad ***************************************************

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
 
   cmd0=SQLEXEC(lnHandle,"SELECT a.cliente,c.nombre,c.vendedor,c.grupo,SUM((b.precio*b.cantidad)) AS Subtotal,SUM((b.precio-b.fobsqm)*cantidad) AS Utilidad "+;
						 "FROM x_xpedidosdirectos a, x_xdetallepedirecto b,clientes c WHERE a.codigo=b.codigo "+;
						 "AND a.cliente=c.codigo AND a.fechapedido>=?a1 and a.fechapedido<=?b1 "+;
						 "AND a.anulado<>1 GROUP BY 1,2,3,4 ORDER BY 6 DESC ","Ybase")
						 
   SQLDISCONNECT(lnHandle)    
ELSE
   AERROR(laErr)
   MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF        						 

SELECT a.grupo,b.grupo as nombre,a.vendedor,SUM(a.subtotal) as subtotal, SUM(a.Utilidad) as Utilidad FROM Ybase as a;
    LEFT JOIN migrupo1 as b ON a.grupo=b.codigo ;
    WHERE LEN(ALLTRIM(a.grupo))>0 GROUP BY 1,2,3 ORDER BY 5 DESC INTO CURSOR Ybase1 
    
SELECT Ybase
GO top
DELETE ALL FOR LEN(ALLTRIM(grupo))>0    

SELECT Ybase1
GO top
SCAN 
   a1=Ybase1.grupo
   a2=Ybase1.nombre
   a3=Ybase1.vendedor
   a4=Ybase1.Subtotal
   a5=Ybase1.Utilidad
   
   SELECT Ybase
   APPEND BLANK
   replace cliente WITH a1
   replace nombre WITH a2
   replace vendedor WITH a3
   replace subtotal WITH a4
   replace utilidad WITH a5
   
   SELECT Ybase1
ENDSCAN 
   
SELECT Ybase
GO top
  SCAN 
     x1=ALLTRIM(Ybase.Cliente)
     x2=Ybase.Vendedor
     x3=Ybase.Subtotal
     x4=Ybase.Utilidad
     x5=Ybase.Nombre
     SELECT Base01x
     LOCATE FOR ALLTRIM(codigoc)=x1
     IF FOUND()
        replace xsub WITH x3
        replace xutil WITH x4
     ELSE
        APPEND BLANK
        replace codigoc WITH x1
        replace nombre WITH x5
        replace vendedor WITH x2
        replace xsub WITH x3
        replace xutil WITH x4
     ENDIF 
     SELECT Ybase          
  ENDSCAN 


SELECT Base01x
GO top
replace ALL xtot WITH totalutil+xutil


SELECT * FROM Base01x ORDER BY xtot DESC INTO CURSOR Base02x READWRITE 

SELECT base02x
GO top
scan
 replace rank WITH RECNO()
ENDSCAN
GO top

SUM ALL xsub TO Rk07
SUM ALL xutil TO Rk08
SUM ALL xtot TO Rk09

******************************************************************************************************************


SUM ALL totalvta FOR vendedor='MB' TO xxx1a 
SUM ALL totalcosto FOR vendedor='MB' TO xxx2a


Rk06=ROUND(xxx1a/xxx2a,2)
GO top
 
               
REPORT FORM UtilidadGral FOR vendedor='MB' preview
REPORT FORM UtilidadGral FOR vendedor='MB' NOCONSOLE TO PRINTER PROMPT 






