


OPEN DATABASE f:\newcompras\data\sqm SHARED

SELECT 0
USE pedidoimp SHARED

SELECT 0
USE detallepedido SHARED

as1='02F0F7'


	 SELECT a.producto,a.codigo,a.saldo,a.um,b.fechapedido,b.fechaalmacen,b.tipopedido,;
      	   IIF(b.tipoembarque="C","C0NTAINER",IIF(b.tipoembarque="P","Parcial","Consolidado")) as Emba;
	       FROM detallepedido as a ;
    	   LEFT JOIN pedidoimp as b ON a.codigo=b.codigo;
	       WHERE  ALLTRIM(a.producto)=ALLTRIM(as1) AND b.anulado<>.t. AND b.terminado<>.t. AND a.saldo<>0 AND b.vsucesiva<>1 ;
	       ORDER BY b.fechaalmacen,b.tipopedido INTO CURSOR BBC READWRITE 
	       
SELECT BBC
BROWSE


CLOSE DATABASES	       