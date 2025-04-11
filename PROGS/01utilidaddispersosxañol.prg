
SET DELETED ON
SET DATE BRITISH

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sqmsistemas;" + ;
                    "PWD=t1s9m.2712;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
LOCAL Anyo,isDye

Anyo=2016
isDye=1

**** Solo Vta Stock
** Sin BIOREDUCTOR

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0

    cmd1=SQLEXEC(lnHandle," SELECT a.moneda,a.codigoc,b.producto,b.um,(b.cantidad-b.cantidevuelta) as Cantidad,b.precio,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*b.precio,2) as subtotal,d.costo,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*d.costo,2) as SubCosto,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*b.precio,2)-ROUND((b.cantidad-b.cantidevuelta)*d.costo,2) as Utilidad,"+;
    					  " a.estado,a.motivoguia,MONTHNAME(a.fecha) as mes ,YEAR(a.fecha) as anio "+;
                          " FROM factura a,detafacturas b,clientes c,vtalotes d,productos e,tipoproductos f WHERE a.unico=b.unico and a.codigoc=c.codigo and "+;
                          " b.idorigen=d.id and b.producto=e.codigo and e.tipoproducto=f.codigo and YEAR(a.fecha)=?Anyo and (a.serie=1 OR a.serie=4) and a.estado<>'AN' "+;
                          " and a.motivoguia=1 and f.codigo='11' ORDER BY a.serie,a.numero ","MydatitoF")
                          
    cmd2=SQLEXEC(lnHandle," SELECT a.moneda,a.codigoc,b.producto,b.um,(b.cantidad-b.cantidevuelta) as Cantidad,b.precio,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*b.precio,2) as subtotal,d.costo,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*d.costo,2) as SubCosto,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*b.precio,2)-ROUND((b.cantidad-b.cantidevuelta)*d.costo,2) as Utilidad,"+;
    					  " a.estado,a.motivoguia,MONTHNAME(a.fecha) as mes ,YEAR(a.fecha) as anio "+;
                          " FROM boleta a,detaboletas b,clientes c,vtalotes d,productos e,tipoproductos f WHERE a.unico=b.unico and a.codigoc=c.codigo and "+;
                          " b.idorigen=d.id and b.producto=e.codigo and e.tipoproducto=f.codigo and YEAR(a.fecha)=?Anyo AND a.serie=1 AND a.estado<>'AN' "+;
                          " and a.motivoguia=1 and f.codigo='11' ORDER BY a.serie,a.numero ","MydatitoB")                                                    
                          		
	cmd12=SQLEXEC(lnHandle,"SELECT codigo,nombre,grupo FROM Clientes","Xclientes")
	
    cmd13=SQLEXEC(lnHandle,"SELECT * FROM Grupodeclientes","Xgrupos")	
																				                                                                                                                                          
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT codigoc,mes,CAST('VSTOCK' as c(10)) as Tipo,SUM(cantidad),SUM(subtotal),SUM(utilidad) FROM MydatitoF GROUP BY 1,2,3 ORDER BY 1 INTO CURSOR alfa
SELECT codigoc,mes,CAST('VSTOCK' as c(10)) as Tipo,SUM(cantidad),SUM(subtotal),SUM(utilidad) FROM MydatitoB GROUP BY 1,2,3 ORDER BY 1 INTO CURSOR delta

CREATE CURSOR allinone (codigoc c(5),mes c(20),sum_cantidad n(12,2),sum_subtotal n(12,2),sum_utilidad n(12,2),nombre c(50),tipo c(10))

SELECT allinone
APPEND FROM DBF('alfa')
APPEND FROM DBF('delta')

SELECT allinone
SCAN
   a1=ALLTRIM(codigoc)
   SELECT Xclientes
   GO top
   LOCATE FOR ALLTRIM(Xclientes.codigo)=a1
   IF FOUND()
      IF LEN(ALLTRIM(Xclientes.grupo))=0
         b1=ALLTRIM(STRCONV(Xclientes.nombre,11))
         SELECT allinone
         replace nombre WITH b1
      ELSE
         c1=ALLTRIM(Xclientes.grupo)
         SELECT Xgrupos
         GO top
         LOCATE FOR ALLTRIM(Xgrupos.codigo)=c1
         IF FOUND()
            d1=ALLTRIM(STRCONV(Xgrupos.grupo,11))
            SELECT allinone
            replace codigoc WITH c1
            replace nombre WITH d1
         ENDIF               
      ENDIF 
   ENDIF 
   SELECT allinone
ENDSCAN

SELECT allinone
BROWSE


