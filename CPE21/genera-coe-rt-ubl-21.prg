*************************************
** GENERA TXT PARA FACTURA ELECTRONICA - SUNAT
** DESDE FUENTE DE RETENCION
*************************************
***DEFINICION PARA AMBIENTE DE RED***
*************************************
SET OPTIMIZE ON
SET EXCLUSIVE OFF && PERMITE QUE UNA TABLA ABIERTA EN UNA RED SE PUEDA COMPARTIR
&& Y MODIFICAR POR CUALQUIER USUARIO DE LA RED
SET MULTILOCKS ON && PARA QUE SE PUEDAN BLOQUEAR MAS DE UN REGISTRO
SET DELETE ON     && PARA QUE LOS REGISTROS MARCADOS NO SE VISUALICEN
SET REFRESH TO 5  && REFRESCAMIENTO CADA 5 SEGUNDOS EN UNA VENTANA EXAMINAR ABIERTA con BROWSE
&& CHANGE o EDIT
SET REPROCESS TO 5 SECONDS && SI DESPUES DE 5 SEGUNDOS NO PUEDE ACTUALIZARLO FOX MANDA UN ERROR.
*************************************
SET SYSMENU OFF
SET TALK OFF      && DESACTIVA LA VISUALIZACION DE RESULTADOS DE LOS COMANDOS
SET CENTURY ON    && 4 DIGITOS PARA EL AÑO
SET DATE DMY      && FORMATO DE FECHA DIA/MES/AÑO
SET ANSI ON       && LA CADENA MAS CORTA SE RELLENARA CON LOS ESPACIOS EN BLANCO NECESARIOS
&& PARA IGUALAR A LA LONGITUD DE LA CADENA MAS LARGA. ("TOMMY"<>"TOM  ")
SET ESCAPE OFF    && DESACTIVA LA TECLA ESC
SET NEAR ON       && COLOCA EL PUNTERO DE REGISTRO AL FINAL DE LA TABLA, EN CASO DE
&& QUE UNA BUSQUEDA DE REGISTRO MEDIANTE FIND O SEEK NO TENGA EXITO.
SET NOTIFY ON     && CONECTA LA VISUALIZACION DE MENSAJES DEL SISTEMA
SET FDOW TO 2
********************************
CLEAR MACROS
CLOSE ALL
CLEAR ALL

SET CENTURY ON

SET ECHO OFF
SET TALK OFF
SET SAFETY OFF
SET DELETED ON
SET DATE BRITISH

PUBLIC m.pcFolderStyle, lgMaquina, GAMYARRAY, x_Esexportacion
LOCAL lcsys16, lcprogram

lcsys16 = SYS(16)
lcprogram = SUBSTR(lcsys16,AT(":", lcsys16) - 1)

lcRuta = STRTRAN(LEFT(lcprogram, RAT("\", lcprogram)),"\PROGS","")
LOCAL lcPath

SET DEFAULT TO [&lcRuta]
lcPath = lcRuta
cPathPc00 = lcRuta
cPathPc10 = m.lcPath + "Formularios\"
cPathPc11 = m.lcPath + "Informes\"
cPathPc12 = m.lcPath + "Progs\"
cPathPc13 = m.lcPath + "Dibujos\"
cPathPc14 = m.lcPath + "FoxyPreviewer v299z30\"
cPathPc15 = m.lcPath + "VCX\"
cPathPc16 = m.lcPath + "Images\"
cPathPc17 = m.lcPath + "Librerias\"
cPathPc18 = m.lcPath + "Data\"

lcPathGeneral = cPathPc00 +";"+ cPathPc10 +";"+ cPathPc11 +";"+ cPathPc12 +";"+ cPathPc13 +";"+ cPathPc14 +";"+ cPathPc15  +";"+ cPathPc16 +";"+ cPathPc17 +";"+ cPathPc18
m.lcPath  = lcPathGeneral

SET PATH TO ..\PROGS,..\INFORMES,..\FORMULARIOS,..\DIBUJOS,..\DATA,..\librerias,&lcPathGeneral;

SET PROCEDURE TO funciones

xServer=2

IF xServer=1
	MyString_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
		"SERVER=192.168.1.179;" + ;
		"PORT=3306;" + ;
		"UID=sistemas;" + ;
		"PWD=d3b14nfw123;" + ;
		"DATABASE=sqmdata;" + ;
		"OPTIONS=0;"
ELSE
	MyString_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
		"SERVER=192.168.1.179;" + ;
		"PORT=3306;" + ;
		"UID=sistemas;" + ;
		"PWD=d3b14nfw123;" + ;
		"DATABASE=sqmdata;" + ;
		"OPTIONS=0;"
*!*		MyString_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
*!*			"SERVER=localhost;" + ;
*!*			"PORT=3387;" + ;
*!*			"UID=root;" + ;
*!*			"PWD=987654321;" + ;
*!*			"DATABASE=sqmdata;" + ;
*!*			"OPTIONS=0;"
ENDIF

mSL = '' && CHR(13)+ CHR(10)
#DEFINE LF_CR CHR(13)
#DEFINE LF_RR CHR(10)+CHR(13)
#DEFINE TABU CHR(9)

LOCAL Seriedoc, Numerodoc

*Codigosqm='S030'   && Codigosqm='I131'
Codigosqm='I207'   && Codigosqm='I131'

Seriedoc  = "R001"
Numerodoc = 3299

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0

	lcCadenaSql= "Select c.seriecr, c.numerocr, d.id, c.Fechacr, c.FechaPago, c.tipocam, ";
			+" c.porcretencion, c.tpagado, c.tretenido, c.observaciones, ";
			+" p.tiposunat, p.ruc, p.nombre, p.direccion, p.prov, p.dpto, p.dist, p.pais, p.ubigeo, ";
			+" d.tipodoc, d.serie, d.numero, d.femision, d.moneda, d.totaldoc, d.correlpago,  ";
			+" d.pagadodol, d.retenciondol, d.pagadosol, d.retencionsol, p.cpe01, p.cpe02 ";
			+" from Retencionp c inner join Detaretencionp d on c.idcr = d.idcr  ";
			+" inner join Clientes p on c.codigop = p.codigo  ";
			+" WHERE c.seriecr=?Seriedoc AND c.numerocr=?Numerodoc ";
			+" order by 1,2,3"
				
	cmd1 = SQLEXEC(lnHandle,lcCadenaSql,"cCR")
	cmd2 = SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codigosqm","Empresa")
	cmd3 = SQLEXEC(lnHandle,"SELECT * FROM k_sunatelectronica ","SunatDE")
	SQLDISCONNECT(lnHandle)

ELSE
	AERROR(laErr)
	MESSAGEBOX("No se pudo conectar a la base de datos"+ CHR(13)+ "Error: " + laErr[2])
	SQLDISCONNECT(lnHandle)
	RETURN
ENDIF

*----------------------------------------------------------------------
* 02 DATOS DEL EMISOR					
*----------------------------------------------------------------------
* Número de RUC del emisor
* Tipo de Documento de Identidad del emisor
* Apellidos y nombres,  denominación o razón social 
* Nombre comercial
* Código de ubigeo
* Dirección completa y detallada
* Urbanización
* Provincia
* Departamento
* Distrito
* Código de país 
* Separador de linea

a_Parte02 = ALLTRIM(Empresa.ruc)
b_Parte02 = '6' 
c_Parte02 = ALLTRIM(Empresa.nombre)
d_Parte02 = ALLTRIM(Empresa.nombre)
e_Parte02 = ALLTRIM(SunatDE.c_myubigeo)
f_Parte02 = ALLTRIM(Empresa.direccion)
g_Parte02 = ALLTRIM(SunatDE.c_myurbanizacion) 
h_Parte02 = ALLTRIM(Empresa.prov)
i_parte02 = ALLTRIM(Empresa.dpto)
j_parte02 = ALLTRIM(Empresa.dist)
k_Parte02 = ALLTRIM(Empresa.pais)  && Basado en Catalogo 04
*----------------------------------------------------------------------
*----------------------------------------------------------------------


SELECT cCR
GO Top
DO WHILE !EOF()
	SCATTER MEMVAR Memo
	IF ISNULL(m.Observaciones)
		m.Observaciones = ''
	ENDIF
	
	mNroCR = ALLTRIM(m.SerieCR)+ '-'+ TRans(m.numerocr, '@L 9999999')
	mFecCR = LEFT(DTOS(m.FechaCR),4)+ '-'+ SUBSTR(DTOS(m.FechaCR),5,2)+ '-'+ RIGHT(DTOS(m.FechaCR), 2)
	
	*----------------------------------------------------
	* 01 CABECERA
	*----------------------------------------------------
	* Tipo de documento.
	* Numeración, conformada por serie y número correlativo
	* Fecha de emisión
	* Separador de linea
	* Separador de sección
	* mParte01
	*----------------------------------------------------
	
	mParte01 = '20' + '|'+ mNroCR+ '|'+ mFecCR + '}'+ mSL+ LF_CR + '~'+ LF_CR+ mSL
	
	mParte02 = a_Parte02+'|'+b_Parte02+'|'+c_Parte02+'|'+d_Parte02+'|'+e_Parte02+'|'+f_Parte02+'|'+g_Parte02+'|'+h_Parte02+'|'+i_parte02+'|'+;
			j_parte02+'|'+k_Parte02+'}'+ LF_CR+ mSL
	
	*----------------------------------------------------
	* 03 DATOS DEL PROVEEDOR					
	*----------------------------------------------------
	* Número de RUC del proveedor
	* Tipo de Documento de Identidad del proveedor
	* Apellidos y nombres,  denominación o razón social 
	* Nombre comercial
	* Código de ubigeo
	* Dirección completa y detallada
	* Urbanización
	* Provincia
	* Departamento
	* Distrito
	* Código de país 
	* Separador de linea
	* Separador de sección
	*----------------------------------------------------
	
	a_Parte03 = IIF(ALLTRIM(m.tiposunat)='0', '0', ALLTRIM(m.ruc))
	b_Parte03 = ALLTRIM(m.tiposunat) &&& Tipo de Documento Catalogo 6  Revisar la Validacion solo asumimmos ruc mIentras
	c_Parte03 = ALLTRIM(m.nombre)
	d_Parte03 = ''   && Nombre comercial
	e_Parte03 = IIF(ISNULL(m.ubigeo), '', ALLTRIM(m.ubigeo))         && Ubigeo '150116' de Lince
	f_Parte03 = ALLTRIM(m.direccion)
	g_Parte03 = ''   && Urbanizacion
	
	IF ATC(ALLTRIM(m.dist), m.direccion) > 0   && Si el distrito está dentro de la dirección, no enviarlos por separado.
		h_Parte03 = ''
		i_parte03 = ''
		j_parte03 = ''
	ELSE
		h_Parte03 = ALLTRIM(m.prov)
		i_parte03 = ALLTRIM(m.dpto)
		j_parte03 = ALLTRIM(m.dist)
	ENDIF
	
	k_Parte03 = ALLTRIM(m.pais)  && Basado en Catalogo 04
	
	mParte03 =a_Parte03+ '|'+b_Parte03+'|'+c_Parte03+'|'+d_Parte03+'|'+e_Parte03+'|'+f_parte03+'|'+g_parte03+'|'+h_Parte03+'|'+i_Parte03+'|'+j_Parte03+'|'+k_Parte03+'}'+ mSL+ LF_CR + '~' + LF_CR + mSL
	
	*----------------------------------------------------
	* 04 DATOS DE RETENCIÓN DEL CRE					
	*----------------------------------------------------
	* Régimen de Retención (01: 3%)
	* Tasa de Retención
	* Observaciones
	* Importe total Retenido - sumatoria -> SUNATRetentionAmount (detalle)
	* Moneda del Importe total Retenido - En moneda nacional
	* Importe de pago sin Retención - sumatoria -> SUNATNetTotalPaid (detalle)
	* Moneda del Importe total Pagado - En moneda nacional
	* Separador de linea
	* Separador de sección
	* 
	*----------------------------------------------------

	mParte04 = '01'+ '|'+ ALLTRIM(STR(m.PorcRetencion, 5,2))+ '|'+ ALLTRIM(m.Observaciones)+ '|'+ ALLTRIM(STR(m.tretenido,10,2));
				+ '|'+ 'PEN'+ '|'+ ALLTRIM(STR(m.tpagado,10,2))+ '|'+ 'PEN'+ '}' ;
				+ mSL+ LF_CR + '~' + LF_CR + mSL   && Regimen retencion / tasa retencion / observaciones / ...
	
	
	*----------------------------------------------------
	* 05 DATOS DE COMPROBANTES DE REFERENCIA - En caso de contener FC y NC, la FC debe enviarse con los montos neteados 					
	*----------------------------------------------------
	


	mDeta_05_08 = ''
	SCAN WHILE seriecr = m.seriecr AND numerocr = m.numerocr
		SCATTER MEMVAR FIELD EXCEPT Observaciones
		** Detalle
		mDocProv = ALLTRIM(m.serie)+ '-'+ Trans(m.numero, '@L 9999999')
		mFDocPro = LEFT(DTOS(m.FEmision),4)+ '-'+ SUBSTR(DTOS(m.FEmision),5,2)+ '-'+ RIGHT(DTOS(m.FEmision), 2)
		mMonProv = IIF(m.Moneda = 'M1', 'PEN', 'USD')
		
		* Número de documento Relacionado
		* Tipo de documento Relacionado
		* Fecha emisión documento Relacionado
		* Importe total documento Relacionado
		* Tipo de moneda documento Relacionado

		mParte05 = mDocProv+ '|'+ ALLTRIM(m.TipoDoc)+ '|'+ mFDocPro+ '|'+ ALLTRIM(STR(m.totaldoc,10,2))+ '|'+ mMonProv+ '|'
		
		** Datos del pago
		IF m.TipoDoc = '07'    && En Nota de crédito no se envian los datos del pago
			mFecPago    = ''
			mNroPago    = ''
			mNetoPagado = ''
			mMonProv    = ''
		ELSE
			mFecPago = LEFT(DTOS(m.FechaPago),4)+ '-'+ SUBSTR(DTOS(m.FechaPago),5,2)+ '-'+ RIGHT(DTOS(m.FechaPago), 2)
			mNroPago = ''
			mPagado  = IIF(m.Moneda = 'M1', m.pagadosol, m.pagadodol)
			IF m.totaldoc = IIF(m.Moneda = 'M1', m.pagadosol, m.pagadodol)
				mNroPago = '1'    && No pago parcial
			ELSE
				mNroPago = ALLTRIM(STR(m.correlpago))    && pago parcial
			ENDIF
			mNetoPagado = ALLTRIM(STR(IIF(m.Moneda = 'M1', m.pagadosol, m.pagadodol),10,2))
		ENDIF
		
		* Fecha de pago
		* Número de pago - En el caso que no exista pagos parciales enviar 1, caso contrario será el correlativo de pago
		* Importe de pago sin retención
		* Moneda de pago - Moneda original
		mParte06 = mFecPago+ '|'+ mNroPago+ '|'+ mNetoPagado+ '|'+ mMonProv+ '|' 
		
		** Datos de la retención
		IF m.TipoDoc = '07'    && En Nota de crédito no se envian los datos de la retención
			mRetenSol   = ''
			mBaseRetSol = ''
			mMonSoles   = ''
		ELSE
			mRetenSol  = ALLTRIM(STR(m.retencionsol,10,2))
			*mBaseRetSol= ALLTRIM(STR(m.pagadosol - m.retencionsol,10,2))
			mBaseRetSol= ALLTRIM(STR(m.pagadosol,10,2))
			mMonSoles  = 'PEN'
		ENDIF
		
		* Importe retenido PaidAmount (PEN) * % Retencion
		* Moneda de importe retenido - En moneda nacional
		* Fecha de Retención
		* Base de la retención - PaidAmount (PEN) - SUNATRetentionAmount
		* Moneda del monto neto pagado - En moneda nacional
		
		mParte07 = mRetenSol+ '|'+ mMonSoles+ '|'+ mFecPago+ '|'+ mBaseRetSol+ '|'+ mMonSoles+ '|'
		
		** Tipo de cambio
		IF m.TipoDoc = '07'    && En Nota de crédito no se envian los datos del tipo de cambio
			mTipoCam = ''
		ELSE
			mTipoCam = ALLTRIM(STR(m.tipocam,6,3))
		ENDIF

		* La moneda de referencia para el Tipo de Cambio
		* La moneda objetivo para la Tasa de Cambio
		* El factor aplicado a la moneda de origen para calcular la moneda de destino (Tipo de cambio)
		* Fecha de cambio
		* Separador de linea
		* Separador de sección

		mParte08 = mMonProv+ '|'+ mMonSoles+ '|'+ mTipoCam+ '|'+ mFecPago+ '}'+ LF_CR +mSL
		
		mDeta_05_08 = mDeta_05_08+ mParte05+ mParte06+ mParte07+ mParte08
	
	ENDSCAN
	
	mDeta_05_08 = mDeta_05_08 + LF_CR + '~' + mSL
	
	** Adjuntos
	mMontoPalabra = ALLT(Convnum(m.tretenido))+ " SOLES"
	
	yy_01=ALLTRIM(cCR.cpe01)
	yy_02=ALLTRIM(cCR.cpe02)
	IF LEN(yy_02)< 7 && Longitud minima correo
		MyListaCorreo=yy_01
	ELSE
		MyListaCorreo=yy_01+';'+yy_02
	ENDIF

	*mCorreoProv = 'egutierrez@sociedadquimica.com.pe'
	
	IF xServer=2
		mCorreoProv = 'egutierrez@sociedadquimica.com.pe'   &&'dvilela@sociedadquimica.com.pe'
	ELSE
		mCorreoProv = MyListaCorreo+ ';'+ 'cpe_sqm@sociedadquimica.com.pe'
	ENDIF
	
	mObserv2    = ''   && Esta observacion ya no se considera.
	mImpresora  = ''
	mCopias     = ''
	
	
	* Campo a definir por el cliente
	* Campo a definir por el cliente
	* Campo a definir por el cliente
	* Separador de linea
	* Observación
	* Monto en palabras
	* Correo electrónico al cual se enviará el comprobante en formato PDF y XMLSi es más de un correo se debe separar por "";"". Ej: correo1@mail.pe;correo2@mail.pe"
	* Se debe encontrar conectada en red y visible desde el servidor de facturación.
	* Número de páginas a imprimir
	* "emitir" (utilizar para implementaciones SPOOL)
	
	* Separador de linea
	* Separador de sección
	* Fin de registro


	*mParte09 = '|'+ '|'+ '|'+ '|'+ 
	mParte09 = '|'+ '|'+ '}'+ LF_CR + mSL + mObserv2+ '|'+ mMontoPalabra+ '|'+ mCorreoProv+ '|'+ mImpresora+ '|'+ mCopias+ '|'+ '}'+ ;
				mSL + LF_CR + '~'+ mSL + LF_CR + '\'
	
	mPartes = mParte01+ mParte02+ mParte03+ mParte04+ mDeta_05_08+ mParte09
	
	IF xServer=2
		xControl='c:\ventas\inputprod\'+ mNroCR+'.txt'
	ELSE
		*xControl='\\SQMSERVER\inputprod\'+ mNroCR+'.txt'
	ENDIF
	
	gnErrFile = FCREATE(xControl)
	IF gnErrFile>0
		=FPUTS(gnErrFile,mPartes)
	ENDIF
	=FCLOSE(gnErrFile)

ENDDO
