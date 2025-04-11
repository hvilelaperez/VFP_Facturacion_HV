SET DELETED ON

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
	"SERVER=192.168.1.179;" + ;
	"PORT=3306;" + ;
	"UID=sistemas;" + ;
	"PWD=d3b14nfw123;" + ;
	"DATABASE=sqmdata;" + ;
	"OPTIONS=0;"

MyCierre= CTOD('31/12/2016')


DO Saldo_Inicial
DO Armar_Kardex
*DO ValKar_CProm
DO ValKar_CLote

SELECT cKardex
DELETE FOR destipart = 'NO INVENTARIABLE'
REPLACE TIPO WITH 'S', TD WITH 'FB', CANTIDAD WITH CANTIDAD * -1, CT_SOL WITH CT_SOL *-1 FOR TD = 'VD'

SELECT ALLTRIM(codtipart) + ' '+ destipart AS Tipo_Art, TIPO, TD, IIF(TD= 'SI', 00, MONTH(Fecha)) as Mes, SUM(CANTIDAD) AS CANTIDAD, SUM(CT_SOL) AS COSTO_TOT ;
FROM CKARDEX GROUP BY Tipo_Art, TIPO, TD,Mes INTO CURSOR cResumen
*COPY TO c:\sistemas\temporal\kar_cpromedio TYPE xls
COPY TO c:\sistemas\temporal\kar_clote TYPE xls

RETURN



PROCEDURE ValKar_CLote
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
			=SEEK(DTOS(m.Fecha), 'cTC')
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
			IF m.VS = '1'   && En Venta sucesiva se guarda el costo (fob) de la importacion en el detalle de la factura de venta sucesiva.
				=SEEK(DTOS(m.Fecha), 'cTC')   && No se cuenta con la fecha de emision de la factura de importacion. Se considera la fecha de la venta.
				mTC_Venta= cTC.Venta
				IF mTC_Venta = 0
					MESSAGEBOX('No existe tipo de cambio para el día '+ DTOC(m.Fecha)+ ' (Venta Sucesiva)', 0+48, 'Error')
					mTC_Venta = 3.25
				ENDIF
				mCU_Sol  = m.CU_Dol * mTC_Venta
				mCT_Sol  = ROUND(Cantidad * mCU_Sol, 2)
			ELSE
				IF SEEK(m.id_vtaslote, 'cVtaLotes')
					IF ALLTRIM(cVtaLotes.producto) = ALLTRIM(m.Producto)
						mFIng = cVtaLotes.FIngreso
						=SEEK(DTOS(mFIng), 'cTC')
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




PROCEDURE ValKar_CProm

WAIT WINDOW 'Valorizando los movimientos del kardex con costo promedio ...' NoWait

lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle <= 0
	WAIT WINDOW 'No se ha podido contectar con el servidor de Base de datos ...' TIMEOUT 2
	Return
ENDIF
cmd0 = SQLEXEC(lnHandle,"SELECT Fecha, Venta FROM tcoficial","cTC")
cmd1 = SQLEXEC(lnHandle,"SELECT codigo, nombre From tipoproductos where inventario = 1","cTipoProd")

SQLDISCONNECT(lnHandle)


SELECT cTC
INDEX on DTOS(Fecha) TAG Fecha

SELECT cTipoProd
INDEX on Codigo TAG Codigo

SELECT cKardex
GO top
DO WHILE !EOF()
	SCATTER MEMVAR Field producto
	mSld_Can = 0
	mSld_Sol = 0
	mCProm   = 0
	SCAN WHILE Producto = m.Producto
		SCATTER Memvar
		IF Tipo = 'I'
			=SEEK(DTOS(m.Fecha), 'cTC')
			mTC_Venta= cTC.Venta
			IF mTC_Venta = 0
				MESSAGEBOX('No existe tipo de cambio para el día '+ DTOC(m.Fecha), 0+48, 'Error')
				mTC_Venta = 3.25
			ENDIF
			mCU_Sol  = CU_Dol * mTC_Venta
			mCT_Sol  = ROUND(Cantidad * mCU_Sol, 2)
			mSld_Can = mSld_Can + Cantidad
			mSld_Sol = mSld_Sol + mCT_Sol
			mCProm   = mSld_Sol / mSld_Can
		ELSE
			mCU_Sol  = mCProm
			mCT_Sol  = ROUND(Cantidad * mCU_Sol, 2)
			mSld_Can = mSld_Can - Cantidad
			mSld_Sol = mSld_Sol - mCT_Sol
		ENDIF
		Replace CU_Sol WITH mCU_Sol, CT_Sol WITH mCT_Sol, Sld_Can WITH mSld_Can, Sld_Sol WITH mSld_Sol
		
		IF SEEK(m.CodTipArt, 'cTipoProd')
			Replace DesTipArt WITH cTipoProd.Nombre
		ELSE
			Replace DesTipArt WITH 'NO INVENTARIABLE'
		ENDIF
	ENDSCAN
ENDDO

WAIT WINDOW 'Valorizando los movimientos del kardex con costo promedio ...' TIMEOUT 1

RETURN




PROCEDURE Armar_Kardex
WAIT WINDOW 'Preparando el kardex ... 1 ' NoWait

lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle <= 0
	WAIT WINDOW 'No se ha podido contectar con el servidor de Base de datos ...' TIMEOUT 2
	Return
ENDIF

cmd1 = SQLEXEC(lnHandle,"Select 'I' as Tipo, Case When TipoOrigen= 'D' Then 'VD' Else 'VI' End as TD, id as unico, fingreso as fecha, '    ' as codigoc, id, producto, qing as cantidad, um, 00.00 as precio, "+ ; 
	"costo as CU_Dol, 0000.0000 as CU_Sol, 00000000.00 as CT_Sol, 00000000.00 as Sld_Can, 00000000.00 as Sld_Sol, 00.000 as TC, '0' as VS, id as id_vtaslote "+ ;
	"From vtalotes Where fingreso >= ?MyCierre ", "cIngresos")

WAIT WINDOW 'Preparando el kardex ... 2 ' NoWait

cmd2 = SQLEXEC(lnHandle,"Select 'S' as Tipo, 'FB' as TD, fc.unico, fc.fecha, fc.codigoc, fd.id, fd.producto, fd.cantidad, fd.um, fd.precio "+;
	", 0000.0000 as CU_Dol, 0000.0000 as CU_Sol, 00000000.00 as CT_Sol, 00000000.00 as Sld_Can, 00000000.00 as Sld_Sol, 00.000 as TC, '0' as VS, fd.idorigen as id_vtaslote "+ ;
	"From factura fc inner join detafacturas fd on fc.unico = fd.unico "+ ;
	"Where fc.fecha >= ?MyCierre and fc.estado <> 'AN' and fc.anuladaxnc = 0 "+ ;
	"union all "+ ;
	"Select 'S' as Tipo, 'FB' as TD, bc.unico, bc.fecha, bc.codigoc, bd.id, bd.producto, bd.cantidad, bd.um, bd.precio "+ ;
	", 0000.0000 as CU_Dol, 0000.0000 as CU_Sol, 00000000.00 as CT_Sol, 00000000.00 as Sld_Can, 00000000.00 as Sld_Sol, 00.000 as TC, '0' as VS, bd.idorigen as id_vtaslote "+ ;
	"From Boleta bc inner join detaboletas bd on bc.unico = bd.unico "+ ;
	"Where bc.fecha >= ?MyCierre and bc.estado <> 'AN' and bc.anuladaxnc = 0 "+ ;
	"union all "+ ;
	"Select 'S' as Tipo, 'VS' as TD, ec.unico, ec.fecha, '    ' as codigoc, ed.id, ed.producto, ed.cantidad, ed.um, 0.00 as precio "+ ;
	", 0000.0000 as CU_Dol, 0000.0000 as CU_Sol, 00000000.00 as CT_Sol, 00000000.00 as Sld_Can, 00000000.00 as Sld_Sol, 00.000 as TC, '0' as VS, ed.unicoorigen as id_vtaslote "+ ;
	"From mastersalidas ec inner join detallesalidas ed on ec.unico = ed.unico "+ ;
	"Where ec.fecha >= ?MyCierre and ec.anulada = 0 and codtipo not in ('T', 'F')", "cSalidas")

cmd3 = SQLEXEC(lnHandle,"Select 'S' as Tipo, 'FB' as TD, fc.unico, fc.fecha, fc.codigoc, fd.id, fd.producto, fd.cantidad, fd.um, fd.precioventa as precio "+;
	", fd.preciofob as CU_Dol, 0000.0000 as CU_Sol, 00000000.00 as CT_Sol, 00000000.00 as Sld_Can, 00000000.00 as Sld_Sol, 00.000 as TC, '1' as VS "+ ;
	"From factura fc inner join im_detallevsucesiva fd on fc.vspedido = fd.codigo "+ ;
	"Where fc.fecha >= ?MyCierre and fc.estado <> 'AN' and fc.anuladaxnc = 0 and LENGTH(rtrim(fc.vspedido)) > 4","cTmpVS")

SELECT *, CAST(0 AS Integer(5,0)) as id_vtaslote FROM cTmpVS INTO CURSOR cVSucesivas
SELECT *, CAST(0 AS Integer(5,0)) as id_vtaslote FROM cTmpVS INTO CURSOR cIngVSuces READWRITE
Replace Tipo WITH 'I', TD WITH 'IV' ALL


WAIT WINDOW 'Preparando el kardex ... 3 ' NoWait

SELECT 'I' as Tipo, 'SI' as TD, 0000 as unico, fingreso as fecha, '    ' as codigoc, 0 as id, codigo as producto, stock as Cantidad, '  ' as UM, 0.00 as precio, ;
 CU_Dol, 0000.0000 as CU_Sol, 00000000.00 as CT_Sol, 00000000.00 as Sld_Can, 00000000.00 as Sld_Sol, 00.000 as TC, '0' as VS, CAST(0 AS Integer(5,0)) as id_vtaslote, LEFT(codigo,2) as CodTipArt, SPACE(40) as DesTipArt FROM cSaldoIni ;
Union all ; 
SELECT *, LEFT(producto,2) as CodTipArt, SPACE(40) as DesTipArt FROM cIngresos ;
Union all ;
SELECT *, LEFT(producto,2) as CodTipArt, SPACE(40) as DesTipArt FROM cIngVSuces ;
union all ;
SELECT *, LEFT(producto,2) as CodTipArt, SPACE(40) as DesTipArt FROM cSalidas ;
union all ;
SELECT *, LEFT(producto,2) as CodTipArt, SPACE(40) as DesTipArt FROM cVSucesivas ;
Into cursor cKardex ORDER BY 7, 4, 1, 2 READWRITE

SQLDISCONNECT(lnHandle)

Return


***************************************************************************************************************************************************
PROCEDURE Saldo_Inicial
WAIT WINDOW 'Calculando saldo inicial al 01/01/2017 ...' NoWait
lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle <= 0
	WAIT WINDOW 'No se ha podido contectar con el servidor de Base de datos ...' TIMEOUT 2
	Return
ENDIF

cmd0=SQLEXEC(lnHandle,"SELECT origen, producto, SUM(canti) as Canti FROM "+;
	"(SELECT b.idorigen AS origen, b.producto, b.cantidad AS canti FROM factura a, detafacturas b "+;
	" WHERE a.unico=b.unico AND a.fecha>?MyCierre AND a.estado<>'AN' AND a.anuladaxnc=0 UNION ALL "+;
	" SELECT b.idorigen AS origen, b.producto, b.cantidad AS canti FROM boleta a, detaboletas b "+;
	" WHERE a.unico=b.unico AND a.fecha>?MyCierre AND a.estado<>'AN' AND a.anuladaxnc=0 UNION ALL "+;
	" SELECT b.idorigen AS origen, b.producto, b.cantidad AS canti FROM guiasremision a, detaguiasremision b "+;
	" WHERE a.unico=b.unico AND a.fecha>?MyCierre AND a.anulada<>1 AND a.facturada=0 AND a.motivoguia<>7 UNION ALL "+;
	" SELECT b.unicoorigen AS origen, b.producto, b.cantidad AS canti FROM mastersalidas a, detallesalidas b "+;
	" WHERE a.unico=b.unico AND a.fecha>?MyCierre AND a.anulada<>1 )"+;
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
			IF MiUnico.fingreso<=MyCierre
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
SCAN FOR fingreso>MyCierre
	DELETE
ENDSCAN

***************************************************************************************************************************************************

SELECT b.tipoproducto,b.nombre,a.producto AS Codigo,a.origen,a.qsaldov,a.qexterno,a.fingreso,a.lotefab,c.nombre as Tnombre,;
	a.costo,a.ubicacion ;
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



*SELECT codigo, lotefab, fingreso, qsaldov as stock, costo as cu_dolar, cTC.Venta as TC_Venta, Costo * cTC.Venta FROM Mistock LEFT JOIN cTC ON Mistock.fingreso = cTC.Fecha
SELECT codigo, lotefab, fingreso, qsaldov as stock, costo as CU_Dol FROM Mistock INTO CURSOR cSaldoIni

*SELECT * FROM Mistock
*WHERE tipoproducto='00' OR BETWEEN(VAL(tipoproducto),1,11) ORDER BY 1,3,11 DESC,8 INTO CURSOR Mistock

SQLDISCONNECT(lnHandle)

Return