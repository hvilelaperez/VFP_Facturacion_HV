SET DELETED ON

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
	"SERVER=192.168.1.179;" + ;
	"PORT=3306;" + ;
	"UID=sistemas;" + ;
	"PWD=d3b14nfw123;" + ;
	"DATABASE=sqmdata;" + ;
	"OPTIONS=0;"

mFecIni= CTOD('19/05/2017')
mFecFin= CTOD('21/06/2017')

CREATE CURSOR cKardex (TipoProd C(50), Producto C(7), DesProd C(100), UM C(6), Origen C(9), LoteFab C(25), FIngreso D, Fecha D, TipoMov C(1), TD  C(2), NumDoc C(15), Glosa C(100), ;
						SIni_Can N(10,2), SIni_Sol N(10,2), SIni_Dol N(10,2), ICom_Can N(10,2), ICom_Sol N(10,2), ICom_Dol N(10,2), IAju_Can N(10,2), IAju_Sol N(10,2), IAju_Dol N(10,2), IVen_Can N(10,2), IVen_Sol N(10,2), IVen_Dol N(10,2), ;
						SVen_Can N(10,2), SVen_Sol N(10,2), SVen_Dol N(10,2), SAjuGas_Can N(10,2), SAjuGas_Sol N(10,2), SAjuGas_Dol N(10,2), SAjuOtr_Can N(10,2), SAjuOtr_Sol N(10,2), SAjuOtr_Dol N(10,2), ;
						CU_Sol N(12,4), CU_Dol N(10,4), Precio N(10,2), id_vtalotes N(7,0))

INDEX on Producto+ Origen+ DTOS(Fecha) TAG ProdFec


DO Carga_Saldo_Inicial WITH mFecIni- 1
DO Carga_Movimientos WITH mFecIni, mFecFin

SELECT cKardex
GO top
REPORT FORM KardexValorizado NOCONSOLE PREVIEW
REPORT FORM KardexValorizado NOCONSOLE TO PRINTER prompt

susp


*DO ValKardex_Lote

*DO ValKar_CProm


RETURN



PROCEDURE ValKardex_Lote
WAIT WINDOW 'Valorizando los movimientos del kardex con costo específico por lote ...' NoWait

lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle <= 0
	WAIT WINDOW 'No se ha podido contectar con el servidor de Base de datos ...' TIMEOUT 2
	Return
ENDIF
cmd0 = SQLEXEC(lnHandle,"SELECT Fecha, Venta FROM tcoficial","cTC")
cmd1 = SQLEXEC(lnHandle,"SELECT codigo, nombre From tipoproductos where inventario = 1","cTipoProd")
cmd2 = SQLEXEC(lnHandle,"SELECT id, fingreso, producto, costo From vtalotes","cVtaLotes")

SQLDISCONNECT(lnHandle)


SELECT cTC
INDEX on DTOS(Fecha) TAG Fecha

SELECT cTipoProd
INDEX on Codigo TAG Codigo

SELECT cVtaLotes
INDEX on id TAG IDLote

SELECT cKardex
GO top
DO WHILE !EOF()
	SCATTER MEMVAR Field producto
	SCAN WHILE Producto = m.Producto
		SCATTER Memvar
		IF Tipo = 'I'
			=SEEK(DTOS(m.FIngreso), 'cTC')
			mTC_Venta= cTC.Venta
			IF mTC_Venta = 0
				MESSAGEBOX('No existe tipo de cambio para el día '+ DTOC(m.Fecha), 0+48, 'Error')
				mTC_Venta = 3.25
			ENDIF
			mCU_Sol  = CU_Dol * mTC_Venta
			mCT_Sol  = ROUND(Cantidad * mCU_Sol, 2)
		ELSE
			mCU_Sol  = 0
			mCT_Sol  = 0
			IF SEEK(m.id_vtaslote, 'cVtaLotes')
				IF ALLTRIM(cVtaLotes.producto) = ALLTRIM(m.Producto)
					mFIng = cVtaLotes.FIngreso
					=SEEK(DTOS(m.Fecha), 'cTC')
					mTC_Venta= cTC.Venta
					IF mTC_Venta = 0
						MESSAGEBOX('No existe tipo de cambio para el día '+ DTOC(mFIng)+ ' (Salidas)', 0+48, 'Error')
						mTC_Venta = 3.25
					ENDIF
					mCU_Sol  = cVtaLotes.Costo * mTC_Venta
					mCT_Sol  = ROUND(Cantidad * mCU_Sol, 2)
				ELSE
					MESSAGEBOX('Error de inconsistencia. El articulo del stock no coincide con el artículo de la salida'+ CHR(13)+ 'Se suspende el programa para revisar...', 0+48, 'Error grave')
					susp
				ENDIF
			ELSE
				MESSAGEBOX('Error de inconsistencia. El id de stock en el movimiento de salida no existe en la tabla de stock'+ CHR(13)+ 'Se suspende el programa para revisar...', 0+48, 'Error grave')
				susp
			ENDIF
		ENDIF
		Replace CU_Sol WITH mCU_Sol, CT_Sol WITH mCT_Sol
		
		IF SEEK(m.CodTipArt, 'cTipoProd')
			Replace DesTipArt WITH cTipoProd.Nombre
		ELSE
			Replace DesTipArt WITH 'NO INVENTARIABLE'
		ENDIF
	ENDSCAN
ENDDO

WAIT WINDOW 'Valorizando los movimientos del kardex con costo específico por lote ...' TIMEOUT 1

RETURN



PROCEDURE Carga_Movimientos
LPARAMETERS mFecIni, mFecFin
WAIT WINDOW 'Cargando los movimientos del rango de fechas... ' NoWait

lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle <= 0
	WAIT WINDOW 'No se ha podido contectar con el servidor de Base de datos ...' TIMEOUT 2
	Return
ENDIF


cmd1 = SQLEXEC(lnHandle,"Select 'I' as TipoMov, Case When s.TipoOrigen= 'D' Then 'VD' Else 'VI' End as TD, s.fingreso as fecha, s.producto, p.nombre as DesProd, tp.nombre as TipoProd, "+ ;
	"IF(s.TipoOrigen= 'W' or s.TipoOrigen= 'I', s.qing, 0000000.00) as ICom_Can, IF(s.TipoOrigen= 'W' or s.TipoOrigen= 'I', ROUND(s.qing* s.CostoSol, 2), 0000000.00) as ICom_Sol, "+ ;
	"IF(s.TipoOrigen= 'W' or s.TipoOrigen= 'I', ROUND(s.qing* s.Costo, 2), 0000000.00) as ICom_Dol, IF(s.TipoOrigen= 'W' or s.TipoOrigen= 'I' or s.TipoOrigen= 'D', 0000000.00, s.qing) as IAju_Can, "+ ;
	"IF(s.TipoOrigen= 'W' or s.TipoOrigen= 'I' or s.TipoOrigen= 'D', 0000000.00, ROUND(s.qing * s.CostoSol, 2)) as IAju_Sol, IF(s.TipoOrigen= 'W' or s.TipoOrigen= 'I' or s.TipoOrigen= 'D', 0000000.00, ROUND(s.qing * s.Costo,2)) as IAju_Dol, "+	;
	"IF(s.TipoOrigen= 'D', s.qing, 0000000.00) as IVen_Can, IF(s.TipoOrigen= 'D', ROUND(s.qing * s.CostoSol, 2), 0000000.00) as IVen_Sol, IF(s.TipoOrigen= 'D', ROUND(s.qing* s.Costo, 2), 0000000.00) as IVen_Dol, s.um, s.id as id_vtalotes, "+ ; 
	"Case When s.TipoOrigen= 'D' Then 'DEVOLUCION DE VENTA' Else tt.nombre End as Glosa, s.Origen, s.FIngreso, s.LoteFab, s.Costo as CU_Dol, s.CostoSol as CU_Sol "+ ;	
	"From vtalotes s "+ ;
	"Left join tipotransaccion tt on tt.codigo = s.tipoorigen "+ ;
	"INNER JOIN Productos p on p.Codigo = s.Producto "+ ;
	"INNER JOIN tipoproductos tp ON p.TipoProducto = tp.Codigo "+ ;
	"Where fingreso >= ?mFecIni And fingreso <= ?mFecFin And tp.inventario = 1", "cIngresos")	

	
cmd2 = SQLEXEC(lnHandle, "Select 'S' as TipoMov, 'FA' as TD, concat(fc.cpe,CAST(fc.serie as char(4)),'-', CAST(fc.numero as char(7))) as NumDoc, fc.fecha, fd.producto, p.nombre as DesProd, tp.nombre as TipoProd, fd.cantidad as SVen_Can, "+ ;
	"Round(fd.cantidad * s.CostoSol, 2) as SVen_Sol, Round(fd.cantidad * s.Costo, 2) as SVen_Dol, fd.um, fd.precio, fd.idorigen as id_vtalotes, "+;
	"Concat(RTRIM(t.descripcion), ' - ', RTRIM(c.nombre)) as Glosa, s.Origen, s.FIngreso, s.LoteFab, s.Costo as CU_Dol, s.CostoSol as CU_Sol "+ ;
	"From factura fc inner join detafacturas fd on fc.unico = fd.unico "+ ;
	"inner join clientes c on c.codigo = fc.codigoc "+ ;
	"Left join motivotraslado t on t.id = fc.motivoguia "+ ;
	"Left Join VtaLotes s on s.id = fd.idorigen " + ;
	"INNER JOIN Productos p on p.Codigo = fd.producto "+ ;
	"INNER JOIN tipoproductos tp ON p.TipoProducto = tp.Codigo "+ ;
	"Where fc.fecha >= ?mFecIni And fc.fecha <= ?mFecFin And fc.motivoguia <> 16 And fc.estado <> 'AN' and fc.anuladaxnc = 0 And tp.inventario = 1", "cSalidasF")

cmd3 = SQLEXEC(lnHandle, "Select 'S' as TipoMov, 'BO' as TD, concat(bc.cpe,CAST(bc.serie as char(4)),'-', CAST(bc.numero as char(7))) as NumDoc, bc.fecha, bd.producto, p.nombre as DesProd, tp.nombre as TipoProd, bd.cantidad as SVen_Can, "+ ;
	"Round(bd.cantidad* s.CostoSol, 2) as SVen_Sol, Round(bd.cantidad* s.Costo, 2) as SVen_Dol, bd.um, bd.precio, bd.idorigen as id_vtalotes, "+ ;
	"Concat(RTRIM(t.descripcion), ' - ', RTRIM(c.nombre)) as Glosa, s.origen, s.FIngreso, s.LoteFab, s.Costo as CU_Dol, s.CostoSol as CU_Sol "+ ;
	"From Boleta bc inner join detaboletas bd on bc.unico = bd.unico "+ ;
	"inner join clientes c on c.codigo = bc.codigoc "+ ;
	"Left join motivotraslado t on t.id = bc.motivoguia "+ ;
	"Left Join VtaLotes s on s.id = bd.idorigen " + ;
	"INNER JOIN Productos p on p.Codigo = bd.producto "+ ;
	"INNER JOIN tipoproductos tp ON p.TipoProducto = tp.Codigo "+ ;	
	"Where bc.fecha >= ?mFecIni and bc.fecha <= ?mFecFin and bc.estado <> 'AN' and bc.anuladaxnc = 0 And tp.inventario = 1", "cSalidasB")

cmd4 = SQLEXEC(lnHandle, "Select 'S' as TipoMov, 'AJ' as TD, concat(cast(YEAR(FECHA) AS CHAR(4)), '-', CAST(MONTH(fecha) as char(2)),'-',CAST(correlativo as char(5))) AS NumDoc, ec.fecha, ed.producto, p.nombre as DesProd, tp.nombre as TipoProd, "+ ;
	"IF(CodTipo= 'T' or CodTipo= 'F', 000000.00, ed.cantidad) as SAjuGas_Can, IF(CodTipo= 'T' or CodTipo= 'F', 000000.00, ROUND(ed.cantidad * s.CostoSol, 2)) as SAjuGas_Sol, "+ ;
	"IF(CodTipo= 'T' or CodTipo= 'F', 000000.00, ROUND(ed.cantidad * s.Costo, 2)) as SAjuGas_Dol, IF(CodTipo= 'T' or CodTipo= 'F', ed.cantidad, 00000.00) as SAjuOtr_Can, "+ ;
	"IF(CodTipo= 'T' or CodTipo= 'F', ROUND(ed.cantidad * s.CostoSol, 2), 00000.00) as SAjuOtr_Sol, IF(CodTipo= 'T' or CodTipo= 'F', ROUND(ed.cantidad * s.Costo, 2), 00000.00) as SAjuOtr_Dol, ed.um, 0.00 as precio, ed.unicoorigen as id_vtalotes, "+ ;
	"ec.Tipo as Glosa, s.Origen, s.FIngreso, s.LoteFab, s.Costo as CU_Dol, s.CostoSol as CU_Sol "+ ;
	"From mastersalidas ec inner join detallesalidas ed on ec.unico = ed.unico "+ ;
	"Left Join VtaLotes s on s.id = ed.unicoorigen " + ;
	"INNER JOIN Productos p on p.Codigo = ed.Producto "+ ;
	"INNER JOIN tipoproductos tp ON p.TipoProducto = tp.Codigo "+ ;	
	"Where ec.fecha >= ?mFecIni and ec.fecha <= ?mFecFin and  ec.anulada = 0 And tp.inventario = 1", "cSalidasO")

*** venta Sucesiva *** 
cmd5 = SQLEXEC(lnHandle, "Select 'I' as TipoMov, 'VS' as TD, concat(vs.fcpe,CAST(vs.fserie as char(4)),'-', CAST(vs.fnumero as char(7))) as NumDoc, vs.ffecha as Fecha, vsd.producto, p.nombre as DesProd, tp.nombre as TipoProd, vsd.cantidad as ICom_Can, "+ ;
	"Round(vsd.cantidad * vsd.PrecioFobSol, 2) as ICom_Sol, Round(vsd.cantidad * vsd.PrecioFob, 2) as ICom_Dol, vsd.um, 0.00 as precio, 00 as id_vtalotes, "+;
	"'IMPORTACION PARA V.SUCESIVA' as Glosa, vs.Pedido as Origen, vs.FFecha as FIngreso, vsd.Lote as LoteFab, vsd.PrecioFob as CU_Dol, vsd.PrecioFobSol as CU_Sol "+ ;
	"From im_vsucesiva vs inner join im_detallevsucesiva vsd on vs.pedido = vsd.codigo "+ ;
	"Inner join clientes c on c.codigo = vs.cliente "+ ;
	"INNER JOIN Productos p on p.Codigo = vsd.producto "+ ;
	"INNER JOIN tipoproductos tp ON p.TipoProducto = tp.Codigo "+ ;
	"Where vs.ffecha >= ?mFecIni And vs.ffecha <= ?mFecFin And vs.anulado = 0 and tp.inventario = 1", "cIngresosVS")
	
cmd6 = SQLEXEC(lnHandle, "Select 'S' as TipoMov, 'VS' as TD, concat(vs.fcpe,CAST(vs.fserie as char(4)),'-', CAST(vs.fnumero as char(7))) as NumDoc, vs.ffecha as Fecha, vsd.producto, p.nombre as DesProd, tp.nombre as TipoProd, vsd.cantidad as SVen_Can, "+ ;
	"Round(vsd.cantidad * vsd.PrecioFobSol, 2) as SVen_Sol, Round(vsd.cantidad * vsd.PrecioFob, 2) as SVen_Dol, vsd.um, vsd.precioventa as precio, 0 as id_vtalotes, "+;
	"Concat('V.SUCESIVA - ', RTRIM(c.nombre)) as Glosa, vs.Pedido as Origen, vs.FFecha as FIngreso, vsd.Lote as LoteFab, vsd.PrecioFob as CU_Dol, vsd.PrecioFobSol as CU_Sol "+ ;
	"From im_vsucesiva vs inner join im_detallevsucesiva vsd on vs.pedido = vsd.codigo "+ ;
	"Inner join clientes c on c.codigo = vs.cliente "+ ;
	"INNER JOIN Productos p on p.Codigo = vsd.producto "+ ;
	"INNER JOIN tipoproductos tp ON p.TipoProducto = tp.Codigo "+ ;
	"Where vs.ffecha >= ?mFecIni And vs.ffecha <= ?mFecFin And vs.anulado = 0 and tp.inventario = 1", "cSalidasVS")

SELECT cKardex
APPEND FROM DBF('cIngresos')
APPEND FROM DBF('cSalidasF')
APPEND FROM DBF('cSalidasB')
APPEND FROM DBF('cSalidasO')

APPEND FROM DBF('cIngresosVS')
APPEND FROM DBF('cSalidasVS')


USE IN cIngresos
USE IN cSalidasF
USE IN cSalidasB
USE IN cSalidasO
USE IN cIngresosVS
USE IN cSalidasVS

SQLDISCONNECT(lnHandle)

Return


***************************************************************************************************************************************************
PROCEDURE Carga_Saldo_Inicial
LPARAMETERS mFecSldIni
WAIT WINDOW 'Calculando saldo inicial al '+ DTOC(mFecSldIni)+' ...' NoWait
lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle <= 0
	WAIT WINDOW 'No se ha podido contectar con el servidor de Base de datos ...' TIMEOUT 2
	Return
ENDIF

cmd0=SQLEXEC(lnHandle,"SELECT origen, producto, SUM(canti) as Canti FROM "+;
	"(SELECT b.idorigen AS origen, b.producto, b.cantidad AS canti FROM factura a, detafacturas b "+;
	" WHERE a.unico=b.unico AND a.fecha>?mFecSldIni AND a.estado<>'AN' AND a.anuladaxnc=0 UNION ALL "+;
	" SELECT b.idorigen AS origen, b.producto, b.cantidad AS canti FROM boleta a, detaboletas b "+;
	" WHERE a.unico=b.unico AND a.fecha>?mFecSldIni AND a.estado<>'AN' AND a.anuladaxnc=0 UNION ALL "+;
	" SELECT b.idorigen AS origen, b.producto, b.cantidad AS canti FROM guiasremision a, detaguiasremision b "+;
	" WHERE a.unico=b.unico AND a.fecha>?mFecSldIni AND a.anulada<>1 AND a.facturada=0 AND a.motivoguia<>7 UNION ALL "+;
	" SELECT b.unicoorigen AS origen, b.producto, b.cantidad AS canti FROM mastersalidas a, detallesalidas b "+;
	" WHERE a.unico=b.unico AND a.fecha>?mFecSldIni AND a.anulada<>1 )"+;
	" AS Resultado  GROUP BY 1,2 ORDER BY 3 DESC","Resultado")

cmd1=SQLEXEC(lnHandle,"SELECT * FROM vtalotes WHERE qsaldov>0","MiBase")
cmd2=SQLEXEC(lnHandle,"SELECT * FROM productos","qProductos")
cmd3=SQLEXEC(lnHandle,"SELECT * FROM tipoproductos","qTipoproductos")

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
		cmd0=SQLEXEC(lnHandle,"SELECT * FROM vtalotes WHERE id=?v1","MiUnico")
		
		SELECT MiUnico
		IF RECCOUNT()>0
			IF MiUnico.fingreso<=mFecSldIni
				SCATTER MEMVAR
				SELECT Mibase
				APPEND BLANK
				GATHER MEMVAR
				replace qsaldov WITH qsaldov+v3
				replace qven WITH qven-v3
			ENDIF
		ENDIF

	ENDIF
	SELECT Resultado
ENDSCAN

SELECT Mibase
SCAN FOR fingreso>mFecSldIni
	DELETE
ENDSCAN

***************************************************************************************************************************************************

SELECT b.tipoproducto,b.nombre,a.producto,a.origen,a.qsaldov,a.qexterno,a.fingreso,a.lotefab,c.nombre as Tnombre,;
	a.costo,a.ubicacion, a.um, a.CostoSol ;
	FROM Mibase as a ;
	INNER JOIN qProductos as b ON ALLTRIM(a.producto)=ALLTRIM(b.Codigo);
	INNER JOIN qTipoproductos as c ON b.tipoproducto=c.Codigo ;
	WHERE c.inventario = 1 ;
	ORDER BY 1,3,6 INTO CURSOR Mistock READWRITE

IF .F.

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
	v1=ALLTRIM(Mistock.Producto)
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

ENDIF

SQLDISCONNECT(lnHandle)


SELECT Producto, Nombre as DesProd, Tnombre as TipoProd, UM, Origen, Lotefab, FIngreso, mFecSldIni as Fecha, 'I' as TipoMov, 'SALDO INICIAL' as Glosa, ;
qsaldov as SIni_Can, ROUND(qsaldov* CostoSol, 2) as SIni_Sol, ROUND(qsaldov* Costo, 2) as SIni_Dol, Costo as CU_Dol, CostoSol as CU_Sol ;
FROM Mistock INTO CURSOR cSaldoIni

SELECT cKardex
APPEND FROM DBF('cSaldoIni')

USE IN cSaldoIni
USE IN MiStock

Return