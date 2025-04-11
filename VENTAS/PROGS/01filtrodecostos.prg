
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
                                                       
    cmd1=SQLEXEC(lnHandle,"SELECT a.id,a.fingreso,a.producto,b.nombre,a.origen,a.ubicacion,a.qsaldov,a.qreserva,a.qstandby,a.quarantine,a.qexterno,a.um,a.costo,"+;
						  "(c.pcargasuelta+d.fletestandar)*d.factordes AS PreRepo,a.lotefab "+;
						  "FROM vtalotes a "+;
						  "LEFT JOIN productos b ON a.producto=b.codigo "+;
						  "LEFT JOIN im_historiaprecios c ON a.producto=c.codigo AND c.actual=1 "+;
						  "LEFT JOIN proveedores d ON SUBSTR(a.producto,3,2)=d.codigo "+;
						  "WHERE a.qsaldov>0 AND SUBSTRING(a.producto,1,2)='11' AND a.costo<>0 AND b.proveedor<>'10' AND proveedor<>'W0' ORDER BY a.producto,a.costo DESC","Mydato")
						  						  						      					       
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Mydato

REPORT FORM 01filtrodecostos FOR costo-prerepo>=2 TO PRINTER PROMPT NODIALOG PREVIEW
 


