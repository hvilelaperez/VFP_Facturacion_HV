*!*	SET DELETED ON
*!*	SET DATE BRITISH
*!*	SET TALK OFF

*!*	OPEN DATABASE Z:\newcompras\data\sqm.dbc SHARED

*!*	SELECT 0
*!*	USE Z:\newcompras\data\pedidoimp.dbf SHARED

*!*	SELECT 0
*!*	USE Z:\newcompras\data\proveedores.dbf SHARED

*!*	SELECT b.nombre,MONTH(a.fechapedido) as mes,COUNT(*) as numero FROM pedidoimp as a LEFT JOIN proveedores as b ON a.proveedor=b.codigo ;
*!*	       WHERE YEAR(fechapedido)=2015 AND anulado<>.t. AND tipoembarque<>'P' GROUP BY 1,2 INTO CURSOR midato       

*!*	SELECT midato
*!*	BROWSE 

 


