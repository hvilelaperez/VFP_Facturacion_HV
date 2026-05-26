
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

Anyo=2018
isDye=1  && 0= No colorantes, 1= Colorantes  (excluir el tipo 12 - auxiliares). Cambiar temporalmente, segun indicacion del manual excel (sistemas wilder.xlsx).

** Sin BIOREDUCTOR

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0

    cmd1=SQLEXEC(lnHandle," SELECT a.moneda,a.codigoc,b.producto,b.um,(b.cantidad-b.cantidevuelta) as Cantidad,b.precio,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*b.precio,2) as subtotal,d.costo,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*d.costo,2) as SubCosto,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*b.precio,2)-ROUND((b.cantidad-b.cantidevuelta)*d.costo,2) as Utilidad,"+;
    					  " a.estado,a.motivoguia,MONTHNAME(a.fecha) as mes ,YEAR(a.fecha) as anio "+;
                          " FROM factura a,detafacturas b,clientes c,vtalotes d,productos e,tipoproductos f WHERE a.unico=b.unico and a.codigoc=c.codigo and "+;
                          " b.idorigen=d.id and b.producto=e.codigo and e.tipoproducto=f.codigo and YEAR(a.fecha)=?Anyo and (a.serie=1 OR a.serie=4 OR a.serie=10 OR a.serie=40 OR a.serie=70) and a.estado<>'AN' And a.anuladaxnc <> 1 "+;
                          " and a.motivoguia=1 and f.escolorante=?isDye and b.producto<>'12W09L' and b.producto<>'12W09Z' order by a.serie,a.numero ","MydatitoF")


                          
    cmd2=SQLEXEC(lnHandle," SELECT a.moneda,a.codigoc,b.producto,b.um,(b.cantidad-b.cantidevuelta) as Cantidad,b.precio,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*b.precio,2) as subtotal,d.costo,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*d.costo,2) as SubCosto,"+;
    					  " ROUND((b.cantidad-b.cantidevuelta)*b.precio,2)-ROUND((b.cantidad-b.cantidevuelta)*d.costo,2) as Utilidad,"+;
    					  " a.estado,a.motivoguia,MONTHNAME(a.fecha) as mes ,YEAR(a.fecha) as anio "+;
                          " FROM boleta a,detaboletas b,clientes c,vtalotes d,productos e,tipoproductos f WHERE a.unico=b.unico and a.codigoc=c.codigo and "+;
                          " b.idorigen=d.id and b.producto=e.codigo and e.tipoproducto=f.codigo and YEAR(a.fecha)=?Anyo AND (a.serie=1 OR a.serie=10) AND a.estado<>'AN' And a.anuladaxnc <> 1 "+;
                          " and a.motivoguia=1 and f.escolorante=?isDye and b.producto<>'12W09L' and b.producto<>'12W09Z' order by a.serie,a.numero ","MydatitoB")                                                    
                          
    *cmd10=SQLEXEC(lnHandle,"SELECT a.cliente as codigoc,b.producto,b.cantidad,b.precio,b.fobsqm,(b.precio*b.cantidad) AS Subtotal,((b.precio-b.fobsqm)*b.cantidad) AS Utilidad,"+;
						   "MONTHNAME(a.fechapedido) as mes,YEAR(a.fechapedido) as anio "+;
						   "FROM x_xpedidosdirectos a, x_xdetallepedirecto b,productos c,tipoproductos d WHERE a.codigo=b.codigo "+;
						   "AND c.codigo=b.producto AND c.tipoproducto=d.codigo AND YEAR(a.fechapedido)=?anyo AND d.escolorante=?isDye "+;
						   "AND a.anulado<>1  AND a.coprol=1","YbaseP") 
						       
    cmd10=SQLEXEC(lnHandle,"SELECT a.cliente as codigoc,b.producto,b.cantidad,b.precio,b.fobsqm,(b.precio*b.cantidad) AS Subtotal,((b.precio-b.fobsqm)*b.cantidad) AS Utilidad,"+;
						   "MONTHNAME(a.coprof) as mes,YEAR(a.coprof) as anio "+;
						   "FROM x_xpedidosdirectos a, x_xdetallepedirecto b,productos c,tipoproductos d WHERE a.codigo=b.codigo "+;
						   "AND c.codigo=b.producto AND c.tipoproducto=d.codigo AND YEAR(a.coprof)=?anyo AND d.escolorante=?isDye "+;
						   "AND a.anulado<>1  AND a.coprol=1","YbaseP")  						                        

    cmd11=SQLEXEC(lnHandle,"SELECT a.cliente as codigoc,b.producto,b.cantidad,(b.cantidad*b.precioventa) AS Subtotal, "+;
							"((b.precioventa-b.preciofob)*b.cantidad) AS Utilidad, "+;
							"MONTHNAME(a.ffecha) as mes,YEAR(a.ffecha) as anio  FROM im_vsucesiva a,"+;
							"im_detallevsucesiva b ,productos c,tipoproductos d WHERE a.pedido=b.codigo "+;
							"AND c.codigo=b.producto AND c.tipoproducto=d.codigo AND YEAR(a.ffecha)=?anyo AND d.escolorante=?isDye AND a.anulado<>1 ","YBaseVs")	
	
	cmd12=SQLEXEC(lnHandle,"SELECT codigo,nombre,grupo FROM Clientes","Xclientes")
	
    cmd13=SQLEXEC(lnHandle,"SELECT * FROM Grupodeclientes","Xgrupos")	
																				                                                                                                                                          
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT codigoc,mes,CAST('VSTOCK' as c(10)) as Tipo,SUM(cantidad),SUM(subtotal),SUM(utilidad) FROM MydatitoF GROUP BY 1,2,3 ORDER BY 1 INTO CURSOR alfa
SELECT codigoc,mes,CAST('VSTOCK' as c(10)) as Tipo,SUM(cantidad),SUM(subtotal),SUM(utilidad) FROM MydatitoB GROUP BY 1,2,3 ORDER BY 1 INTO CURSOR delta
SELECT codigoc,mes,CAST('PDIRECTO' as c(10)) as Tipo,SUM(cantidad),SUM(subtotal),SUM(utilidad) FROM YBaseP GROUP BY 1,2,3 ORDER BY 1 INTO CURSOR beta
SELECT codigoc,mes,CAST('VSUCESIVA' as c(10)) as Tipo,SUM(cantidad),SUM(subtotal),SUM(utilidad) FROM YBaseVs GROUP BY 1,2,3 ORDER BY 1 INTO CURSOR gamma

CREATE CURSOR allinone (codigoc c(5),mes c(20),sum_cantidad n(12,2),sum_subtotal n(12,2),sum_utilidad n(12,2),nombre c(50),tipo c(10))

SELECT allinone
APPEND FROM DBF('alfa')
APPEND FROM DBF('delta')
APPEND FROM DBF('beta')
APPEND FROM DBF('gamma')

SELECT allinone
SCAN
   a1=ALLTRIM(codigoc)
   SELECT Xclientes
   GO top
   LOCATE FOR ALLTRIM(Xclientes.codigo)=a1
   IF FOUND()
      IF LEN(ALLTRIM(Xclientes.grupo))=0
         b1=ALLTRIM(Xclientes.nombre)
         SELECT allinone
         replace nombre WITH b1
      ELSE
         c1=ALLTRIM(Xclientes.grupo)
         SELECT Xgrupos
         GO top
         LOCATE FOR ALLTRIM(Xgrupos.codigo)=c1
         IF FOUND()
            d1=ALLTRIM(Xgrupos.grupo)
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


