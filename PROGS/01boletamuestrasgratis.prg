
SET DELETED ON
SET DATE BRITISH


Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sqmsistemas;" + ;
                    "PWD=t1s9m.2712;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

PUBLIC xp_ini1,xp_fin1

xp_ini1=CTOD('01/02/2016')
xp_fin1=CTOD('26/02/2016')


lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle > 0
                                                       
    cmd1=SQLEXEC(lnHandle,"SELECT a.fecha,a.serie,a.numero,c.nombre,d.nombre,b.cantidad,b.precio,b.subtotal,e.costo "+;
						  "FROM boleta a,detaboletas b,clientes c,productos d, vtalotes e "+;
						  "WHERE a.unico=b.unico AND a.codigoc=c.codigo AND b.producto=d.codigo AND b.idorigen=e.id "+;
					      "AND a.fecha BETWEEN ?xp_ini1 AND ?xp_fin1 AND a.condipag='MG' ORDER BY a.codigoc,a.fecha ","Mydato")
           						      					       
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Mydato
REPORT FORM 01boletasmg1 TO PRINTER PROMPT NODIALOG PREVIEW
