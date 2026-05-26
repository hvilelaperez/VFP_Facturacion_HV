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

SET PROCEDURE TO funciones
SET CENTURY ON

SET ECHO OFF
SET TALK OFF
SET SAFETY OFF
SET DELETED ON
SET DATE BRITISH

**DV.17.03.20************************************************************
PUBLIC m.pcFolderStyle, lgMaquina, GAMYARRAY, x_Esexportacion
LOCAL lcsys16, lcprogram

x_Esexportacion = 0
lcsys16 = SYS(16)
lcprogram = SUBSTR(lcsys16,AT(":", lcsys16) - 1)

lcRuta = STRTRAN(LEFT(lcprogram, RAT("\", lcprogram)),"\PROGS","")
LOCAL lcPath

**SISTEMAS # Administrator
**DV.17.03.20************************************************************
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

**DV.17.03.20************************************************************
lcPathGeneral = cPathPc00 +";"+ cPathPc10 +";"+ cPathPc11 +";"+ cPathPc12 +";"+ cPathPc13 +";"+ cPathPc14 +";"+ cPathPc15  +";"+ cPathPc16 +";"+ cPathPc17 +";"+ cPathPc18
m.lcPath  = lcPathGeneral

SET PATH TO ..\PROGS,..\INFORMES,..\FORMULARIOS,..\DIBUJOS,..\DATA,..\librerias,&lcPathGeneral;

xServer=2

IF xServer=1
	*MyString= "DRIVER={MySQL ODBC 3.51 Driver};" + ;
	*	"SERVER=192.168.1.79;" + ;
	*	"PORT=3304;" + ;
	*	"UID=sistemas;" + ;
	*	"PWD=informatica;" + ;
	*	"DATABASE=indicolor;" + ;
	*	"OPTIONS=0;"

	MyString= "DRIVER={MySQL ODBC 3.51 Driver};" + ;
		"SERVER=192.168.1.179;" + ;
		"PORT=3306;" + ;
		"UID=sistemas;" + ;
		"PWD=d3b14nfw123;" + ;
		"DATABASE=sqmdata;" + ;
		"OPTIONS=0;"

ELSE
	*MyString= "DRIVER={MySQL ODBC 3.51 Driver};" + ;
	*	"SERVER=localhost;" + ;
	*	"PORT=3306;" + ;
	*	"UID=root;" + ;
	*	"PWD=987654321;" + ;
	*	"DATABASE=indicolor;" + ;
	*	"OPTIONS=0;"

	*MyString= "DRIVER={MySQL ODBC 3.51 Driver};" + ;
	*	"SERVER=localhost;" + ;
	*	"PORT=3387;" + ;
	*	"UID=root;" + ;
	*	"PWD=987654321;" + ;
	*	"DATABASE=sqmdata;" + ;
	*	"OPTIONS=0;"
	
	MyString= "DRIVER={MySQL ODBC 3.51 Driver};" + ;
		"SERVER=192.168.1.179;" + ;
		"PORT=3306;" + ;
		"UID=sistemas;" + ;
		"PWD=d3b14nfw123;" + ;
		"DATABASE=sqmdata;" + ;
		"OPTIONS=0;"

ENDIF

*MyString= "DRIVER={MySQL ODBC 3.51 Driver};" + ;
*                    "SERVER=192.168.1.252;" + ;
*                    "PORT=3306;" + ;
*                    "UID=sistemas;" + ;
*                    "PWD=informatica;" + ;
*                    "DATABASE=indicolor;" + ;
*                    "OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(MyString)

#DEFINE LF_CR CHR(13)
#DEFINE LF_RR CHR(10)+CHR(13)

#DEFINE TABU CHR(9)
SET DELETED ON

*LOCAL xControl,Snt_Documento,StrBody,Pase1,Codigosqm,DocuIgv,Miserie,MitipoDoc,Seriedoc,Numerodoc,Hoy
*LOCAL FraseMG,FraseBoleta,AcumulaMG,FraseDetrac01,FraseDetrac02,MinSolesDetrac,MinDolarDetrac,TcVentaHoy,PctjeDetracServ,x_isExport,x_EsLibre
*LOCAL MiPedVtaSuc,CtaRegVs,CtaMiReg,NotaVs01,FraseVs01,MyUbigeo,MyUrbanizacion,MyListaCorreo,x_ChargeNc, mSwExporta, CDCondipag

LOCAL xControl,Snt_Documento,StrBody,Pase1,Codigosqm,Miserie,MitipoDoc
LOCAL Seriedoc,Numerodoc,Hoy, FraseMG,FraseBoleta,AcumulaMG,FraseDetrac01
LOCAL FraseDetrac02,MinSolesDetrac,MinDolarDetrac,TcVentaHoy,PctjeDetracServ
LOCAL x_isExport,x_EsLibre, MiPedVtaSuc,CtaRegVs,CtaMiReg,NotaVs01,FraseVs01
LOCAL MyUbigeo,MyUrbanizacion,MyListaCorreo,x_ChargeNc, mSwExporta, CDCondipag
LOCAL IsInafecta
LOCAL mAfecDetrac, mIdFactura, mSer_ref, mPedidoVS

mAfecDetrac = ''
mIdFactura  = 0
mPedidoVS   = ''
mSer_ref = 0

mCondPagGratis= 'MG'     && las muestras gratis inafecto.

mSwExporta = 0
Iscondipag = 0
Codigosqm= 'I207'   && 'I131'

AcumulaMG=0
x_isExport=0
x_EsLibre=0
CtaRegVs=0
CtaMiReg=0
Hoy=DATE()

x01_StrBody=''
x02_StrBody=''
x03_StrBody=''
x04_StrBody=''
x05_StrBody=''
x06_StrBody=''
x07_StrBody=''
x08_StrBody=''
StrBody=''

x_ChargeNc=0

*--------------------------------------------------
*--------------------------------------------------
*MitipoDoc='C'
MitipoDoc='D'

*x_SunatipoApli = 'B'
x_SunatipoApli = 'F'

Seriedoc=10
*Numerodoc=204
*Numerodoc=241
*Numerodoc=255
*Numerodoc=134
*Numerodoc=254
*Numerodoc=4
Numerodoc=118


*--------------------------------------------------
*--------------------------------------------------

lnHandle = SQLSTRINGCONNECT(MyString)

IF lnHandle > 0
	cmd0=SQLEXEC(lnHandle,"SELECT * FROM constantes ","MiDatosPlus")
	cmd3=SQLEXEC(lnHandle,"SELECT * FROM k_sunatelectronica ","KonsMess")
	cmd2=SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codigosqm","MiDatasqm")
	cmd5=SQLEXEC(lnHandle,"SELECT venta FROM tcoficial WHERE fecha=?hoy","Cambiooficial")
	IF MitipoDoc='D'  && Debito
		cmd1=SQLEXEC(lnHandle,"SELECT a.*, 'F' as TipoDoc FROM ndebito a WHERE cpe=?x_SunatipoApli AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
		GO TOP IN SunatMidoc
		mCpe_ref= SunatMidoc.Cpe_Apli
		mSer_ref= SunatMidoc.Serie_Apli
		mNro_ref= SunatMidoc.Numero_Apli
		IF SunatMidoc.Cpe_Apli= 'F'
			cmd= SQLEXEC(lnHandle,"SELECT Unico, guiaserie, guianum, Exportacion, inafecta, condipag, TipoDetraccion, vspedido FROM Factura WHERE cpe=?mCpe_ref AND serie=?mSer_ref AND numero=?mNro_ref","cFacGuiaRef")
			GO TOP IN cFacGuiaRef
			mAfecDetrac = cFacGuiaRef.TipoDetraccion
			mIdFactura  = cFacGuiaRef.Unico
			mPedidoVS   = cFacGuiaRef.vspedido
			USE IN cFacGuiaRef
		ENDIF
	ELSE  && Credito
		cmd1=SQLEXEC(lnHandle,"SELECT a.* FROM ncredito a  WHERE cpe=?x_SunatipoApli AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
		GO TOP IN SunatMidoc
		mCpe_ref= SunatMidoc.CpeF
		mSer_ref= SunatMidoc.SerieF
		mNro_ref= SunatMidoc.NumeroF
		IF SunatMidoc.TipoDoc= 'F'
			cmd= SQLEXEC(lnHandle,"SELECT Unico, guiaserie, guianum, Exportacion, inafecta, condipag, TipoDetraccion, vspedido FROM Factura WHERE cpe=?mCpe_ref AND serie=?mSer_ref AND numero=?mNro_ref","cFacGuiaRef")
			GO TOP IN cFacGuiaRef
			mAfecDetrac = cFacGuiaRef.TipoDetraccion
			mIdFactura  = cFacGuiaRef.Unico
			mPedidoVS   = cFacGuiaRef.vspedido
			IF !ISNULL(cFacGuiaRef.guianum) AND cFacGuiaRef.guianum <> 0
				mSer_gr = cFacGuiaRef.guiaserie
				mNum_gr = cFacGuiaRef.guianum
				cmd= SQLEXEC(lnHandle,"SELECT FlagExportacion FROM GuiasRemision WHERE serie=?mSer_gr AND numero=?mNum_gr","cGuiaExp")
				GO TOP IN cGuiaExp
				IF !ISNULL(cGuiaExp.FlagExportacion)
					mSwExporta = cGuiaExp.FlagExportacion
				ENDIF
				USE IN cGuiaExp
			ELSE
				IF cFacGuiaRef.Exportacion = 1
					mSwExporta = 1
				ENDIF
			ENDIF
			USE IN cFacGuiaRef
		ELSE
			cmd= SQLEXEC(lnHandle,"SELECT Unico FROM Boleta WHERE cpe=?mCpe_ref AND serie=?mSer_ref AND numero=?mNro_ref","cFacGuiaRef")
			GO TOP IN cFacGuiaRef
			mIdFactura  = cFacGuiaRef.Unico
			USE IN cFacGuiaRef
		ENDIF
	ENDIF
	SQLDISCONNECT(lnHandle)
ELSE
	AERROR(laErr)
	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

IF USED("cFacGuiaRef")
	IsInafecta = cFacGuiaRef.inafecta
	CDCondipag = ALLTRIM(cFacGuiaRef.condipag)
ELSE
	IsInafecta=0
	CDCondipag = ""
ENDIF

IF mSwExporta = 1
	x_Esexportacion = 1
ELSE
	mSwExporta = 0
	x_Esexportacion = 0
ENDIF

MyUbigeo=ALLTRIM(KonsMess.c_myubigeo)
MyUrbanizacion=ALLTRIM(KonsMess.c_myurbanizacion)
FraseMG=ALLTRIM(KonsMess.c_frasemg)
FraseBoleta=ALLTRIM(KonsMess.c_fraseboleta)
FraseDetrac01=ALLTRIM(KonsMess.c_frasedetrac01)
FraseDetrac02=ALLTRIM(KonsMess.c_frasedetrac02)
FraseVs01=ALLTRIM(KonsMess.c_frasevs01)
NotaVs01=ALLTRIM(KonsMess.c_notavtasucesiva)

TcVentaHoy=Cambiooficial.venta
PctjeDetracServ=MiDatosPlus.percepcionserv
MinSolesDetrac=MiDatosPlus.minperservsoles
MinDolarDetrac=ROUND(MinSolesDetrac/TcVentaHoy,2)
Igv_ele=MiDatosPlus.igv
Miserie=SunatMidoc.serie

MiPedVtaSuc=''

SELECT SunatMidoc

LOCAL MyUnico
MyUnico=SunatMidoc.UNICO

*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte01
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
&& Código de tipo de documento
IF MitipoDoc='D'
	a_Parte01='08'  && Nota Debito
ELSE
	a_Parte01='07'  && Nota Credito
ENDIF
*---------------------------------------------------------------------------
&& Serie y número del comprobante <Serie>-<Número>La serie debe ser
&& alfanumérica de cuatro (4) caracteres, siendo el primer caracter
&& de la izquierda la letra F o BEl número correlativo podrá tener
&& hasta ocho (8) caracteres y se iniciará en 00000001.
*---------------------------------------------------------------------------
b_Parte01=x_SunatipoApli+TRANSFORM(serie,'@L 999')+'-'+TRANSFORM(numero,'@L 99999999')

y_Pyear=STR(YEAR(SunatMidoc.fecha),4,0)
y_Pmont=TRANSFORM(MONTH(SunatMidoc.fecha),"@L 99")
y_PDayy=TRANSFORM(DAY(SunatMidoc.fecha),"@L 99")

&&Fecha de emisión
c_Parte01=y_Pyear+'-'+y_Pmont+'-'+y_PDayy

DO CASE  && Catalogo 02 Anexo 08
		&& Código de tipo de moneda en la cual se emite la nota de crédito electrónica
	CASE SunatMidoc.Moneda='M1'
		d_Parte01='PEN'
	CASE SunatMidoc.Moneda='M2'
		d_Parte01='USD'
ENDCASE

*---------------------------------------------------------------------------
* 09/10/2018 - Incorpora la siguientes lineas de codigo
e_Parte01=''
f_Parte01=''
g_Parte01=''
h_Parte01=''
i_Parte01=''
j_Parte01=''  && Hora de emisión

k_Parte01=''  && Código de tipo de operación.
** 11/01/2019:  Asignar el codigo de tipo de operacion correspondiente
DO Case
	CASE x_Esexportacion= 1
		k_Parte01='0200'    && Exportación
	CASE !EMPTY(mAfecDetrac)
		k_Parte01='1001'    && Operación sujeta Detraccion 
	OTHERWISE
		k_Parte01='0101'    && Venta Interna
ENDCASE

*---------------------------------------------------------------------------

x01_StrBody=a_Parte01+'|'+b_Parte01+'|'+c_Parte01+'|'+d_Parte01+'|'+e_Parte01+'|';
	+f_Parte01+'|'+g_Parte01+'|'+h_Parte01+'|'+i_Parte01+'|'+j_Parte01+'|'+k_Parte01+ '}'

* Fin Parte01
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte02
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
SELECT MiDatasqm

&&Número de RUC del emisor
a_Parte02=ALLTRIM(MiDatasqm.ruc)
&& Tipo de Documento de Identidad del emisor
b_Parte02='6' &&& Tipo de Documento Catalogo 6 ruc

c_Parte02=ALLTRIM(MiDatasqm.nombre)
d_Parte02=ALLTRIM(MiDatasqm.nombre)
e_Parte02=MyUbigeo
f_Parte02=ALLTRIM(MiDatasqm.direccion)
g_Parte02=MyUrbanizacion
h_Parte02=ALLTRIM(MiDatasqm.prov)
i_parte02=ALLTRIM(MiDatasqm.dpto)
j_parte02=ALLTRIM(MiDatasqm.DIST)
k_Parte02=ALLTRIM(MiDatasqm.pais)  && Basado en Catalogo 04

** 10/10/2018: Nuevos campos
l_Parte02= ''   && Pagina web del emisor - opcional
m_Parte02= ''   && Telefono del emisor - opcional
n_Parte02= ''   && email del emisor - opcional
o_Parte02= '0000'  && Código de establecimiento anexo declarado en el ruc - obligatorio. Consultar a Contabilidad (**Obs**)

x02_StrBody=a_Parte02+'|'+b_Parte02+'|'+c_Parte02+'|'+d_Parte02+'|'+e_Parte02+'|'+;
			f_Parte02+'|'+g_Parte02+'|'+h_Parte02+'|'+i_parte02+'|'+j_parte02+'|'+;
			k_Parte02+'|'+l_Parte02+'|'+m_Parte02+'|'+n_Parte02+'|'+o_Parte02+'}'

* Fin Parte02
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte03
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------

LOCAL Codcli
Codcli=SunatMidoc.codigoc

lnHandle = SQLSTRINGCONNECT(MyString)

IF lnHandle > 0
	cmd1=SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codcli","MiCliente")
	SQLDISCONNECT(lnHandle)
ELSE
	AERROR(laErr)
	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Micliente
&& Número de RUC del receptor
a_Parte03=ALLTRIM(Micliente.ruc)
&& Tipo de Documento de Identidad del receptor
b_Parte03=ALLTRIM(Micliente.tiposunat)  &&& Tipo de Documento Catalogo 6  Revisar la Validacion solo asumimmos ruc mIentras

&& Nombre o razón social del receptor
c_Parte03=ALLTRIM(Micliente.nombre)
d_Parte03=''       && Nombre comercial del receptor - opcional
e_Parte03=''       && Código de ubigeo del receptor - opcional
f_Parte03=ALLTRIM(Micliente.direccion)
g_Parte03='' && Urbanizacion (SE HA QUITADO DE LA STRUCTURA)---
h_Parte03=ALLTRIM(Micliente.prov)
i_parte03=ALLTRIM(Micliente.dpto)
j_parte03=ALLTRIM(Micliente.DIST)
k_Parte03=ALLTRIM(Micliente.pais)  && Basado en Catalogo 04
l_Parte03= "0000"   && Código del domicilio fiscal o de local anexo del receptor   && 11/01/2019 Campo obligatorio consulta a Contabilidad

x03_StrBody=a_Parte03+'|'+b_Parte03+'|'+c_Parte03+'|'+d_Parte03+'|'+e_Parte03+'|'+;
			f_parte03+'|'+g_parte03+'|'+h_parte03+'|'+i_Parte03+'|'+j_Parte03+'|'+;
			k_Parte03+'|'+l_parte03+'}'+LF_CR+'~'

* Fin Parte03
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte04
* DATOS DE COMPROBANTE DE REFERENCIA
*---------------------------------------------------------------------------

&& 11/01/2019: Fecha del documento de referencia
IF MitipoDoc='D'
	d_Parte04= LEFT(DTOS(SunatMidoc.fecha_apli), 4)+ '-'+ SUBSTR(DTOS(SunatMidoc.fecha_apli),5,2)+ '-'+ RIGHT(DTOS(SunatMidoc.fecha_apli), 2)
ELSE
	d_Parte04= LEFT(DTOS(SunatMidoc.fechaF), 4)+ '-'+ SUBSTR(DTOS(SunatMidoc.fechaF),5,2)+ '-'+ RIGHT(DTOS(SunatMidoc.fechaF), 2)
ENDIF

IF MitipoDoc='D' &&& Para Nota de Debito
	&&Código de tipo de nota de débito
	b_Parte04= ALLTRIM(SunatMidoc.Motivo)
	DO CASE
		CASE b_Parte04= 'PROTESTO DE LETRA'
			a_Parte04 ='03' && 39 Catalogo 10 03: Penalidades / Otros conceptos
		CASE b_Parte04= 'REFINANCIAMIENTO'
			a_Parte04 ='03' && 39 Catalogo 10 03: Penalidades / Otros conceptos
		CASE b_Parte04= 'CHEQUE DEVUELTO'
			a_Parte04 ='03' && 39 Catalogo 10 03: Penalidades / Otros conceptos
		CASE b_Parte04= 'CORRECCION DE PRECIO'
			a_Parte04 ='02' && 39 Catalogo 10 02: Aumento en el valor
		CASE b_Parte04= 'INTERESES VARIOS'
			a_Parte04 ='03' && 39 Catalogo 10 03: Penalidades / Otros conceptos
		CASE b_Parte04= 'GASTOS VARIOS'
			a_Parte04 ='03' && 39 Catalogo 10 03: Penalidades / Otros conceptos
		OTHERWISE
			a_Parte04 ='03' && 39 Catalogo 10 03: Penalidades / Otros conceptos
	ENDCASE
	c_Parte04 = ALLTRIM(SunatMidoc.cpe_apli)+TRANSFORM(SunatMidoc.serie_apli,'@L 999')+'-'+TRANSFORM(SunatMidoc.numero_apli,'@L 99999999') &&38
	e_Parte04= TRANSFORM(SunatMidoc.tiposunat_apli,'@L 99')  &&41
ELSE   && Para Nota de Credito
	DO CASE
		CASE SunatMidoc.tipo=1
			a_Parte04 ='06' && 39 Catalogo 09  Devolucion por ItEM (07) --- TOTAL (06)
			b_Parte04='DEVOLUCION DE MERCADERIA'  &&40
		CASE SunatMidoc.tipo=2
			a_Parte04 ='04' && 39 Catalogo 09  Descuento Global
			b_Parte04='DESCUENTO DE PRECIO'
		CASE SunatMidoc.tipo=9
			a_Parte04 ='01' && 39 Catalogo 09  Anulacion de la operacion
			b_Parte04='ANULACION DE DOCUMENTO'
		CASE SunatMidoc.tipo=10
			a_Parte04 ='04' && 39 Catalogo 09  Descuento Global
			b_Parte04='DESCUENTO'  &&40
	ENDCASE
	
	IF !EMPTY(ALLTRIM(SunatMidoc.xmodifica))
		c_Parte04 = ALLTRIM(SunatMidoc.xmodifica)
		IF ALLTRIM(SunatMidoc.xTipoDoc)= 'Factura'
			e_Parte04= '01'
		ELSE
			e_Parte04= '03'
		ENDIF
	ELSE
		c_Parte04 =ALLTRIM(SunatMidoc.CpeF)+TRANSFORM(SunatMidoc.SerieF,'@L 999')+'-'+TRANSFORM(SunatMidoc.NumeroF,'@L 99999999') &&38
		DO CASE
			CASE SunatMidoc.TipoDoc='F'
				e_Parte04='01'  &&41
			CASE SunatMidoc.TipoDoc='B'
				e_Parte04='03'  &&41
		ENDCASE
	ENDIF
ENDIF

x04_StrBody=a_Parte04+'|'+b_Parte04+'|'+c_Parte04+'|'+d_Parte04+'|'+e_Parte04+'}'+LF_CR+'~'

* Fin Parte04
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte05
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------

&& Total Valor de Venta - Exportación / Exoneradas / Inafectas

IF x_Esexportacion = 1 OR IsInafecta= 1 OR (SunatMidoc.TipoDoc='F' And mSer_ref=60) 
	a_parte05= ALLTRIM(STR(SunatMidoc.neto,12,2))   && Total valor de la venta
	b_parte05= '0.00'         && Importe del tributo
	IF x_Esexportacion = 1
		c_parte05= 'G'        && Categoría de impuestos  G: Exportacion
		d_parte05= '9995'     && Código de tributo 
		e_parte05= 'EXP'      && Nombre de tributo
		f_parte05= 'FRE'      && Código internacional tributo
	ELSE
		c_parte05= 'O'        && Categoría de impuestos O: Inafecto
		d_parte05= '9998'     && Código de tributo 
		e_parte05= 'INA'      && Nombre de tributo
		f_parte05= 'FRE'      && Código internacional tributo
	ENDIF
ELSE
	a_parte05= ''
	b_parte05= ''
	c_parte05= ''
	d_parte05= ''
	e_parte05= ''
	f_parte05= ''
ENDIF

sub01P05=a_parte05+'|'+b_parte05+'|'+c_parte05+'|'+d_parte05+'|'+e_parte05+'|'+f_parte05+'}'+LF_CR

&& Total Valor de Venta - Gratuitas
IF CDCondipag $ mCondPagGratis
	a2parte05= ALLTRIM(STR(SunatMidoc.neto,12,2))   && Total valor de la venta
	b2parte05= ALLTRIM(STR(SunatMidoc.igv,12,2))    && Sumatoria IGV
	c2parte05= 'Z'         && Categoría de impuestos Z: Gratuitas
	d2parte05= '9996'      && Código de tributo
	e2parte05= 'GRA'       && Nombre de tributo
	f2parte05= 'FRE'       && Código internacional tributo
ELSE
	a2parte05= ''
	b2parte05= ''
	c2parte05= ''
	d2parte05= ''
	e2parte05= ''
	f2parte05= ''
ENDIF

sub02P05= a2parte05+'|'+b2parte05+'|'+c2parte05+'|'+d2parte05+'|'+e2parte05+'|'+f2parte05+'}'+LF_CR

&& Total Valor de Venta - Gravadas
IF !CDCondipag $ mCondPagGratis AND x_Esexportacion = 0 AND IsInafecta= 0 AND !(SunatMidoc.TipoDoc='F' And mSer_ref=60) 
	a3parte05= ALLTRIM(STR(SunatMidoc.neto,12,2))   && Total valor de la venta
	b3parte05= ALLTRIM(STR(SunatMidoc.igv,12,2))    && Sumatoria IGV
	c3parte05= 'S'         && Categoría de impuestos  S: IGV        
	d3parte05= '1000'      && Código de tributo
	e3parte05= 'IGV'       && Nombre de tributo
	f3parte05= 'VAT'       && Código internacional tributo
ELSE
	a3parte05= ''
	b3parte05= ''
	c3parte05= ''
	d3parte05= ''
	e3parte05= ''
	f3parte05= ''
ENDIF

sub03P05= a3parte05+'|'+b3parte05+'|'+c3parte05+'|'+d3parte05+'|'+e3parte05+'|'+f3parte05+'}'+LF_CR

&& Total Valor de Venta - ISC
a4parte05= ""    && Total valor de la venta
&& Importe del tributo
b4parte05=""  && Sumatoria IGV
&& Categoría de impuestos
c4parte05=""
&& Código de tributo
d4parte05="" && Ver Catalogo 05
&& Nombre de tributo
e4parte05="" && Ver Catalogo 05
&& Código internacional tributo
f4parte05="" && Ver Catalogo 05
*x_Parte05='18.00'
sub04P05=a4parte05+'|'+b4parte05+'|'+c4parte05+'|'+d4parte05+'|'+e4parte05+'|'+f4parte05+'}'+LF_CR

x05_StrBody = sub01P05 + sub02P05 + sub03P05 + sub04P05 + '~'

* Fin Parte05

*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte06: Montos Totales
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
*a_Parte06=''
*b_Parte06=ALLTRIM(STR(SunatMidoc.total,12,2))
*x06_StrBody=a_Parte06+'|'+b_Parte06+'|'+'}'+'~'

a_Parte06= ALLTRIM(STR(SunatMidoc.neto,12,2))    && Total valor de la venta
b_Parte06= ALLTRIM(STR(SunatMidoc.TOTAL,12,2))   && Total precio de venta (incluye impuestos)
c_Parte06= '0.00'                                && Monto total de otros cargos del comprobante
d_Parte06= ALLTRIM(STR(SunatMidoc.TOTAL,12,2))   && Importe total de la venta, cesión en uso o del servicio prestado
e_Parte06= ''                                	&& Monto para Redondeo del Importe Total
f_Parte06= ALLTRIM(STR(SunatMidoc.igv,12,2))     && Sumatoria de impuestos

x06_StrBody=a_Parte06+'|'+b_Parte06+'|'+c_Parte06+'|'+d_Parte06+'|'+e_Parte06+'|'+f_Parte06+'}'+LF_CR+'~'

* Fin Parte06
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte07 - Detalles
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------

IF MitipoDoc='D'
	a_Parte07 = ALLTRIM(STR(1)) && Numero de Linea
	b_Parte07 = ALLTRIM(STR(1)) && Cantidad de Item
	c_Parte07 = 'NIU'  && NIU
	d_Parte07 = ALLTRIM(STR(SunatMidoc.neto,13,2))
	e_Parte07 = ALLTRIM(STR(SunatMidoc.igv,12,2))
	f_Parte07 = ALLTRIM(STR(SunatMidoc.Total,12,2))
	g_Parte07= d_Parte01  && Codigo tipo de moneda
	
	h_Parte07 = ALLTRIM(STR(SunatMidoc.neto,12,2))
	i_Parte07 = ALLTRIM(STR(SunatMidoc.igv,12,2))
	
	DO Case
		CASE x_Esexportacion = 1
			j_Parte07= 'G'   && Categoria Impuesto 
			k_Parte07= '0.00' && Porcentaje de impuesto
			l_Parte07= '40'   && Codigo de tipo de afectacion del IGV  40: Exportacion
			m_Parte07= '9995' && Código de tributo
			n_Parte07= 'EXP'  && Nombre de tributo
			o_Parte07= 'FRE'  && Código internacional de tributo
		CASE IsInafecta= 1 OR (SunatMidoc.TipoDoc='F' And mSer_ref=60)
			j_Parte07= 'O'   && Categoria Impuesto 
			k_Parte07= '0.00' && Porcentaje de impuesto
			l_Parte07= '30'   && Codigo de tipo de afectacion del IGV   30: Inafecto - Operacion Onerosa  (29/01/2019: Consultar a Contabilidad)
			m_Parte07= '9998' && Código de tributo
			n_Parte07= 'INA'  && Nombre de tributo
			o_Parte07= 'FRE'  && Código internacional de tributo
		CASE CDCondipag $ mCondPagGratis      && Muestra gratis promocional
			j_Parte07= 'Z'   && Categoria Impuesto 
			k_Parte07= '0.00' && Porcentaje de impuesto
			l_Parte07= '36'   && Codigo de tipo de afectacion del IGV   36: Inafecto - Retiro por publicidad  (29/01/2019: Consultar a Contabilidad)
			m_Parte07= '9996' && Código de tributo
			n_Parte07= 'GRA'  && Nombre de tributo
			o_Parte07= 'FRE'  && Código internacional de tributo
		OTHERWISE
			j_Parte07= 'S'   && Categoria Impuesto
			k_Parte07= ALLTRIM(Str(Igv_ele, 6, 2))  && Porcentaje de impuesto
			l_Parte07= '10'   && Codigo de tipo de afectacion del IGV   10: Gravado - Operacion Onerosa
			m_Parte07= '1000' && Código de tributo
			n_Parte07= 'IGV'  && Nombre de tributo
			o_Parte07= 'VAT'  && Código internacional de tributo
	ENDCASE
	
	** Tributo del ISC ***
	p_Parte07= ''
	q_Parte07= ''
	r_Parte07= ''
	s_Parte07= ''
	t_Parte07= ''
	u_Parte07= ''
	v_Parte07= ''
	w_Parte07= ''
	
	** Otros tributos ***
	x_Parte07= ''
	y_Parte07= ''
	z_Parte07= ''
	a1Parte07= ''
	b1Parte07= ''
	c1Parte07= ''
	d1Parte07= ''
	
	e1Parte07= ALLTRIM(SunatMidoc.Observacion)   && Descripcion 
	f1Parte07= ''
	mLoteArt = ''
	
	** Codigo producto SQM / Codigo Sunat	
	lnHandle = SQLSTRINGCONNECT(MyString)
	IF lnHandle > 0
		cmd0= SQLEXEC(lnHandle,"SELECT a.Producto,b.nombre, b.CodSunat FROM detafacturas a ,productos b WHERE a.producto=b.codigo AND a.unico=?mIdFactura","SunatMidetalle")
		SQLDISCONNECT(lnHandle)
	ELSE
		AERROR(laErr)
		MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	ENDIF
	GO TOP IN SunatMidetalle
	
	IF a_Parte04= '02'  && Correccion de precio
		g1Parte07= SunatMidetalle.Producto  && Codigo del producto SQM
		h1Parte07= SunatMidetalle.CodSunat  && Codigo de Producto Sunat
	ELSE
		g1Parte07= ''  && Codigo del producto SQM
		h1Parte07= ''  && Codigo de Producto Sunat			
	ENDIF
	
	i1Parte07= ''
	j1Parte07= ALLTRIM(STR(SunatMidoc.neto,12,2))   && Valor unitario (sin igv)
	
	** Concepto tributario - Se podrá indicar informacion adicional al item el cual es materia de comunicacion
	k1Parte07= ''   && Nombre del concepto
	l1Parte07= ''   && Código de concepto tributario del item
	m1Parte07= ''   && valor de la propiedad del item
	n1Parte07= ''   && Fecha de inicio de la propiedad del item
	o1Parte07= ''   && Fecha de fin de la propiedad del item
	p1Parte07= ''   && Duracion (dias) de la propiedad del item
	
	StrBody= a_Parte07+ '|'+ b_Parte07+ '|'+ c_Parte07+ '|'+ d_Parte07+ '|'+ e_Parte07+ '|'+ f_Parte07+ '|'+ g_Parte07+ '|'+ h_Parte07 ;
				+ '|'+ i_Parte07+ '|'+ j_Parte07+ '|'+ k_Parte07+ '|'+ l_Parte07+ '|'+ m_Parte07+ '|'+ n_Parte07+ '|'+ o_Parte07+ '|'+ p_Parte07 ;
				+ '|'+ q_Parte07+ '|'+ r_Parte07+ '|'+ s_Parte07+ '|'+ t_Parte07+ '|'+ u_Parte07+ '|'+ v_Parte07+ '|'+ w_Parte07+ '|'+ x_Parte07 ;
				+ '|'+ y_Parte07+ '|'+ z_Parte07+ '|'+ a1Parte07+ '|'+ b1Parte07+ '|'+ c1Parte07+ '|'+ d1Parte07+ '|'+ e1Parte07+ '|'+ f1Parte07 ;
				+ '|'+ g1Parte07+ '|'+ h1Parte07+ '|'+ i1Parte07+ '|'+ j1Parte07+ '|'+ k1Parte07+ '|'+ l1Parte07+ '|'+ m1Parte07+ '|'+ n1Parte07 ;
				+ '|'+ o1Parte07+ '|'+ p1Parte07+ '|'+ mLoteArt+ '}'
	
	x07_StrBody = StrBody+ '~'
	
	USE IN SunatMidetalle
	
ELSE && Nota de Credito
	Isvtasucesiva= 0
	lnHandle = SQLSTRINGCONNECT(MyString)
	IF lnHandle > 0
		DO Case
			CASE SunatMidoc.tipo= 1   && Devolucion de Mercaderia
				cmd0= SQLEXEC(lnHandle,"SELECT a.*,b.nombre, b.CodSunat, '' as txt_alternativo FROM detallencredito a ,productos b WHERE a.producto=b.codigo AND a.unico=?Myunico","SunatMidetalle")
			CASE SunatMidoc.tipo= 2   && Descuento de Precio
				cmd0= SQLEXEC(lnHandle,"SELECT a.*,b.nombre, b.CodSunat, '' as txt_alternativo FROM detallencredito a ,productos b WHERE a.producto=b.codigo AND a.unico=?Myunico","SunatMidetalle")
			CASE SunatMidoc.tipo= 9   && Anulacion de documento
				IF mSer_ref= 60 && Si es Factura Vta Sucesiva
					Isvtasucesiva= 1
					cmd0= SQLEXEC(lnHandle,"SELECT a.*,b.nombre, b.CodSunat, a.Cantidad as cantaplicada, Convert(round(cantidad * precioventa, 2), Decimal(10,2)) as SubTotal, "+ ;
						"Convert(0, decimal(10,2)) as precioorigen, Convert(0, decimal(10,2)) as nuevoprecio FROM im_detallevsucesiva a ,productos b WHERE a.producto=b.codigo AND a.Codigo=?mPedidoVS","SunatMidetalle")
				ELSE
					IF SunatMidoc.TipoDoc= 'F'
						cmd0= SQLEXEC(lnHandle,"SELECT a.*,CAST(b.nombre as CHAR(200)) as Nombre, b.CodSunat, a.Cantidad as cantaplicada, Convert(0, decimal(10,2)) as precioorigen, Convert(0, decimal(10,2)) as nuevoprecio "+ ;
								"FROM detafacturas a ,productos b WHERE a.producto=b.codigo AND a.unico=?mIdFactura","SunatMidetalle")
					ELSE
						cmd0= SQLEXEC(lnHandle,"SELECT a.*,CAST(b.nombre as CHAR(200)) as Nombre, b.CodSunat, a.Cantidad as cantaplicada, Convert(0, decimal(10,2)) as precioorigen, Convert(0, decimal(10,2)) as nuevoprecio "+ ;
								"FROM detaboletas a ,productos b WHERE a.producto=b.codigo AND a.unico=?mIdFactura","SunatMidetalle")
					ENDIF
				ENDIF
		ENDCASE
		SQLDISCONNECT(lnHandle)
	ELSE
		AERROR(laErr)
		MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	ENDIF

	**
	IF Isvtasucesiva=0
		*******Agrupacion de Items solo para el TXT *********************************************************************************************
		SELECT producto,PADR(nombre,250) as Nombre,um,cantaplicada,precioorigen,nuevoprecio,subtotal,CodSunat, txt_alternativo FROM Sunatmidetalle INTO CURSOR way01
		SELECT Sunatmidetalle
		DELETE ALL
		SELECT way01
		SCAN
			var1=ALLTRIM(producto)
			var2=ALLTRIM(nombre)
			var3=ALLTRIM(um)
			var4=cantaplicada
			var5=precioorigen
			var6=nuevoprecio
			var7=subtotal
			mSunat=CodSunat
			IF !ISNULL(txt_alternativo) AND !EMPTY(txt_alternativo) AND LEFT(var1, 2) $ '99,SS'
				mTxtAlter = ALLTRIM(txt_alternativo)
				mLineas   = MEMLINES(mTxtAlter)
				IF mLineas > 0
					var2      = ''
					FOR I= 1 TO mLineas
						mTxtLinea = ALLTRIM(MLINE(mTxtAlter, I))
						var2 = var2+ IIF(!EMPTY(var2),'^', '')+ mTxtLinea
					ENDFOR
				ENDIF
			ENDIF
			SELECT Sunatmidetalle
			LOCATE FOR ALLTRIM(producto)=var1 AND ALLTRIM(um)=var3
			IF FOUND()
				REPLACE cantaplicada WITH cantaplicada+ var4
				REPLACE subtotal WITH subtotal+ var7
			ELSE
				APPEND BLANK
				REPLACE producto WITH var1
				REPLACE nombre WITH var2
				REPLACE um WITH var3
				REPLACE cantaplicada WITH var4
				REPLACE precioorigen WITH var5
				REPLACE nuevoprecio WITH var6
				REPLACE subtotal WITH var7
				REPLACE CodSunat WITH mSunat
			ENDIF
			SELECT way01
		ENDSCAN
		USE IN way01
	ENDIF
	**
	
	StrBody=''
	mItem = 0
	SELECT SunatMidetalle
	GO TOP
	SCAN
		mItem = mItem+ 1
		a_Parte07= ALLTRIM(STR(mItem,5))
		mCant = SunatMidetalle.cantaplicada
		IF SunatMidoc.tipo= 2  && Descuento de precio
			mCant = 1
		ENDIF
		b_Parte07 = ALLTRIM(STR(mCant,10,2))
		IF ALLTRIM(UPPER(Sunatmidetalle.um))='UN' OR SunatMidoc.tipo= 2   && Descuento de precio
			c_Parte07='NIU'
		ELSE
			c_Parte07=UPPER(ALLTRIM(Sunatmidetalle.um)) && Catalogo 03
		ENDIF
		d_Parte07= ALLTRIM(STR(SunatMidetalle.SubTotal,13,2))
		
		igvlinea= ROUND(((Sunatmidetalle.SubTotal* Igv_ele)/100),2)
		mPU     = ROUND((Sunatmidetalle.SubTotal + igvlinea) / mCant, 2)
		mVU     = ROUND((Sunatmidetalle.SubTotal) / mCant, 2)
		mBaseIGV = Sunatmidetalle.SubTotal
		IF CDCondipag = mCondPagGratis OR (SunatMidoc.TipoDoc='F' And mSer_ref=60)  && Muestra Gratis o Vta Sucesiva
			igvlinea = 0
			e_Parte07= ALLTRIM(STR(0.00,12,2))  && 0.00 x Inafecta   && TaxAmount
			f_Parte07= ALLTRIM(STR(mVU+ 0,12,2))   && Valor Unitario + Impuesto   && PriceAmount
		ELSE
			IF IsInafecta=1 OR x_Esexportacion= 1  && Si es Exportación o es Inafecta
				igvlinea = 0
				e_Parte07= ALLTRIM(STR(0.00,12,2))  && 0.00 x Inafecta
				f_Parte07= ALLTRIM(STR(mVU+ 0,12,2))   && Valor Unitario + Impuestos   && PriceAmount
			ELSE
				e_Parte07= ALLTRIM(STR(igvlinea,12,2))  && Monto Igv de la Linea
				f_Parte07= ALLTRIM(STR(mPU,12,2))       && Valor Unitario + Impuestos  && PriceAmount
			ENDIF
		ENDIF
		g_Parte07= d_Parte01  && Codigo tipo de moneda
		
		** Tributo del IGV ***
		h_Parte07= ALLTRIM(STR(mBaseIGV, 12, 2))
		i_Parte07= ALLTRIM(STR(igvlinea,12,2))
		DO Case
			CASE x_Esexportacion = 1
				j_Parte07= 'G'   && Categoria Impuesto 
				k_Parte07= '0.00' && Porcentaje de impuesto
				l_Parte07= '40'   && Codigo de tipo de afectacion del IGV  40: Exportacion
				m_Parte07= '9995' && Código de tributo
				n_Parte07= 'EXP'  && Nombre de tributo
				o_Parte07= 'FRE'  && Código internacional de tributo
			CASE IsInafecta= 1 OR (SunatMidoc.TipoDoc='F' And mSer_ref=60)
				j_Parte07= 'O'   && Categoria Impuesto 
				k_Parte07= '0.00' && Porcentaje de impuesto
				l_Parte07= '30'   && Codigo de tipo de afectacion del IGV   30: Inafecto - Operacion Onerosa  (29/01/2019: Consultar a Contabilidad)
				m_Parte07= '9998' && Código de tributo
				n_Parte07= 'INA'  && Nombre de tributo
				o_Parte07= 'FRE'  && Código internacional de tributo
			CASE CDCondipag $ mCondPagGratis      && Muestra gratis promocional
				j_Parte07= 'Z'   && Categoria Impuesto 
				k_Parte07= '0.00' && Porcentaje de impuesto
				l_Parte07= '36'   && Codigo de tipo de afectacion del IGV   36: Inafecto - Retiro por publicidad  (29/01/2019: Consultar a Contabilidad)
				m_Parte07= '9996' && Código de tributo
				n_Parte07= 'GRA'  && Nombre de tributo
				o_Parte07= 'FRE'  && Código internacional de tributo
			OTHERWISE
				j_Parte07= 'S'   && Categoria Impuesto
				k_Parte07= ALLTRIM(Str(Igv_ele, 6, 2))  && Porcentaje de impuesto
				l_Parte07= '10'   && Codigo de tipo de afectacion del IGV   10: Gravado - Operacion Onerosa
				m_Parte07= '1000' && Código de tributo
				n_Parte07= 'IGV'  && Nombre de tributo
				o_Parte07= 'VAT'  && Código internacional de tributo
		ENDCASE
		
		** Tributo del ISC ***
		p_Parte07= ''
		q_Parte07= ''
		r_Parte07= ''
		s_Parte07= ''
		t_Parte07= ''
		u_Parte07= ''
		v_Parte07= ''
		w_Parte07= ''
		
		** Otros tributos ***
		x_Parte07= ''
		y_Parte07= ''
		z_Parte07= ''
		a1Parte07= ''
		b1Parte07= ''
		c1Parte07= ''
		d1Parte07= ''
		
		IF SunatMidoc.tipo= 2   && Descuento de precio
			e1Parte07= PADR(ALLTRIM(SunatMidetalle.producto),8,' ')+' '+ALLTRIM(SUBSTR(SunatMidetalle.nombre,1,55))+'   '+'Cant: '+ALLTRIM(STR(SunatMidetalle.cantaplicada,10,2))+'   '+'Valor Unit: '+ALLTRIM(STR(SunatMidetalle.precioorigen,10,2))+'   '+'NVU: '+ALLTRIM(STR(SunatMidetalle.nuevoprecio,10,2))+'   '+'Subtotal: '+ALLTRIM(STR(SunatMidetalle.subtotal,10,2))
		ELSE
			e1Parte07= ALLTRIM(SunatMidetalle.nombre)
		ENDIF
		e1Parte07= e1Parte07
		mLoteArt = ''
		
		f1Parte07= ''
		g1Parte07= ALLTRIM(SunatMidetalle.Producto)
		h1Parte07= ALLTRIM(SunatMidetalle.CodSunat)
		i1Parte07= ''
		j1Parte07= ALLTRIM(STR(mVU,12,2))
		
		** Concepto tributario - Se podrá indicar informacion adicional al item el cual es materia de comunicacion
		k1Parte07= ''   && Nombre del concepto
		l1Parte07= ''   && Código de concepto tributario del item
		m1Parte07= ''   && valor de la propiedad del item
		n1Parte07= ''   && Fecha de inicio de la propiedad del item
		o1Parte07= ''   && Fecha de fin de la propiedad del item
		p1Parte07= ''   && Duracion (dias) de la propiedad del item
		
		StrBody = StrBody+ a_Parte07+ '|'+ b_Parte07+ '|'+ c_Parte07+ '|'+ d_Parte07+ '|'+ e_Parte07+ '|'+ f_Parte07+ '|'+ g_Parte07+ '|'+ h_Parte07 ;
					+ '|'+ i_Parte07+ '|'+ j_Parte07+ '|'+ k_Parte07+ '|'+ l_Parte07+ '|'+ m_Parte07+ '|'+ n_Parte07+ '|'+ o_Parte07+ '|'+ p_Parte07 ;
					+ '|'+ q_Parte07+ '|'+ r_Parte07+ '|'+ s_Parte07+ '|'+ t_Parte07+ '|'+ u_Parte07+ '|'+ v_Parte07+ '|'+ w_Parte07+ '|'+ x_Parte07 ;
					+ '|'+ y_Parte07+ '|'+ z_Parte07+ '|'+ a1Parte07+ '|'+ b1Parte07+ '|'+ c1Parte07+ '|'+ d1Parte07+ '|'+ e1Parte07+ '|'+ f1Parte07 ;
					+ '|'+ g1Parte07+ '|'+ h1Parte07+ '|'+ i1Parte07+ '|'+ j1Parte07+ '|'+ k1Parte07+ '|'+ l1Parte07+ '|'+ m1Parte07+ '|'+ n1Parte07 ;
					+ '|'+ o1Parte07+ '|'+ p1Parte07+ '|'+ mLoteArt+ '}'
	ENDSCAN
	x07_StrBody = StrBody+ '~'
	
	USE IN SunatMidetalle
ENDIF

* Fin Parte07
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte08 LEYENDAS
*---------------------------------------------------------------------------
a_parte08= '' && ALLTRIM(Convnum(VAL(b_Parte06)))+IIF(d_Parte01='PEN'," SOLES", " DOLARES AMERICANOS")   && Monto total en letras
b_parte08= '' && '1000'

x08_StrBody = a_parte08+ '|'+ b_parte08+ '}'+LF_CR+ '~'

* Fin Parte08
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte09 ADJUNTOS
*---------------------------------------------------------------------------
* 
*---------------------------------------------------------------------------
a_parte09 = ''   && Tienda. Campo a definir por el cliente
b_parte09 = ''   && Caja. Campo a definir por el cliente
c_parte09 = ''   && Cajero. Campo a definir por el cliente
d_parte09 = ''   && Libre 1. Campo a definir por el cliente
e_parte09 = ''   && Libre 2. Campo a definir por el cliente
f_parte09 = ''   && Libre 3. Campo a definir por el cliente

x09_StrBody = a_parte09+ '|'+ b_parte09+'|'+ c_parte09+'|'+ d_parte09+'|'+ e_parte09+'|'+ f_parte09+'}'+LF_CR
*---------------------------------------------------------------------------

g_parte09 = ''   && Observacion
h_parte09 = ALLTRIM(Convnum(VAL(b_Parte06)))+IIF(d_Parte01='PEN'," SOLES", " DOLARES AMERICANOS")  && Monto en palabras

* Fin Parte09
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------

**** Configurando lista de correo a enviar ***
yy_01=ALLTRIM(Micliente.cpe01)
yy_02=ALLTRIM(Micliente.cpe02)

IF LEN(yy_02)<7 && Longitud minima correo
	MyListaCorreo=yy_01
ELSE
	MyListaCorreo=yy_01+';'+yy_02
ENDIF

IF xServer=2
	MyListaCorreo = 'egutierrez@sociedadquimica.com.pe'
ELSE
	MyListaCorreo = MyListaCorreo+ ';'+ 'cpe_sqm@sociedadquimica.com.pe'
ENDIF

**********************************************
i_parte09 =  MyListaCorreo    && "Correo electrónico al cual se enviará el comprobante en formato PDF y XMLSi es más de un correo se debe separar por "";"". Ej: correo1@mail.pe;correo2@mail.pe"
j_parte09 = ''   && Se debe encontrar conectada en red y visible desde el servidor de facturación.
k_parte09 = ''   && Número de páginas a imprimir
l_parte09 = ''   && "emitir" (utilizar para implementaciones SPOOL)

x09_StrBody = x09_StrBody + g_parte09+ '|'+ h_parte09+'|'+ i_parte09+'|'+ j_parte09+'|'+ k_parte09+'|'+ l_parte09+'}'+LF_CR+'~'+LF_CR+'\'

********Fin Parte09 ****************************************************************************************************************************************

IF xServer=2
	xControl='C:\Ventas\inputprod\'+ ALLTRIM(MitipoDoc)+ b_Parte01+'.txt'
ELSE
	xControl='\\SQMSERVER\inputprod\'+ ALLTRIM(MitipoDoc)+ b_Parte01+'.txt'
ENDIF

gnErrFile = FCREATE(xControl)  && If not create it

IF gnErrFile>0
	StrBody= x01_StrBody+LF_CR+x02_StrBody+LF_CR+x03_StrBody+LF_CR;
			+x04_StrBody+LF_CR+x05_StrBody+LF_CR+x06_StrBody+LF_CR;
			+x07_StrBody+LF_CR+x08_StrBody+LF_CR+x09_StrBody

	=FPUTS(gnErrFile,StrBody) &&Graba la variable en el archivo txt
	SET CENTURY OFF
	=FCLOSE(gnErrFile) &&cerramos el archivo.
ELSE
	WAIT WINDOW "Error al abrir el archivo"
ENDIF
IF MitipoDoc='C' AND x_ChargeNc=1
	SELECT SunatMidetalle
	DELETE ALL
ENDIF
SELECT SunatMidoc
DELETE ALL
