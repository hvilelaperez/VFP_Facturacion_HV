
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

    cmd0=SQLEXEC(lnHandle,"select * from clientes ","BaseCli")
    
    && SIN 
    *cmd1=SQLEXEC(lnHandle,"SELECT 'FACTURA' as Name,a.serie,a.numero,a.fecha,a.moneda,a.vendedor,a.codigoc,a.total,a.saldo,c.nombre,b.producto,d.origen,e.nombre as Nproducto,b.um,b.cantidad,"+;
    					  " b.precio,b.subtotal,d.costo,ROUND(b.cantidad*d.costo,2) as SubCosto,"+;
    					  " b.subtotal-ROUND(b.cantidad*d.costo,2) as Utilidad, ROUND(b.subtotal/ROUND(b.cantidad*d.costo,2),2) as Factor,"+;
    					  " a.estado,a.motivoguia "+;
                          " FROM factura a,detafacturas b,clientes c,vtalotes d,productos e WHERE a.unico=b.unico and a.codigoc=c.codigo and "+;
                          " b.idorigen=d.id and b.producto=e.codigo and a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 order by a.serie,a.numero ","MydatitoF") 
                          
    cmd1=SQLEXEC(lnHandle,"SELECT 'FACTURA' as Name,a.serie,a.numero,a.fecha,a.moneda,a.vendedor,a.codigoc,a.total,a.saldo,c.nombre,b.producto,d.origen,e.nombre as Nproducto,b.um,(b.cantidad-b.cantidevuelta) as cantidad,"+;
    					  " b.precio,ROUND((b.cantidad-b.cantidevuelta)*b.precio,2) as subtotal,d.costo,ROUND((b.cantidad-b.cantidevuelta)*d.costo,2) as SubCosto,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*b.precio,2)-ROUND((b.cantidad-b.cantidevuelta)*d.costo,2) as Utilidad, ROUND(ROUND((b.cantidad-b.cantidevuelta)*b.precio,2)/ROUND((b.cantidad-b.cantidevuelta)*d.costo,2),2) as Factor,"+;
    					  " a.estado,a.motivoguia "+;
                          " FROM factura a,detafacturas b,clientes c,vtalotes d,productos e WHERE a.unico=b.unico and a.codigoc=c.codigo and "+;
                          " b.idorigen=d.id and b.producto=e.codigo and a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 order by a.serie,a.numero ","MydatitoF")                                                     
                          
    cmd4=SQLEXEC(lnHandle,"SELECT * from Factura a where a.fecha>=?a1 and a.fecha<=?b1 and a.serie=1 order by a.serie,a.numero","FxFactura")                       
                                                                                                                   
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
DELETE FOR estado='AN' && quito los anulados x afecta los promedios del factor 


SELECT * FROM Mydatitof  WHERE estado<>'AN' ORDER BY serie,numero INTO CURSOR Mydatitofone READWRITE 

************************************************************************************************************

SELECT Master 
APPEND FROM DBF("Mydatitofone") && llena la data

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
  IF ISNULL(FACTOR)
     REPLACE FACTOR WITH 0  
  ENDIF 
  
  REPLACE NOMBRE WITH STRCONV(NOMBRE,11)
  REPLACE NPRODUCTO WITH STRCONV(NPRODUCTO,11)   
ENDSCAN
GO TOP

PUBLIC Rk01,Rk02,Rk03,Rk04,Rk05
SUM ALL subtotal TO Rk01
SUM ALL subcosto TO Rk02
SUM ALL utilidad TO Rk03
Rk04=ROUND(Rk01/Rk02,2)

SELECT codigoc,SUM(subtotal) as Totalvta,SUM(subcosto) as totalcosto,SUM(utilidad) as Totalutil ;
       FROM master WHERE vendedor='MB' GROUP BY 1 ORDER BY 4 DESC INTO CURSOR resumen

SELECT a.codigoc,SUBSTR(STRCONV(b.nombre,11),1,50) as nombre,a.totalvta,ROUND((a.totalvta/rk01)*100,2) as f1,;
       a.totalcosto,ROUND((a.totalcosto/rk02)*100,2) as f2,;
       a.totalutil,ROUND((a.totalutil/rk03)*100,2) as f3 FROM resumen as a;
       LEFT JOIN Basecli as b ON a.codigoc=b.codigo INTO CURSOR base01
         
SELECT base01
SUM ALL totalvta TO xxx1
SUM ALL totalcosto TO xxx2
SUM ALL totalutil TO xxx3

Rk05=ROUND(xxx1/xxx2,2)

*BROWSE
      
               
*REPORT FORM inforutilidadxvend  preview
*REPORT FORM inforutilidadxvend FOR vendedor='LR' NOCONSOLE TO PRINTER PROMPT 





