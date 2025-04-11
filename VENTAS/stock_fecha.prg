Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
	"SERVER=192.168.1.179;" + ;
	"PORT=3306;" + ;
	"UID=sistemas;" + ;
	"PWD=d3b14nfw123;" + ;
	"DATABASE=sqmdata;" + ;
	"OPTIONS=0;"

mFecAl = CTOD('31/07/2017')

WAIT WINDOW 'Calculando stock al '+ DTOC(mFecAl)+ ' ...' NoWait
lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle <= 0
	WAIT WINDOW 'No se ha podido contectar con el servidor de Base de datos ...' TIMEOUT 2
	Return
ENDIF

cmd0=SQLEXEC(lnHandle,"SELECT origen, producto, SUM(canti) as Canti FROM "+;
	"(SELECT b.idorigen AS origen, b.producto, b.cantidad AS canti FROM factura a, detafacturas b "+;
	" WHERE a.unico=b.unico AND a.fecha>?mFecAl AND a.estado<>'AN' AND a.anuladaxnc=0 UNION ALL "+;
	" SELECT b.idorigen AS origen, b.producto, b.cantidad AS canti FROM boleta a, detaboletas b "+;
	" WHERE a.unico=b.unico AND a.fecha>?mFecAl AND a.estado<>'AN' AND a.anuladaxnc=0 UNION ALL "+;
	" SELECT b.idorigen AS origen, b.producto, b.cantidad AS canti FROM guiasremision a, detaguiasremision b "+;
	" WHERE a.unico=b.unico AND a.fecha>?mFecAl AND a.anulada<>1 AND a.facturada=0 AND a.motivoguia<>7 UNION ALL "+;
	" SELECT b.unicoorigen AS origen, b.producto, b.cantidad AS canti FROM mastersalidas a, detallesalidas b "+;
	" WHERE a.unico=b.unico AND a.fecha>?mFecAl AND a.anulada<>1 )"+;
	" AS Resultado  GROUP BY 1,2 ORDER BY 3 DESC","cExtornar")
	
cmd1=SQLEXEC(lnHandle,"SELECT * FROM vtalotes WHERE qsaldov>0","MiBase")
cmd2=SQLEXEC(lnHandle,"SELECT * FROM productos","qProductos")
cmd3=SQLEXEC(lnHandle,"SELECT * FROM tipoproductos","qTipoproductos")
cmd4=SQLEXEC(lnHandle,"Select Producto, Max(fecha) as Fecha From Kardex Where Salida > 0 And Fecha <= ?mFecAl Group by producto","cResuKar")


SELECT cExtornar
SCAN
	v1=cExtornar.origen
	v3=cExtornar.canti
	SELECT Mibase
	GO TOP
	LOCATE FOR id=v1
	IF FOUND()
		replace qsaldov WITH qsaldov+v3
		replace qven WITH qven-v3
	ELSE
		cmd0=SQLEXEC(lnHandle,"SELECT * FROM vtalotes WHERE id=?v1","MiUnico")
		
		SELECT MiUnico
		IF RECCOUNT()>0
			IF MiUnico.fingreso<=mFecAl
				SCATTER MEMVAR
				SELECT Mibase
				APPEND BLANK
				GATHER MEMVAR
				replace qsaldov WITH qsaldov+v3
				replace qven WITH qven-v3
			ENDIF
		ENDIF
		USE IN MiUnico
	ENDIF
	SELECT cExtornar
ENDSCAN

SELECT Mibase
SCAN FOR fingreso>mFecAl
	DELETE
ENDSCAN

***************************************************************************************************************************************************

SELECT b.tipoproducto,b.nombre,a.producto AS Codigo, a.origen,a.qsaldov,a.qexterno,a.fingreso,a.lotefab,c.nombre as Tnombre,;
	a.costo,a.ubicacion, a.UM, a.qIng ;
	FROM Mibase as a ;
	LEFT JOIN qProductos as b ON ALLTRIM(a.producto)=ALLTRIM(b.Codigo);
	LEFT JOIN qTipoproductos as c ON b.tipoproducto=c.Codigo ;
	ORDER BY 1,3,6 INTO CURSOR Mistock READWRITE

OPEN DATABASE z:\newcomprassqm\data\sqm.dbc SHARED
SELECT 0
USE z:\newcomprassqm\data\pedidoimp.dbf SHARED
SELECT 0
USE z:\newcomprassqm\data\detallepedido.dbf SHARED
SELECT 0
USE z:\newcomprassqm\data\iembarque.dbf SHARED
SELECT 0
USE z:\newcomprassqm\data\proveedores.dbf SHARED

SELECT Mistock
GO top
SCAN FOR costo=0
	v1=ALLTRIM(Mistock.Codigo)
	Xped=ALLTRIM(Mistock.origen)
	Xprov=SUBSTR(ALLTRIM(Mistock.origen),3,2)

	SELECT a.pu,b.paisembarque as pais FROM sqm!detallepedido as a  LEFT JOIN sqm!iembarque as b;
		ON a.Codigo=b.Codigo ;
		WHERE a.producto=v1 AND a.Codigo=Xped  INTO ARRAY Mypu

	IF _tally <>0
		IF Xprov<>"F0"
			SELECT a.fletestandar,a.factordes FROM sqm!proveedores as a WHERE a.Codigo=Xprov INTO ARRAY Myval
		ELSE
			IF Mypu(1,2)="TW"
				SELECT a.fletestandar2,a.factordes FROM sqm!proveedores as a WHERE a.Codigo=Xprov INTO ARRAY Myval
			ELSE
				SELECT a.fletestandar,a.factordes FROM sqm!proveedores as a WHERE a.Codigo=Xprov INTO ARRAY Myval
			ENDIF
		ENDIF
		replace Mistock.costo WITH ROUND((Mypu(1,1)+Myval(1,1))*Myval(1,2),2)
	ENDIF
ENDSCAN

SELECT proveedores
USE
SELECT iembarque
USE
SELECT detallepedido
USE
SELECT pedidoimp
USE

SQLDISCONNECT(lnHandle)

Select S.Codigo, P.Nombre, S.UM, MIN(S.FIngreso) as FIngreso, SUM(S.qing) as Ingresos, SUM(S.qsaldoV) as Stock, ;
  	Max(K.Fecha) as UltFSalida From Mistock S ;
	LEFT JOIN cResuKar K On S.Codigo = K.Producto ;
	inner join qProductos P on S.Codigo = P.Codigo ;
	inner join qTipoproductos TP on P.tipoproducto = TP.Codigo ;
	Where S.qsaldoV > 0 and TP.Superclase = 1 ;
	Group by S.Codigo, S.UM, P.Nombre INTO CURSOR cTmpRes
	
Select *, mFecAl - IIF(Empty(UltFSalida) OR ISNULL(UltFSalida), FIngreso, UltFSalida) as Dias FROM cTmpRes INTO CURSOR cResultado

USE IN cTmpRes

USE IN cExtornar
USE IN MiBase
USE IN qProductos
USE IN qTipoproductos
USE IN cResuKar
USE IN Mistock

Return