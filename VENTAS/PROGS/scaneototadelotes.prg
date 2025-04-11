SET DELETED ON
SET DATE BRITISH

LOCAL MyString_ofi01,Pase1,Second2,My90

My90=DATE()-90

CREATE CURSOR contenedor (supercd c(3),tipoproducto c(2),agrupacion c(7),nombre c(70),codigo c(7),origen c(9),qsaldov n(10,2),saldo n(10,2),qexterno n(10,2),xllegar n(10,2),fingreso d,lotefab c(35),tnombre c(35),costo n(10,2),ubicacion c(2),nocosto n(1,0),nagrupacion c(70))
CREATE CURSOR equivalente (sqm c(7),indicolor c(7))

MyString_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ; 
           		"SERVER=192.168.1.179;" + ;                                                               		
           		"PORT=3306;" + ;
           		"UID=sistemas;" + ;
           		"PWD=d3b14nfw123;" + ;           		
           		"DATABASE=sqmdata;" + ;                             
           		"OPTIONS=0;"
           		
Mystring_ofi02 = "DRIVER={MySQL ODBC 3.51 Driver};" + ; && Server Datos Indicolor
           		"SERVER=192.168.1.221;" + ;                                                    
           		"PORT=3306;" + ;
           		"UID=sistemas;" + ;
           		"PWD=informatica;" + ;
           		"DATABASE=indicolor;" + ;                             
           		"OPTIONS=0;"    
           		
lnHandle2 = SQLSTRINGCONNECT(MyString_ofi02)  &&& Creando Master de Productos
IF lnHandle2 > 0  	                        
    cmd3=SQLEXEC(lnHandle2,"SELECT * FROM productos ","xyzProductos_in") && Para conexiones INDICOLOR 
                                                      
    SQLDISCONNECT(lnHandle2)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF           		       		

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)  &&& Creando Master de Productos
IF lnHandle > 0  	                      
	cmd1=SQLEXEC(lnHandle,"SELECT DISTINCT a.idsqm as Agrupacion,a.tipoproducto,b.nombre,CAST(1 as Decimal(1,0))as esgrupo,"+;
	                      "CAST(c.clase AS CHAR(70)) as nagrupacion FROM productos a,tipoproductos b,clases c "+;
	                      "WHERE a.tipoproducto=b.codigo AND a.idsqm=c.idsqm AND length(TRIM(a.idsqm))>0 ORDER BY 1","Prima")
	                      
	cmd2=SQLEXEC(lnHandle,"SELECT a.codigo as Agrupacion,a.tipoproducto,b.nombre,CAST(0 as Decimal(1,0))as esgrupo,"+;
	                      "CAST(a.nombre AS CHAR(70)) as nagrupacion FROM productos a,tipoproductos b "+;
	                      "WHERE a.tipoproducto=b.codigo AND b.escolorante=1 AND length(TRIM(a.idsqm))=0 ORDER BY 1 ","Segundo")   

    cmd3=SQLEXEC(lnHandle,"SELECT * FROM productos ","xyzProductos") && Para conexiones SQM
    
    cmd4=SQLEXEC(lnHandle,"SELECT * FROM tipoproductos ","xyzTipos") && Para conexiones SQM e INDICOLOR (es lo mismo)
                                             
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Prima
APPEND FROM DBF('Segundo')

SELECT *,CAST('' as c(7)) as Indicodigo FROM  Prima ORDER BY tipoproducto,esgrupo,agrupacion INTO CURSOR PrimerOrden READWRITE 

SELECT Prima
USE
SELECT Segundo
USE 


SELECT PrimerOrden
GO top
lnHandle = SQLSTRINGCONNECT(MyString_ofi01) && Agregando Stock SQM
IF lnHandle > 0    

   SCAN 
       av1=ALLTRIM(agrupacion)
       av2=esgrupo
       av3=ALLTRIM(nagrupacion)
       
       IF av2=1    
            cmd1=SQLEXEC(lnHandle,"SELECT ?av1 as agrupacion,b.tipoproducto,b.nombre,a.producto AS Codigo,a.origen,a.qsaldov,a.qsaldov-a.qexterno as saldo,a.qexterno,a.fingreso,"+;
                          "a.lotefab,c.nombre as Tnombre,a.costo,a.ubicacion,CAST(0 AS DECIMAL(1,0)) AS Nocosto, CAST(0 AS DECIMAL(10,2)) AS xllegar,"+;
                          "CAST('SQM' AS CHAR) AS Supercd,?av3 as nagrupacion FROM vtalotes a,productos b,tipoproductos c "+;
                          "WHERE a.producto=b.codigo AND b.tipoproducto=c.codigo AND b.idsqm=?av1 AND a.qsaldov>0 order by 1,3,6","Mistock")   
                                                   
            cmd2=SQLEXEC(lnHandle,"SELECT indicodigo FROM productos WHERE idsqm=?av1","Pass1x")
    
       ELSE 
            cmd1=SQLEXEC(lnHandle,"SELECT ?av1 as agrupacion,b.tipoproducto,b.nombre,a.producto AS Codigo,a.origen,a.qsaldov,a.qsaldov-a.qexterno as saldo,a.qexterno,a.fingreso,"+;
                          "a.lotefab,c.nombre as Tnombre,a.costo,a.ubicacion,CAST(0 AS DECIMAL(1,0)) AS Nocosto, CAST(0 AS DECIMAL(10,2)) AS xllegar,"+;
                          "CAST('SQM' AS CHAR) AS Supercd,?av3 as nagrupacion FROM vtalotes a,productos b,tipoproductos c "+;
                          "WHERE a.producto=b.codigo AND b.tipoproducto=c.codigo AND a.producto=?av1 AND a.qsaldov>0 order by 1,3,6","Mistock")
                          
	        cmd2=SQLEXEC(lnHandle,"SELECT indicodigo FROM productos WHERE codigo=?av1","Pass1x")                           
       ENDIF
       
       SELECT Mistock
       IF RECCOUNT()>0
          SELECT Contenedor
          APPEND FROM DBF('MiStock')
       ENDIF   
       
       
       Pase1=0
       Second2=''      
       SELECT Pass1x   
       IF RECCOUNT()=1 && Es un solo registro no esta agrupado o es grupo de uno
          GO top
          IF LEN(ALLTRIM(Pass1x.indicodigo))=6 && si hay codigo equivalente en INDICOLOR
             Pase1=1
             Second2=ALLTRIM(Pass1x.indicodigo)
          ELSE
             Pase1=0
          ENDIF           
       ELSE
          GO top
          stz=0
          SCAN FOR LEN(ALLTRIM(Pass1x.indicodigo))=6 && buscar codigo equivalente INDICOLOR en todo el arreglo
              stz=stz+1
              Pase1=1
              Second2=ALLTRIM(Pass1x.indicodigo)
          ENDSCAN 
         IF stz=0
           Pase1=0
         ENDIF                  
       ENDIF             
       
       IF pase1=1
         SELECT equivalente
         APPEND BLANK
         replace sqm WITH av1
         replace indicolor WITH second2         
       ENDIF
             
       SELECT PrimerOrden                                                                         
   ENDSCAN                           
                               
   SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT equivalente
GO top
SCAN
   bb1=ALLTRIM(sqm)
   bb2=ALLTRIM(indicolor)
   SELECT PrimerOrden
   GO top
   LOCATE FOR ALLTRIM(agrupacion)=bb1
   IF FOUND()
      replace indicodigo WITH bb2
   ENDIF
   SELECT equivalente
ENDSCAN       
   
SELECT primerorden
GO top             
lnHandle2 = SQLSTRINGCONNECT(MyString_ofi02) && Agregando INDICOLOR STOCK
IF lnHandle2 > 0  
   SCAN FOR LEN(ALLTRIM(indicodigo))>0
       op1=ALLTRIM(agrupacion)
       op2=ALLTRIM(indicodigo)
       op3=ALLTRIM(nagrupacion)
       cmdx1=SQLEXEC(lnHandle2,"SELECT ?op1 as Agrupacion,b.tipoproducto,b.nombre,a.producto AS Codigo,a.origen,a.qsaldov,a.qsaldov-a.qexterno as saldo,a.qexterno,a.fingreso,"+;
    	                      "a.lotefab,c.nombre as Tnombre,a.costo,a.ubicacion,CAST(0 AS DECIMAL(1,0)) AS Nocosto,CAST(0 AS DECIMAL(10,2)) AS xllegar,"+;
    	                      "CAST('IND' AS CHAR) AS Supercd,?op3 as nagrupacion FROM vtalotes a,productos b,tipoproductos c WHERE a.producto=b.codigo AND b.tipoproducto=c.codigo "+;
    	                      "AND a.producto=?op2 AND a.qsaldov>0 order by 1,3,6","MistockIndi")        	                                                                                                                       
       
       SELECT MistockIndi
       IF RECCOUNT()>0
          SELECT Contenedor
          APPEND FROM DBF('MiStockIndi')
       ENDIF
       
       SELECT primerorden
    ENDSCAN
    SQLDISCONNECT(lnHandle2)
ELSE             
     AERROR(laErr)
     MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])             
ENDIF


**************************************************** Jalando las Importaciones SQM ************************************************************
OPEN DATABASE f:\newcompras\data\sqm.dbc SHARED
SELECT 0
USE f:\newcompras\data\pedidoimp.dbf SHARED
SELECT 0
USE f:\newcompras\data\detallepedido.dbf SHARED
SELECT 0
USE f:\newcompras\data\iembarque.dbf SHARED
SELECT 0
USE f:\newcompras\data\proveedores.dbf SHARED

SELECT * FROM Pedidoimp WHERE anulado<>.t. AND vsucesiva<>1 AND terminado<>.t. INTO CURSOR Pedidoimp_sq
SELECT b.* FROM Pedidoimp as a LEFT JOIN Detallepedido as b ON a.codigo=b.codigo WHERE a.anulado<>.t. AND a.vsucesiva<>1 AND a.terminado<>.t. INTO CURSOR Detallepedido_sq
SELECT b.* FROM Pedidoimp as a LEFT JOIN iembarque as b ON a.codigo=b.codigo WHERE a.anulado<>.t. AND a.vsucesiva<>1 AND a.terminado<>.t. INTO CURSOR Iembarque_sq
SELECT * FROM Proveedores INTO CURSOR Proveedores_sq

SELECT pedidoimp
USE
SELECT detallepedido 
USE
SELECT iembarque
USE 
SELECT proveedores
USE 
CLOSE DATABASES 

SELECT PrimerOrden
GO top
SCAN 
   zk1=esgrupo
   zk2=ALLTRIM(agrupacion)
   zk3=ALLTRIM(nagrupacion)
   
   IF zk1=1 
      SELECT d.idsqm,a.producto,a.codigo,a.saldo,a.um,b.fechapedido,b.fechaalmacen,b.tipopedido,a.pu,c.paisembarque as pais,a.lote,d.nombre,e.nombre as tnombre ;
    	  FROM detallepedido_sq as a ;
		  LEFT JOIN pedidoimp_sq as b ON a.codigo=b.codigo;
	      LEFT JOIN iembarque_sq as c ON a.codigo=c.codigo;
	      LEFT JOIN xyzproductos as d ON a.producto=d.codigo;
	      LEFT JOIN xyzTipos as e ON d.tipoproducto=e.codigo;	      
		  WHERE  b.anulado<>.t. AND b.terminado<>.t. AND a.saldo<>0 AND b.vsucesiva<>1 AND ALLTRIM(d.idsqm)==zk2;  	        
       	  INTO CURSOR Mydata5xDC        	            	   	 
   ELSE
      SELECT a.producto,a.codigo,a.saldo,a.um,b.fechapedido,b.fechaalmacen,b.tipopedido,a.pu,c.paisembarque as pais,a.lote,d.nombre,e.nombre as tnombre ;
    	  FROM detallepedido_sq as a ;
		  LEFT JOIN pedidoimp_sq as b ON a.codigo=b.codigo;
	      LEFT JOIN iembarque_sq as c ON a.codigo=c.codigo;
	      LEFT JOIN xyzproductos as d ON a.producto=d.codigo;
	      LEFT JOIN xyzTipos as e ON d.tipoproducto=e.codigo;
		  WHERE  ALLTRIM(a.producto)==zk2 AND b.anulado<>.t. AND b.terminado<>.t. AND a.saldo<>0 AND b.vsucesiva<>1 ;
       	  INTO CURSOR Mydata5xDC
   ENDIF        	  
	
   SELECT Mydata5xDC
   IF RECCOUNT()>0
	   GO top
	   SCAN 
	   		lb1=Mydata5xDC.producto
	   		lb2=Mydata5xDC.codigo
	   		lb3=Mydata5xDC.saldo
	   		lb4=Mydata5xDC.lote
	   		lb5=Mydata5xDC.fechaalmacen
	   		lb6=Mydata5xDC.nombre
	   		lb7=Mydata5xDC.tnombre
	   			   
	   		SELECT Contenedor
	   		APPEND BLANK
	   		replace agrupacion WITH zk2
	   		replace codigo WITH lb1
	   		replace origen WITH lb2
	   		replace xllegar WITH lb3
	   		replace qsaldov WITH lb3 
	   		replace lotefab WITH lb4	
	   		replace fingreso WITH lb5
	   		replace tipoproducto WITH SUBSTR(lb1,1,2)
	   		replace tnombre WITH lb7	  
	   		replace nombre WITH lb6 	
	   		replace supercd WITH 'SQM'	
	   		replace nagrupacion WITH zk3   		
	   ENDSCAN 		
   ENDIF
   SELECT PrimerOrden
ENDSCAN
**********************************************************************************************************************************************


**************************************************** Jalando las Importaciones INDICOLOR******************************************************
OPEN DATABASE Z:\newcompras\data\sqm.dbc SHARED
SELECT 0
USE Z:\newcompras\data\pedidoimp.dbf SHARED
SELECT 0
USE Z:\newcompras\data\detallepedido.dbf SHARED
SELECT 0
USE Z:\newcompras\data\iembarque.dbf SHARED
SELECT 0
USE Z:\newcompras\data\proveedores.dbf SHARED

SELECT * FROM Pedidoimp WHERE anulado<>.t. AND terminado<>.t. INTO CURSOR Pedidoimp_in
SELECT b.* FROM Pedidoimp as a LEFT JOIN Detallepedido as b ON a.codigo=b.codigo WHERE a.anulado<>.t. AND a.terminado<>.t. INTO CURSOR Detallepedido_in
SELECT b.* FROM Pedidoimp as a LEFT JOIN iembarque as b ON a.codigo=b.codigo WHERE a.anulado<>.t. AND a.terminado<>.t. INTO CURSOR Iembarque_in
SELECT * FROM Proveedores INTO CURSOR Proveedores_in

SELECT pedidoimp
USE
SELECT detallepedido 
USE
SELECT iembarque
USE 
SELECT Proveedores
USE 
CLOSE DATABASES 

SELECT PrimerOrden
GO top
SCAN FOR LEN(ALLTRIM(indicodigo))>0

   zk1=ALLTRIM(agrupacion)
   zk2=ALLTRIM(indicodigo)
   zk3=ALLTRIM(nagrupacion)
   
   SELECT a.producto,a.codigo,a.saldo,a.um,b.fechapedido,b.fechaalmacen,b.tipopedido,a.pu,c.paisembarque as pais,a.lote,d.nombre,e.nombre as tnombre ;
    	  FROM detallepedido_in as a ;
		  LEFT JOIN pedidoimp_in as b ON a.codigo=b.codigo;
	      LEFT JOIN iembarque_in as c ON a.codigo=c.codigo;
	      LEFT JOIN xyzproductos_in as d ON a.producto=d.codigo;
	      LEFT JOIN xyzTipos as e ON d.tipoproducto=e.codigo;
		  WHERE  ALLTRIM(a.producto)==zk2 AND b.anulado<>.t. AND b.terminado<>.t. AND a.saldo<>0 INTO CURSOR Mydata5xDC
          	  	
   SELECT Mydata5xDC
   IF RECCOUNT()>0
	   GO top
	   SCAN 
	   		lb1=Mydata5xDC.producto
	   		lb2=Mydata5xDC.codigo
	   		lb3=Mydata5xDC.saldo
	   		lb4=Mydata5xDC.lote
	   		lb5=Mydata5xDC.fechaalmacen
	   		lb6=Mydata5xDC.nombre
	   		lb7=Mydata5xDC.tnombre
	   			   
	   		SELECT Contenedor
	   		APPEND BLANK
	   		replace agrupacion WITH zk1
	   		replace codigo WITH lb1
	   		replace origen WITH lb2
	   		replace xllegar WITH lb3
	   		replace qsaldov WITH lb3 
	   		replace lotefab WITH lb4	
	   		replace fingreso WITH lb5
	   		replace tipoproducto WITH SUBSTR(lb1,1,2)
	   		replace tnombre WITH lb7	  
	   		replace nombre WITH lb6 	
	   		replace supercd WITH 'IND'	 
	   		replace nagrupacion WITH zk3  		
	   ENDSCAN 		
   ENDIF
   SELECT PrimerOrden
ENDSCAN
**********************************************************************************************************************************************
   
********* Poniendo Costo a Importaciones SQM por llegar  *************************************************************************************
SELECT Contenedor
GO top
SCAN FOR xllegar>0 AND ALLTRIM(Supercd)='SQM'
     xs2=ALLTRIM(origen)
     xs3=ALLTRIM(codigo)
     xs4=qsaldov
  
     SELECT a.pu,b.paisembarque as pais FROM detallepedido_sq as a  LEFT JOIN iembarque_sq as b;
   		 	ON a.codigo=b.codigo WHERE ALLTRIM(a.producto)==xs3 AND ALLTRIM(a.codigo)==xs2  INTO ARRAY Mypu
         
     IF _tally=0  
        SELECT contenedor
        replace nocosto WITH 2        
  	 ELSE
  	     Xprov=SUBSTR(xs3,3,2)
					               
  	 	 IF Xprov<>"F0"
  		  	SELECT a.fletestandar,a.factordes FROM proveedores_sq as a WHERE a.codigo==Xprov INTO ARRAY Myval                  
	     ELSE 
      	  	IF Mypu(1,2)="TW"
          	   SELECT a.fletestandar2,a.factordes FROM proveedores_sq as a WHERE a.codigo==Xprov INTO ARRAY Myval        
          	ELSE
          	   SELECT a.fletestandar,a.factordes FROM proveedores_sq as a WHERE a.codigo==Xprov INTO ARRAY Myval        
         	ENDIF
         ENDIF 	         	        
         SELECT contenedor
         replace costo WITH ROUND((Mypu(1,1)+Myval(1,1))*Myval(1,2),2)
         replace nocosto WITH 1 		 
     ENDIF                    
    SELECT contenedor   
ENDSCAN
*************************************************************************************************************************************************

********* Poniendo Costo a Importaciones INDICOLOR por llegar  *************************************************************************************
SELECT Contenedor
GO top
SCAN FOR xllegar>0 AND ALLTRIM(Supercd)='IND'
     xs2=ALLTRIM(origen)
     xs3=ALLTRIM(codigo)
     xs4=qsaldov
    
     SELECT a.pu,b.paisembarque as pais FROM detallepedido_in as a  LEFT JOIN iembarque_in as b;
   	        ON a.codigo=b.codigo WHERE ALLTRIM(a.producto)==xs3 AND ALLTRIM(a.codigo)==xs2 INTO ARRAY Mypu    
      
     IF _tally=0 
        SELECT contenedor
        replace nocosto WITH 2 
  	 ELSE
  	     Xprov=SUBSTR(xs3,3,2)
					               
  	 	 IF Xprov<>"F0"
  		  	SELECT a.fletestandar,a.factordes FROM proveedores_in as a WHERE a.codigo==Xprov INTO ARRAY Myval                  
	     ELSE 
      	  	IF Mypu(1,2)="TW"
          	   SELECT a.fletestandar2,a.factordes FROM proveedores_in as a WHERE a.codigo==Xprov INTO ARRAY Myval        
          	ELSE
          	   SELECT a.fletestandar,a.factordes FROM proveedores_in as a WHERE a.codigo==Xprov INTO ARRAY Myval        
         	ENDIF
         ENDIF 	         	        
         SELECT contenedor
         replace costo WITH ROUND((Mypu(1,1)+Myval(1,1))*Myval(1,2),2)
         replace nocosto WITH 1 		 
     ENDIF                    
    SELECT contenedor   
ENDSCAN
*************************************************************************************************************************************************
 
SELECT * FROM contenedor ORDER BY tipoproducto,agrupacion,codigo,costo DESC INTO CURSOR Mibase

SELECT agrupacion,SUM(qsaldov) as TotalStock FROM Mibase GROUP BY 1 INTO CURSOR resumen1

SELECT *,CAST(0.00 as N(10,2)) as Prom90m,IIF(LEN(ALLTRIM(agrupacion))=5,1,0) as grupo FROM resumen1 INTO CURSOR resumen2 READWRITE 

SELECT resumen2
GO top
lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0
   SCAN 
       sp1=ALLTRIM(agrupacion)
       
       IF grupo=0    
          cmd1=SQLEXEC(lnHandle,"SELECT b.producto as Codigo,SUM(b.cantidad) as Todventa FROM detaguiasremision b, guiasremision a "+;
                                " WHERE a.unico=b.unico AND a.fecha>=?My90 and a.anulada<>1 and a.motivoguia=1 and b.producto=?sp1 "+;
                                " GROUP BY 1 ","Ventas90")
       ELSE
       
          cmd1=SQLEXEC(lnHandle,"SELECT c.idsqm as Codigo,SUM(b.cantidad) as Todventa FROM detaguiasremision b, guiasremision a,productos c "+;
                                " WHERE a.unico=b.unico AND b.producto=c.codigo AND a.fecha>=?My90 and a.anulada<>1 and a.motivoguia=1 and c.idsqm=?sp1 "+;
                                " GROUP BY 1 ","Ventas90")
       ENDIF 
                                     
       SELECT Ventas90       
       IF RECCOUNT()>0
          ventita=Ventas90.Todventa/3
          SELECT resumen2
          replace Prom90m WITH ventita
       ENDIF 
       SELECT resumen2                                    
   ENDSCAN 
   SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF	

SELECT a.*,b.Prom90m,b.Totalstock FROM Mibase as a LEFT JOIN Resumen2 as b ON a.agrupacion=b.agrupacion  INTO CURSOR totalbase

SELECT totalbase
REPORT FORM infostockspecialfull TO PRINTER PROMPT NODIALOG PREVIEW






 