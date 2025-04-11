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
                    
OPEN DATABASE f:\newcompras\data\sqm SHARED
 
SELECT 0 
USE f:\newcompras\data\pedidoimp SHARED

SELECT 0
USE f:\newcompras\data\detallepedido SHARED                  
                    
LOCAL Pasado,Hoy,Mipro,DayOne,Saldazo,Nombrazo
Hoy=DATE()
Pasado=Hoy-180  && Aprox 6 Meses atras  
Futuro=Hoy+90             
MiPro='02F0FT'
DayOne=CTOD('01'+'/'+TRANSFORM(MONTH(Pasado),"@l 99")+'/'+STR(YEAR(Pasado),4,0))

CREATE CURSOR Mitrash (Micampo d, Ctrl c(1))
CREATE CURSOR Matriz (Nombre c(85))


as1=Hoy-DayOne
FOR i = 0 TO as1
    SELECT Mitrash
    APPEND BLANK
    replace Micampo WITH dayone+i
    replace ctrl WITH 'A'
ENDFOR 

as2=Futuro-Hoy
FOR j = 0 TO as2
    SELECT Mitrash
    APPEND BLANK 
    replace Micampo WITH Hoy+j
    replace ctrl WITH 'D'
ENDFOR     

SELECT distinct 'C'+STR(YEAR(Micampo),4)+'_'+TRANSFORM(MONTH(Micampo),"@l 99")+'_'+ctrl as Clase;
       FROM mitrash INTO CURSOR resumen

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

      cmd0=SQLEXEC(lnHandle,"SELECT * FROM clientes ","Xclientes")
      cmd1=SQLEXEC(lnHandle,"SELECT nombre FROM productos WHERE codigo=?Mipro ","Midetalle")      
      cmd2=SQLEXEC(lnHandle,"SELECT SUM(qsaldov) AS Saldo FROM vtalotes WHERE producto=?Mipro and qsaldov>0 and sobrepedido<>1 ","Pas1")
    
      cmd3=SQLEXEC(lnHandle,"SELECT CAST(MONTH(a.fllegadaaduana) AS UNSIGNED) AS Mes1,MONTHNAME(a.fllegadaaduana) AS Mes,"+;
                            "YEAR(a.fllegadaaduana) AS anio,CONCAT(c.codigo,'-',c.nombre) as nombre,SUM(b.cantidad) AS total,'SI' AS Tipo "+;
                            "FROM x_xpedidosdirectos a,x_xdetallepedirecto b,clientes c "+;                            
							"WHERE a.codigo=b.codigo AND a.cliente=c.codigo AND a.fllegadaaduana>?DayOne "+;
							"AND b.producto=?Mipro AND a.terminado=1 AND a.anulado<>1 GROUP BY 1,2,3,4 "+;
							"UNION "+;
							"SELECT CAST(MONTH(a.fllegadaaduana) AS UNSIGNED) AS Mes1,MONTHNAME(a.fllegadaaduana) AS Mes, "+;
							"YEAR(a.fllegadaaduana) AS anio,CONCAT(c.codigo,'-',c.nombre) as nombre,SUM(b.cantidad) AS total, 'NO' AS Tipo "+;
							"FROM x_xpedidosdirectos a,x_xdetallepedirecto b,clientes c  "+;							
							"WHERE a.codigo=b.codigo AND a.cliente=c.codigo AND a.fllegadaaduana>?DayOne "+;
							"AND b.producto=?Mipro AND a.coprol=1 AND Terminado<>1 AND anulado<>1 GROUP BY 1,2,3,4 "+;
							"ORDER BY 3,1 ","MiBase0") 							 
		 					                                               
      SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Pas1
GO top
Saldazo=Pas1.saldo

SELECT Midetalle
GO top
Nombrazo=STRCONV(Midetalle.nombre,11)

SELECT MONTH(a.fechaalmacen) as Mes1, cMONTH(a.fechaalmacen) as Mes, YEAR(a.fechaalmacen) as Anio, ;
       ALLTRIM(c.codigo)+'-'+c.nombre as nombre, SUM(b.cantidad) as total ,'SI' as Tipo ;
       FROM  Pedidoimp as a ;
       LEFT JOIN detallepedido as b on a.codigo=b.codigo ;       
       LEFT JOIN xclientes as c on a.vscliente=c.codigo ;
       WHERE a.fechaalmacen>=Dayone AND b.producto=Mipro AND Anulado<>.t. AND terminado=.t. AND ;
       vsucesiva=1 GROUP BY 1,2,3,4 ORDER BY 2,1 INTO CURSOR Mibasea
       
SELECT MONTH(a.fechaalmacen) as Mes1, cMONTH(a.fechaalmacen) as Mes, YEAR(a.fechaalmacen) as Anio, ;
       ALLTRIM(c.codigo)+'-'+c.nombre as nombre, SUM(b.cantidad) as total ,'NO' as Tipo ;
       FROM  Pedidoimp as a ;
       LEFT JOIN detallepedido as b on a.codigo=b.codigo ;       
       LEFT JOIN xclientes as c on a.vscliente=c.codigo ;
       WHERE a.fechaalmacen>=Dayone AND a.fechaalmacen<=Futuro AND b.producto=Mipro AND Anulado<>.t. AND terminado<>.t. ;
       AND vsucesiva=1 GROUP BY 1,2,3,4 ORDER BY 2,1 INTO CURSOR Mibaseb   
 
SELECT MONTH(a.fechaalmacen) as Mes1, cMONTH(a.fechaalmacen) as Mes, YEAR(a.fechaalmacen) as Anio, ;
       '1_SQM' AS nombre, SUM(b.cantidad) as total ,'SI' as Tipo ;
       FROM  Pedidoimp as a ;
       LEFT JOIN detallepedido as b on a.codigo=b.codigo ;              
       WHERE a.fechaalmacen>=Dayone AND b.producto=Mipro AND Anulado<>.t. AND terminado=.t. AND ;
       vsucesiva<>1 GROUP BY 1,2,3,4 ORDER BY 2,1 INTO CURSOR MibaseaSqm
       
SELECT MONTH(a.fechaalmacen) as Mes1, cMONTH(a.fechaalmacen) as Mes, YEAR(a.fechaalmacen) as Anio, ;
       '1_SQM' AS nombre, SUM(b.cantidad) as total ,'NO' as Tipo ;
       FROM  Pedidoimp as a ;
       LEFT JOIN detallepedido as b on a.codigo=b.codigo ;              
       WHERE a.fechaalmacen>=Dayone AND a.fechaalmacen<=Futuro AND b.producto=Mipro AND Anulado<>.t. AND terminado<>.t. ;
       AND vsucesiva<>1 GROUP BY 1,2,3,4 ORDER BY 2,1 INTO CURSOR MibasebSqm   
       
CREATE CURSOR Mibase (mes1 n(2,0),mes c(12),anio n(4,0),nombre c(85), total n(10,2),tipo c(2))
SELECT Mibase
APPEND FROM DBF('Mibase0')                 
APPEND FROM DBF('Mibasea')
APPEND FROM DBF('Mibaseb')
APPEND FROM DBF('Mibaseasqm')
APPEND FROM DBF('Mibasebsqm')
       
SELECT distinct STRCONV(nombre,11) as Tnom FROM Mibase INTO CURSOR Xchange

SELECT resumen 
SCAN 
   Passe=Clase
   ALTER table Matriz ADD COLUMN &Passe c(150) &&N(10,2)
ENDSCAN 

SELECT Xchange
GO top
SCAN
    SELECT Matriz
    APPEND BLANK 
    replace nombre WITH Xchange.Tnom
ENDSCAN

SELECT Mibase
SCAN 
   as1=ALLTRIM(STRCONV(Nombre,11))
   a2='C'+STR(anio,4)+'_'+TRANSFORM(mes1,"@l 99")+IIF(tipo='SI','_A','_D')
   a3=total
   SELECT Matriz
   GO top
   LOCATE FOR ALLTRIM(nombre)=as1
   IF FOUND()
      Xby=(a2)
      Xbx=ALLTRIM(STR(VAL(Xby)+a3,11,2))
      replace &a2 WITH Xbx
      *replace &a2 WITH &a2+a3
   ENDIF
   SELECT Mibase
ENDSCAN       

SELECT Matriz
gnFieldcount = AFIELDS(gaMyArray)  && Create array.
    
SELECT Matriz 
GO top
SCAN 
    IF nombre<>'1_SQM'
       FOR w= 2 TO GnFieldcount 
           ad=EVALUATE(GaMyarray(w,1))                                                                            
           IF VAL(ad)>0
              IF UPPER(RIGHT(ALLTRIM(GaMyarray(w,1)),1))='D'
                	ctp1=VAL(SUBSTR(GaMyarray(w,1),2,4)) && año
                	ctp2=VAL(SUBSTR(GaMyarray(w,1),7,2)) && mes
                	ctp3=ALLTRIM(SUBSTR(nombre,1,4))  
                	      
					lnHandle = SQLSTRINGCONNECT(Mystring)
					IF lnHandle > 0
				
      					cmd0=SQLEXEC(lnHandle,"SELECT a.fllegadaaduana as Mes1,b.cantidad,a.codigo as Ped "+;       				
							  	  "FROM x_xpedidosdirectos a,x_xdetallepedirecto b "+;							
							   	  "WHERE a.codigo=b.codigo AND MONTH(a.fllegadaaduana)=?ctp2 "+;
							  	  "AND YEAR(a.fllegadaaduana)=?ctp1 AND b.producto=?Mipro AND a.terminado<>1 "+;
							   	  "and TRIM(a.cliente)=?ctp3 AND a.coprol=1 AND A.anulado<>1 ","Flag01")
					ELSE
   						AERROR(laErr)
    					MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
					ENDIF
					
					SELECT a.fechaalmacen as Mes1,b.cantidad,a.codigo as Ped ;
       				FROM  Pedidoimp as a ;
       				LEFT JOIN detallepedido as b on a.codigo=b.codigo ;              				
       				WHERE MONTH(a.fechaalmacen)=ctp2 AND YEAR(a.fechaalmacen)=ctp1 AND a.vscliente=ctp3 ;       				
       			    AND b.producto=Mipro AND Anulado<>.t. AND Terminado<>.t. ;       			    
       				AND vsucesiva=1  INTO CURSOR Flag02 
       															
				    SELECT Flag01
				    APPEND FROM DBF('Flag02')
				    
				    SELECT * FROM Flag01 ORDER BY Mes1 DESC INTO CURSOR Phaser
				    SELECT Phaser				    				    				    
				    GO top				  				    				    
				    cad1=''
				    SCAN
				       cad1=cad1+' // '+ALLTRIM(STR(cantidad,10,2))+' _ '+DTOC(Mes1)+' _ '+ALLTRIM(Ped)+CHR(13)
				    ENDSCAN
				    				    
				    SELECT Matriz 
				    replace &GaMyarray(w,1) WITH cad1 										                                                      
              ENDIF    
           ENDIF 
       ENDFOR 
                     
    ELSE 

       FOR w= 2 TO GnFieldcount 
           ad=EVALUATE(GaMyarray(w,1))                                                                            
           IF VAL(ad)>0
              IF UPPER(RIGHT(ALLTRIM(GaMyarray(w,1)),1))='D'
                	ctp1=VAL(SUBSTR(GaMyarray(w,1),2,4)) && año
                	ctp2=VAL(SUBSTR(GaMyarray(w,1),7,2)) && mes
                	                 	      
				    SELECT a.fechaalmacen as Mes1,b.cantidad,a.codigo as ped FROM  Pedidoimp as a ;
       				LEFT JOIN detallepedido as b on a.codigo=b.codigo ;              				
       				WHERE MONTH(a.fechaalmacen)=ctp2 AND YEAR(a.fechaalmacen)=ctp1  ;       				
       			    AND b.producto=Mipro AND Anulado<>.t. AND Terminado<>.t. ;       			    
       				AND vsucesiva<>1  INTO CURSOR Flag01
       				        															
				    SELECT Flag01
				    				    
				    SELECT * FROM Flag01 ORDER BY Mes1 DESC INTO CURSOR Phaser
				    SELECT Phaser				    				    				    
				    GO top				  				    				    
				    cad1=''
				    SCAN
				       cad1=cad1+' // '+ALLTRIM(STR(cantidad,10,2))+' _ '+DTOC(Mes1)+' _ '+ALLTRIM(Ped)+CHR(13)
				    ENDSCAN
				    				    
				    SELECT Matriz 
				    replace &GaMyarray(w,1) WITH cad1 										                                                      
              ENDIF    
           ENDIF 
       ENDFOR     
                     
    ENDIF 
    
    SELECT Matriz     
ENDSCAN 
  
        
REPORT FORM horizonte PREVIEW  

SELECT pedidoimp
USE
SELECT detallepedido
USE 


                        