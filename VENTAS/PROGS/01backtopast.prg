
PUBLIC Mystring_ofi01
Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ; 
           		"SERVER=192.168.1.179;" + ;                                                               		
           		"PORT=3306;" + ;
           		"UID=sistemas;" + ;
           		"PWD=d3b14nfw123;" + ;           		
           		"DATABASE=sqmdata;" + ;                             
           		"OPTIONS=0;"
           		
Myfecha='2017-01-01'
           		
lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0  
    cmd0=SQLEXEC(lnHandle,"SELECT origen,SUM(canti) as Canti FROM "+;
                          "(SELECT b.idorigen AS origen,b.cantidad AS canti FROM factura a, detafacturas b "+;
                          " WHERE a.unico=b.unico AND a.fecha>=?Myfecha AND a.estado<>'AN' UNION "+;
                          " SELECT b.idorigen AS origen,b.cantidad AS canti FROM boleta a, detaboletas b "+;
                          " WHERE a.unico=b.unico AND a.fecha>=?Myfecha AND a.estado<>'AN' UNION "+;
                          " SELECT b.idorigen AS origen,b.cantidad AS canti FROM guiasremision a, detaguiasremision b "+;
                          " WHERE a.unico=b.unico AND a.fecha>=?Myfecha AND a.anulada<>1 AND a.facturada=0 AND a.motivoguia<>7 UNION "+;
                          " SELECT b.unicoorigen AS origen,b.cantidad AS canti FROM mastersalidas a, detallesalidas b "+;
                          " WHERE a.unico=b.unico AND a.fecha>=?Myfecha AND a.anulada<>1 )"+;
                          " AS Resultado  GROUP BY 1 ORDER BY 2 DESC","Resultado")
                          
    cmd0=SQLEXEC(lnHandle,"SELECT * FROM vtalotes WHERE qsaldov>0","MiBase")                        
    
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT Resultado
SCAN  
   v1=Resultado.origen
   v3=Resultado.canti
   SELECT Mibase
   GO TOP 
   LOCATE FOR id=v1
   IF FOUND()
      replace qsaldov WITH qsaldov+v3
      replace qven WITH qven-v3
   ELSE
		lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
		IF lnHandle > 0  		                          
		    cmd0=SQLEXEC(lnHandle,"SELECT * FROM vtalotes WHERE id=?v1","MiUnico")                        		    
		    SQLDISCONNECT(lnHandle)        
		ELSE
		    AERROR(laErr)
		    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
		ENDIF    
		SELECT MiUnico
		IF RECCOUNT()>0
		   SCATTER MEMVAR 
		   SELECT MiBase
		   APPEND BLANK 
		   GATHER MEMVAR 
		   replace qsaldov WITH qsaldov+v3
		   replace qven WITH qven-v3
		ENDIF 
		       
   ENDIF  
   SELECT Resultado    
ENDSCAN 


SELECT Mibase
BROWSE 




