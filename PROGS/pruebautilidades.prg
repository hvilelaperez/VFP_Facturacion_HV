
SET ECHO OFF 
SET TALK OFF
SET DELETED ON
SET DATE BRITISH

PUBLIC autil1,autil2

a1=CTOD("01/12/2009")
b1=CTOD("31/12/2009")

autil1=a1
autil2=b1

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


CREATE CURSOR Master (name c(15),serie n(1,0),numero n(6,0),fecha d,moneda c(2),total n(10,2),saldo n(10,2),codigoc c(4),nombre c(80),producto c(7),nproducto c(80),origen c(11),um c(2),cantidad n(10,2),precio n(10,2),subtotal n(10,2),costo n(10,2),subcosto n(10,2),utilidad n(10,2),factor n(10,2) NULL ,estado c(5),motivoguia n(2,0),tip c(2))

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd0=SQLEXEC(lnHandle,"select * from clientes ","BaseCli")

    cmd1=SQLEXEC(lnHandle,"SELECT 'FACTURA' as Name,a.serie,a.numero,a.fecha,a.moneda,a.codigoc,a.total,a.saldo,c.nombre,b.producto,d.origen,e.nombre as Nproducto,b.um,b.cantidad,"+;
    					  " b.precio,b.subtotal,d.costo,ROUND(b.cantidad*d.costo,2) as SubCosto,"+;
    					  " b.subtotal-ROUND(b.cantidad*d.costo,2) as Utilidad, ROUND(b.subtotal/ROUND(b.cantidad*d.costo,2),2) as Factor,"+;
    					  " a.estado,a.motivoguia "+;
                          " FROM factura a,detafacturas b,clientes c,vtalotes d,productos e WHERE a.unico=b.unico and a.codigoc=c.codigo and "+;
                          " b.idorigen=d.id and b.producto=e.codigo and a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 order by a.serie,a.numero ","MydatitoF")
                          
    cmd2=SQLEXEC(lnHandle,"SELECT 'BOLETA' as Name,a.serie,a.numero,a.fecha,a.moneda,a.codigoc,a.total,a.saldo,IF(a.clientesvarios=1,a.especialname,c.nombre) as Nombre,b.producto,d.origen,e.nombre as Nproducto,b.um,b.cantidad,"+;
    					  " b.precio,b.subtotal,d.costo,ROUND(b.cantidad*d.costo,2) as SubCosto,"+;
    					  " b.subtotal-ROUND(b.cantidad*d.costo,2) as Utilidad, ROUND(b.subtotal/ROUND(b.cantidad*d.costo,2),2) as Factor,"+;
    					  " a.estado,a.motivoguia "+;
                          " FROM boleta a,detaboletas b,clientes c,vtalotes d,productos e WHERE a.unico=b.unico and a.codigoc=c.codigo and "+;
                          " b.idorigen=d.id and b.producto=e.codigo and a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 order by a.serie,a.numero ","MydatitoB")

    cmd3=SQLEXEC(lnHandle,"SELECT a.tipo,a.serie,a.numero,a.fecha,a.moneda,a.codigoc,a.total,a.saldo,c.nombre,b.producto,d.origen,f.nombre as nproducto,b.um,b.cantaplicada,"+;
    					  " d.costo,e.precio as Preciofactura,b.nuevoprecio,b.subtotal,a.estado "+;
                          " FROM ncredito a,detallencredito b,detafacturas e,clientes c,vtalotes d ,productos f WHERE "+;
                          " a.unico=b.unico and a.codigoc=c.codigo and b.idorigen=e.id and e.idorigen=d.id"+;
                          " and b.producto=f.codigo and a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 order by a.serie,a.numero ","MydatitoC")

                          
    cmd4=SQLEXEC(lnHandle,"SELECT * from Factura a where a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 order by a.serie,a.numero","FxFactura")                       
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
       CAST(0.00 as n(10,2)) as Factor,estado,tipo as Motivoguia FROM Mydatitoc INTO CURSOR Mydatitoc2 READWRITE 
       
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
SCAN FOR estado='AN'
     replace subtotal WITH 0
     replace costo WITH 0
     replace subcosto WITH 0
     replace utilidad WITH 0
     replace factor WITH 0
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

GO TOP
               
REPORT FORM inforutilidadxdoc preview
REPORT FORM inforutilidadxdoc NOCONSOLE TO PRINTER PROMPT 





