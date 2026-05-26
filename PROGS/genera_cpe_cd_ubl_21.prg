LPARAMETER pCia, pTD, pSerieLet, pSerieNro, pNumero

mSwPrueba= 0

SET PROCEDURE TO funciones

#DEFINE LF_CR CHR(13)
#DEFINE LF_RR CHR(10)+CHR(13)

#DEFINE TABU CHR(9)

LOCAL cpe_ControlTxt,StrBody,cpe_CodCia,cpe_SerieLet,Miserie,cpe_TipoDoc,cpe_SerieNro,cpe_Numero,FraseDetrac01,FraseDetrac02
LOCAL MyUbigeo,MyUrbanizacion,cpe_Correos, cpe_Condipag, cpe_CondPagGratis
LOCAL cpe_Inafecta, cpe_Exportacion, cpe_AfecDetrac, cpe_idFac, cpe_Serie_Ref, cpe_PedVtaSuc
LOCAL cpe_PorcIGV

LOCAL StsCentury

StsCentury = SET('CENTURY')
SET CENTURY ON
SET DELETED ON

IF pCia= 1  && SQM
	mCadConexion = MyString_ofi01   && Variable publica del sistema Ventas SQM
	cpe_CodCia= 'S030'    &&  'I207': Para hacer pruebas en Indicolor con datos de SQM
ELSE
	mCadConexion = MyString         && Variable publica del sistema Ventas Indicolor
	cpe_CodCia= 'I131'
ENDIF

cpe_TipoDoc = pTD
cpe_SerieLet= pSerieLet
cpe_SerieNro= pSerieNro
cpe_Numero  = pNumero

cpe_Exportacion= 0
cpe_AfecDetrac = ''
cpe_idFac = 0
cpe_PedVtaSuc = ''
cpe_Serie_Ref = 0
cpe_Inafecta = 0
cpe_Condipag = ''

cpe_CondPagGratis= 'MG'     && las muestras gratis inafecto.

x01_StrBody=''
x02_StrBody=''
x03_StrBody=''
x04_StrBody=''
x05_StrBody=''
x06_StrBody=''
x07_StrBody=''
x08_StrBody=''
StrBody=''

*--------------------------------------------------

lnHandle = SQLSTRINGCONNECT(mCadConexion)

IF lnHandle > 0
	cmd0=SQLEXEC(lnHandle,"SELECT * FROM constantes ","cDatos_Cpe")
	cmd3=SQLEXEC(lnHandle,"SELECT * FROM k_sunatelectronica ","cDatos2_Cpe")
	cmd2=SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?cpe_CodCia","cDatosCia_cpe")
	IF cpe_TipoDoc='D'  && Debito
		cmd1=SQLEXEC(lnHandle,"SELECT a.*, 'F' as TipoDoc FROM ndebito a WHERE cpe=?cpe_SerieLet AND a.serie=?cpe_SerieNro AND a.numero=?cpe_Numero","cDocCab_Cpe")
		GO TOP IN cDocCab_Cpe
		mCpe_ref= cDocCab_Cpe.Cpe_Apli
		cpe_Serie_Ref= cDocCab_Cpe.Serie_Apli
		mNro_ref= cDocCab_Cpe.Numero_Apli
		IF cDocCab_Cpe.Cpe_Apli= 'F'
			cmd= SQLEXEC(lnHandle,"SELECT Unico, guiaserie, guianum, Exportacion, inafecta, condipag, TipoDetraccion, vspedido FROM Factura WHERE cpe=?mCpe_ref AND serie=?cpe_Serie_Ref AND numero=?mNro_ref","cFacGuiaRef")
			GO TOP IN cFacGuiaRef
			cpe_AfecDetrac = cFacGuiaRef.TipoDetraccion
			cpe_idFac = cFacGuiaRef.Unico
			cpe_PedVtaSuc = cFacGuiaRef.vspedido
			cpe_Inafecta = cFacGuiaRef.inafecta
			cpe_Condipag = ALLTRIM(cFacGuiaRef.condipag)
			USE IN cFacGuiaRef
		ENDIF
	ELSE  && Credito
		cmd1=SQLEXEC(lnHandle,"SELECT a.* FROM ncredito a  WHERE cpe=?cpe_SerieLet AND a.serie=?cpe_SerieNro AND a.numero=?cpe_Numero","cDocCab_Cpe")
		GO TOP IN cDocCab_Cpe
		mCpe_ref= cDocCab_Cpe.CpeF
		cpe_Serie_Ref= cDocCab_Cpe.SerieF
		mNro_ref= cDocCab_Cpe.NumeroF
		IF cDocCab_Cpe.TipoDoc= 'F'
			cmd= SQLEXEC(lnHandle,"SELECT Unico, guiaserie, guianum, Exportacion, inafecta, condipag, TipoDetraccion, vspedido FROM Factura WHERE cpe=?mCpe_ref AND serie=?cpe_Serie_Ref AND numero=?mNro_ref","cFacGuiaRef")
			GO TOP IN cFacGuiaRef
			cpe_AfecDetrac = cFacGuiaRef.TipoDetraccion
			cpe_idFac = cFacGuiaRef.Unico
			cpe_PedVtaSuc = cFacGuiaRef.vspedido
			cpe_Inafecta = cFacGuiaRef.inafecta
			cpe_Condipag = ALLTRIM(cFacGuiaRef.condipag)
			IF !ISNULL(cFacGuiaRef.guianum) AND cFacGuiaRef.guianum <> 0
				mSer_gr = cFacGuiaRef.guiaserie
				mNum_gr = cFacGuiaRef.guianum
				cmd= SQLEXEC(lnHandle,"SELECT FlagExportacion FROM GuiasRemision WHERE serie=?mSer_gr AND numero=?mNum_gr","cGuiaExp")
				GO TOP IN cGuiaExp
				IF !ISNULL(cGuiaExp.FlagExportacion)
					cpe_Exportacion = cGuiaExp.FlagExportacion
				ENDIF
				USE IN cGuiaExp
			ELSE
				IF cFacGuiaRef.Exportacion = 1
					cpe_Exportacion = 1
				ENDIF
			ENDIF
			USE IN cFacGuiaRef
		ELSE
			cmd= SQLEXEC(lnHandle,"SELECT Unico, condipag FROM Boleta WHERE cpe=?mCpe_ref AND serie=?cpe_Serie_Ref AND numero=?mNro_ref","cFacGuiaRef")
			GO TOP IN cFacGuiaRef
			cpe_idFac  = cFacGuiaRef.Unico
			cpe_Condipag = ALLTRIM(cFacGuiaRef.condipag)
			USE IN cFacGuiaRef
		ENDIF
	ENDIF
	SQLDISCONNECT(lnHandle)
ELSE
	AERROR(laErr)
	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

MyUbigeo=ALLTRIM(cDatos2_Cpe.c_myubigeo)
MyUrbanizacion=ALLTRIM(cDatos2_Cpe.c_myurbanizacion)
FraseDetrac01=ALLTRIM(cDatos2_Cpe.c_frasedetrac01)
FraseDetrac02=ALLTRIM(cDatos2_Cpe.c_frasedetrac02)

cpe_PorcIGV=cDatos_Cpe.igv
Miserie=cDocCab_Cpe.serie

SELECT cDocCab_Cpe

LOCAL MyUnico
MyUnico=cDocCab_Cpe.UNICO

*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte01
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
&& Código de tipo de documento
IF cpe_TipoDoc='D'
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
b_Parte01=cpe_SerieLet+TRANSFORM(serie,'@L 999')+'-'+TRANSFORM(numero,'@L 99999999')

y_Pyear=STR(YEAR(cDocCab_Cpe.fecha),4,0)
y_Pmont=TRANSFORM(MONTH(cDocCab_Cpe.fecha),"@L 99")
y_PDayy=TRANSFORM(DAY(cDocCab_Cpe.fecha),"@L 99")

&&Fecha de emisión
c_Parte01=y_Pyear+'-'+y_Pmont+'-'+y_PDayy

DO CASE  && Catalogo 02 Anexo 08
		&& Código de tipo de moneda en la cual se emite la nota de crédito electrónica
	CASE cDocCab_Cpe.Moneda='M1'
		d_Parte01='PEN'
	CASE cDocCab_Cpe.Moneda='M2'
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
	CASE cpe_Exportacion= 1
		k_Parte01='0200'    && Exportación
	CASE !EMPTY(cpe_AfecDetrac)
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
SELECT cDatosCia_cpe

&&Número de RUC del emisor
a_Parte02=ALLTRIM(cDatosCia_cpe.ruc)
&& Tipo de Documento de Identidad del emisor
b_Parte02='6' &&& Tipo de Documento Catalogo 6 ruc

c_Parte02=ALLTRIM(cDatosCia_cpe.nombre)
d_Parte02=ALLTRIM(cDatosCia_cpe.nombre)
e_Parte02=MyUbigeo
f_Parte02=ALLTRIM(cDatosCia_cpe.direccion)
g_Parte02=MyUrbanizacion
h_Parte02=ALLTRIM(cDatosCia_cpe.prov)
i_parte02=ALLTRIM(cDatosCia_cpe.dpto)
j_parte02=ALLTRIM(cDatosCia_cpe.DIST)
k_Parte02=ALLTRIM(cDatosCia_cpe.pais)  && Basado en Catalogo 04

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
Codcli=cDocCab_Cpe.codigoc

lnHandle = SQLSTRINGCONNECT(mCadConexion)

IF lnHandle > 0
	cmd1=SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codcli","cDatosCli_cpe")
	SQLDISCONNECT(lnHandle)
ELSE
	AERROR(laErr)
	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT cDatosCli_cpe
&& Número de RUC del receptor
a_Parte03=ALLTRIM(cDatosCli_cpe.ruc)
&& Tipo de Documento de Identidad del receptor
b_Parte03=ALLTRIM(cDatosCli_cpe.tiposunat)  &&& Tipo de Documento Catalogo 6  Revisar la Validacion solo asumimmos ruc mIentras

&& Nombre o razón social del receptor
c_Parte03=ALLTRIM(cDatosCli_cpe.nombre)
d_Parte03=''       && Nombre comercial del receptor - opcional
e_Parte03=''       && Código de ubigeo del receptor - opcional
f_Parte03=ALLTRIM(cDatosCli_cpe.direccion)
g_Parte03='' && Urbanizacion (SE HA QUITADO DE LA STRUCTURA)---
h_Parte03=ALLTRIM(cDatosCli_cpe.prov)
i_parte03=ALLTRIM(cDatosCli_cpe.dpto)
j_parte03=ALLTRIM(cDatosCli_cpe.DIST)
k_Parte03=ALLTRIM(cDatosCli_cpe.pais)  && Basado en Catalogo 04
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
IF cpe_TipoDoc='D'
	d_Parte04= LEFT(DTOS(cDocCab_Cpe.fecha_apli), 4)+ '-'+ SUBSTR(DTOS(cDocCab_Cpe.fecha_apli),5,2)+ '-'+ RIGHT(DTOS(cDocCab_Cpe.fecha_apli), 2)
ELSE
	d_Parte04= LEFT(DTOS(cDocCab_Cpe.fechaF), 4)+ '-'+ SUBSTR(DTOS(cDocCab_Cpe.fechaF),5,2)+ '-'+ RIGHT(DTOS(cDocCab_Cpe.fechaF), 2)
ENDIF

IF cpe_TipoDoc='D' &&& Para Nota de Debito
	&&Código de tipo de nota de débito
	b_Parte04= ALLTRIM(cDocCab_Cpe.Motivo)
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
	c_Parte04 = ALLTRIM(cDocCab_Cpe.cpe_apli)+TRANSFORM(cDocCab_Cpe.serie_apli,'@L 999')+'-'+TRANSFORM(cDocCab_Cpe.numero_apli,'@L 99999999') &&38
	e_Parte04= TRANSFORM(cDocCab_Cpe.tiposunat_apli,'@L 99')  &&41
ELSE   && Para Nota de Credito
	DO CASE
		CASE cDocCab_Cpe.tipo=1
			a_Parte04 ='06' && 39 Catalogo 09  Devolucion por ItEM (07) --- TOTAL (06)
			b_Parte04='DEVOLUCION DE MERCADERIA'  &&40
		CASE cDocCab_Cpe.tipo=2
			a_Parte04 ='04' && 39 Catalogo 09  Descuento Global
			b_Parte04='DESCUENTO DE PRECIO'
		CASE cDocCab_Cpe.tipo=9
			a_Parte04 ='01' && 39 Catalogo 09  Anulacion de la operacion
			b_Parte04='ANULACION DE DOCUMENTO'
		CASE cDocCab_Cpe.tipo=10
			a_Parte04 ='04' && 39 Catalogo 09  Descuento Global
			b_Parte04='DESCUENTO'  &&40
	ENDCASE
	
	IF !EMPTY(ALLTRIM(cDocCab_Cpe.xmodifica))
		c_Parte04 = ALLTRIM(cDocCab_Cpe.xmodifica)
		IF ALLTRIM(cDocCab_Cpe.xTipoDoc)= 'Factura'
			e_Parte04= '01'
		ELSE
			e_Parte04= '03'
		ENDIF
	ELSE
		c_Parte04 =ALLTRIM(cDocCab_Cpe.CpeF)+TRANSFORM(cDocCab_Cpe.SerieF,'@L 999')+'-'+TRANSFORM(cDocCab_Cpe.NumeroF,'@L 99999999') &&38
		DO CASE
			CASE cDocCab_Cpe.TipoDoc='F'
				e_Parte04='01'  &&41
			CASE cDocCab_Cpe.TipoDoc='B'
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

IF cpe_Exportacion = 1 OR cpe_Inafecta= 1 OR (cDocCab_Cpe.TipoDoc='F' And cpe_Serie_Ref=60) 
	a_parte05= ALLTRIM(STR(cDocCab_Cpe.neto,12,2))   && Total valor de la venta
	b_parte05= '0.00'         && Importe del tributo
	IF cpe_Exportacion = 1
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
IF cpe_Condipag $ cpe_CondPagGratis
	a2parte05= ALLTRIM(STR(cDocCab_Cpe.neto,12,2))   && Total valor de la venta
	b2parte05= ALLTRIM(STR(cDocCab_Cpe.igv,12,2))    && Sumatoria IGV
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
IF !cpe_Condipag $ cpe_CondPagGratis AND cpe_Exportacion = 0 AND cpe_Inafecta= 0 AND !(cDocCab_Cpe.TipoDoc='F' And cpe_Serie_Ref=60) 
	a3parte05= ALLTRIM(STR(cDocCab_Cpe.neto,12,2))   && Total valor de la venta
	b3parte05= ALLTRIM(STR(cDocCab_Cpe.igv,12,2))    && Sumatoria IGV
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
*b_Parte06=ALLTRIM(STR(cDocCab_Cpe.total,12,2))
*x06_StrBody=a_Parte06+'|'+b_Parte06+'|'+'}'+'~'

a_Parte06= ALLTRIM(STR(cDocCab_Cpe.neto,12,2))    && Total valor de la venta
b_Parte06= ALLTRIM(STR(cDocCab_Cpe.TOTAL,12,2))   && Total precio de venta (incluye impuestos)
c_Parte06= '0.00'                                && Monto total de otros cargos del comprobante
d_Parte06= ALLTRIM(STR(cDocCab_Cpe.TOTAL,12,2))   && Importe total de la venta, cesión en uso o del servicio prestado
e_Parte06= ''                                	&& Monto para Redondeo del Importe Total
f_Parte06= ALLTRIM(STR(cDocCab_Cpe.igv,12,2))     && Sumatoria de impuestos

x06_StrBody=a_Parte06+'|'+b_Parte06+'|'+c_Parte06+'|'+d_Parte06+'|'+e_Parte06+'|'+f_Parte06+'}'+LF_CR+'~'

* Fin Parte06
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------
* Inicio Parte07 - Detalles
*---------------------------------------------------------------------------
*---------------------------------------------------------------------------

IF cpe_TipoDoc='D'
	a_Parte07 = ALLTRIM(STR(1)) && Numero de Linea
	b_Parte07 = ALLTRIM(STR(1)) && Cantidad de Item
	c_Parte07 = 'NIU'  && NIU
	d_Parte07 = ALLTRIM(STR(cDocCab_Cpe.neto,13,2))
	e_Parte07 = ALLTRIM(STR(cDocCab_Cpe.igv,12,2))
	f_Parte07 = ALLTRIM(STR(cDocCab_Cpe.Total,12,2))
	
	IF cpe_Condipag = cpe_CondPagGratis
		g_Parte07= '02'  && PriceTypeCode: 02 Valor referencial unitario en operaciones no onerosas (Gratuitas)
	ELSE
		g_Parte07= '01'  && PriceTypeCode: 01 Precion Unitario (inc IGV)  Código de tipo de precio de venta unitario
	ENDIF
	
	h_Parte07 = ALLTRIM(STR(cDocCab_Cpe.neto,12,2))
	i_Parte07 = ALLTRIM(STR(cDocCab_Cpe.igv,12,2))
	
	DO Case
		CASE cpe_Exportacion = 1
			j_Parte07= 'G'   && Categoria Impuesto 
			k_Parte07= '0.00' && Porcentaje de impuesto
			l_Parte07= '40'   && Codigo de tipo de afectacion del IGV  40: Exportacion
			m_Parte07= '9995' && Código de tributo
			n_Parte07= 'EXP'  && Nombre de tributo
			o_Parte07= 'FRE'  && Código internacional de tributo
		CASE cpe_Inafecta= 1 OR (cDocCab_Cpe.TipoDoc='F' And cpe_Serie_Ref=60)
			j_Parte07= 'O'   && Categoria Impuesto 
			k_Parte07= '0.00' && Porcentaje de impuesto
			l_Parte07= '30'   && Codigo de tipo de afectacion del IGV   30: Inafecto - Operacion Onerosa  (29/01/2019: Consultar a Contabilidad)
			m_Parte07= '9998' && Código de tributo
			n_Parte07= 'INA'  && Nombre de tributo
			o_Parte07= 'FRE'  && Código internacional de tributo
		CASE cpe_Condipag $ cpe_CondPagGratis      && Muestra gratis promocional
			j_Parte07= 'Z'   && Categoria Impuesto 
			k_Parte07= '0.00' && Porcentaje de impuesto
			l_Parte07= '36'   && Codigo de tipo de afectacion del IGV   36: Inafecto - Retiro por publicidad  (29/01/2019: Consultar a Contabilidad)
			m_Parte07= '9996' && Código de tributo
			n_Parte07= 'GRA'  && Nombre de tributo
			o_Parte07= 'FRE'  && Código internacional de tributo
		OTHERWISE
			j_Parte07= 'S'   && Categoria Impuesto
			k_Parte07= ALLTRIM(Str(cpe_PorcIGV, 6, 2))  && Porcentaje de impuesto
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
	
	e1Parte07= ALLTRIM(cDocCab_Cpe.Observacion)   && Descripcion 
	f1Parte07= ''
	mLoteArt = ''
	
	** Codigo producto SQM / Codigo Sunat	
	lnHandle = SQLSTRINGCONNECT(mCadConexion)
	IF lnHandle > 0
		cmd0= SQLEXEC(lnHandle,"SELECT a.Producto,b.nombre, b.CodSunat FROM detafacturas a ,productos b WHERE a.producto=b.codigo AND a.unico=?cpe_idFac","cDocDet_Cpe")
		SQLDISCONNECT(lnHandle)
	ELSE
		AERROR(laErr)
		MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	ENDIF
	GO TOP IN cDocDet_Cpe
	
	IF a_Parte04= '02'  && Correccion de precio
		g1Parte07= cDocDet_Cpe.Producto  && Codigo del producto SQM
		h1Parte07= cDocDet_Cpe.CodSunat  && Codigo de Producto Sunat
	ELSE
		g1Parte07= ''  && Codigo del producto SQM
		h1Parte07= ''  && Codigo de Producto Sunat			
	ENDIF
	
	i1Parte07= ''
	j1Parte07= ALLTRIM(STR(cDocCab_Cpe.neto,12,2))   && Valor unitario (sin igv)
	
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
	
ELSE && Nota de Credito
	Isvtasucesiva= 0
	lnHandle = SQLSTRINGCONNECT(mCadConexion)
	IF lnHandle > 0
		DO Case
			CASE cDocCab_Cpe.tipo= 1   && Devolucion de Mercaderia
				cmd0= SQLEXEC(lnHandle,"SELECT a.*,b.nombre, b.CodSunat, '' as txt_alternativo FROM detallencredito a ,productos b WHERE a.producto=b.codigo AND a.unico=?Myunico","cDocDet_Cpe")
			CASE cDocCab_Cpe.tipo= 2   && Descuento de Precio
				cmd0= SQLEXEC(lnHandle,"SELECT a.*,b.nombre, b.CodSunat, '' as txt_alternativo FROM detallencredito a ,productos b WHERE a.producto=b.codigo AND a.unico=?Myunico","cDocDet_Cpe")
			CASE cDocCab_Cpe.tipo= 9   && Anulacion de documento
				IF cpe_Serie_Ref= 60 && Si es Factura Vta Sucesiva
					Isvtasucesiva= 1
					cmd0= SQLEXEC(lnHandle,"SELECT a.*,b.nombre, b.CodSunat, a.Cantidad as cantaplicada, Convert(round(cantidad * precioventa, 2), Decimal(10,2)) as SubTotal, "+ ;
						"Convert(0, decimal(10,2)) as precioorigen, Convert(0, decimal(10,2)) as nuevoprecio FROM im_detallevsucesiva a ,productos b WHERE a.producto=b.codigo AND a.Codigo=?cpe_PedVtaSuc","cDocDet_Cpe")
				ELSE
					IF cDocCab_Cpe.TipoDoc= 'F'
						cmd0= SQLEXEC(lnHandle,"SELECT a.*,CAST(b.nombre as CHAR(200)) as Nombre, b.CodSunat, a.Cantidad as cantaplicada, Convert(0, decimal(10,2)) as precioorigen, Convert(0, decimal(10,2)) as nuevoprecio "+ ;
								"FROM detafacturas a ,productos b WHERE a.producto=b.codigo AND a.unico=?cpe_idFac","cDocDet_Cpe")
					ELSE
						cmd0= SQLEXEC(lnHandle,"SELECT a.*,CAST(b.nombre as CHAR(200)) as Nombre, b.CodSunat, a.Cantidad as cantaplicada, Convert(0, decimal(10,2)) as precioorigen, Convert(0, decimal(10,2)) as nuevoprecio "+ ;
								"FROM detaboletas a ,productos b WHERE a.producto=b.codigo AND a.unico=?cpe_idFac","cDocDet_Cpe")
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
		SELECT producto,PADR(nombre,250) as Nombre,um,cantaplicada,precioorigen,nuevoprecio,subtotal,CodSunat, txt_alternativo FROM cDocDet_Cpe INTO CURSOR way01
		SELECT cDocDet_Cpe
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
			SELECT cDocDet_Cpe
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
	SELECT cDocDet_Cpe
	GO TOP
	SCAN
		mItem = mItem+ 1
		a_Parte07= ALLTRIM(STR(mItem,5))
		mCant = cDocDet_Cpe.cantaplicada
		IF cDocCab_Cpe.tipo= 2  && Descuento de precio
			mCant = 1
		ENDIF
		b_Parte07 = ALLTRIM(STR(mCant,10,2))
		IF ALLTRIM(UPPER(cDocDet_Cpe.um))='UN' OR cDocCab_Cpe.tipo= 2   && Descuento de precio
			c_Parte07='NIU'
		ELSE
			c_Parte07=UPPER(ALLTRIM(cDocDet_Cpe.um)) && Catalogo 03
		ENDIF
		d_Parte07= ALLTRIM(STR(cDocDet_Cpe.SubTotal,13,2))
		
		igvlinea= ROUND(((cDocDet_Cpe.SubTotal* cpe_PorcIGV)/100),2)
		mPU     = ROUND((cDocDet_Cpe.SubTotal + igvlinea) / mCant, 2)
		mVU     = ROUND((cDocDet_Cpe.SubTotal) / mCant, 2)
		mBaseIGV = cDocDet_Cpe.SubTotal
		IF cpe_Condipag = cpe_CondPagGratis OR (cDocCab_Cpe.TipoDoc='F' And cpe_Serie_Ref=60)  && Muestra Gratis o Vta Sucesiva
			igvlinea = 0
			e_Parte07= ALLTRIM(STR(0.00,12,2))  && 0.00 x Inafecta   && TaxAmount
			f_Parte07= ALLTRIM(STR(mVU+ 0,12,2))   && Valor Unitario + Impuesto   && PriceAmount
		ELSE
			IF cpe_Inafecta=1 OR cpe_Exportacion= 1  && Si es Exportación o es Inafecta
				igvlinea = 0
				e_Parte07= ALLTRIM(STR(0.00,12,2))  && 0.00 x Inafecta
				f_Parte07= ALLTRIM(STR(mVU+ 0,12,2))   && Valor Unitario + Impuestos   && PriceAmount
			ELSE
				e_Parte07= ALLTRIM(STR(igvlinea,12,2))  && Monto Igv de la Linea
				f_Parte07= ALLTRIM(STR(mPU,12,2))       && Valor Unitario + Impuestos  && PriceAmount
			ENDIF
		ENDIF
		
		IF cpe_Condipag = cpe_CondPagGratis
			g_Parte07= '02'  && PriceTypeCode: 02 Valor referencial unitario en operaciones no onerosas (Gratuitas)
		ELSE
			g_Parte07= '01'  && PriceTypeCode: 01 Precion Unitario (inc IGV)  Código de tipo de precio de venta unitario
		ENDIF
		
		** Tributo del IGV ***
		h_Parte07= ALLTRIM(STR(mBaseIGV, 12, 2))
		i_Parte07= ALLTRIM(STR(igvlinea,12,2))
		DO Case
			CASE cpe_Exportacion = 1
				j_Parte07= 'G'   && Categoria Impuesto 
				k_Parte07= '0.00' && Porcentaje de impuesto
				l_Parte07= '40'   && Codigo de tipo de afectacion del IGV  40: Exportacion
				m_Parte07= '9995' && Código de tributo
				n_Parte07= 'EXP'  && Nombre de tributo
				o_Parte07= 'FRE'  && Código internacional de tributo
			CASE cpe_Inafecta= 1 OR (cDocCab_Cpe.TipoDoc='F' And cpe_Serie_Ref=60)
				j_Parte07= 'O'   && Categoria Impuesto 
				k_Parte07= '0.00' && Porcentaje de impuesto
				l_Parte07= '30'   && Codigo de tipo de afectacion del IGV   30: Inafecto - Operacion Onerosa  (29/01/2019: Consultar a Contabilidad)
				m_Parte07= '9998' && Código de tributo
				n_Parte07= 'INA'  && Nombre de tributo
				o_Parte07= 'FRE'  && Código internacional de tributo
			CASE cpe_Condipag $ cpe_CondPagGratis      && Muestra gratis promocional
				j_Parte07= 'Z'   && Categoria Impuesto 
				k_Parte07= '0.00' && Porcentaje de impuesto
				l_Parte07= '36'   && Codigo de tipo de afectacion del IGV   36: Inafecto - Retiro por publicidad  (29/01/2019: Consultar a Contabilidad)
				m_Parte07= '9996' && Código de tributo
				n_Parte07= 'GRA'  && Nombre de tributo
				o_Parte07= 'FRE'  && Código internacional de tributo
			OTHERWISE
				j_Parte07= 'S'   && Categoria Impuesto
				k_Parte07= ALLTRIM(Str(cpe_PorcIGV, 6, 2))  && Porcentaje de impuesto
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
		
		IF cDocCab_Cpe.tipo= 2   && Descuento de precio
			e1Parte07= PADR(ALLTRIM(cDocDet_Cpe.producto),8,' ')+' '+ALLTRIM(SUBSTR(cDocDet_Cpe.nombre,1,55))+'   '+'Cant: '+ALLTRIM(STR(cDocDet_Cpe.cantaplicada,10,2))+'   '+'Valor Unit: '+ALLTRIM(STR(cDocDet_Cpe.precioorigen,10,2))+'   '+'NVU: '+ALLTRIM(STR(cDocDet_Cpe.nuevoprecio,10,2))+'   '+'Subtotal: '+ALLTRIM(STR(cDocDet_Cpe.subtotal,10,2))
		ELSE
			e1Parte07= ALLTRIM(cDocDet_Cpe.nombre)
		ENDIF
		e1Parte07= e1Parte07
		mLoteArt = ''
		
		f1Parte07= ''
		g1Parte07= ALLTRIM(cDocDet_Cpe.Producto)
		h1Parte07= ALLTRIM(cDocDet_Cpe.CodSunat)
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
yy_01=ALLTRIM(cDatosCli_cpe.cpe01)
yy_02=ALLTRIM(cDatosCli_cpe.cpe02)

IF LEN(yy_02)<7 && Longitud minima correo
	cpe_Correos=yy_01
ELSE
	cpe_Correos=yy_01+';'+yy_02
ENDIF

IF mSwPrueba= 1
	cpe_Correos = 'egutierrez@sociedadquimica.com.pe'
ELSE
	cpe_Correos = cpe_Correos+ ';'+ 'cpe_sqm@sociedadquimica.com.pe'
ENDIF

**********************************************
i_parte09 =  cpe_Correos    && "Correo electrónico al cual se enviará el comprobante en formato PDF y XMLSi es más de un correo se debe separar por "";"". Ej: correo1@mail.pe;correo2@mail.pe"
j_parte09 = ''   && Se debe encontrar conectada en red y visible desde el servidor de facturación.
k_parte09 = ''   && Número de páginas a imprimir
l_parte09 = ''   && "emitir" (utilizar para implementaciones SPOOL)

x09_StrBody = x09_StrBody + g_parte09+ '|'+ h_parte09+'|'+ i_parte09+'|'+ j_parte09+'|'+ k_parte09+'|'+ l_parte09+'}'+LF_CR+'~'+LF_CR+'\'

********Fin Parte09 ****************************************************************************************************************************************

IF mSwPrueba= 1
	cpe_ControlTxt='C:\Ventas\inputprod\'+ ALLTRIM(cpe_TipoDoc)+ b_Parte01+'.txt'
ELSE
	cpe_ControlTxt='\\MV-SIS03\input_prod\'+ ALLTRIM(cpe_TipoDoc)+ b_Parte01+'.txt'
	*cpe_ControlTxt='C:\Ventas\inputprod\'+ ALLTRIM(cpe_TipoDoc)+ b_Parte01+'.txt'
ENDIF

gnErrFile = FCREATE(cpe_ControlTxt)  && If not create it

IF gnErrFile>0
	StrBody= x01_StrBody+LF_CR+x02_StrBody+LF_CR+x03_StrBody+LF_CR;
			+x04_StrBody+LF_CR+x05_StrBody+LF_CR+x06_StrBody+LF_CR;
			+x07_StrBody+LF_CR+x08_StrBody+LF_CR+x09_StrBody

	=FPUTS(gnErrFile,StrBody) &&Graba la variable en el archivo txt
	=FCLOSE(gnErrFile) &&cerramos el archivo.
ELSE
	WAIT WINDOW "Error al abrir el archivo"
ENDIF

IF StsCentury= 'OFF'
	SET CENTURY OFF
ENDIF

USE IN cDatos_Cpe
USE IN cDatos2_Cpe
USE IN cDatosCia_cpe
USE IN cDatosCli_cpe

USE IN cDocCab_Cpe
USE IN cDocDet_Cpe
