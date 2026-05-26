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

**DV.17.03.20************************************************************
PUBLIC m.pcFolderStyle, lgMaquina, GAMYARRAY, x_Esexportacion
LOCAL lcsys16, lcprogram
LOCAL TotalAnticipos
TotalAnticipos= 0

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

SET PROCEDURE TO funciones

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

*!*		MyString= "DRIVER={MySQL ODBC 3.51 Driver};" + ;
*!*			"SERVER=localhost;" + ;
*!*			"PORT=3387;" + ;
*!*			"UID=root;" + ;
*!*			"PWD=987654321;" + ;
*!*			"DATABASE=sqmdata;" + ;
*!*			"OPTIONS=0;"

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

LOCAL xControl,Snt_Documento,StrBody,Pase1,Codigosqm,DocuIgv,Miserie,MitipoDoc,Seriedoc,Numerodoc,Hoy
LOCAL FraseMG,FraseBoleta,AcumulaMG,FraseDetrac01,FraseDetrac02,FraseDetrac03
LOCAL MinSolesDetrac,MinDolarDetrac,TcVentaHoy,PctjeDetracServ,x_EsLibre
LOCAL MiPedVtaSuc,CtaRegVs,CtaMiReg,NotaVs01,FraseVs01,MyUbigeo,MyUrbanizacion
LOCAL MyListaCorreo,Isvtasucesiva,IsInafecta

Isvtasucesiva=0
*Codigosqm= 'I207'  && 'I131'
Codigosqm= 'S030'  && 'I131'
DocuIgv=0
AcumulaMG=0
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
x09_StrBody=''
StrBody=''

*---------------------------------
*MitipoDoc = x_Sunatipodoc
*Seriedoc  = Myserief
*Numerodoc = Mynumerof

*---------------------------------
MitipoDoc = "F"
*Seriedoc  = 030
*Numerodoc = 24

*Seriedoc  = 060
*Numerodoc = 11

*---------------------------------
*Seriedoc  = 010
*Numerodoc = 5778
*---------------------------------
*---------------------------------
*Seriedoc  = 10
*Numerodoc = 10985

*Seriedoc  = 40
*Numerodoc = 70

*Seriedoc  = 70
*Numerodoc = 6

*Seriedoc  = 70
*Numerodoc = 5

*Seriedoc  = 10
*Numerodoc = 5348

*Seriedoc  = 30
*Numerodoc = 23

Seriedoc  = 30
Numerodoc = 31

*Seriedoc  = 30
*Numerodoc = 32

*Seriedoc  = 50
*Numerodoc = 74

*Seriedoc  = 70
*Numerodoc = 5

*MitipoDoc = "B"

*Seriedoc  = 10
*Numerodoc = 209

*Seriedoc  = 10
*Numerodoc = 469

*Seriedoc  = 10
*Numerodoc = 472

*Seriedoc  = 10
*Numerodoc = 4

*Seriedoc  = 10
*Numerodoc = 254

*Seriedoc  = 10
*Numerodoc = 469

*--------------------------------------------------
*--------------------------------------------------

lnHandle = SQLSTRINGCONNECT(MyString)

IF lnHandle > 0
	cmd0=SQLEXEC(lnHandle,"SELECT * FROM constantes ","MiDatosPlus")
	cmd3=SQLEXEC(lnHandle,"SELECT * FROM k_sunatelectronica ","KonsMess")
	cmd2=SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codigosqm","MiDatasqm")
	cmd5=SQLEXEC(lnHandle,"SELECT venta FROM tcoficial WHERE fecha=?hoy","Cambiooficial")
	cmd6=SQLEXEC(lnHandle,"SELECT * FROM detalleanticipos WHERE TRIM(cpe)=?Mitipodoc AND serie=?Seriedoc AND numero=?numerodoc","MisAnticipos") &&DIFANTICIPOS

	IF MitipoDoc='F'
		IF Seriedoc=60 && Si es Factura Vta Sucesiva
			Isvtasucesiva=1
			cmd1=SQLEXEC(lnHandle,"SELECT a.*,' ' as NomPago FROM factura a WHERE a.cpe='F' AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
			cmd5=SQLEXEC(lnHandle,"SELECT * FROM im_vsucesiva WHERE fcpe='F' AND fserie=?Seriedoc and fnumero=?Numerodoc","Datavs") && Revisa
		ELSE
			cmd1=SQLEXEC(lnHandle,"SELECT a.*,b.nombre as NomPago FROM factura a,condicionpago b WHERE a.condipag=b.codigo AND "+;
				"a.cpe='F' AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
		ENDIF
	ELSE
		cmd1=SQLEXEC(lnHandle,"SELECT a.*,b.nombre as NomPago FROM boleta a,condicionpago b WHERE a.condipag=b.codigo AND "+;
			"a.cpe='B' AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
	ENDIF
	SQLDISCONNECT(lnHandle)
ELSE
	AERROR(laErr)
	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

MyUbigeo=ALLTRIM(KonsMess.c_myubigeo)
MyUrbanizacion=ALLTRIM(KonsMess.c_myurbanizacion)
FraseMG=ALLTRIM(KonsMess.c_frasemg)
FraseBoleta=ALLTRIM(KonsMess.c_fraseboleta)
FraseDetrac01=ALLTRIM(KonsMess.c_frasedetrac01)
FraseDetrac02=ALLTRIM(KonsMess.c_frasedetrac02)
FraseDetrac03=ALLTRIM(KonsMess.c_frasedetrac03)
FraseVs01=ALLTRIM(KonsMess.c_frasevs01)
NotaVs01=ALLTRIM(KonsMess.c_notavtasucesiva)

TcVentaHoy=Cambiooficial.venta
PctjeDetracServ=MiDatosPlus.percepcionserv
MinSolesDetrac=MiDatosPlus.minperservsoles
MinDolarDetrac=ROUND(MinSolesDetrac/TcVentaHoy,2)
Igv_ele=MiDatosPlus.igv
Miserie=SunatMidoc.serie

IF MitipoDoc='F'
	MiPedVtaSuc= SunatMidoc.vspedido
	IsInafecta=  SunatMidoc.inafecta
	x_Esexportacion = SunatMidoc.Exportacion
	IF Miserie=60
		*OR Miserie=30
		&& Vta Sucesiva - inafecta
		IsInafecta= 1
	ENDIF
ELSE
	MiPedVtaSuc= ''
	IsInafecta=  0
ENDIF

SELECT SunatMidoc
IF x_Esexportacion = 0
	mDetCPago = ''
	mObsCuerpo= ''
	mObsPieDoc= ''
	mIncoterms= ''
ELSE
	mDetCPago = IIF(ISNULL(SunatMidoc.DetaCondPago), '', ALLTRIM(SunatMidoc.DetaCondPago))
	mObsCuerpo= IIF(ISNULL(SunatMidoc.ObsCuerpoDoc), '', ALLTRIM(SunatMidoc.ObsCuerpoDoc))
	mObsPieDoc= IIF(ISNULL(SunatMidoc.ObsPieDoc), '', ALLTRIM(SunatMidoc.ObsPieDoc))
	mIncoterms= IIF(ISNULL(SunatMidoc.Incoterms), '', ALLTRIM(SunatMidoc.Incoterms))
ENDIF

SELECT MisAnticipos   && Anticipo(s) aplicado(s) a la factura
GO TOP
IF !EOF() AND !ISNULL(MisAnticipos.monto_fa)
	SUM ALL MisAnticipos.monto_fa TO TotalAnticipos
ENDIF

SELECT SunatMidoc
*******Inicio Parte01 ***********************************************************************************************************************************
IF MitipoDoc='F'
	a_Parte01='01'  && Factura
ELSE
	a_Parte01='03'  && Boleta
ENDIF

b_Parte01=MitipoDoc+TRANSFORM(serie,'@L 999')+'-'+TRANSFORM(numero,'@L 99999999')

y_Pyear=STR(YEAR(SunatMidoc.fecha),4,0)
y_Pmont=TRANSFORM(MONTH(SunatMidoc.fecha),"@L 99")
y_PDayy=TRANSFORM(DAY(SunatMidoc.fecha),"@L 99")

c_Parte01=y_Pyear+'-'+y_Pmont+'-'+y_PDayy

DO CASE  && Catalogo 02 Anexo 08
	CASE SunatMidoc.Moneda='M1'
		d_Parte01='PEN'
	CASE SunatMidoc.Moneda='M2'
		d_Parte01='USD'
ENDCASE

IF SunatMidoc.directa=1
	e_Parte01='' && No hay guia de Remision
ELSE
	IF MitipoDoc='F' &&& Hay Facturacion Agrupada
		IF SunatMidoc.agrupada=1
			*e_Parte01=ALLTRIM(STRCONV(SunatMidoc.variasguias,11))
			e_Parte01=ALLTRIM(SunatMidoc.variasguias)
		ELSE
			IF SunatMidoc.guiaserie=0 OR SunatMidoc.guianum=0
				e_Parte01=''
			ELSE
				e_Parte01=TRANSFORM(SunatMidoc.guiaserie,'@L 999')+'-'+TRANSFORM(SunatMidoc.guianum,'@L 99999999')
			ENDIF
		ENDIF
	ELSE  && Si es Boleta (No hay Boletas Agrupadas)
		IF SunatMidoc.guiaserie=0 OR SunatMidoc.guianum=0
			e_Parte01=''
		ELSE
			e_Parte01=TRANSFORM(SunatMidoc.guiaserie,'@L 999')+'-'+TRANSFORM(SunatMidoc.guianum,'@L 99999999')
		ENDIF
	ENDIF
ENDIF

f_Parte01='09' && Ver Catalogo 01 -- Valor Guia de remision remitente  Validar vacias ???
g_Parte01='' && No Aplica (NUmero - Otro documento referido a la operacion)
h_Parte01='' && No Aplica (Tipo - Otro documento referido a la operacion) && Catalogo Nro12

DO CASE
	CASE MitipoDoc='F'
		IF SunatMidoc.directa=1
			i_Parte01=ALLTRIM(SunatMidoc.ocdirecta)  && Ver si es asi NO va OC
		ELSE
			IF SunatMidoc.agrupada=1
				*i_Parte01=''  &&& no se como llenar para las agrupadas, Como va NO va OC			
				i_Parte01=ALLTRIM(SunatMidoc.ocdirecta)  && Ver si es asi NO va OC
			ELSE
				LocM1=SunatMidoc.guiaserie
				LocM2=SunatMidoc.guianum

				lnHandle = SQLSTRINGCONNECT(MyString)
				IF lnHandle > 0
					cmd2=SQLEXEC(lnHandle,"SELECT oc FROM guiasremision WHERE serie=?LocM1 and numero=?LocM2","LocMx")
					SQLDISCONNECT(lnHandle)
				ELSE
					AERROR(laErr)
					MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
				ENDIF
				i_Parte01=ALLTRIM(LocMx.oc) && Orden de Compra  (Busqueda en Guia de Remision)
				USE IN LocMx
			ENDIF
		ENDIF
	CASE MitipoDoc='B'
		i_Parte01=''
ENDCASE


** 20/06/2018: Nuevos campos
j_Parte01= ''  && Fecha de vencimiento - opcional
k_Parte01= ''  && Hora de emisión - opcional
IF x_Esexportacion= 0
	IF MitipoDoc='F' AND Miserie= 50 AND LEN(ALLTRIM(SunatMidoc.tipodetraccion))> 1
		l_Parte01= '1001'  && Código de Tipo de operacion: Operacion sujeta a detracción
	ELSE
		l_Parte01= '0101'  && Código de Tipo de operacion: Venta Interna
	ENDIF
ELSE
	l_Parte01= '0200'  && Código de Tipo de operacion: Exportacion de bienes
	*IF Miserie=30
	*	l_Parte01= '1001'
	*ENDIF
ENDIF

m_Parte01 = ''   && Cantidad de items del documento - opcional
n_Parte01 = ''   && Fecha de inicio de ciclo de facturación - opcional
o_Parte01 = ''   && Fecha de fin de ciclo de facturación - opcional
**

IF MitipoDoc='F'
	x01_StrBody=a_Parte01+'|'+b_Parte01+'|'+c_Parte01+'|'+d_Parte01+'|';
				+e_Parte01+'|'+f_Parte01+'|'+g_Parte01+'|'+h_Parte01+'|';
				+i_Parte01+'|'+j_Parte01+'|'+k_Parte01+'|'+l_Parte01+'|';
				+m_Parte01+'|'+n_Parte01+'|'+o_Parte01+'}'
ELSE
	x01_StrBody=a_Parte01+'|'+b_Parte01+'|'+c_Parte01+'|'+d_Parte01+'|';
				+e_Parte01+'|'+f_Parte01+'|'+g_Parte01+'|'+h_Parte01+'|';
				+i_Parte01+'|'+j_Parte01+'|'+k_Parte01+'|'+l_Parte01+'|';
				+n_Parte01+'|'+o_Parte01+'}'
ENDIF

********Fin Parte01 ****************************************************************************************************************************************
********Inicio Parte02: DATOS DEL EMISOR *******************************************************************************************************************

SELECT MiDatasqm

a_Parte02=ALLTRIM(MiDatasqm.ruc)

b_Parte02='6' &&& Tipo de Documento Catalogo 6 RUC para sqm

c_Parte02=ALLTRIM(MiDatasqm.nombre)
d_Parte02=c_Parte02
e_Parte02=MyUbigeo
f_Parte02=ALLTRIM(MiDatasqm.direccion)
g_Parte02=MyUrbanizacion
h_Parte02=ALLTRIM(MiDatasqm.prov)
i_parte02=ALLTRIM(MiDatasqm.dpto)
j_parte02=ALLTRIM(MiDatasqm.DIST)
k_Parte02=ALLTRIM(MiDatasqm.pais)  && Basado en Catalogo 04

** 20/06/2018: Nuevos campos
l_Parte02= ''   && Pagina web del emisor - opcional
m_Parte02= ''   && Telefono del emisor - opcional
n_Parte02= ''   && email del emisor - opcional
o_Parte02='0000'  && Código de establecimiento anexo declarado en el ruc - obligatorio. Consultar a Contabilidad (**Obs**)

x02_StrBody=a_Parte02+'|'+b_Parte02+'|'+c_Parte02+'|'+d_Parte02+'|';
	+e_Parte02+'|'+f_Parte02+'|'+g_Parte02+'|'+h_Parte02+'|';
	+i_parte02+'|'+j_parte02+'|'+k_Parte02+'|'+l_Parte02+'|';
	+m_Parte02+'|'+n_Parte02+'|'+o_Parte02+'}'

********Fin Parte02 ****************************************************************************************************************************************

********Inicio Parte03 : DATOS DEL RECEPTOR ****************************************************************************************************************
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
IF ALLTRIM(Micliente.tiposunat)='0'
	*IF Miserie=30 AND IsInafecta=1  && Vta Sucesiva
	*	a_Parte03 = "-"
	*ELSE
	a_Parte03 = ALLTRIM(Micliente.ruc)  && 17/10/2017.Edgar: Se habilitó para que el archivo de texto se genere con el numero de identidad del cliente.
	*ENDIF
ELSE
	a_Parte03 = ALLTRIM(Micliente.ruc)
ENDIF

IF Miserie=30 AND IsInafecta=1  && Vta Sucesiva
	b_Parte03="0"
ELSE
	b_Parte03=ALLTRIM(Micliente.tiposunat) &&& Tipo de Documento Catalogo 6  Revisar la Validacion solo asumimmos ruc mIentras
ENDIF

c_Parte03=ALLTRIM(Micliente.nombre)
c_Parte32=''       && Nombre comercial del receptor - opcional
c_Parte33=''       && Código de ubigeo del receptor - opcional
d_Parte03=ALLTRIM(Micliente.direccion)
e_Parte03=''       && Urbanizacion (SE HA QUITADO DE LA STRUCTURA)
f_Parte03=ALLTRIM(Micliente.prov)
g_parte03=ALLTRIM(Micliente.dpto)
h_parte03=ALLTRIM(Micliente.DIST)
i_Parte03=ALLTRIM(Micliente.pais)  && Basado en Catalogo 04

** 20/06/2018: nuevo campo
j_Parte03= '0000'   && Codigo de establecimiento anexo sunat   && Consultar a Contabilidad   (**Obs**)

x03_StrBody=a_Parte03+'|'+b_Parte03+'|'+c_Parte03+'|'+c_Parte32+'|'+c_Parte33+'|'+d_Parte03+'|'+e_Parte03+'|'+f_Parte03+'|'+g_parte03+'|'+h_parte03+'|'+i_Parte03+'|'+j_Parte03+'}'+LF_CR+'~'

********Fin Parte03 ****************************************************************************************************************************************

********Inicio Parte04: IMPUESTOS - TOTALES POR OPERACION **************************************************************************************************
** 20/06/2018: Cambio de los valores de los campos de esta sección

*** Totales venta exportacion / exoneradas / inafectas
IF x_Esexportacion = 1 OR IsInafecta= 1
	a_parte04= ALLTRIM(STR(SunatMidoc.neto,12,2))
	b_parte04= '0.00'
	IF x_Esexportacion = 1
		c_parte04= 'G'   && Exportacion
		d_parte04= '9995'
		e_parte04= 'EXP'
		f_parte04= 'FRE'
	ELSE
		c_parte04= 'O'   && Inafecto
		d_parte04= '9998'
		e_parte04= 'INA'
		f_parte04= 'FRE'
	ENDIF
ELSE
	a_parte04= ''
	b_parte04= ''
	c_parte04= ''
	d_parte04= ''
	e_parte04= ''
	f_parte04= ''
ENDIF
sub01P04= a_parte04+'|'+b_parte04+'|'+c_parte04+'|'+d_parte04+'|'+e_parte04+'|'+f_parte04+'}'+LF_CR

** Totales Gratuito
mCondPagGratis= 'MG'     && las muestras gratis inafectas??. Consultar a Contabilidad
IF ALLTRIM(SunatMidoc.condipag) $ mCondPagGratis
	a2parte04= ALLTRIM(STR(SunatMidoc.neto,12,2))
	b2parte04= ALLTRIM(STR(SunatMidoc.igv,12,2))
	c2parte04= 'Z'
	d2parte04= '9996'
	e2parte04= 'GRA'
	f2parte04= 'FRE'
ELSE
	a2parte04= ''
	b2parte04= ''
	c2parte04= ''
	d2parte04= ''
	e2parte04= ''
	f2parte04= ''
ENDIF
sub02P04= a2parte04+'|'+b2parte04+'|'+c2parte04+'|'+d2parte04+'|'+e2parte04+'|'+f2parte04+'}'+LF_CR

** Totales Gravado
IF !ALLTRIM(SunatMidoc.condipag) $ mCondPagGratis ;
		AND x_Esexportacion = 0 AND IsInafecta= 0
	a3parte04= ALLTRIM(STR(SunatMidoc.neto,12,2))
	b3parte04= ALLTRIM(STR(SunatMidoc.igv,12,2))
	c3parte04= 'S'
	d3parte04= '1000'
	e3parte04= 'IGV'
	f3parte04= 'VAT'
ELSE
	a3parte04= ''
	b3parte04= ''
	c3parte04= ''
	d3parte04= ''
	e3parte04= ''
	f3parte04= ''
ENDIF
sub03P04= a3parte04+'|'+b3parte04+'|'+c3parte04+'|'+d3parte04+'|'+e3parte04+'|'+f3parte04+'}'+LF_CR

** Totales ISC / Otros tributos. No aplica
a4parte04= ''
b4parte04= ''
c4parte04= ''
d4parte04= ''
e4parte04= ''
f4parte04= ''
sub04P04= a4parte04+'|'+b4parte04+'|'+c4parte04+'|'+d4parte04+'|'+e4parte04+'|'+f4parte04+'}'

x04_StrBody=sub01P04+ sub02P04+ sub03P04+ sub04P04+ LF_CR+ '~'

********Fin Parte04 ****************************************************************************************************************************************
********Inicio Parte05: MONTOS TOTALES *********************************************************************************************************************
** 20/06/2018: Cambio de valores de campos   && Falta implementar caso de despachos de anticipos. Esto se encuentra  implementado en otro metodo.
a_Parte05= ALLTRIM(STR(SunatMidoc.neto,12,2))    && Total valor de la venta
b_Parte05= ALLTRIM(STR(SunatMidoc.TOTAL,12,2))   && Total precio de venta (incluye impuestos)
c_Parte05= '0.00'                                && Total descuentos por items
d_Parte05= '0.00'                                && Total otros cargos del comprobante
e_Parte05= ALLTRIM(STR(TotalAnticipos, 10,2))    && Monto total de anticipos del comprobante (revisando los ejemplos incluido igv)
f_Parte05= ALLTRIM(STR(SunatMidoc.TOTAL,12,2))   && Importe total de la venta
g_Parte05= ''                                    && Monto para redondeo del importe total (no se aplica aqui)
h_Parte05= ALLTRIM(STR(SunatMidoc.igv,12,2))     && Sumatoria de impuestos
x05_StrBody=a_Parte05+'|'+b_Parte05+'|'+c_Parte05+'|'+d_Parte05+'|'+e_Parte05+'|'+f_Parte05+'|'+g_Parte05+'|'+h_Parte05+'}'+LF_CR+'~'

********Fin Parte05 ****************************************************************************************************************************************

********Inicio Parte06: DESCUENTO GLOBAL - FISE - PERCEPCION ***********************************************************************************************
** 20/06/2018: Cambio de valores de campos
a_Parte06='' && Indicador de cargo / descuento global - no aplica
b_Parte06='' && Codigo del motivo del cargo/descuento - no aplica
c_Parte06='' && Factor del cargo/descuento - no aplica
d_Parte06='' && Monto del cargo/descuento - no aplica
e_Parte06='' && Monto de base de cargo/descuento - no aplica
x06_StrBody=a_Parte06+'|'+b_Parte06+'|'+c_Parte06+'|'+d_Parte06+'|'+e_Parte06+'}'+LF_CR+'~'

********Fin Parte06 ****************************************************************************************************************************************

********Inicio Parte07: DATOS DEL ANTICIPO *****************************************************************************************************************

IF TotalAnticipos = 0
	a_Parte07='' && Monto Prepagado o anticipado (no incluye impuestos)
	b_Parte07='' && Código del tipo de moneda del monto prepagado o anticipado
	c_Parte07='' && Serie y numero de comprobante del anticipo
	d_Parte07='' && Codigo de tipo de Doc Anticipo  Catalogo 12
	e_Parte07='' && Identificador del pago
	f_Parte07='' && Fecha de pago

	x07_StrBody=a_Parte07+'|'+b_Parte07+'|'+c_Parte07+'|'+d_Parte07+'|'+e_Parte07+'|'+f_Parte07+'}'+LF_CR+'~'

ELSE
	SELECT MisAnticipos
	x07_StrBodySub=''
	SCAN
		y_PyearAnRe=STR(YEAR(frecepcionpago_fa),4,0)
		y_PmontAnRe=TRANSFORM(MONTH(frecepcionpago_fa),"@L 99")
		y_PDayyAnRe=TRANSFORM(DAY(frecepcionpago_fa),"@L 99")

		fectxtAnRe=y_PyearAnRe+'-'+y_PmontAnRe+'-'+y_PDayyAnRe

		y_PyearAnEf=STR(YEAR(fefectuadapago_fa),4,0)
		y_PmontAnEf=TRANSFORM(MONTH(fefectuadapago_fa),"@L 99")
		y_PDayyAnEf=TRANSFORM(DAY(fefectuadapago_fa),"@L 99")

		fectxtAnEf=y_PyearAnEf+'-'+y_PmontAnEf+'-'+y_PDayyAnEf

		a_Parte07=ALLTRIM(STR(monto_fa,12,2))

		DO CASE  && Catalogo 02 Anexo 08
			CASE ALLTRIM(tiporef_fa)='01'
				b_Parte07='PEN'
			CASE ALLTRIM(tiporef_fa)='02'
				b_Parte07='USD'
		ENDCASE

		c_Parte07=ALLTRIM(cpe_fa)+ TRANSFORM(serie_fa, '@L 999')+ '-'+ TRANSFORM(numero_fa, '@L 999999')

		d_Parte07="02"  && Factura emitida por anticipo (catalogo 12)
		e_Parte07="1"
		f_Parte07=fectxtAnRe
		
		x07_StrBodySub=x07_StrBodySub+ a_Parte07+'|'+b_Parte07+'|'+c_Parte07+'|'+d_Parte07+'|'+e_Parte07+'|'+f_Parte07+'}'

	ENDSCAN
	x07_StrBody=x07_StrBodySub+LF_CR+'~'

ENDIF

********Fin Parte07 ****************************************************************************************************************************************

********Inicio Parte08: DETALLES ***************************************************************************************************************************
LOCAL MyUnico,Subdetalle,igvlinea
MyUnico=SunatMidoc.UNICO
DocuIgv=Igv_ele  && Porcentaje de IGV (18)

x08_StrBody=''
Subdetalle ='' && Enlazar cada linea del detalle

lnHandle = SQLSTRINGCONNECT(MyString)
IF lnHandle > 0
	IF MitipoDoc='F'
		IF Miserie=60
			cmd0=SQLEXEC(lnHandle,"SELECT a.producto,a.cantidad,a.um,a.precioventa as precio, ROUND((a.cantidad*a.precioventa),2) as subtotal,b.nombre,a.lote as lotefab,"+;
				"c.CodSunat FROM im_detallevsucesiva a INNER JOIN productos b ON a.producto=b.codigo INNER JOIN TipoProductos c ON b.TipoProducto=c.Codigo "+;
				"WHERE a.codigo=?MiPedVtaSuc","SunatMidetalle")
		ELSE
			cmd0=SQLEXEC(lnHandle,"SELECT a.*,b.nombre,c.CodSunat FROM detafacturas a INNER JOIN productos b ON a.producto=b.codigo "+ ;
				"INNER JOIN TipoProductos c ON b.TipoProducto=c.Codigo WHERE a.unico=?Myunico","SunatMidetalle")
		ENDIF
	ELSE
		cmd0=SQLEXEC(lnHandle,"SELECT a.*,b.nombre,c.CodSunat FROM detaboletas a INNER JOIN productos b ON a.producto=b.codigo "+ ;
			"INNER JOIN TipoProductos c ON b.TipoProducto=c.Codigo WHERE a.unico=?Myunico","SunatMidetalle")
	ENDIF

	SQLDISCONNECT(lnHandle)
ELSE
	AERROR(laErr)
	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

IF Isvtasucesiva=0
	*******Agrupacion de Items solo para el TXT *********************************************************************************************
	SELECT producto,nombre,lotefab,um,cantidad,precio,subtotal,es_alter,txt_alternativo,CodSunat FROM Sunatmidetalle INTO CURSOR way01 READWRITE
	SELECT Sunatmidetalle
	DELETE ALL
	SELECT way01
	SCAN
		var1=ALLTRIM(producto)
		var2=ALLTRIM(nombre)
		var3=ALLTRIM(lotefab)
		var4=ALLTRIM(um)
		var5=cantidad
		var6=precio
		var7=subtotal
		var8=es_alter
		var9=txt_alternativo
		mSunat=CodSunat
		SELECT Sunatmidetalle
		LOCATE FOR ALLTRIM(producto)=var1 AND ALLTRIM(um)=var4 AND precio=var6
		IF FOUND()
			*replace lotefab WITH lotefab+'-'+var3
			REPLACE lotefab WITH ALLTRIM(lotefab)+ IIF(!EMPTY(var3) AND !EMPTY(lotefab),'-', '')+ var3
			REPLACE cantidad WITH cantidad+var5
			REPLACE subtotal WITH subtotal+var7
		ELSE
			APPEND BLANK
			REPLACE producto WITH var1
			REPLACE nombre WITH var2
			REPLACE lotefab WITH var3
			REPLACE um WITH var4
			REPLACE cantidad WITH var5
			REPLACE precio WITH var6
			REPLACE subtotal WITH var7
			REPLACE es_alter WITH var8
			REPLACE txt_alternativo WITH var9
			REPLACE CodSunat WITH mSunat
		ENDIF
		SELECT way01
	ENDSCAN
	USE IN way01
ENDIF

******************************************************************************************************************

SELECT Sunatmidetalle
COUNT TO CtaRegVs
GO TOP
SCAN
	CtaMiReg=CtaMiReg+1
	AcumulaMG=AcumulaMG+Sunatmidetalle.subtotal

	a_Parte08= ALLTRIM(STR(CtaMiReg,3))
	b_Parte08= ALLTRIM(STR(Sunatmidetalle.cantidad,13,2))
	IF ALLTRIM(UPPER(Sunatmidetalle.um))='UN'
		c_Parte08='NIU'  && NIU
	ELSE
		c_Parte08=UPPER(ALLTRIM(Sunatmidetalle.um)) && Catalogo 03
	ENDIF
	d_Parte08=ALLTRIM(STR(Sunatmidetalle.subtotal,13,2))   && Valor de venta del item (- descuentos)

	igvlinea = ROUND((Sunatmidetalle.subtotal*DocuIgv)/100, 2)
	preconigv= ROUND((Sunatmidetalle.subtotal*DocuIgv)/100, 2)+ Sunatmidetalle.subtotal
	
	mPU = ROUND(Sunatmidetalle.Precio * (1+ (DocuIgv/100)), 2)
	
	IF ALLTRIM(SunatMidoc.condipag)='OB'
		g_Parte08= '02'  && PriceTypeCode: 01 Precion Unitario (inc IGV)
	ELSE
		g_Parte08= '01'
	ENDIF
	
	IF MitipoDoc='F'
		IF Miserie=60 OR IsInafecta=1  && Vta Sucesiva
			e_Parte08= ALLTRIM(STR(0.00,12,2))  && Sumatoria de impuestos por linea
			f_Parte08= ALLTRIM(STR(Sunatmidetalle.Precio,12,2)) && PriceAmount  && p*q *igv (en este caso no hay igv)
			
			** Datos relativos al IGV
			m_Parte08= ALLTRIM(STR(Sunatmidetalle.subtotal,13,2)) && Monto de la operacion - afectacion al igv por item
			n_Parte08= e_Parte08   && IGV item
			o_Parte08= 'O'    && Categoría del impuesto
			p_Parte08= '0.00' && Porcentaje del impuesto

			IF Miserie=30
				q_Parte08= '40'

			ELSE
				q_Parte08= '30'   && Código de tipo de afectación del IGV. Catalogo 07: Inafecto - Operacion Onerosa. TaxExemptionReasonCode
			ENDIF
			r_Parte08= '9998' && Código de tributo
			s_Parte08= 'INA'  && Nombre de tributo
			t_Parte08= 'FRE'  && Código internacional de tributo
		ELSE
			IF x_Esexportacion= 1 && Si es Exportación o es Inafecta
				e_Parte08=ALLTRIM(STR(0.00,12,2))  && 0.00 x Inafecta
				f_Parte08=ALLTRIM(STR(Sunatmidetalle.Precio,12,2)) && PriceAmount  && p*q *igv (en este caso no hay igv)
				
				** Datos afectos a IGV
				m_Parte08= ALLTRIM(STR(Sunatmidetalle.subtotal,13,2)) && Monto de la operacion - afectacion al igv por item
				n_Parte08= e_Parte08   && IGV item
				o_Parte08= 'G'         && Categoría del impuesto
				p_Parte08= '0.00'
				q_Parte08= '40'   && Catalogo 07: Exportacion. TaxExemptionReasonCode
				r_Parte08= '9995' && Código de tributo
				s_Parte08= 'EXP'  && Nombre de tributo
				t_Parte08= 'FRE'  && Código internacional de tributo
			ELSE
				e_Parte08=ALLTRIM(STR(igvlinea,12,2))  && Monto Igv de la Linea
				f_Parte08=ALLTRIM(STR(mPU,12,2)) && Price Amount
				*g_Parte08='01' && PriceTypeCode

				** Datos relativos al IGV
				m_Parte08= ALLTRIM(STR(Sunatmidetalle.subtotal,13,2)) && Monto de la operacion - afectacion al igv por item
				n_Parte08= e_Parte08  && IGV item
				o_Parte08= 'S'        && Categoría del impuesto
				p_Parte08= ALLTRIM(STR(DocuIgv, 6, 2))
				q_Parte08= '10'   && Catalogo 07: Gravado - Operacion Onerosa. TaxExemptionReasonCode
				r_Parte08= '1000' && Código de tributo
				s_Parte08= 'IGV'  && Nombre de tributo
				t_Parte08= 'VAT'  && Código internacional de tributo
			ENDIF
		ENDIF
	ELSE
		DO CASE
			CASE ALLTRIM(SunatMidoc.condipag)='MG'  && Si es que es Muestra Gratis
				e_Parte08=ALLTRIM(STR(0.00,12,2))  && 0.00 x Inafecta
				f_Parte08=ALLTRIM(STR(Sunatmidetalle.Precio,12,2)) && PriceAmount
				*g_Parte08='02' && PriceTypeCode: 02 Valor referencial unitario en operaciones no onerosas
				
				** Datos relativos al IGV
				m_Parte08= ALLTRIM(STR(Sunatmidetalle.subtotal,13,2)) && Monto de la operacion - afectacion al igv por item
				n_Parte08= e_Parte08  && IGV item
				o_Parte08= 'Z'    && Categoria del impuesto
				p_Parte08= '0.00' && Porcentaje del impuesto
				q_Parte08= '36'   && Catalogo 07: Inafecto - Retiro por Publicidad
				r_Parte08= '9996' && Código de tributo
				s_Parte08= 'GRA'  && Nombre de tributo
				t_Parte08= 'FRE'  && Código internacional de tributo

			CASE ALLTRIM(SunatMidoc.condipag)='OB'  && Si es que es por OBSEQUIO (Gravada)  Transferencia gratuita
				e_Parte08=ALLTRIM(STR(igvlinea,12,2))  && Monto Igv de la Linea
				f_Parte08=ALLTRIM(STR(mPU,12,2)) && Price Amount
				*g_Parte08='01' && PriceTypeCode

				** Datos relativos al IGV
				m_Parte08= ALLTRIM(STR(Sunatmidetalle.subtotal,13,2)) && Monto de la operacion - afectacion al igv por item
				n_Parte08= e_Parte08  && IGV item
				o_Parte08= 'S'  && Categoría del impuesto
				p_Parte08= ALLTRIM(STR(DocuIgv, 6, 2))  && Porcentaje del impuesto
				q_Parte08= '10'   && Catalogo 07: Gravado - Operacion Onerosa. TaxExemptionReasonCode
				r_Parte08= '1000' && Código de tributo
				s_Parte08= 'IGV'  && Nombre de tributo
				t_Parte08= 'VAT'  && Código internacional de tributo

			OTHERWISE  &&(Gravada)
				e_Parte08=ALLTRIM(STR(igvlinea,12,2))  && Monto Igv de la Linea
				f_Parte08=ALLTRIM(STR(mPU,12,2)) && Price Amount
				*g_Parte08='01' && PriceTypeCode

				** Datos relativos al IGV
				m_Parte08= ALLTRIM(STR(Sunatmidetalle.subtotal,13,2)) && Monto de la operacion - afectacion al igv por item
				n_Parte08= e_Parte08  && IGV item
				o_Parte08= 'S'    && Categoría del impuesto
				p_Parte08= ALLTRIM(STR(DocuIgv, 6, 2))   && Porcentaje del impuesto
				q_Parte08= '10'   && Catalogo 07: Gravado - Operacion Onerosa. TaxExemptionReasonCode
				r_Parte08= '1000' && Código de tributo
				s_Parte08= 'IGV'  && Nombre de tributo
				t_Parte08= 'VAT'  && Código internacional de tributo
		ENDCASE
	ENDIF

	h_Parte08= ''  && Indicador de cargo / descuento del item
	i_Parte08= ''  && Codigo del motivo de cargo / descuento
	j_Parte08= ''  && factor del cargo / descuento
	k_Parte08= ''  && Monto del cargo / descuento
	l_Parte08= ''  && Monto de base de cargo / descuento

	** Datos relativos a ISC  - No aplica
	u_Parte08= ''  && Monto de operacion afecta a ISC
	v_Parte08= ''  && Monto de ISC
	w_Parte08= ''  && Categoria de impuesto
	x_Parte08= ''  && Porcentaje de impuesto ISC
	y_Parte08= ''  && Código de tipo de sistema ISC
	z_Parte08= ''  && Código de tributo
	a1Parte08= ''  && Nombre de tributo
	b1Parte08= ''  && Código internacional de tributo

	** Datos relativos a Otros tributos - No aplica
	c1Parte08= ''  && Monto de operacion afecta a Otros tributos
	d1Parte08= ''  && Monto otros tributos
	e1Parte08= ''  && Categoria de impuesto
	f1Parte08= ''  && Porcentaje de impuesto
	g1Parte08= ''  && Código de tributo
	h1Parte08= ''  && Nombre de tributo
	i1Parte08= ''  && Código internacional de tributo

	mLoteArt = ''
	** Descripcion detallada e información adicional
	IF MitipoDoc='F' AND Miserie=60  &&& Es Vta Sucesiva
		mLoteArt = ALLTRIM(Sunatmidetalle.lotefab)
		IF CtaMiReg=CtaRegVs  && Es el ultimo registro del detalle
			j1Parte08=ALLTRIM(Sunatmidetalle.nombre)
			k1Parte08='^^'+'^ORIGEN:'+ALLTRIM(Datavs.paisorigen)+'^'+ALLTRIM(Datavs.aranceles)+'^'+NotaVs01 &&Detalle adicional
		ELSE
			j1Parte08=ALLTRIM(Sunatmidetalle.nombre)
			k1Parte08=''  && Detalle adicional
		ENDIF
	ELSE
		DO CASE
			CASE x_Esexportacion = 1
				mTxtAlter = ALLTRIM(Sunatmidetalle.txt_alternativo)
				IF !EMPTY(mTxtAlter)
					j1Parte08= ''
					k1Parte08= ''  && Detalle adicional
					mLineas   = MEMLINES(mTxtAlter)
					IF mLineas > 0
						FOR I= 1 TO mLineas
							mTxtLinea = ALLTRIM(MLINE(mTxtAlter, I))
							j1Parte08 = j1Parte08+ IIF(!EMPTY(j1Parte08),'^', '')+ mTxtLinea
						ENDFOR
					ENDIF
					j1Parte08= j1Parte08
				ELSE
					mLoteArt = ALLTRIM(Sunatmidetalle.lotefab)
					IF CtaMiReg=CtaRegVs  && Es el ultimo registro del detalle
						j1Parte08= ALLTRIM(Sunatmidetalle.nombre)
						k1Parte08= ''  && Detalle adicional
						mLineas = MEMLINES(mObsCuerpo)
						IF mLineas > 0
							FOR I= 1 TO mLineas
								mTxtLinea = ALLTRIM(MLINE(mObsCuerpo, I))
								k1Parte08 = k1Parte08+ '^'+ mTxtLinea
							ENDFOR
						ENDIF
					ELSE
						j1Parte08= ALLTRIM(Sunatmidetalle.nombre)
						k1Parte08= ''  && Detalle adicional
					ENDIF
				ENDIF
			CASE Sunatmidetalle.es_alter=0
				j1Parte08= ALLTRIM(Sunatmidetalle.nombre)+' '+ALLTRIM(Sunatmidetalle.lotefab)
				k1Parte08= ''  && Detalle adicional
			OTHERWISE
				j1Parte08= ALLTRIM(Sunatmidetalle.txt_alternativo)
				k1Parte08= ''  && Detalle adicional
		ENDCASE
	ENDIF

	l1Parte08= ALLTRIM(Sunatmidetalle.producto)
	m1Parte08= IIF(ISNULL(Sunatmidetalle.CodSunat), '', ALLTRIM(Sunatmidetalle.CodSunat))  && Código de producto Sunat. Catalogo 25. Obligatorio a partir del 01/01/2019 **Obs**
	n1Parte08= ''  && Código de producto GS1
	
	o1Parte08= ALLTRIM(STR(Sunatmidetalle.precio,12,2))  &&& PriceAmount: Valor unitario sin IGV
	
	** Concepto tributario - Se podrá indicar informacion adicional al item el cual es materia de comunicacion
	p1Parte08= ''   && Nombre del concepto
	q1Parte08= ''   && Código de concepto tributario del item
	r1Parte08= ''   && valor de la propiedad del item
	s1Parte08= ''   && Fecha de inicio de la propiedad del item
	t1Parte08= ''   && Fecha de fin de la propiedad del item
	u1Parte08= ''   && Duracion (dias) de la propiedad del item
	
	Subdetalle=a_Parte08+'|'+b_Parte08+'|'+c_Parte08+'|'+d_Parte08+'|'+e_Parte08+'|'+f_Parte08+'|'+g_Parte08+'|'+h_Parte08+'|'+i_Parte08+'|'+;
		j_Parte08+'|'+k_Parte08+'|'+l_Parte08+'|'+m_Parte08+'|'+n_Parte08+'|'+o_Parte08+'|'+p_Parte08+'|'+q_Parte08+'|'+r_Parte08+'|'+;
		s_Parte08+'|'+t_Parte08+'|'+u_Parte08+'|'+v_Parte08+'|'+w_Parte08+'|'+x_Parte08+'|'+y_Parte08+'|'+z_Parte08+'|'+a1Parte08+'|'+;
		b1Parte08+'|'+c1Parte08+'|'+d1Parte08+'|'+e1Parte08+'|'+f1Parte08+'|'+g1Parte08+'|'+h1Parte08+'|'+i1Parte08+'|'+j1Parte08+'|'+;
		k1Parte08+'|'+l1Parte08+'|'+m1Parte08+'|'+n1Parte08+'|'+o1Parte08+'|'+p1Parte08+'|'+q1Parte08+'|'+r1Parte08+'|'+s1Parte08+'|'+;
		t1Parte08+'|'+u1Parte08+'|'+mLoteArt+ '}'
	
	x08_StrBody= x08_StrBody+ Subdetalle
	
ENDSCAN

x08_StrBody= x08_StrBody+LF_CR+'~'

********Fin Parte08 ****************************************************************************************************************************************

********Inicio Parte09 : DETRACCION (SOLO PARA FACTURAS)****************************************************************************************************
IF MitipoDoc='F'
	IF MitipoDoc='F' AND Miserie= 50 AND LEN(ALLTRIM(SunatMidoc.tipodetraccion))> 1
		x09_StrBody = ''
		SELECT Sunatmidetalle
		CtaMiReg = 0
		SCAN
			CtaMiReg= CtaMiReg+ 1
			a_Parte09= ALLTRIM(STR(CtaMiReg,3))  && Numero de linea
			b_Parte09= '001' && Medio de pago  001 Deposito en cuenta
			c_Parte09= '00068294282'
			d_Parte09= LEFT(SunatMidoc.tipodetraccion, 3)     && 020, 023, 037
			e_Parte09= ALLTRIM(STR(PctjeDetracServ/100,12,2)) && Porcentaje de la detracción
	
			preconigv= ROUND((Sunatmidetalle.subtotal*DocuIgv)/100, 2)+ Sunatmidetalle.subtotal
			f_Parte09= ALLTRIM(STR(ROUND(preconigv * (PctjeDetracServ/100), 2), 12,2))   && Monto de la detracción. ALLTRIM(STR(ROUND((VAL(b_Parte05)*PctjeDetracServ)/100,2),12,2))
			g_Parte09= d_Parte01   && Código de tipo de Moneda
	
			x09_StrBody = x09_StrBody+ a_Parte09+'|'+b_Parte09+'|'+c_Parte09+'|'+d_Parte09+'|'+e_Parte09+'|'+f_Parte09+'|'+g_Parte09+'}'
		ENDSCAN
	ELSE
		a_Parte09= ''
		b_Parte09= ''
		c_Parte09= ''
		d_Parte09= ''
		e_Parte09= ''
		f_Parte09= ''
		g_Parte09= ''
		x09_StrBody = a_Parte09+'|'+b_Parte09+'|'+c_Parte09+'|'+d_Parte09+'|'+e_Parte09+'|'+f_Parte09+'|'+g_Parte09+'}'
	ENDIF
	x09_StrBody= x09_StrBody+LF_CR+'~'
ELSE
	x09_StrBody= ''
ENDIF
********Fin Parte09 ****************************************************************************************************************************************

********Inicio Parte10, Parte11 y Parte12 : FACTURA GUIA, CONDUCTORES, VEHICULOS ***************************************************************************
IF MitipoDoc='F'
	* No se aplica.
	x10_StrBody = '|||||||||||||||||||||||||}'+LF_CR+'~'    && Datos de la direccion de partida y llegada, datos del transportista y vehiculos
	x11_StrBody = '|}'+LF_CR+ '~'   && Datos de los conductores: Numero y tipo de documento
	x12_StrBody = '}' +LF_CR+ '~'   && Datos de los vehiculos: Numero de placa de vehiculo de translado
ELSE
	x10_StrBody = ''
	x11_StrBody = ''
	x12_StrBody = ''
ENDIF
********Fin Parte10, Parte11 Y Parte12 *********************************************************************************************************************

********Inicio Parte13: LEYENDAS ***************************************************************************************************************************

mMontoLetras = ALLTRIM(Convnum(VAL(b_Parte05)))+IIF(d_Parte01='PEN'," SOLES", " DOLARES AMERICANOS")   && Monto total en letras

* Desactivado porque el monto en letras sale en un campo posterior (campo obligatorio)
a_parte13= ''  && mMontoLetras
b_parte13= ''  && '1000'

x13_StrBody = a_parte13+ '|'+ b_parte13+ '}'+LF_CR+ '~'
********Fin Parte13 ****************************************************************************************************************************************

******** Inicio Parte14: ADJUNTOS **************************************************************************************************************************
a_parte14= ''   && Tienda. Campo a definir por el cliente
b_parte14= ''   && Caja. Campo a definir por el cliente
c_parte14= ''   && Cajero. Campo a definir por el cliente

d_parte14= ''   && Libre 1. Campo a definir por el cliente
e_parte14= ''   && Libre 2. Campo a definir por el cliente
f_parte14= ''   && Libre 3. Campo a definir por el cliente

g_parte14= ''   && Observacion

IF MitipoDoc='F' AND Miserie=60 &&& Solo Para Vta Sucesiva
	d_parte14= ALLTRIM(Datavs.bl)  && BL Conocimiento de Embarque
	
	h_Parte14= ALLTRIM(Datavs.incoterm)  && Descripcion INCOTERMS	
	i_Parte14= ALLTRIM(STR(Datavs.fvalorfob,12,2)) && Total FOB
	j_Parte14= ALLTRIM(STR(Datavs.fvalorflete,12,2)) && Total Flete
	k_Parte14= ALLTRIM(STR(Datavs.fvalorseguro,12,2)) && Total Seguro
	
	n_Parte14= ALLTRIM(Datavs.pedido)  && Lista de Empaque / OC
ELSE
	d_parte14= ''
	
	IF x_Esexportacion = 1
		h_Parte14=mIncoterms
	ELSE
		h_Parte14=''  && Incoterms
	EndIf	
	i_Parte14= '' && Total FOB
	j_Parte14= '' && Total Flete
	k_Parte14= '' && Total Seguro
	
	n_Parte14= '' && Lista de Empaque / OC
ENDIF

l_parte14=''  && Guia Transporte
m_Parte14=''  && Medio Transporte

DO CASE
	CASE MitipoDoc='B'
		IF ALLTRIM(SunatMidoc.condipag)='MG'
			e_parte14= ' MUESTRA PROMOCIONAL '
		ELSE
			e_parte14= ALLTRIM(SunatMidoc.Nompago)
		ENDIF
	OTHERWISE && Factura
		IF Miserie=60  &&& Si es Vta Sucesiva
			e_parte14= ALLTRIM(Datavs.condicionpago)
		ELSE
			IF x_Esexportacion = 1 AND !EMPTY(mDetCPago)
				e_parte14= ALLTRIM(SunatMidoc.Nompago)+ ' / '+ mDetCPago
			ELSE
				e_parte14= ALLTRIM(SunatMidoc.Nompago)
			ENDIF
		ENDIF
ENDCASE

f_parte14= Micliente.Codigo

DO CASE
	CASE MitipoDoc='B' && Boleta
		IF ALLTRIM(SunatMidoc.condipag)='MG'
			g_parte14=FraseMG+' '+IIF(d_Parte01='PEN','S/','US$')+' '+ALLTRIM(STR(AcumulaMG,12,2))+' '+FraseBoleta
		ELSE
			g_parte14=FraseBoleta
		ENDIF
	CASE MitipoDoc='F' && Factura
		DO CASE
			CASE Miserie=50  && Servicios Averiguar si por el monto aplica la Percepcion
				DO CASE
					CASE ALLTRIM(SunatMidoc.tipodetraccion)='020-01'
						g_parte14=FraseDetrac01
					CASE ALLTRIM(SunatMidoc.tipodetraccion)='037-01'
						g_parte14=FraseDetrac02
					CASE ALLTRIM(SunatMidoc.tipodetraccion)='022-01'
						g_parte14=FraseDetrac03
					OTHERWISE
						g_parte14=''
				ENDCASE
			CASE Miserie=60  &&  Factura Vta Sucesiva
				g_parte14=FraseVs01
			CASE x_Esexportacion = 1
				g_parte14=mObsPieDoc
			OTHERWISE
				g_parte14=''
		ENDCASE
ENDCASE

o_Parte14= ''   && Glosa


a2parte14= ''   && Observaciones
b2parte14= mMontoLetras   && Monto en palabras

**** Configurando lista de correo a enviar ***
yy_01=ALLTRIM(Micliente.cpe01)
yy_02=ALLTRIM(Micliente.cpe02)
IF LEN(yy_02)< 7 && Longitud minima correo
	MyListaCorreo=yy_01
ELSE
	MyListaCorreo=yy_01+';'+yy_02
ENDIF

IF xServer=2
	MyListaCorreo = 'egutierrez@sociedadquimica.com.pe'
ELSE
	MyListaCorreo = MyListaCorreo+ ';'+ 'cpe_sqm@sociedadquimica.com.pe'
ENDIF

*MyListaCorreo = 'egutierrez@sociedadquimica.com.pe'
c2parte14= MyListaCorreo
d2parte14= ''  && Nombre de Impresora
e2parte14= ''  && Copias

f2parte14= ''  && Emitir (para implementaciones SPOOL)

*IF MitipoDoc='F'
	x14_StrBody=a_parte14+'|'+b_parte14+'|'+c_parte14+'|'+d_parte14+'|'+e_parte14+'|'+f_parte14+'|'+g_parte14+;
			'|'+h_parte14+'|'+i_parte14+'|'+j_parte14+'|'+k_parte14+'|'+l_parte14+'|'+m_parte14+'|'+n_parte14+;
			'|'+o_parte14+'}'+LF_CR+ a2parte14+'|'+b2parte14+'|'+c2parte14+'|'+d2parte14+'|'+e2parte14+'|'+ f2parte14+ '}'+ LF_CR+ '~'
*ELSE    && Desactivado para que esta seccion sea igual en facturas y boletas. Segun archivo excel el campo observacion en boletas sale en otra posicion.
*	x14_StrBody= a_parte14+'|'+b_parte14+'|'+c_parte14+'|'+d_parte14+'|'+e_parte14+'|';
*		+f_parte14+'}'+LF_CR+g_parte14+'|'+ a2parte14+'|'+b2parte14+'|'+c2parte14+'|';
*		+d2parte14+'|'+e2parte14+'|'+ '}'+ +LF_CR+'~'
*ENDIF

******** Fin de Parte14 ************************************************************************************************************************************
*
******** Inicio Parte15: MEDIOS DE PAGO ********************************************************************************************************************
DO CASE
	CASE MitipoDoc='B'
		IF ALLTRIM(SunatMidoc.condipag)='MG'
			a_Parte15=' MUESTRA PROMOCIONAL '
		ELSE
			a_Parte15=ALLTRIM(SunatMidoc.Nompago)
		ENDIF
	OTHERWISE && Factura
		IF Miserie=60  &&& Si es Vta Sucesiva
			a_Parte15=ALLTRIM(Datavs.condicionpago)
		ELSE
			IF x_Esexportacion = 1 AND !EMPTY(mDetCPago)
				a_Parte15= ALLTRIM(SunatMidoc.Nompago)+ ' / '+ mDetCPago
			ELSE
				a_Parte15=ALLTRIM(SunatMidoc.Nompago)
			ENDIF
		ENDIF
ENDCASE
b_Parte15= b_Parte05  && = ALLTRIM(STR(SunatMidoc.total,12,2))   && Total precio de venta (incluye impuestos)
x15_StrBody= a_Parte15+ '|'+ b_Parte15+ '}'+LF_CR+'~'+LF_CR+'/'

********Fin Parte15 ****************************************************************************************************************************************

*xControl='c:\VENTAS\'+b_Parte01+'.txt'
*xControl='\\SQMSERVER\inputprod\'+b_Parte01+'.txt'

IF xServer=2
	xControl='c:\ventas\inputprod\'+b_Parte01+'.txt'
ELSE
	*xControl='\\SQMSERVER\inputprod\'+b_Parte01+'.txt'
ENDIF

gnErrFile = FCREATE(xControl)

IF gnErrFile>0
	IF MitipoDoc='F'
		StrBody=x01_StrBody+LF_CR+x02_StrBody+LF_CR+x03_StrBody+LF_CR+x04_StrBody+LF_CR+x05_StrBody+LF_CR;
			+x06_StrBody+LF_CR+x07_StrBody+LF_CR+x08_StrBody+LF_CR+ x09_StrBody+LF_CR+ x10_StrBody+LF_CR;
			+x11_StrBody+LF_CR+x12_StrBody+LF_CR+x13_StrBody+LF_CR+x14_StrBody+LF_CR+x15_StrBody
	ELSE
		StrBody=x01_StrBody+LF_CR+x02_StrBody+LF_CR+x03_StrBody+LF_CR+x04_StrBody+LF_CR+x05_StrBody+LF_CR;
			+x06_StrBody+LF_CR+x07_StrBody+LF_CR+x08_StrBody+LF_CR+ ;
			+x13_StrBody+LF_CR+x14_StrBody+LF_CR+x15_StrBody
	ENDIF
	=FPUTS(gnErrFile,StrBody) &&Graba la variable en el archivo txt
	SET CENTURY OFF
	=FCLOSE(gnErrFile) &&cerramos el archivo.
ELSE
	WAIT WINDOW "Error al abrir el archivo"
ENDIF

USE IN Sunatmidetalle
USE IN SunatMidoc

USE IN MiDatosPlus
USE IN KonsMess
USE IN MiDatasqm
USE IN Cambiooficial
USE IN Micliente

IF USED('Datavs')
	USE IN Datavs
ENDIF
