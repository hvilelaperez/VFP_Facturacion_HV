*!*	SET TALK OFF
*!*	SET ECHO OFF

*!*	SET DELETED ON
*!*	SET DATE BRITISH
*!*	SET PROCEDURE TO funciones 

*!*	PUBLIC My60,My30,My90,Huesos_no
*!*	LOCAL Meses_nohuesos

*!*	My90=DATE()-90
*!*	My60=DATE()-60
*!*	My30=DATE()-30

*!*	PUBLIC Mystring_ofi01
*!*	Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ; 
*!*	           		"SERVER=190.41.122.156;" + ;                                                               		
*!*	           		"PORT=3306;" + ;
*!*	           		"UID=accesoweb;" + ;
*!*	           		"PWD=aBcxX$678;" + ;           		
*!*	           		"DATABASE=sqmdata;" + ;                             
*!*	           		"OPTIONS=0;"


*!*	lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
*!*	IF lnHandle > 0     
*!*	    cmd0=SQLEXEC(lnHandle,"SELECT anti_huesos_meses as Meses FROM constantes ","NewAnti")
*!*	    cmd1=SQLEXEC(lnHandle,"SELECT producto AS Codigo,SUM(qsaldov) as Saldo FROM vtalotes WHERE qsaldov>0 GROUP BY 1","Mistock")    
*!*	    cmd1=SQLEXEC(lnHandle,"SELECT producto AS Codigo,SUM((qsaldov-(qstandby+qexterno+quarantine))) as Saldo FROM vtalotes WHERE qsaldov>0 GROUP BY 1","MistockA")    
*!*	    cmd10=SQLEXEC(lnHandle,"SELECT producto AS Codigo,SUM(qstandby) as Saldo FROM vtalotes WHERE qstandby>0 GROUP BY 1","MistockB")    
*!*	    cmd15=SQLEXEC(lnHandle,"SELECT producto AS Codigo,SUM(qexterno) as Saldo FROM vtalotes WHERE qexterno>0 GROUP BY 1","MistockC")        
*!*	    cmd15=SQLEXEC(lnHandle,"SELECT producto AS Codigo,SUM(quarantine) as Saldo FROM vtalotes WHERE quarantine>0 GROUP BY 1","MistockD")           
*!*	    cmd2=SQLEXEC(lnHandle,"SELECT codigo,proveedor,nombre,um,idsqm,activo FROM productos ","Mibase") 
*!*	    cmd3=SQLEXEC(lnHandle,"SELECT * FROM tipoproductos","MiTipos")                                              
*!*	    SQLDISCONNECT(lnHandle)
*!*	ELSE
*!*	    AERROR(laErr)
*!*	    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
*!*	ENDIF

*!*	SELECT NewAnti
*!*	Meses_nohuesos=NewAnti.Meses*30
*!*	Huesos_no=ALLTRIM(STR(NewAnti.Meses,2,0))+" Meses"


*!*	*************** Busqueda de Stock Disponible de Productos d ********************************
*!*	 
*!*	&& Para el Saldo General 
*!*	SELECT  SUBSTR(a.codigo,1,2) as Tipo,a.codigo as Cod1,b.Codigo,a.Proveedor,a.Nombre,b.Saldo,a.Um,a.idsqm,a.activo ;
*!*			FROM Mibase as a LEFT JOIN Mistock as b  ON a.Codigo=b.Codigo INTO CURSOR Master0  READWRITE
*!*			
*!*	SELECT b.nombre as NombreTipo,a.* FROM master0 as a LEFT JOIN MiTipos as b ON a.tipo=b.codigo;
*!*	       INTO CURSOR MASTER1

*!*	SELECT Mistock
*!*	USE 

*!*	&& Para el Saldo de Disponible (Saldo Venta - (standby+qexterno+quarantine) . Por el momento sin la reserva.
*!*	SELECT  SUBSTR(a.codigo,1,2) as Tipo,a.codigo as Cod1,b.Codigo,a.Proveedor,a.Nombre,b.Saldo,a.Um,a.idsqm,a.activo ;
*!*			FROM Mibase as a LEFT JOIN MistockA as b  ON a.Codigo=b.Codigo INTO CURSOR Master0  READWRITE
*!*			
*!*	SELECT b.nombre as NombreTipo,a.* FROM master0 as a LEFT JOIN MiTipos as b ON a.tipo=b.codigo;
*!*	       INTO CURSOR MASTER1A
*!*	       
*!*	SELECT MistockA
*!*	USE 

*!*	&& Para el Saldo de StandBy
*!*	SELECT  SUBSTR(a.codigo,1,2) as Tipo,a.codigo as Cod1,b.Codigo,a.Proveedor,a.Nombre,b.Saldo,a.Um,a.idsqm,a.activo ;
*!*			FROM Mibase as a LEFT JOIN MistockB as b  ON a.Codigo=b.Codigo INTO CURSOR Master0  READWRITE
*!*			
*!*	SELECT b.nombre as NombreTipo,a.*,'B' as Clase FROM master0 as a LEFT JOIN MiTipos as b ON a.tipo=b.codigo;
*!*	       WHERE saldo>0 INTO CURSOR MASTER1B
*!*	   
*!*	SELECT MistockB
*!*	USE 

*!*	&& Para el Saldo de Almacen Externo
*!*	SELECT  SUBSTR(a.codigo,1,2) as Tipo,a.codigo as Cod1,b.Codigo,a.Proveedor,a.Nombre,b.Saldo,a.Um,a.idsqm,a.activo ;
*!*			FROM Mibase as a LEFT JOIN MistockC as b  ON a.Codigo=b.Codigo INTO CURSOR Master0  READWRITE
*!*			
*!*	SELECT b.nombre as NombreTipo,a.*,'C' as clase FROM master0 as a LEFT JOIN MiTipos as b ON a.tipo=b.codigo;
*!*	       WHERE saldo>0 INTO CURSOR MASTER1C
*!*	   
*!*	SELECT MistockC
*!*	USE 

*!*	&& Para el Saldo de Almacen en Cuarentena
*!*	SELECT  SUBSTR(a.codigo,1,2) as Tipo,a.codigo as Cod1,b.Codigo,a.Proveedor,a.Nombre,b.Saldo,a.Um,a.idsqm,a.activo ;
*!*			FROM Mibase as a LEFT JOIN MistockD as b  ON a.Codigo=b.Codigo INTO CURSOR Master0  READWRITE
*!*			
*!*	SELECT b.nombre as NombreTipo,a.*,'D' as clase FROM master0 as a LEFT JOIN MiTipos as b ON a.tipo=b.codigo;
*!*	       WHERE saldo>0 INTO CURSOR MASTER1D
*!*	   
*!*	SELECT MistockD
*!*	USE 
*!*	       
*!*	SELECT master0
*!*	USE

*!*	************ Hasta aquí MASTER1 esta con los  Productos con sus stock respectivos ***********



*!*	************* Lista por Productos que estan pedidos **********************************

*!*	OPEN DATABASE Z:\newcomprassqm\data\sqm.dbc SHARED

*!*	SELECT 0
*!*	USE Z:\newcomprassqm\data\pedidoimp SHARED

*!*	SELECT 0
*!*	USE Z:\newcomprassqm\data\detallepedido SHARED

*!*	SELECT 0
*!*	USE Z:\newcomprassqm\data\iembarque SHARED


*!*	SELECT Detallepedido.producto, Pedidoimp.codigo,;
*!*	  IIF(Pedidoimp.tipopedido="M","TM","TA") AS via,;
*!*	  IIF(Pedidoimp.tipoembarque="C","CONTAINER",IIF(Pedidoimp.tipoembarque="P","Parcial","Consolidado")) AS embarque,;
*!*	  Pedidoimp.fechaestimada, Iembarque.fecllegada1, Iembarque.fecllegada2, Iembarque.anticipado,;
*!*	  Detallepedido.saldo as Cantidad, Detallepedido.um,;
*!*	  IIF(EMPTY(Iembarque.bl),"","BL") AS bl, Pedidoimp.tipopedido;
*!*	 FROM ;
*!*	     sqm!pedidoimp ;
*!*	    LEFT OUTER JOIN sqm!detallepedido ;
*!*	   ON  Pedidoimp.codigo = Detallepedido.codigo ;
*!*	    INNER JOIN sqm!iembarque ;
*!*	   ON  Detallepedido.codigo = Iembarque.codigo;
*!*	 WHERE  Pedidoimp.terminado <> ( .T. ) AND pedidoimp.anulado<>.t.;
*!*	 ORDER BY Pedidoimp.fechaalmacen,Detallepedido.producto INTO CURSOR pedidos1
*!*	  
*!*	 SELECT producto,codigo,via,embarque,fechaestimada+diastramite(embarque,fechaestimada,tipopedido,anticipado)as fecha1,;
*!*	 		fecllegada1+diastramite(embarque,fecllegada1,tipopedido,anticipado)as fecha2,;
*!*	 		fecllegada2+diastramite(embarque,fecllegada2,tipopedido,anticipado)as fecha3,;
*!*	 		cantidad,um,bl;
*!*	        FROM pedidos1 INTO CURSOR pedidos2

*!*	 SELECT a.producto,;
*!*	        CAST(IIF(a.embarque="CONTAINER","CONT:Ped. "+a.codigo+" "+a.via+" "+dTOc(a.fecha1)+" "+dTOc(a.fecha2)+" "+DTOC(a.fecha3)+" "+a.bl,;
*!*	        "Ped. "+a.codigo+" "+a.via+" "+dTOc(a.fecha1)+" "+dTOc(a.fecha2)+" "+DTOC(a.fecha3)+" "+a.bl) as Char(80)) as Var,;
*!*	        a.cantidad,a.um,b.idsqm FROM pedidos2 as a LEFT JOIN Mibase as b ON a.producto=b.codigo ;
*!*	        INTO CURSOR pedidos3 readwrite


*!*	SELECT pedidos3
*!*	DELETE FOR cantidad=0
*!*	        
*!*	SELECT pedidos2
*!*	USE
*!*	SELECT pedidos1
*!*	USE
*!*	SELECT detallepedido
*!*	USE
*!*	SELECT iembarque
*!*	USE    
*!*	SELECT pedidoimp
*!*	USE

*!*	    
*!*	************ HASTA AQUI PEDIDOS3 ESTA CON LOS DATOS PENDIENTES DE IMPORTACION ****************************** 


*!*	**************************Consumo de los ultimos 2 meses y el ultimo mes ******************************************	
*!*	lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
*!*	IF lnHandle > 0
*!*	    **** Condiguro para 3 meses
*!*	    cmd1=SQLEXEC(lnHandle,"SELECT b.producto as Codigo,SUM(b.cantidad) as Todventa FROM detaguiasremision b, guiasremision a "+;
*!*	                          " WHERE a.unico=b.unico AND a.fecha>=?My90 and a.anulada<>1 and a.motivoguia=1 "+;
*!*	                          " GROUP BY 1 ","Ventas90")    
*!*	  
*!*	    cmd2=SQLEXEC(lnHandle,"SELECT b.producto as Codigo,SUM(b.cantidad) as Todventa FROM detaguiasremision b, guiasremision a "+;
*!*	                          " WHERE a.unico=b.unico AND a.fecha>=?My30 and a.anulada<>1 and a.motivoguia=1 "+;
*!*	                          " GROUP BY 1 ","Ventas30")                                                 
*!*	    SQLDISCONNECT(lnHandle)
*!*	ELSE
*!*	    AERROR(laErr)
*!*	    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
*!*	ENDIF		
*!*	***********************************************************************************************************************		


*!*	********* SE CONSOLIDA LAS VENTAS *************************************************************************************
*!*	SELECT a.*,(b.todventa/3) as Prom2M FROM master1A as a LEFT JOIN ventas90 as b ON a.cod1=b.codigo;
*!*		   INTO CURSOR aver1	   

*!*	SELECT a.*,b.todventa as UltMes,"A" as Clase,CAST(0.00 as n(10,2))as Nosuma;
*!*			FROM aver1 as a LEFT JOIN ventas30 as b ON a.cod1=b.codigo;
*!*			INTO CURSOR resultado readwrite

*!*	SELECT resultado
*!*	APPEND FROM DBF('Master1B')
*!*	SELECT resultado 
*!*	APPEND FROM DBF('Master1C')
*!*	SELECT resultado 
*!*	APPEND FROM DBF('Master1D')

*!*	SELECT master1A
*!*	USE 
*!*	SELECT master1B
*!*	USE 
*!*	SELECT master1C
*!*	USE 
*!*	SELECT master1D
*!*	USE 
*!*	SELECT ventas30
*!*	USE
*!*	SELECT ventas90
*!*	USE
*!*	SELECT aver1
*!*	USE
*!*	        
*!*	******** TERMINA EL PROCESO DE CONSOLID *********************************************************************
*!*	SELECT pedidos3 &&& HABILITADO Con IDSQM
*!*	GO top	
*!*	SCAN
*!*	   var1y=producto
*!*	   var2y=var
*!*	   var3y=cantidad
*!*	   var4y=idsqm
*!*	   SELECT resultado
*!*	      APPEND BLANK
*!*		   replace cod1 WITH var1y
*!*		   replace nombre WITH var2y
*!*		   replace saldo WITH var3y
*!*		   replace clase WITH "Y"
*!*	   	   replace tipo WITH SUBSTR(var1y,1,2)
*!*		   replace prom2m WITH 0
*!*		   replace ultmes WITH 0   	   
*!*		   replace idsqm WITH var4y
*!*	   SELECT pedidos3      
*!*	ENDSCAN

*!*	SELECT Pedidos3
*!*	USE
*!*	SELECT Mibase
*!*	USE 
*!*	SELECT resultado
*!*	GO top

*!*	SCAN
*!*	 	replace codigo WITH cod1 
*!*	 
*!*	 	IF clase<>"A" && AND clase<>"B" AND clase<>"C" AND clase<>"D"
*!*	  		replace codigo WITH " " 
*!*	 	ENDIF 
*!*	  
*!*	 	IF ISNULL(prom2m) 
*!*	    	replace prom2m WITH 0
*!*	 	ENDIF
*!*	 	IF ISNULL(Ultmes) 
*!*	    	replace ultmes WITH 0
*!*	 	ENDIF
*!*	 
*!*	 	IF ISNULL(Saldo) 
*!*	    	replace saldo WITH 0
*!*		ENDIF      
*!*	ENDSCAN
*!*	GO top


*!*	*****RECLASIFICANDO LOS CODIGOS QUE SE DEBEN MOSTRAR*********************************
*!*	SELECT cod1,COUNT(cod1) as cuenta FROM resultado GROUP BY 1 INTO CURSOR dinamico
*!*	SELECT dinamico
*!*	SCAN FOR cuenta=1
*!*	     asdx=cod1
*!*	     SELECT resultado
*!*	     GO top
*!*	     LOCATE FOR resultado.cod1=asdx
*!*	     IF FOUND()
*!*	       IF resultado.activo=0 AND resultado.saldo=0 AND resultado.clase="A"
*!*	          DELETE
*!*	       ENDIF    
*!*	     ENDIF
*!*	     SELECT dinamico
*!*	ENDSCAN     
*!*	**************************************************************************************


*!*	SELECT resultado 
*!*	INDEX on tipo+idsqm+cod1+clase TAG unico
*!*	SET ORDER TO tag unico

*!*	SELECT resultado.cod1, SUM(resultado.saldo) as Tstock,SUM(resultado.prom2m) as T2meses,;
*!*		   SUM(resultado.ultmes) as Tultimo;
*!*		   FROM resultado ;
*!*		   GROUP BY resultado.cod1 ORDER BY resultado.cod1 INTO CURSOR cabecera readwrite
*!*		   
*!*		   
*!*	SELECT cabecera
*!*	INDEX on cod1 TAG micodigo
*!*		   
*!*	SELECT resultado
*!*	SCAN FOR !EMPTY(idsqm)
*!*	    IF VAL(SUBSTR(ALLTRIM(idsqm),4,2))<50
*!*	       DELETE
*!*	    ENDIF    
*!*	ENDSCAN 
*!*	GO TOP 
*!*	SET RELATION TO cod1 INTO cabecera


*!*	SELECT  * FROM resultado WHERE clase='A' INTO CURSOR reflejo READWRITE && Copiamos a un espejo datos unicos de producto
*!*	 
*!*	SELECT reflejo  &&& Revisamos si tiene importaciones pendientes si es asi se marca en el campo nosuma
*!*	replace nosuma WITH 0
*!*	GO top

*!*	  SCAN
*!*	      xas=reflejo.cod1
*!*	      SELECT resultado
*!*	      GO TOP 
*!*	      LOCATE FOR cod1=xas AND clase='Y'
*!*	      IF FOUND()
*!*	         SELECT reflejo
*!*	         replace reflejo.nosuma WITH 1
*!*	      ELSE 
*!*	         SELECT reflejo
*!*	      ENDIF       
*!*	      SELECT reflejo       
*!*	  ENDSCAN     

*!*	&& Seleccionamos sólo los que son Huesos según los parametros ya predeterminados
*!*	SELECT * FROM reflejo WHERE clase='A' AND ((saldo/prom2m)>=12 OR (saldo>0 AND prom2m=0 AND nosuma<>1)) AND (tipo='00' OR BETWEEN(VAL(tipo),1,12)) INTO CURSOR Huesos READWRITE 

*!*	&& Creo el cursor contenedor que guardará la información valorizada       
*!*	CREATE CURSOR fondo (codigo c(7),nombre c(75),cantidad n(10,2), costo n(10,2) , totalc n(10,2), origen c(9),Prom3m n(10,2))

*!*	&& Cargo la información de lotes valorizados en el contenedor
*!*	SELECT Huesos
*!*	GO top
*!*	SCAN
*!*	    P1cod=Huesos.cod1
*!*	    P2cod=Huesos.nombre
*!*		lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
*!*		IF lnHandle > 0             
*!*	           cmd1=SQLEXEC(lnHandle,"SELECT origen,qsaldov,costo FROM vtalotes WHERE producto=?P1cod and qsaldov>0 ","Stk1")                                                 
*!*	           SQLDISCONNECT(lnHandle)
*!*		ELSE
*!*	       AERROR(laErr)
*!*	       MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
*!*	    ENDIF
*!*	    SELECT Stk1
*!*	    GO top
*!*	    SCAN 
*!*	        a1=Stk1.qsaldov
*!*	        a2=Stk1.costo
*!*	        a3=Stk1.origen
*!*	        SELECT Fondo
*!*	        APPEND BLANK
*!*	        replace codigo WITH P1cod  
*!*	        replace nombre WITH P2cod
*!*	        replace cantidad WITH a1
*!*	        replace costo WITH a2
*!*	        replace totalc WITH ROUND(cantidad*costo,2)
*!*	        replace origen WITH a3
*!*	        SELECT Stk1 
*!*	    ENDSCAN   
*!*	    SELECT Huesos   
*!*	ENDSCAN 


*!*	SELECT Fondo
*!*	SCAN FOR costo=0 AND SUBSTR(Fondo.origen,1,2)='01'
*!*	    Rx1=Fondo.Codigo
*!*	    Rx2=Fondo.Origen
*!*	    
*!*	    SELECT 0 && Cargo información del Proveedor del Producto
*!*	    USE Z:\newcomprassqm\data\proveedores.dbf SHARED

*!*	    SELECT codigo,fletestandar2 as flete2,fletestandar as fleted,fletestandarcli,factordes as factor FROM proveedores ;
*!*	           WHERE codigo=SUBSTR(ALLTRIM(Rx1),3,2) INTO CURSOR datoprov
*!*	      
*!*	    SELECT Proveedores        
*!*	    USE
*!*	    
*!*	    SELECT 0 && Cargo información del Precio FOB UNITARIO SQM
*!*	    USE Z:\newcomprassqm\data\Detallepedido.dbf SHARED

*!*	    SELECT pu FROM Detallepedido WHERE Codigo=Rx2 AND Producto=Rx1 INTO CURSOR Mypu      
*!*	    
*!*	    SELECT Detallepedido        
*!*	    USE
*!*	        
*!*	    SELECT 0 && Cargo información del Tipo de Pedido y el Pais de Origen
*!*	    USE Z:\newcomprassqm\data\Pedidoimp.dbf SHARED         
*!*	    SELECT 0
*!*	    USE Z:\newcomprassqm\data\Iembarque.dbf SHARED
*!*	    
*!*	    SELECT a.tipopedido,b.paisembarque as pais FROM Pedidoimp as a LEFT JOIN Iembarque as b ON a.codigo=b.codigo WHERE a.codigo=Rx2 INTO CURSOR Mydata5DC
*!*	    
*!*	    SELECT Pedidoimp        
*!*	    USE
*!*	    SELECT Iembarque
*!*	    USE 
*!*	   
*!*	    SELECT Fondo 
*!*	      
*!*	    IF SUBSTR(ALLTRIM(Rx1),3,2)="F0"
*!*	       DO case
*!*	          CASE Mydata5DC.tipopedido='M'
*!*	     
*!*	               IF ALLTRIM(Mydata5DC.pais)="TW"          
*!*	                  replace costo WITH ROUND((Mypu.pu+datoprov.flete2)*datoprov.factor,2)
*!*	                  replace totalc WITH ROUND(cantidad*costo,2)
*!*	               ELSE    
*!*	                  replace costo WITH ROUND((Mypu.pu+datoprov.fleted)*datoprov.factor,2)
*!*	                  replace totalc WITH ROUND(cantidad*costo,2)
*!*	               ENDIF 
*!*	                   
*!*	          CASE Mydata5DC.tipopedido='A'
*!*	               DO case
*!*	                  CASE ALLTRIM(Mydata5DC.pais)="US"
*!*	                       replace costo WITH ROUND((Mypu.pu+3.20)*1.20,2)                  
*!*	                       replace totalc WITH ROUND(cantidad*costo,2)
*!*	                  CASE ALLTRIM(Mydata5DC.pais)="HN"
*!*	                       replace costo WITH ROUND((Mypu.pu+2.90)*1.20,2) 
*!*	                       replace totalc WITH ROUND(cantidad*costo,2)                  
*!*	               ENDCASE                                  
*!*	       ENDCASE 
*!*	               
*!*	     ELSE 
*!*	        replace costo WITH ROUND((Mypu.pu+datoprov.fleted)*datoprov.factor,2)
*!*	        replace totalc WITH ROUND(cantidad*costo,2)
*!*	     ENDIF      
*!*	ENDSCAN 

*!*	SELECT codigo,nombre,SUM(cantidad) as Cantidad,SUM(totalc) as Money,SUM(totalc) as Prom3;
*!*	       FROM fondo GROUP BY 1,2  ORDER BY 4 DESC INTO CURSOR ResumenB READWRITE 

*!*	SELECT SUBSTR(a.codigo,1,2) as Tipo,a.codigo,a.nombre,a.cantidad,a.money,a.Prom3,b.nombre as tnombre,;
*!*	       CAST(CTOD('  /   /  ') AS D ) AS Fechita,' ' as Cat,'A' as Milevel, CAST(' ' as C(20)) as Lote,CAST(0.00 as n(10,2)) as Stock,;
*!*	       CAST(CTOD('  /   /  ') AS D ) AS Fecfab,CAST(CTOD('  /   /  ') AS D ) AS fecven,CAST(CTOD('  /   /  ') AS D ) AS Ingreso,CAST(' ' as c(1)) as Ubi ;
*!*	       FROM ResumenB as a LEFT JOIN Mitipos as b ON SUBSTR(a.codigo,1,2)=b.codigo ORDER BY 1,5 DESC  INTO CURSOR Resumen READWRITE 
*!*	              
*!*	SELECT resumen
*!*	GO top
*!*	lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
*!*	IF lnHandle > 0
*!*	  SCAN 
*!*	    a1=codigo
*!*	    cmd1=SQLEXEC(lnHandle,"SELECT MIN(fingreso) as Minimo FROM vtalotes WHERE producto=?a1","Minime")   
*!*	    cmd1=SQLEXEC(lnHandle,"SELECT * FROM vtalotes WHERE producto=?a1 and qsaldov>0","MonDiu")
*!*	    SELECT Minime
*!*	    IF RECCOUNT()>0
*!*	       b1=Minimo
*!*	    ENDIF 
*!*	    SELECT resumen
*!*	    replace fechita WITH b1       
*!*	    IF fechita>DATE()-Meses_nohuesos
*!*	       DELETE
*!*	    ENDIF        
*!*	  ENDSCAN                                              
*!*	  SQLDISCONNECT(lnHandle)
*!*	ELSE
*!*	    AERROR(laErr)
*!*	    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
*!*	ENDIF

*!*	SELECT resumen 
*!*	replace ALL Prom3 WITH 0
*!*	GO top
*!*	SCAN
*!*	    as1=codigo
*!*	    SELECT huesos
*!*	    GO top
*!*	    LOCATE FOR cod1=as1
*!*	    IF FOUND()
*!*	       as2=Prom2m
*!*	       SELECT resumen 
*!*	       replace prom3 WITH as2
*!*	    ENDIF 
*!*	    SELECT resumen   
*!*	ENDSCAN 

*!*	************************** Agregando Categoria ABC *******************************************************
*!*	LOCAL My90
*!*	My90=DATE()-90

*!*	lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
*!*	IF lnHandle > 0                                                       
*!*	    cmd1=SQLEXEC(lnHandle," SELECT DISTINCT a.codigoc, b.producto FROM factura A, detafacturas b "+;        
*!*							  "	WHERE a.unico = b.unico AND a.fecha >=?My90 ORDER BY b.producto ","Miqbex")    					       
*!*	    SQLDISCONNECT(lnHandle)        
*!*	ELSE
*!*	    AERROR(laErr)
*!*	    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
*!*	ENDIF

*!*	SELECT COUNT(codigoc) as Numero,producto FROM miqbex GROUP BY producto ORDER BY producto INTO CURSOR Miqbex2 

*!*	SELECT resumen
*!*	GO top
*!*	SCAN
*!*	    ax=ALLTRIM(resumen.codigo)
*!*	    SELECT Miqbex2
*!*	    GO top
*!*	    LOCATE for ALLTRIM(producto)=ax 
*!*	    IF FOUND()
*!*	       ay=Miqbex2.Numero       
*!*	       DO case
*!*	          CASE ay>=12
*!*	               aqu='A'
*!*	          CASE ay>=8 AND ay<=11
*!*	               aqu='B'
*!*	          CASE ay>=3 AND ay<=7
*!*	               aqu='C'
*!*	          CASE ay=2
*!*	               aqu='D'
*!*	          CASE ay>=0 AND ay<=1
*!*	               aqu='E'                   
*!*	       ENDCASE 
*!*	    ELSE 
*!*	       aqu='E'
*!*	    ENDIF              
*!*	    SELECT resumen
*!*	    replace cat WITH aqu           
*!*	ENDSCAN 
*!*	**************************************************************************************
*!*	SELECT * FROM resumen INTO CURSOR gresumen READWRITE 

*!*	SELECT resumen
*!*	GO top
*!*	lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
*!*	IF lnHandle > 0
*!*	  SCAN 
*!*	    a1=codigo 
*!*	    a2=tipo
*!*	    a3=tnombre 
*!*	    cmd1=SQLEXEC(lnHandle,"SELECT * FROM vtalotes WHERE producto=?a1 and qsaldov>0","MonDiu")
*!*	    SELECT Mondiu
*!*	    IF RECCOUNT()>0
*!*	       SCAN
*!*	         pr1=Mondiu.qsaldov
*!*	         pr2=Mondiu.lotefab
*!*	         pr3=Mondiu.fab_real
*!*	         pr4=Mondiu.exp_real
*!*	         pr5=Mondiu.ubicacion
*!*	         pr6=Mondiu.fingreso
*!*	         SELECT gresumen
*!*	         APPEND BLANK 
*!*	         replace tipo WITH a2
*!*	         replace tnombre WITH a3
*!*	         replace codigo WITH a1
*!*	         replace lote WITH pr2
*!*	         replace stock WITH pr1
*!*	         replace fecfab WITH pr3
*!*	         replace fecven WITH pr4
*!*	         replace milevel WITH 'B'
*!*	         replace ingreso WITH pr6
*!*	         replace ubi WITH pr5
*!*	       ENDSCAN   
*!*	    ENDIF 
*!*	    SELECT resumen        
*!*	  ENDSCAN                                              
*!*	  SQLDISCONNECT(lnHandle)
*!*	ELSE
*!*	    AERROR(laErr)
*!*	    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
*!*	ENDIF

*!*	SELECT gresumen
*!*	SELECT * FROM gresumen ORDER BY tipo,codigo,milevel INTO CURSOR resumenx

*!*	SELECT resumenx 
*!*	GO top

*!*	SET REPORTBEHAVIOR 80
*!*	REPORT FORM 01listahuesos1ext TO PRINTER PROMPT NODIALOG PREVIEW
*!*	*BROWSE 


