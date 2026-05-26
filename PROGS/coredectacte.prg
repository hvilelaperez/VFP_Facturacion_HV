
SET TALK OFF
SET ECHO OFF
SET FDOW TO 2
SET DELETED ON
SET DATE BRITISH
SET PROCEDURE TO funciones 

PUBLIC My60,My30

My60=DATE()-60
My30=DATE()-30
My90=DATE()-90
My180=DATE()-180
HoyMk=DATE()

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0    
    cmd01=SQLEXEC(lnHandle,"SELECT producto AS Codigo,SUM(qsaldov) as Saldo FROM vtalotes WHERE qsaldov>0 GROUP BY 1","Mistock")      
    cmd02=SQLEXEC(lnHandle,"SELECT producto AS Codigo,SUM((qsaldov-(qstandby+qexterno+quarantine))) as Saldo FROM vtalotes WHERE qsaldov>0  GROUP BY 1","MistockA")    
    cmd03=SQLEXEC(lnHandle,"SELECT producto AS Codigo,SUM(qstandby) as Saldo FROM vtalotes WHERE qstandby>0 GROUP BY 1","MistockB")    
    cmd04=SQLEXEC(lnHandle,"SELECT producto AS Codigo,SUM(qexterno) as Saldo FROM vtalotes WHERE qexterno>0 GROUP BY 1","MistockC")        
    cmd05=SQLEXEC(lnHandle,"SELECT producto AS Codigo,SUM(quarantine) as Saldo FROM vtalotes WHERE quarantine>0 GROUP BY 1","MistockD")            
    cmd06=SQLEXEC(lnHandle,"SELECT codigo,proveedor,nombre,um,idsqm,activo FROM productos ","Mibase") 
    cmd07=SQLEXEC(lnHandle,"SELECT * FROM tipoproductos","MiTipos") 
    
    **************************Consumo de los ultimos 2 meses y el ultimo mes ********************************************	
    cmd08=SQLEXEC(lnHandle,"SELECT b.producto as Codigo,SUM(b.cantidad) as Todventa FROM detaguiasremision b, guiasremision a "+;
                          " WHERE a.unico=b.unico AND a.fecha>=?My60 and a.anulada<>1 and a.motivoguia=1 "+;
                          " GROUP BY 1 ","Ventas60")      
    cmd09=SQLEXEC(lnHandle,"SELECT b.producto as Codigo,SUM(b.cantidad) as Todventa FROM detaguiasremision b, guiasremision a "+;
                          " WHERE a.unico=b.unico AND a.fecha>=?My30 and a.anulada<>1 and a.motivoguia=1 "+;
                          " GROUP BY 1 ","Ventas30") 
                          
    ******************* REVISA LAS RESERVAS  y NO ATENDIDOS***************************************************************    
    cmd10=SQLEXEC(lnHandle,"SELECT a.producto as codigo,b.cliente,c.nombre,b.fechaini,b.fechafin,a.cantidad-a.despachado as saldo,b.observaciones "+;
                          " FROM detareservas a,reserva b, clientes c WHERE a.unico=b.id AND b.cliente=c.codigo AND a.estado=1 "+;
                          " AND fechafin>=?HoyMk ORDER BY a.producto ","MyReservitax") 
                          
    cmd11=SQLEXEC(lnHandle,"SELECT a.producto as codigo,b.cliente,c.nombre,b.fecha,b.fechaini,b.fechafin,a.cantidad-a.despachado as saldo,b.observaciones "+;
                          " FROM detapednoatendidos a,pednoatendidos b, clientes c WHERE a.unico=b.id AND b.cliente=c.codigo and a.estado=1 "+;
                          " ORDER BY a.producto ","MyNoatendx") 
                            
	******************REVISA CONSIGNACION DE CLIENTES*********************************************************************
    cmd12=SQLEXEC(lnHandle,"select a.producto as codigo,a.qing-a.devuelto as saldo,b.cliente,c.nombre "+;
                          "FROM vtalotes a, masteringresos b, clientes c WHERE a.unico=b.unico"+;
                          " and b.cliente=c.codigo and YEAR(b.fecha)>=2009 "+;
                          " and b.tipo='9' and b.consigpendiente=1 and a.xdevolver=1 ","Myconsig1")

	************************* Revisando los prestamos ********************************************************************
    cmd13=SQLEXEC(lnHandle,"SELECT b.producto as Codigo,d.Nombre as Cadena,a.fecha,b.um,b.cantidad-b.cantidevuelta as Cantidad,c.idsqm "+;
                           "FROM factura a,detafacturas b,productos c,clientes d "+;
                           "WHERE a.unico=b.unico and b.producto=c.codigo and a.codigoc=d.codigo and a.serie=2 and a.saldo>1 "+;                          
                           "and b.cantidad-b.cantidevuelta>0 and a.estado<>'AN' and a.cobrable02=0 ","Prestamosx")  
                                       
    cmd14=SQLEXEC(lnHandle," SELECT DISTINCT a.codigoc, b.producto FROM factura A, detafacturas b "+;        
						  "	WHERE a.unico = b.unico AND a.fecha >=?My90 ORDER BY b.producto ","Miqbex")    					       
                                                                                                                                                                                                                                                                         
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

************* Lista por Productos que estan pedidos **********************************

IF DIRECTORY(vpRutaDBFInd)
	WAIT WINDOW 'Buscando importaciones de Indicolor en San Isidro ...' NoWait
	Open Database &vpRutaDBFInd.sqm.Dbc Shared
	Use &vpRutaDBFInd.pedidoimp.Dbf Shared In 0
	Use &vpRutaDBFInd.detallepedido.Dbf Shared In 0
	Use &vpRutaDBFInd.iembarque.Dbf Shared In 0
ELSE
	WAIT WINDOW 'Buscando importaciones de Indicolor en Lince ...' NoWait
	Open Database \\SRVLINCE\d\Newcompras\Data\sqm.Dbc Shared
	Use \\SRVLINCE\d\Newcompras\Data\pedidoimp.Dbf Shared In 0
	Use \\SRVLINCE\d\Newcompras\Data\detallepedido.Dbf Shared In 0
	Use \\SRVLINCE\d\Newcompras\Data\iembarque.Dbf Shared In 0
ENDIF

SELECT Detallepedido.producto, Pedidoimp.codigo,IIF(Pedidoimp.tipopedido="M","TM","TA") AS via,;
  IIF(Pedidoimp.tipoembarque="C","CONTAINER",IIF(Pedidoimp.tipoembarque="P","Parcial","Consolidado")) AS embarque,;
  Pedidoimp.fechaestimada, Iembarque.fecllegada1, Iembarque.fecllegada2,Iembarque.anticipado,;
  Detallepedido.saldo as Cantidad, Detallepedido.um,IIF(EMPTY(Iembarque.bl),"","BL") AS bl, Pedidoimp.tipopedido;
  FROM sqm!pedidoimp LEFT OUTER JOIN sqm!detallepedido ON  Pedidoimp.codigo = Detallepedido.codigo ;
                     INNER JOIN sqm!iembarque ON  Detallepedido.codigo = Iembarque.codigo;
  WHERE  Pedidoimp.terminado <> ( .T. ) AND pedidoimp.anulado<>.t. AND pedidoimp.vsucesiva<>1 ;
  ORDER BY Pedidoimp.fechaalmacen,Detallepedido.producto INTO CURSOR pedidos1
 
SELECT producto,codigo,via,embarque,fechaestimada+diastramite(embarque,fechaestimada,tipopedido,anticipado)as fecha1,;
 		fecllegada1+diastramite(embarque,fecllegada1,tipopedido,anticipado)as fecha2,;
 		fecllegada2+diastramite(embarque,fecllegada2,tipopedido,anticipado)as fecha3,;
 		cantidad,um,bl;
        FROM pedidos1 INTO CURSOR pedidos2
        
SELECT a.producto,;
        CAST(IIF(a.embarque="CONTAINER","CONT:Ped. "+a.codigo+" "+a.via+" "+dTOc(a.fecha1)+" "+dTOc(a.fecha2)+" "+DTOC(a.fecha3)+" "+a.bl,;
        "Ped. "+a.codigo+" "+a.via+" "+dTOc(a.fecha1)+" "+dTOc(a.fecha2)+" "+DTOC(a.fecha3)+" "+a.bl) as Char(80)) as Var,;
        a.cantidad,a.um,b.idsqm FROM pedidos2 as a LEFT JOIN Mibase as b ON a.producto=b.codigo ;
        INTO CURSOR pedidos3 readwrite

SELECT pedidos3
DELETE FOR cantidad=0
        
USE IN pedidos2
USE IN pedidos1

USE IN detallepedido
USE IN iembarque
USE IN pedidoimp
************ HASTA AQUI PEDIDOS3 ESTA CON LOS DATOS PENDIENTES DE IMPORTACION ***************************************** 




*************** Busqueda de Stock Disponible de Productos d ******************************** 
&& Para el Saldo General 
SELECT  SUBSTR(a.codigo,1,2) as Tipo,a.codigo as Cod1,b.Codigo,a.Proveedor,a.Nombre,b.Saldo,a.Um,a.idsqm,a.activo ;
		FROM Mibase as a LEFT JOIN Mistock as b  ON a.Codigo=b.Codigo INTO CURSOR Master0  READWRITE
		
SELECT b.nombre as NombreTipo,a.* FROM master0 as a LEFT JOIN MiTipos as b ON a.tipo=b.codigo;
       INTO CURSOR MASTER1

SELECT Mistock
USE 

&& Para el Saldo de Disponible (Saldo Venta - (standby+qexterno+quarantine) . Por el momento sin la reserva.
SELECT  SUBSTR(a.codigo,1,2) as Tipo,a.codigo as Cod1,b.Codigo,a.Proveedor,a.Nombre,b.Saldo,a.Um,a.idsqm,a.activo ;
		FROM Mibase as a LEFT JOIN MistockA as b  ON a.Codigo=b.Codigo INTO CURSOR Master0  READWRITE
		
SELECT b.nombre as NombreTipo,a.* FROM master0 as a LEFT JOIN MiTipos as b ON a.tipo=b.codigo;
       INTO CURSOR MASTER1A
       
SELECT MistockA
USE 

&& Para el Saldo de StandBy
SELECT  SUBSTR(a.codigo,1,2) as Tipo,a.codigo as Cod1,b.Codigo,a.Proveedor,a.Nombre,b.Saldo,a.Um,a.idsqm,a.activo ;
		FROM Mibase as a LEFT JOIN MistockB as b  ON a.Codigo=b.Codigo INTO CURSOR Master0  READWRITE
		
SELECT b.nombre as NombreTipo,a.*,'B' as Clase FROM master0 as a LEFT JOIN MiTipos as b ON a.tipo=b.codigo;
       WHERE saldo>0 INTO CURSOR MASTER1B
   
SELECT MistockB
USE 

&& Para el Saldo de Almacen Externo
SELECT  SUBSTR(a.codigo,1,2) as Tipo,a.codigo as Cod1,b.Codigo,a.Proveedor,a.Nombre,b.Saldo,a.Um,a.idsqm,a.activo ;
		FROM Mibase as a LEFT JOIN MistockC as b  ON a.Codigo=b.Codigo INTO CURSOR Master0  READWRITE
		
SELECT b.nombre as NombreTipo,a.*,'C' as clase FROM master0 as a LEFT JOIN MiTipos as b ON a.tipo=b.codigo;
       WHERE saldo>0 INTO CURSOR MASTER1C
   
SELECT MistockC
USE 

&& Para el Saldo de Almacen en Cuarentena
SELECT  SUBSTR(a.codigo,1,2) as Tipo,a.codigo as Cod1,b.Codigo,a.Proveedor,a.Nombre,b.Saldo,a.Um,a.idsqm,a.activo ;
		FROM Mibase as a LEFT JOIN MistockD as b  ON a.Codigo=b.Codigo INTO CURSOR Master0  READWRITE
		
SELECT b.nombre as NombreTipo,a.*,'D' as clase FROM master0 as a LEFT JOIN MiTipos as b ON a.tipo=b.codigo;
       WHERE saldo>0 INTO CURSOR MASTER1D
   
SELECT MistockD
USE 

SELECT Mitipos
USE 
       
SELECT master0
USE
************ Hasta aquí MASTER1 esta con los  Productos con sus stock respectivos ***********



********* SE CONSOLIDA LAS VENTAS *************************************************************************************

SELECT a.*,(b.todventa/2) as Prom2M FROM master1A as a LEFT JOIN ventas60 as b ON a.cod1=b.codigo;
	   INTO CURSOR aver1	   

SELECT a.*,b.todventa as UltMes,"A" as Clase,CAST(0.00 as n(10,2))as Nosuma,CAST(' ' as c(1))as Quali ;
		FROM aver1 as a LEFT JOIN ventas30 as b ON a.cod1=b.codigo;
		INTO CURSOR resultado readwrite

SELECT resultado
APPEND FROM DBF('Master1B')
SELECT resultado 
APPEND FROM DBF('Master1C')
SELECT resultado 
APPEND FROM DBF('Master1D')


SELECT master1A
USE 
SELECT master1B
USE 
SELECT master1C
USE 
SELECT master1D
USE 

SELECT ventas30
USE

SELECT ventas60
USE

SELECT aver1
USE  
      
******** TERMINA EL PROCESO DE CONSOLID *********************************************************************
SELECT codigo,IIF(UPPER(ALLTRIM(SUBSTR(observaciones,1,4)))="PROY" AND !EMPTY(observaciones),;
       "Proyección "+DTOC(fechaini)+" al "+DTOC(fechafin)+" "+ALLTRIM(cliente)+"-"+ALLTRIM(nombre),;
       "Reserva "+DTOC(fechaini)+" al "+DTOC(fechafin)+" "+ALLTRIM(cliente)+"-"+ALLTRIM(nombre)) as cadena,;
       CAST(saldo*-1 as N(10,2)) as Saldo FROM MyReservitax  INTO CURSOR reserva1x readwrite
       
SELECT codigo,"Ped.NO Atendido "+" del "+DTOC(fecha)+' '+ALLTRIM(cliente)+"-"+ALLTRIM(nombre) as cadena,;
       CAST(saldo*-1 as N(10,2)) as Saldo FROM MyNoatendx  INTO CURSOR Noatendidosx readwrite
       
SELECT reserva1x
APPEND FROM DBF('Noatendidosx')       
        
SELECT a.*,b.idsqm FROM reserva1x as a LEFT JOIN mibase as b ON a.codigo=b.codigo ORDER BY a.codigo INTO CURSOR reserva1
 
SELECT reserva1x
USE
SELECT Noatendidosx
USE 
**************************************************************************************************************

SELECT SUM(saldo) as saldo ,codigo,cliente,nombre FROM Myconsig1 GROUP BY 2,3,4 ORDER BY 2 INTO CURSOR Myconsig2

SELECT (a.saldo*-1) as Saldo,a.codigo,"Deuda SQM con :"+ALLTRIM(STRCONV(a.Nombre,11)) as Cadena,b.idsqm FROM ;
        Myconsig2 as a LEFT JOIN mibase as b ON a.codigo=b.codigo INTO CURSOR consignacion1 
  
SELECT Myconsig1
USE
SELECT Myconsig2
USE         
****************************************************************************************************************

SELECT codigo,"Préstamo a: "+SUBSTR(cadena,1,40)+" el "+DTOC(fecha) as Cadena,um,cantidad,idsqm FROM Prestamosx;
       INTO CURSOR prestamos
       
SELECT Prestamosx
USE            
**************************************************************************************************************** 

SELECT reserva1 &&& HABILITADO Con IDSQM
GO top
SCAN
   var1x=codigo
   var2x=cadena
   var3x=saldo
   var4x=idsqm
   SELECT resultado
	   APPEND BLANK
	   replace cod1 WITH var1x
	   replace nombre WITH var2x
	   replace nosuma WITH var3x
	   replace clase WITH "Z"
	   replace tipo WITH SUBSTR(var1x,1,2)
	   replace prom2m WITH 0
	   replace ultmes WITH 0
	   replace saldo WITH 0
	   replace idsqm WITH var4x
  SELECT reserva1
ENDSCAN

SELECT pedidos3 &&& HABILITADO Con IDSQM
GO top	
SCAN
   var1y=producto
   var2y=var
   var3y=cantidad
   var4y=idsqm
   SELECT resultado
      APPEND BLANK
	   replace cod1 WITH var1y
	   replace nombre WITH var2y
	   replace saldo WITH var3y
	   replace clase WITH "Y"
   	   replace tipo WITH SUBSTR(var1y,1,2)
	   replace prom2m WITH 0
	   replace ultmes WITH 0   	   
	   replace idsqm WITH var4y
   SELECT pedidos3      
ENDSCAN

SELECT consignacion1 &&& HABILITADO Con IDSQM
GO top	
SCAN
   var1n=codigo
   var2n=cadena
   var3n=saldo
   var4n=idsqm
   SELECT resultado
      APPEND BLANK
	   replace cod1 WITH var1n
	   replace nombre WITH var2n
	   replace saldo WITH var3n
	   replace clase WITH "N"
   	   replace tipo WITH SUBSTR(var1n,1,2)
	   replace prom2m WITH 0
	   replace ultmes WITH 0   	   
	   replace idsqm WITH var4n
   SELECT consignacion1      
ENDSCAN

SELECT prestamos &&& HABILITADO Con IDSQM
GO top	
SCAN
   var1a=codigo
   var2a=cadena
   var3a=cantidad
   var4a=idsqm
   SELECT resultado
      APPEND BLANK
	   replace cod1 WITH var1a
	   replace nombre WITH var2a
	   replace saldo WITH var3a
	   replace clase WITH "M"
   	   replace tipo WITH SUBSTR(var1a,1,2)
	   replace prom2m WITH 0
	   replace ultmes WITH 0   	   
	   replace idsqm WITH var4a
   SELECT prestamos      
ENDSCAN


SELECT prestamos
USE
SELECT Pedidos3
USE
SELECT reserva1
USE
SELECT Mibase
USE 


SELECT resultado
GO top
SCAN
 replace codigo WITH cod1 
 
 IF clase<>"A" && AND clase<>"B" AND clase<>"C" AND clase<>"D"
  replace codigo WITH " " 
 ENDIF 
  
 IF ISNULL(prom2m) 
    replace prom2m WITH 0
 ENDIF
 IF ISNULL(Ultmes) 
    replace ultmes WITH 0
 ENDIF
 
 IF ISNULL(Saldo) 
    replace saldo WITH 0
 ENDIF      
ENDSCAN
GO top

*****RECLASIFICANDO LOS CODIGOS QUE SE DEBEN MOSTRAR*********************************
SELECT cod1,COUNT(cod1) as cuenta FROM resultado GROUP BY 1 INTO CURSOR dinamico
SELECT dinamico
SCAN FOR cuenta=1
     asdx=cod1
     SELECT resultado
     GO top
     LOCATE FOR resultado.cod1=asdx
     IF FOUND()
       IF resultado.activo=0 AND resultado.saldo=0 AND resultado.clase="A"
          DELETE
       ENDIF    
     ENDIF
     SELECT dinamico
ENDSCAN
     
**************************************************************************************
SELECT COUNT(codigoc) as Numero,producto FROM miqbex GROUP BY producto ORDER BY producto INTO CURSOR Miqbex2 

SELECT resultado 
GO top
SCAN
    ax=ALLTRIM(resultado.cod1)
    SELECT Miqbex2
    GO top
    LOCATE for ALLTRIM(producto)=ax 
    IF FOUND()
       ay=Miqbex2.Numero
       
       DO case
          CASE ay>=12
               aqu='A'
          CASE ay>=8 AND ay<=11
               aqu='B'
          CASE ay>=3 AND ay<=7
               aqu='C'
          CASE ay=2
               aqu='D'
          CASE ay>=0 AND ay<=1
               aqu='E'                   
       ENDCASE 
    ELSE 
       aqu='E'
    ENDIF    
          
    SELECT resultado
    replace quali WITH aqu
           
ENDSCAN 
**************************************************************************************

SELECT resultado 
INDEX on tipo+idsqm+cod1+clase TAG unico
SET ORDER TO tag unico

SELECT resultado.cod1, SUM(resultado.saldo) as Tstock,SUM(resultado.prom2m) as T2meses,;
	   SUM(resultado.ultmes) as Tultimo;
	   FROM resultado ;
	   GROUP BY resultado.cod1 ORDER BY resultado.cod1 INTO CURSOR cabecera readwrite
	   
	   
SELECT cabecera
INDEX on cod1 TAG micodigo
	   
SELECT resultado
SCAN FOR !EMPTY(idsqm)
    IF VAL(SUBSTR(ALLTRIM(idsqm),4,2))<50
       DELETE
    ENDIF    
ENDSCAN 
GO TOP 
SET RELATION TO cod1 INTO cabecera

REPORT FORM ctactemercaderia TO PRINTER PROMPT NODIALOG PREVIEW
