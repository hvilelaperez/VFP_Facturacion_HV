SET DEFAULT TO f:\newcompras\data
OPEN DATABASE f:\newcompras\data\sqm.dbc SHARED

SELECT 0
USE f:\newcompras\data\pedidoimp.dbf SHARED
SELECT 0
USE f:\newcompras\data\iembarque.dbf SHARED

*SELECT a.codigo,a.proveedor,a.fechapedido,a.fecconfirma,b.fecembarque,a.fechaestimada as fechallegada,b.paisembarque,(b.fecembarque-a.fecCONFIRMA) as dias ;
FROM pedidoimp as a ;
LEFT JOIN iembarque as b ON a.codigo=b.codigo ;
WHERE YEAR(a.fechapedido)=2015 AND anulado<>.t. AND vsucesiva<>1 AND a.tipoembarque<>'P' AND a.tipopedido='M' INTO CURSOR final

SELECT a.proveedor,AVG((b.fecembarque-a.fecCONFIRMA)) as dias ;
FROM pedidoimp as a ;
LEFT JOIN iembarque as b ON a.codigo=b.codigo ;
WHERE YEAR(a.fechapedido)=2015 AND anulado<>.t. AND vsucesiva<>1 AND a.tipoembarque<>'P' AND a.tipopedido='M' GROUP BY 1 INTO CURSOR final

*SELECT AVG((b.fecembarque-a.fecCONFIRMA)) as dias ;
FROM pedidoimp as a ;
LEFT JOIN iembarque as b ON a.codigo=b.codigo ;
WHERE YEAR(a.fechapedido)=2016 AND anulado<>.t. AND vsucesiva<>1 AND a.tipoembarque<>'P' AND a.tipopedido='M' INTO CURSOR final

SELECT final
BROWSE

SELECT iembarque
USE
SELECT pedidoimp
USE
