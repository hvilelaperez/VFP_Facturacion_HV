Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
	"SERVER=192.168.1.179;" + ;
	"PORT=3306;" + ;
	"UID=sistemas;" + ;
	"PWD=d3b14nfw123;" + ;
	"DATABASE=sqmdata;" + ;
	"OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle <= 0
	WAIT WINDOW 'No se ha podido contectar con el servidor de Base de datos ...' TIMEOUT 2
	Return
ENDIF

*DO DepuraDuplicadosMasDatos

*DO RetornoPrecioLista

*DO ActPreciosCotizaOtrosCli
*DO DepuraMasdetalle

*DO CargarClienteEmpleado

DO EtiquetasClientes
*DO Act_packing_stock
*DO Act_Prec_Ganan
*DO RestauraStock

*DO Act_VentaSucesiva

*DO Gen_SalAju_Redondeo

*DO Act_KardexGuia
*DO Act_KardexPack

*DO Act_Direc_Prov


SQLDISCONNECT(lnHandle)

RETURN


PROCEDURE Act_Direc_Prov

SUSPEND

cmd1 = SQLEXEC(lnHandle, "Select codigo,direccion, dpto, prov, dist from clientes "+ ;
	"where origen= 'C' and trim(direccion) <> '' AND TRIM(DPTO) <> '' AND trim(Codigo) not in ('C438','A027','C147','S075','A261','I109','T188','S189','L268','A219', 'C530')", "cDirProv")
SELECT cDirProv
SCAN
	mCod = codigo
	mDir = Direccion
	mDep = Dpto
	mPro = Prov
	mDis = Dist
	
	cmd1 = SQLEXEC(lnHandle, "Insert into Direcciones (cliente,direccion,dpto,prov,dist,inactivo) Values (?mCod,?mDir,?mDep,?mPro,?mDis,0)")	
ENDSCAN

RETURN


PROCEDURE Act_KardexGuia
cmd1 = SQLEXEC(lnHandle, "Select Fecha, Origen, Tipo, Guia, Factura from masteringresos where (tipo= 'W' or tipo = 'I') And Anulado <> 1", "cGuiaIng")
SELECT cGuiaIng
SCAN
	mOri = Origen
	mTDoc = ''
	mNDoc = ''
	IF ALLTRIM(Guia)= '999-999999' OR ALLTRIM(Guia)= '000-000000' OR ALLTRIM(Guia)= '001-000001'
		IF !EMPTY(Factura) AND ALLTRIM(Factura) <> '000-000000'
			mTDoc = 'F'
			mNDoc = ALLTRIM(Factura)
		EndIf
	ELSE
		mTDoc = 'G'
		mNDoc = ALLTRIM(Guia)
	ENDIF
	cmd1 = SQLEXEC(lnHandle, "Update Kardex Set TDocRef= ?mTDoc, NDocRef=?mNDoc Where Origen= ?mOri")
ENDSCAN

RETURN


PROCEDURE Act_KardexPack
cmd1 = SQLEXEC(lnHandle, "Select id, FIngreso, Producto, Origen, Packing From VtaLotes "+ ;
	"Where FIngreso >= '2011-01-01' And fingreso <= '2016-12-31' And (TipoOrigen= 'W' Or TipoOrigen= 'I') And TRIM(packing) <> '' Order by FIngreso, Origen, Producto, id", "cAlm")
SELECT cAlm
GO Top
DO WHILE !EOF()
	mOri  = Origen
	mProd = Producto
	mPack = Packing
	cmd1 = SQLEXEC(lnHandle, "Update Kardex Set Packing= ?mPack Where Producto= ?mProd And Origen= ?mOri")	
	
	WAIT Windows 'Actualizando '+ DTOC(FIngreso)+ ' '+ mOri+ ' ...' NoWait
	SELECT cAlm
	SCAN WHILE Origen= mOri AND Producto= mProd
	ENDSCAN
ENDDO
RETURN



PROCEDURE Gen_SalAju_Redondeo
SUSPEND

cmd1 = SQLEXEC(lnHandle, "Select id, origen, producto, um, moneda, qing, qsaldov, costo, costosol, '0' as StockOk  From vtalotes Where qsaldov < 0.01 And qsaldov > 0", "cSldMin")
SELECT cSldMin
SCAN
	SCATTER Memvar
	mIdLote = cSldMin.Id
	cmd1 = SQLEXEC(lnHandle, "Select 'S' as Tipo, c.unico, c.Fecha, d.cantidad from detallesalidas d inner join mastersalidas c on d.unico = c.unico where d.unicoorigen=?mIdLote and c.anulada<>1","cTSal")
	cmd2 = SQLEXEC(lnHandle, "Select 'G' as Tipo, c.unico, c.Fecha, d.cantidad from detaguiasremision d inner join guiasremision c on d.unico= c.unico where idorigen=?mIdLote and c.anulada<>1 and c.motivoguia in (1,2,10,11,12,14)","cTGui")
	cmd3 = SQLEXEC(lnHandle, "Select 'F' as Tipo, c.unico, c.Fecha, d.cantidad from detafacturas d inner join factura c on d.unico= c.unico where idorigen=?mIdLote and c.estado<>'AN' and c.directa= 1 And c.anuladaxnc <> 1","cTFac")
	cmd4 = SQLEXEC(lnHandle, "Select 'B' as Tipo, c.unico, c.Fecha, d.cantidad from detaboletas d inner join boleta c on d.unico= c.unico where idorigen=?mIdLote and c.estado<>'AN' and c.directa= 1 And c.anuladaxnc <> 1", "cTBol")
	
	SELECT cTSal 
	SUM Cantidad TO mTSal
	SELECT cTGui
	SUM Cantidad TO mTGui
	SELECT cTFac
	SUM Cantidad TO mTFac
	SELECT cTBol
	SUM Cantidad TO mTBol
	
	mTotSal = mTSal+ mTGui+ mTFac+ mTBol
	
	mValidaSaldo = m.QIng - mTotSal
	IF mValidaSaldo = m.qsaldov
		SELECT cSldMin
		Replace StockOk WITH '1'
	ELSE
		MESSAGEBOX('El stock del producto '+ ALLTRIM(m.Producto)+ ' id '+ ALLTRIM(STR(m.id, 10))+ ' es diferente al calculado según los movimientos'+ ;
				Chr(13)+ CHR(13)+ 'Stock: '+ ALLTRIM(STR(m.qsaldov,10,3))+ ' Calculado: '+ ALLTRIM(STR(mValidaSaldo,10,3)), 0+ 48, 'Inconsistencia')
	ENDIF
ENDSCAN

SELECT * FROM cSldMin WHERE StockOk = '1' INTO CURSOR cArtxAjus
SELECT cArtxAjus
GO Top
IF !EOF()
	*** Realizar salida por ajuste redondeo
	mFecSal = DATE()
	mAnio   = YEAR(mFecSal)
	mMes    = MONTH(mFecSal)
	
    cmd1=SQLEXEC(lnHandle,"SELECT MAX(correlativo) as Nume FROM mastersalidas WHERE YEAR(fecha)=?mAnio AND MONTH(fecha)=?mMes","cNumeros")
	cmd2=SQLEXEC(lnHandle,"SELECT MAX(unico) as Unico FROM mastersalidas","cUnicos")
	
	mCorrelN = IIF(ISNULL(cNumeros.Nume), 1, cNumeros.Nume+ 1)
	mUnicoN  = IIF(ISNULL(cUnicos.Unico), 1, cUnicos.Unico+ 1)
	mDocSal  = TRANSFORM(mAnio,"@l 9999")+"-"+TRANSFORM(mMes,"@l 99")+"-"+TRANSFORM(mCorrelN,"@l 999")		
	
	cmd1 = SQLEXEC(lnHandle,"Insert into MasterSalidas (unico,fecha,correlativo,tipo,codtipo,observaciones,trabajada,anulada, usuario) "+ ;
		"Values (?mUnicoN, ?mFecSal, ?mCorrelN, 'AJUSTE', 'A', 'AJUSTE POR REDONDEO', 0, 0, 'SISTEMAS')")	
	SELECT cArtxAjus
	SCAN 
		mProd = Producto
		mCant = QSaldov
		mUM   = UM
		mCos  = Costo
		mMon  = Moneda
		mId   = Id
		
		cmd0=SQLEXEC(lnHandle,"SELECT ID,SALDO FROM kardex WHERE producto=?mProd ORDER BY ID DESC LIMIT 1","cSaldoKdx")
		mSld = IIF(RECCOUNT('cSaldoKdx')=0, 0, cSaldoKdx.Saldo)
		mSld = mSld - mCant
		
    	cmd1=SQLEXEC(lnHandle,"INSERT INTO Detallesalidas (unico,producto,cantidad,um,costo,moneda,unicoorigen,idorigen)"+;
                          " values (?mUnicoN,?mProd,?mCant,?mUM,?mCos,?mMon,?mId,?mId) ")
		
        cmd2=SQLEXEC(lnHandle,"UPDATE Vtalotes set qven=qven+?mCant,qsaldov=qsaldov-?mCant,qsaldoa=qsaldoa-?mCant WHERE id=?mID" )
		
    	cmd3=SQLEXEC(lnHandle,"INSERT INTO kardex (producto,fecha,tipodoc,numero,cliente,salida,ingreso,saldo,origen,historial2)"+;
                            " values (?mProd,?mFecSal,'GS',?mDocSal,'AJUSTE POR REDONDEO',?mCant,0,?mSld,' ',current_timestamp)")
		
	ENDSCAN
ENDIF

SQLDISCONNECT(lnHandle)        
	
RETURN



PROCEDURE Act_VentaSucesiva

cmd1 = SQLEXEC(lnHandle, "SELECT vs.id, vs.pedido, vsd.id as id_deta, vsd.producto, vsd.cantidad, vsd.preciofob, vsd.preciofobsol, ie.FecBL, ie.fecfactura, tc.venta "+;
		"From im_vsucesiva vs "+ ;
		"inner join im_detallevsucesiva vsd on vs.pedido = vsd.codigo "+ ;
		"inner join im_iembarque ie on ie.codigo = vs.pedido "+ ;
		"left join tcoficial tc on tc.fecha = ie.fecbl "+ ;
		"WHERE VS.ffecha > '2017-01-01' and vsd.preciofobsol= 0", "cVtaSuc")

susp
SELECT cVtaSuc
SCAN
	mIdDeta = id_deta
	mVenta  = Venta
	cmd1 = SQLEXEC(lnHandle, "Update im_detallevsucesiva Set preciofobsol = preciofob * ?mVenta Where id = ?mIdDeta")	
ENDSCAN
Return



PROCEDURE CargarClienteEmpleado
SUSPEND

cmd1 = SQLEXEC(lnHandle, "Select codigo, dni, nombres, apellidopat, apellidomat from empleados where activo= 'S' order by 3,4,5","cTrab")
SELECT cTrab
SCAN
	IF ALLTRIM(Codigo) $ '0005,0169,0086,0100,0013,0018,0007,0138,0112'
		LOOP
	ENDIF
	WAIT WINDOW 'Cargando '+ ALLTRIM(nombres) NoWait
	mNombre = ALLTRIM(Nombres)+ ' '+ ALLTRIM(ApellidoPat)+ ' '+ ALLTRIM(ApellidoMat)
	mDNi    = DNI
	mDirec  = 'LIMA'
	mLetra = LEFT(mNombre, 1)
	cmd1 = SQLEXEC(lnHandle, "Select max(CONVERT(SUBSTRING(codigo,2,3), decimal)) as ultsec from clientes Where LEFT(Codigo, 1) = ?mLetra Order by Codigo DESC","cCli")
	SELECT cCli
	GO Top
	IF !EOF()
		mSigCod = cCli.ultsec+ 1
	ELSE
		mSigCod = 1
	ENDIF
	IF mSigCod  < 900
		mCodCli = mLetra+ TRANSFORM(mSigCod, '@L 999')
		cmd1 = SQLEXEC(lnHandle, "Insert into clientes (codigo, nombre, tiposunat, esdni, ruc, direccion, pais, dpto, prov, dist, activo, empleado, cpe01) "+ ;
				"Values (?mCodCli, ?mNombre, '1', 1, ?mDni, 'LIMA', 'PE', 'LIMA', 'LIMA', '',1, 1, 'CLIENTES_NOCPE@SOCIEDADQUIMICA.COM.PE')")
	ELSE
		MESSAGEBOX('Revisar el correlativo del codigo')
		SUSPEND
	ENDIF
ENDSCAN

REturn


PROCEDURE EtiquetasClientes
	SELECT cClientes    && Tabla importada de la hoja de calculo que envió Recepción por correo.
	LABEL FORM LabelEtiquetasRegalos3x NOCONSOLE PREVIEW
	LABEL FORM LabelEtiquetasRegalos3x NOCONSOLE TO PRINTER prompt
Return



* Actualiza el packing de los productos en stock. En las salidas del deposito simple hacia nuestros almacenes, el sistema no estaba actualizando el packing en la tabla vtalotes.
PROCEDURE Act_packing_stock

cmd1 = SQLEXEC(lnHandle, "Select * From Productos","cProd")
	
RETURN


* Actualiza los datos registrados en la tabla productos de la bd MySQL hacia la tabla productos de DBF.
PROCEDURE Act_Prec_Ganan

OPEN DATABASE z:\newcomprassqm\data\sqm.dbc SHARED

USE Productos Order Codigo IN 0

cmd1 = SQLEXEC(lnHandle, "Select * From Productos","cProd")

SELECT cProd
=AFIELDS(aStruc)
CREATE CURSOR cNuevos FROM ARRAY aStruc

SELECT cProd
SCAN
	IF Activo= 0
		Loop
	ENDIF
	SCATTER MEMVAR Memo
	mCod = ALLT(m.Codigo)
	SELECT Productos
	IF SEEK(mCod)
		Replace Nombre WITH STRCONV(ALLTRIM(m.Nombre), 11), colorindex WITH ALLTRIM(m.colorindex), fullcolorindex WITH ALLTRIM(m.fullcolorindex), partida WITH ALLTRIM(m.Partida)
		*Replace pctjeadvalorem WITH m.pctjeadvalorem
		Replace Activo WITH (m.Activo= 1), Detalles WITH ALLTRIM(m.Detalles), descontinuado WITH (m.descontinuado= 1),concentracion WITH m.concentracion, actprelocal WITH (m.actprelocal= 1)
		Replace actfacimp WITH (m.actfacimp= 1), prelocal WITH m.prelocal, uflete WITH m.uflete, udesa WITH m.udesa, nombre2 WITH STRCONV(ALLTRIM(m.nombre2),11), factorgan WITH m.factorgan, um WITH ALLTRIM(m.um)
		Replace fobstd WITH m.fobstd, colorindextwo WITH ALLTRIM(m.colorindextwo)
	ELSE
		INSERT INTO cNuevos FROM Memvar
	ENDIF
ENDSCAN

Return




PROCEDURE RestauraStock

mFecIni = CTOd('30/09/2017')
mFecFin = CTOd('02/10/2017')


cmd1 = SQLEXEC(lnHandle, "Select ec.fecha, ed.producto, ed.cantidad, ed.um, 0.00 as precio, ed.unicoorigen, "+ ;
	"ec.Tipo as Glosa, s.Origen, s.FIngreso, s.LoteFab, s.Costo as CU_Dol, s.CostoSol as CU_Sol "+ ;
	"From mastersalidas ec inner join detallesalidas ed on ec.unico = ed.unico "+ ;
	"Left Join VtaLotes s on s.id = ed.unicoorigen " + ;
	"Where ec.fecha >= ?mFecIni and ec.fecha <= ?mFecFin and  ec.anulada = 0", "cSalidasO")
	
cmd1 = SQLEXEC(lnHandle, "Select c.fecha, c.motivoguia, d.producto, d.cantidad, d.idorigen from detaguiasremision d "+ ;
		"inner join guiasremision c on c.unico = d.unico " +;
		"where c.fecha >= ?mFecIni and c.fecha <= ?mFecFin and c.anulada = 0 and d.anulado = 0", "cSalidasG")


SELECT stk2909
SCAN
	mIdLote   = stk2909.Id
	mSaldoIni = stk2909.QSaldoV
	mUbica    = stk2909.Ubicacion
	cmd = SQLEXEC(lnHandle, "Update VtaLotes Set qsaldov = ?mSaldoIni, qsaldov2 = ?mSaldoIni, Ubicacion = ?mUbica Where id = ?mIdLote")
	WAIT WINDOW 'Actualizando el stock 1 ... '+ ALLTRIM(STR(mIdLote)) NoWait	
ENDSCAN

mSwAct = .T.

IF mSwAct
	SELECT cSalidasG
	SCAN
		mIdLote = idOrigen
		mCant   = Cantidad
		cmd1 = SQLEXEC(lnHandle, "Update VtaLotes Set qsaldov = qsaldov - ?mCant Where id = ?mIdLote")
		WAIT WINDOW 'Actualizando el stock 2 ... '+ ALLTRIM(STR(mIdLote)) NoWait
	ENDSCAN
	WAIT WINDOW 'Actualizando el stock ... ' TIMEOUT 0.1

	SELECT cSalidasO
	SCAN
		mIdLote = unicoorigen
		mCant   = Cantidad
		cmd1 = SQLEXEC(lnHandle, "Update VtaLotes Set qsaldov = qsaldov - ?mCant Where id = ?mIdLote")
		WAIT WINDOW 'Actualizando el stock 3 ... '+ ALLTRIM(STR(mIdLote)) NoWait
	ENDSCAN
	WAIT WINDOW 'Actualizando el stock ... ' TIMEOUT 0.1	
ENDIF

SQLDISCONNECT(lnHandle)

RETURN



PROCEDURE RetornoPrecioLista

*WAIT WINDOW 'Buscando productos sin ventas en los ultimos 6 para restaurar sus precios a precios lista ...' NoWait
WAIT WINDOW 'Buscando precios de stock sin movimiento para restaurar a precios de lista ...' NoWait

SET EXACT OFF
SET DELETED ON

mFec6MIni= DATE()- 180
mFec6MFin= DATE()- (180+90)

mFec6MIni2= DATE()- 180
mFec6MFin2= DATE()- (180+90+ 360)

cmd1 = SQLEXEC(lnHandle, "Select Cliente, CAST('' as Char(70)) as NombreCli, Producto, CAST('' as Char(80)) as NombreArt, UM, Precio, Moneda, FechaModifi, "+ ;
						"CAST(0.00 as Decimal(10,2)) as PrecioLista, CAST('0000-00-00' as Date) as FecPrecLista, Masivo, CAST(0 as Char(1)) as UltPrecLista, CAST('' as Char(1)) as Restaurar "+ ;
							"From preciostockclientes Where Precio > 0 And fechamodifi< ?mFec6MIni And fechamodifi> ?mFec6MFin Order by Cliente", "cPrecios")

CREATE CURSOR cListaPrecios (Fecha D, PrecioLista N(10,2), Cliente C(4), Producto C(7), NuevoPrecio N(10,2), ByPass L, Lista C(4))

**** Lista de cambio de precios no chinos ***
OPEN DATABASE \\SQMSERVER\d\newcomprassqm\data\sqmventas.DBC SHARED
USE sqmventas!listacambioprecio SHARED IN 0 
USE sqmventas!listcampredetalle SHARED IN 0
USE sqmventas!fulldetalle SHARED IN 0

SELECT a.Fecha, b.lista, b.preciolista, c.cliente, c.Producto, c.nuevoprecio, bypass FROM listcampredetalle b INNER JOIN fulldetalle c ;
ON b.lista= c.lista AND b.codigo= c.producto INNER JOIN ListaCambioPrecio a ON a.Numero= b.Lista WHERE b.Cotizado AND a.Fecha < mFec6MIni2 AND a.Fecha > mFec6MFin2 ;
	ORDER BY cliente, producto INTO CURSOR cLisPrecNoChinos

**** Lista de cambio de precios Chinos / Agrupados ***
USE sqmventas!listachinos SHARED IN 0
USE sqmventas!listachinosdetalle SHARED IN 0
USE sqmventas!fulldetallechino SHARED IN 0

SELECT a.Fecha, b.lista, b.preciolista, c.cliente, c.Producto, c.nuevoprecio, bypass FROM listachinosdetalle b INNER JOIN fulldetallechino c ;
	ON b.lista= c.lista AND b.codigo= c.producto INNER JOIN listachinos a ON a.Numero= b.Lista WHERE b.Cotizado AND a.Fecha < mFec6MIni2 AND a.Fecha > mFec6MFin2 ;
	ORDER BY cliente, producto INTO CURSOR cLisPrecChinos

SELECT cListaPrecios
APPEND FROM DBF('cLisPrecNoChinos')
APPEND FROM DBF('cLisPrecChinos')
USE IN cLisPrecNoChinos
USE IN cLisPrecChinos

INDEX ON Cliente TAG Cli
INDEX ON Producto TAG Pro


SELECT cPrecios
GO Top
DO WHILE !EOF()
	mCliente  = ALLTRIM(Cliente)
	
	cmd2 = SQLEXEC(lnHandle, "Select Nombre, Grupo, Activo From Clientes Where Codigo= ?mCliente", "cGrupo")
	GO TOP IN cGrupo
	mGrupoCli = IIF(ISNULL(cGrupo.Grupo), '', cGrupo.Grupo)
	mCliActivo= cGrupo.Activo
	mNomCli   = cGrupo.Nombre
	USE IN cGrupo
	IF !EMPTY(mGrupoCli)
		cmd3 = SQLEXEC(lnHandle, "Select Codigo From Clientes Where Grupo= ?mGrupoCli", "cCliGrupo")
	ELSE
		cmd3 = SQLEXEC(lnHandle, "Select Codigo From Clientes Where Codigo= ?mCliente", "cCliGrupo")
	ENDIF
	INDEX on Codigo TAG CliGrup

	SELECT cPrecios
	SCAN WHILE ALLTRIM(Cliente)= mCliente
		IF mCliActivo= 0
			LOOP
		ENDIF
		mProducto = ALLTRIM(Producto)
		mFecModif = FechaModifi
		mPreModif = Precio
		
		cmd3 = SQLEXEC(lnHandle, "Select Nombre, idSqm, Activo From Productos Where Codigo= ?mProducto", "cGrupoArt")
		GO TOP IN cGrupoArt
		mGrupoArt = IIF(ISNULL(cGrupoArt.idSqm), '', cGrupoArt.idSqm)
		mArtActivo= cGrupoArt.Activo
		mNomArt   = cGrupoArt.Nombre
		USE IN cGrupoArt
		
		IF mArtActivo = 0
			LOOP
		ENDIF
		
		IF !EMPTY(mGrupoArt)
			cmd4 = SQLEXEC(lnHandle, "Select Codigo From Productos Where IdSqm= ?mGrupoArt", "cArtGrupo")
		ELSE
			cmd4 = SQLEXEC(lnHandle, "Select Codigo From Productos Where Codigo= ?mProducto", "cArtGrupo")
		ENDIF
		INDEX on Codigo TAG ArtGrup
		
		IF !EMPTY(mGrupoCli)
			IF !EMPTY(mGrupoArt)
				cmd4 = SQLEXEC(lnHandle, "Select d.punitario, d.cantidad from guiasremision c inner join detaguiasremision d on c.unico= d.unico "+ ;
						"Inner join Clientes cl on cl.Codigo= c.Cliente INNER JOIN Productos p ON p.Codigo= d.Producto Where cl.Grupo=?mGrupoCli And p.idSqm=?mGrupoArt And c.fecha>= ?mFecModif and c.motivoguia= 1 and c.Anulada= 0", "cVenta")
			ELSE
				cmd4 = SQLEXEC(lnHandle, "Select d.punitario, d.cantidad from guiasremision c inner join detaguiasremision d on c.unico= d.unico "+ ;
						"Inner join Clientes cl on cl.Codigo= c.Cliente Where cl.Grupo=?mGrupoCli And d.Producto=?mProducto And c.fecha>= ?mFecModif and c.motivoguia= 1 and c.Anulada= 0", "cVenta")
			ENDIF
		ELSE
			IF !EMPTY(mGrupoArt)
				cmd4 = SQLEXEC(lnHandle, "Select d.punitario, d.cantidad from guiasremision c inner join detaguiasremision d on c.unico= d.unico "+ ;
						"INNER JOIN Productos p ON p.Codigo= d.Producto Where c.Cliente=?mCliente And p.idSqm=?mGrupoArt And c.fecha>= ?mFecModif and c.motivoguia= 1 and c.Anulada= 0", "cVenta")
			ELSE
				cmd4 = SQLEXEC(lnHandle, "Select d.punitario, d.cantidad from guiasremision c inner join detaguiasremision d on c.unico= d.unico "+ ;
						"Where c.Cliente=?mCliente And d.Producto=?mProducto And c.fecha>= ?mFecModif and c.motivoguia= 1 and c.Anulada= 0", "cVenta")					
			ENDIF
		ENDIF
		
		IF RECCOUNT('cVenta')= 0
			mUltPrecLis = .F.
			IF !EMPTY(mGrupoCli)
				IF !EMPTY(mGrupoArt)
					SELECT p.Fecha, p.Lista, p.PrecioLista FROM cListaPrecios p INNER JOIN cCliGrupo c ON p.Cliente= c.Codigo INNER JOIN cArtGrupo a ON a.Codigo = p.Producto ;
							WHERE p.NuevoPrecio= mPreModif INTO CURSOR cPrecLista ORDER BY p.Fecha
					IF _Tally= 0
						mUltPrecLis = .T.
						SELECT p.Fecha, p.Lista, p.PrecioLista FROM cListaPrecios p INNER JOIN cCliGrupo c ON p.Cliente= c.Codigo INNER JOIN cArtGrupo a ON a.Codigo = p.Producto ;
							INTO CURSOR cPrecLista ORDER BY p.Fecha
					ENDIF
				ELSE
					SELECT p.Fecha, p.Lista, p.PrecioLista FROM cListaPrecios p INNER JOIN cCliGrupo c ON p.Cliente= c.Codigo WHERE p.Producto= mProducto AND p.NuevoPrecio= mPreModif INTO CURSOR cPrecLista ORDER BY p.Fecha
					IF _Tally= 0
						mUltPrecLis = .T.
						SELECT p.Fecha, p.Lista, p.PrecioLista FROM cListaPrecios p INNER JOIN cCliGrupo c ON p.Cliente= c.Codigo WHERE p.Producto= mProducto INTO CURSOR cPrecLista ORDER BY p.Fecha
					ENDIF
				ENDIF
			ELSE
				IF !EMPTY(mGrupoArt)
					SELECT p.Fecha, p.Lista, p.PrecioLista FROM cListaPrecios p INNER JOIN cArtGrupo a ON a.Codigo= p.Producto WHERE Cliente= mCliente AND NuevoPrecio= mPreModif INTO CURSOR cPrecLista ORDER BY Fecha
					IF _Tally= 0
						mUltPrecLis = .T.
						SELECT p.Fecha, p.Lista, p.PrecioLista FROM cListaPrecios p INNER JOIN cArtGrupo a ON a.Codigo= p.Producto WHERE Cliente= mCliente INTO CURSOR cPrecLista ORDER BY Fecha
					ENDIF
				ELSE
					SELECT Fecha, Lista, PrecioLista FROM cListaPrecios WHERE Cliente= mCliente AND Producto= mProducto AND NuevoPrecio= mPreModif INTO CURSOR cPrecLista ORDER BY Fecha
					IF _Tally= 0
						mUltPrecLis = .T.
						SELECT Fecha, Lista, PrecioLista FROM cListaPrecios WHERE Cliente= mCliente AND Producto= mProducto INTO CURSOR cPrecLista ORDER BY Fecha
					ENDIF
				ENDIF
			ENDIF
			GO BOTTOM
			mPrecLista = cPrecLista.PrecioLista
			mFecLista  = cPrecLista.Fecha
			
			SELECT cPrecios
			Replace NombreCli WITH mNomCli, NombreArt WITH mNomArt
			Replace Restaurar WITH 'X', PrecioLista WITH mPrecLista, UltPrecLista WITH IIF(mUltPrecLis, '1', '0'), FecPrecLista WITH mFecLista
			
			USE IN cPrecLista
			USE IN cArtGrupo
		ENDIF
		USE IN cVenta
	ENDSCAN
	
	USE IN cCliGrupo
	
	SELECT cPrecios
ENDDO

USE IN cListaPrecios

USE IN listacambioprecio
USE IN listcampredetalle
USE IN fulldetalle
USE IN listachinos
USE IN listachinosdetalle
USE IN fulldetallechino
CLOSE DATABASES

WAIT WINDOW 'Proceso terminado' NoWait

RETURN




PROCEDURE ActPreciosCotizaOtrosCli

vusuario = 'SISTEMAS'

cmd1=SQLEXEC(lnHandle,"Select c.id, c.anio, c.correlativo, c.cliente, cl.grupo, c.fecha, c.Moneda from cotizaciones c inner join clientes cl on c.cliente= cl.codigo "+ ;
						"where (c.codreferencia= 1 or c.codreferencia= 3) and c.masiva= 0 and c.fecha > '2018-06-01' and LENGTH(TRIM(IFNULL(cl.grupo, '')))> 0 Order by c.id", "cCotizaActPre")
SELECT cCotizaActPre
mRegTot = RECCOUNT()
SCAN
	WAIT Windows 'Procesado '+ STR(RECNO() / mRegTot * 100, 5,2)+ ' ...' NoWait
	mIdGrupo= ALLTRIM(cCotizaActPre.Grupo)
	mCliOri = ALLTRIM(cCotizaActPre.Cliente)
	mIdCoti = cCotizaActPre.ID
	mFecCot = cCotizaActPre.Fecha
	mMonCot = cCotizaActPre.Moneda
	IF !EMPTY(mIdGrupo)
		cmd2=SQLEXEC(lnHandle,"Select unico, producto, um, precio From DetaCotizaciones Where Unico=?mIdCoti", "Myprecioscotizados")
		
		cmd3=SQLEXEC(lnHandle,"SELECT codigo FROM Clientes  WHERE grupo=?mIdGrupo","MySel")
		SELECT MySel
		DELETE ALL FOR ALLTRIM(MySel.codigo)= mCliOri
		GO TOP
		SCAN FOR !DELETED()
			mOtroCli= ALLTRIM(MySel.Codigo)
			
			SELECT Myprecioscotizados
			SCAN
				a1= mOtroCli
				a2= Myprecioscotizados.Producto
				a3= Myprecioscotizados.um
				a4= mFecCot
				a5= Myprecioscotizados.Precio
				a6= mMonCot
				a7= mFecCot
				a8=0
				a9=0
				a10=CTOD("  /  /  ")
				a11=CTOD("  /  /  ") && Ultima Compra
				a12=0 && Masivo
				a13=0
				a20=0
				a21=0
				a22='Copia Autom. Precio desde '+ mCliOri
				
				cmd10=SQLEXEC(lnHandle,"SELECT producto FROM preciostockclientes WHERE cliente=?a1 and Producto=?a2","averigua")
				IF RECCOUNT('averigua') = 0 && Si no tiene registrado el producto
					cmd2=SQLEXEC(lnHandle,"INSERT INTO preciostockclientes (cliente,producto,um,fechaingreso,precio,moneda, fechamodifi,"+;
								"activoespecial,precioespecial,fechaprecioesp, ultimacompra,masivo,idcotiespecial,preciocontado,idcoticontado,usuariomod) "+;
								"VALUES (?a1,?a2,?a3,?a4,?a5,?a6,?a7,?a8,?a9,?a10,?a11,?a12,?a13,?a20,?a21,?vusuario)")
				ELSE
					cmd2=SQLEXEC(lnHandle,"UPDATE preciostockclientes SET precio=?a5,moneda=?a6,fechamodifi=?a7, masivo=0, usuariomod=?vusuario WHERE "+;
						" cliente=?a1 and producto=?a2 ")
				ENDIF
				cmd3=SQLEXEC(lnHandle,"INSERT INTO masdetalleprecios (cliente,producto,fecha,precio,referencia,fechahora) "+;
					" VALUES (?a1,?a2,?a7,?a5,?a22,current_timestamp) ")
				USE IN averigua
			
				** Actualizando en grupos de artículos
				cmd1=SQLEXEC(lnHandle,"SELECT idsqm FROM productos WHERE codigo=?a2","Temp01")
				GO TOP IN Temp01
				IF !EMPTY(ALLTRIM(Temp01.idsqm)) && Si es producto agrupado
					mGrupoArt=Temp01.idsqm
					cmd1 = SQLEXEC(lnHandle,"SELECT codigo, UM FROM productos WHERE idsqm=?mGrupoArt","Temp02")
					SELECT Temp02
					GO TOP
					SCAN
						IF ALLTRIM(Temp02.codigo)= ALLTRIM(a2)
							LOOP
						ENDIF
						MyproBase= Temp02.codigo
						mUM      = ALLTRIM(Temp02.UM)
						cmd2 = SQLEXEC(lnHandle,"Select id From preciostockclientes WHERE cliente=?a1 and producto=?MyproBase", "cExistePre")
						GO TOP IN cExistePre
						IF EOF('cExistePre')
							cmd3= SQLEXEC(lnHandle,"INSERT INTO preciostockclientes (cliente,producto,um,fechaingreso,precio,moneda,fechamodifi,masivo,usuariomod) "+;
														"VALUES (?a1,?MyproBase,?mUM,?a4,?a5,?a6,?a7,0,?vusuario)")
						ELSE
							cmd3= SQLEXEC(lnHandle,"UPDATE preciostockclientes SET precio=?a5,fechamodifi=?a7,masivo=0, moneda=?a6,usuariomod=?vusuario WHERE cliente=?a1 and producto=?MyproBase")
						ENDIF
						
						cmd3=SQLEXEC(lnHandle,"INSERT INTO masdetalleprecios (cliente,producto,fecha,precio,referencia,fechahora) "+;
									" VALUES (?a1,?MyproBase,?a7,?a5,?a22,current_timestamp) ")
						USE IN cExistePre
					ENDSCAN
					USE IN Temp02
				ENDIF
				USE IN Temp01
				***
			ENDSCAN
			SELECT MySel
		ENDSCAN
		USE IN MySel
		USE IN Myprecioscotizados
	ENDIF
ENDSCAN

USE IN cCotizaActPre
Return


PROCEDURE DepuraMasdetalle
SUSPEND

cmd1=SQLEXEC(lnHandle,"Select cliente, producto, fecha, precio, referencia, count(*) as cantreg, max(id) as idelim from masdetalleprecios "+ ;
		"WHERE FECHA > '2018-07-01' group by cliente, producto, fecha, precio, referencia having count(*) > 1", "cRegElim")


SELECT cRegElim
SCAN
	mIdElim = IdElim
	cmd2=SQLEXEC(lnHandle,"Delete from masdetalleprecios Where id=?mIdElim")
ENDSCAN

USE IN cRegElim
RETURN


