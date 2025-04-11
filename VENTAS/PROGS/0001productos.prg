
SET DELETED ON
SET DATE BRITISH
SET TALK OFF

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=d3b14nfw123;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
                    
lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle > 0
                                                       
    *cmd1=SQLEXEC(lnHandle,"SELECT a.producto,b.nombre,a.lotefab,a.qsaldov as saldo,a.qreserva,a.qstandby,a.quarantine,a.qsaldov-(a.qreserva+a.qstandby+a.quarantine+a.qexterno) as disponible,"+;
                          "a.qexterno,a.ubicacion FROM vtalotes a,productos b,tipoproductos c "+;
                          "WHERE a.producto=b.codigo AND b.tipoproducto=c.codigo AND c.escolorante=1 AND a.qsaldov>0 ORDER BY a.producto","MyCursor")	
                          
    md1=SQLEXEC(lnHandle,"SELECT producto,cantidad,precio,subtotal,ROUND(subtotal*(18/100),10,2) as igvamout FROM detafacturas where unico=10684","aviso")
    
                              				  						  						      					       
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT aviso
BROWSE 

*!*	SELECT MyCursor
*!*	COPY TO c:\ventas\MisProductos.xls xls

