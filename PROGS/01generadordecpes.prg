** Programa para generar archivo de texto de los comprobantes electronicos para Acepta en la unidad c:\ventas

SET PROCEDURE TO funciones
SET CENTURY ON
#DEFINE LF_CR CHR(10)+CHR(13)
#DEFINE TABU CHR(9)
SET DELETED ON

LOCAL xControl,Snt_Documento,StrBody,Pase1,Codigosqm,DocuIgv,Miserie,MitipoDoc,Seriedoc,Numerodoc,Hoy
LOCAL FraseMG,FraseBoleta,AcumulaMG,FraseDetrac01,FraseDetrac02,FraseDetrac03,MinSolesDetrac,MinDolarDetrac,TcVentaHoy,PctjeDetracServ,x_isExport,x_EsLibre
LOCAL MiPedVtaSuc,CtaRegVs,CtaMiReg,NotaVs01,FraseVs01,MyUbigeo,MyUrbanizacion
LOCAL MyListaCorreo,Isvtasucesiva,IsInafecta

Isvtasucesiva=0
Codigosqm='S030'
DocuIgv=0
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

MitipoDoc='F' &&x_Sunatipodoc
Seriedoc=10   &&Myserief
Numerodoc=13166 &&Mynumerof

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0
	cmd0=SQLEXEC(lnHandle,"SELECT * FROM constantes ","MiDatosPlus")
	cmd3=SQLEXEC(lnHandle,"SELECT * FROM k_sunatelectronica ","KonsMess")
	cmd2=SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codigosqm","MiDatasqm")
	cmd5=SQLEXEC(lnHandle,"SELECT venta FROM tcoficial WHERE fecha=?hoy","Cambiooficial")
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
	MiPedVtaSuc=SunatMidoc.vspedido
	IsInafecta=SunatMidoc.inafecta
ELSE
	MiPedVtaSuc=''
	IsInafecta=0
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
			e_Parte01=ALLTRIM(SunatMidoc.variasguias)
		ELSE
			IF SunatMidoc.guiaserie=0 OR SunatMidoc.guianum=0
				e_Parte01=''
			ELSE
				e_Parte01=TRANSFORM(guiaserie,'@L 999')+'-'+TRANSFORM(guianum,'@L 99999999')
			ENDIF
		ENDIF
	ELSE  && Si es Boleta (No hay Boletas Agrupadas)
		IF SunatMidoc.guiaserie=0 OR SunatMidoc.guianum=0
			e_Parte01=''
		ELSE
			e_Parte01=TRANSFORM(guiaserie,'@L 999')+'-'+TRANSFORM(guianum,'@L 99999999')
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
				i_Parte01=ALLTRIM(SunatMidoc.ocdirecta)  && Ver si es asi NO va OC
				* i_Parte01=''  &&& no se como llenar para las agrupadas, Como va NO va OC
			ELSE
				LocM1=SunatMidoc.guiaserie
				LocM2=SunatMidoc.guianum

				lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
				IF lnHandle > 0
					cmd2=SQLEXEC(lnHandle,"SELECT oc FROM guiasremision WHERE serie=?LocM1 and numero=?LocM2","LocMx")
					SQLDISCONNECT(lnHandle)
				ELSE
					AERROR(laErr)
					MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
				ENDIF

				i_Parte01=ALLTRIM(LocMx.oc) && Orden de Compra  (Busqueda en Guia de Remision)
			ENDIF
		ENDIF
	CASE MitipoDoc='B'
		i_Parte01=''
ENDCASE

x01_StrBody=a_Parte01+'|'+b_Parte01+'|'+c_Parte01+'|'+d_Parte01+'|'+e_Parte01+'|'+f_Parte01+'|'+g_Parte01+'|'+h_Parte01+'|'+i_Parte01+'|'+'}'

********Fin Parte01 ****************************************************************************************************************************************

********Inicio Parte02**************************************************************************************************************************************

SELECT MiDatasqm

a_Parte02=ALLTRIM(MiDatasqm.ruc)
b_Parte02='6' &&& Tipo de Documento Catalogo 6 RUC para sqm
c_Parte02=ALLTRIM(MiDatasqm.nombre)
d_Parte02=ALLTRIM(MiDatasqm.nombre)
e_Parte02=MyUbigeo
f_Parte02=ALLTRIM(MiDatasqm.direccion)
g_Parte02=MyUrbanizacion
h_Parte02=ALLTRIM(MiDatasqm.prov)
i_parte02=ALLTRIM(MiDatasqm.dpto)
j_parte02=ALLTRIM(MiDatasqm.dist)
k_Parte02=ALLTRIM(MiDatasqm.pais)  && Basado en Catalogo 04

x02_StrBody=a_Parte02+'|'+b_Parte02+'|'+c_Parte02+'|'+d_Parte02+'|'+e_Parte02+'|'+f_Parte02+'|'+g_Parte02+'|'+h_Parte02+'|'+i_parte02+'|'+;
	j_parte02+'|'+k_Parte02+'|'+'}'

********Fin Parte02 ****************************************************************************************************************************************

********Inicio Parte03**************************************************************************************************************************************
LOCAL Codcli
Codcli=SunatMidoc.codigoc

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0
	cmd1=SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codcli","MiCliente")
	SQLDISCONNECT(lnHandle)
ELSE
	AERROR(laErr)
	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF
SELECT Micliente

a_Parte03=ALLTRIM(Micliente.ruc)
b_Parte03=ALLTRIM(Micliente.tiposunat) &&& Tipo de Documento Catalogo 6  Revisar la Validacion solo asumimmos ruc mIentras
c_Parte03=ALLTRIM(Micliente.nombre)
d_Parte03=ALLTRIM(Micliente.direccion)
e_Parte03='' && Urbanizacion (SE HA QUITADO DE LA STRUCTURA)
f_Parte03=ALLTRIM(Micliente.prov)
g_parte03=ALLTRIM(Micliente.dpto)
h_parte03=ALLTRIM(Micliente.dist)
i_Parte03=ALLTRIM(Micliente.pais)  && Basado en Catalogo 04

x03_StrBody=a_Parte03+'|'+b_Parte03+'|'+c_Parte03+'|'+d_Parte03+'|'+f_Parte03+'|'+g_parte03+'|'+h_parte03+'|'+i_Parte03+'|'+'}'+'~'

********Fin Parte03 ****************************************************************************************************************************************

********Inicio Parte04**************************************************************************************************************************************
***&&& Sub para IGV
a_Parte04=ALLTRIM(STR(SunatMidoc.igv,12,2))  && Sumatoria IGV
b_Parte04=ALLTRIM(STR(Igv_ele,5,0))    && ALLTRIM(STR(ROUND(((SunatMidoc.igv*100)/SunatMidoc.neto),0),15,0))  && Porcentaje del IGV
c_Parte04='1000' && Ver Catalogo 05
d_Parte04='IGV' && Ver Catalogo 05
e_Parte04='VAT' && Ver Catalogo 05

sub01P04=a_Parte04+'|'+b_Parte04+'|'+c_Parte04+'|'+d_Parte04+'|'+e_Parte04+'|'+'}'

***&& Sub Para ISC (NO aplica)
f_Parte04=''
g_Parte04='' && ISC Ver Catalogo 05
h_Parte04='' && ISC Ver Catalogo 05
i_Parte04='' && ISC Ver Catalogo 05

sub02P04=f_Parte04+'|'+g_Parte04+'|'+h_Parte04+'|'+i_Parte04+'|'+'}'

***&& Sub Para Otros (NO aplica)
j_Parte04=''
k_Parte04='' && ID ???
l_Parte04='' && ISC Ver Catalogo 05
m_Parte04='' && ISC Ver Catalogo 05

sub03P04=j_Parte04+'|'+k_Parte04+'|'+l_Parte04+'|'+m_Parte04+'|'+'}'

x04_StrBody=sub01P04+sub02P04+sub03P04+'~'
DocuIgv=VAL(b_Parte04)

********Fin Parte04 ****************************************************************************************************************************************

********Inicio Parte06**************************************************************************************************************************************

a_Parte06=''  &&ALLTRIM(STR(0.00,12,2)) && Anticipo (NO manejamos)
b_Parte06='' && Codigo Doc Anticipo  Catalogo 12
c_Parte06='' && Serie y NUm de Factura de Anticipo
d_Parte06='' && Fecha recepcion anticipo
e_Parte06='' && Fecha efectuó el anticipo
f_Parte06='' && Hora pago de anticipo

x06_StrBody=a_Parte06+'|'+b_Parte06+'|'+c_Parte06+'|'+d_Parte06+'|'+e_Parte06+'|'+f_Parte06+'|'+'}'+'~'

********Fin Parte06 ****************************************************************************************************************************************

********Inicio Parte07**************************************************************************************************************************************
LOCAL MyUnico,Subdetalle,igvlinea
MyUnico=SunatMidoc.unico
x07_StrBody=''
Subdetalle='' && Enlazar cada linea del detalle

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0

	IF MitipoDoc='F'
		IF Miserie=60
			cmd0=SQLEXEC(lnHandle,"SELECT a.producto,a.cantidad,a.um,a.precioventa as precio,ROUND((a.cantidad*a.precioventa),2) as subtotal,b.nombre, "+;
				"a.lote as lotefab FROM im_detallevsucesiva a ,productos b "+;
				"WHERE a.producto=b.codigo AND a.codigo=?MiPedVtaSuc","SunatMidetalle")
		ELSE
			cmd0=SQLEXEC(lnHandle,"SELECT a.*,b.nombre  FROM detafacturas a , productos b WHERE a.producto=b.codigo AND a.unico=?Myunico","SunatMidetalle")
		ENDIF
	ELSE
		cmd0=SQLEXEC(lnHandle,"SELECT a.*,b.nombre  FROM detaboletas a , productos b WHERE a.producto=b.codigo AND a.unico=?Myunico","SunatMidetalle")
	ENDIF

	SQLDISCONNECT(lnHandle)
ELSE
	AERROR(laErr)
	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

*******Agrupacion de Items solo para el TXT *********************************************************************************************
IF Isvtasucesiva=0
	SELECT producto,nombre,lotefab,um,cantidad,precio,subtotal,es_alter,txt_alternativo FROM Sunatmidetalle INTO CURSOR way01 READWRITE
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
		SELECT Sunatmidetalle
		LOCATE FOR ALLTRIM(producto)=var1 AND ALLTRIM(um)=var4 AND precio=var6
		IF FOUND()
			replace lotefab WITH lotefab+'-'+var3
			replace cantidad WITH cantidad+var5
			replace subtotal WITH subtotal+var7
		ELSE
			APPEND BLANK
			replace producto WITH var1
			replace nombre WITH var2
			replace lotefab WITH var3
			replace um WITH var4
			replace cantidad WITH var5
			replace precio WITH var6
			replace subtotal WITH var7
			replace es_alter WITH var8
			replace txt_alternativo WITH var9
		ENDIF
		SELECT way01
	ENDSCAN
	SELECT Sunatmidetalle
ENDIF
******************************************************************************************************************

SELECT Sunatmidetalle
CtaRegVs=RECCOUNT()
GO top
SCAN
	CtaMiReg=CtaMiReg+1
	AcumulaMG=AcumulaMG+Sunatmidetalle.subtotal
	igvlinea=0
	IF MitipoDoc='F' AND Miserie=60  &&& Es Vta Sucesiva
		IF CtaMiReg=CtaRegVs  && Es el ultimo registro del detalle
			a_Parte07=ALLTRIM(Sunatmidetalle.nombre)
			b_Parte07='^^'+'^ORIGEN:'+ALLTRIM(Datavs.paisorigen)+'^'+ALLTRIM(Datavs.aranceles)+'^'+NotaVs01 &&Detalle adicional
		ELSE
			a_Parte07=ALLTRIM(Sunatmidetalle.nombre)
			b_Parte07=''  && Detalle adicional
		ENDIF
	ELSE
		IF Sunatmidetalle.es_alter=0
			a_Parte07=ALLTRIM(Sunatmidetalle.nombre)+' '+ALLTRIM(Sunatmidetalle.lotefab)
			b_Parte07=''  && Detalle adicional
		ELSE
			a_Parte07=ALLTRIM(Sunatmidetalle.txt_alternativo)
			b_Parte07=''  && Detalle adicional
		ENDIF
	ENDIF
	c_Parte07=ALLTRIM(Sunatmidetalle.producto)
	IF ALLTRIM(UPPER(Sunatmidetalle.um))='UN'
		d_Parte07='NIU'  && NIU
	ELSE
		d_Parte07=UPPER(ALLTRIM(Sunatmidetalle.um)) && Catalogo 03
	ENDIF
	e_Parte07=ALLTRIM(STR(Sunatmidetalle.cantidad,13,2))

	f_Parte07=ALLTRIM(STR(Sunatmidetalle.subtotal,13,2))

	preconigv=ROUND(((Sunatmidetalle.subtotal*DocuIgv)/100),2)+Sunatmidetalle.subtotal

	DO CASE &&& PriceAmount,
			&&& PriceTypeCode
			&&& Código de Precio Catalogo 16 Revisar  (revisar)
			&&& 01 Precion Unitario (inc IGV)
			&&& 02 Valor referencial unitario en operaciones no onerosas
		CASE MitipoDoc='F' && Facturas
			IF Miserie=60  && Es Vta Sucesiva (Inafecta)
				g_Parte07=ALLTRIM(STR(Sunatmidetalle.subtotal,12,2)) && PriceAmount  && p*q *igv (en este caso no hay igv)
				h_Parte07='01' && PriceTypeCode
			ELSE && Otras Series
				IF x_isExport=1 OR IsInafecta=1 && Es Por Exportacion (Inafecta)  u Otras Causas  que se apliquen inafecta
					g_Parte07=ALLTRIM(STR(Sunatmidetalle.subtotal,12,2)) && PriceAmount  && p*q *igv (en este caso no hay igv)
					h_Parte07='01' && PriceTypeCode
				ELSE  &&& Factura gravada
					g_Parte07=ALLTRIM(STR(preconigv,12,2)) && Price Amount
					h_Parte07='01' && PriceTypeCode
				ENDIF
			ENDIF
		OTHERWISE  && MiTipoDoc='B' Boletas
			DO CASE
				CASE ALLTRIM(SunatMidoc.condipag)='MG'  && Si es que es Muestra Gratis (Inafecta)
					g_Parte07=ALLTRIM(STR(Sunatmidetalle.subtotal,12,2)) && PriceAmount
					h_Parte07='02' && PriceTypeCode
				CASE ALLTRIM(SunatMidoc.condipag)='OB'  && Si es que es por OBSEQUIO (Gravada)
					g_Parte07=ALLTRIM(STR(preconigv,12,2)) && Price Amount
					h_Parte07='01' && PriceTypeCode
				OTHERWISE  &&  Gravada
					g_Parte07=ALLTRIM(STR(preconigv,12,2)) && Price Amount
					h_Parte07='01' && PriceTypeCode
			ENDCASE
	ENDCASE  &&& PriceAmount,PriceTypeCode

	i_Parte07='' &&& Indicador , Colocar False (vacio)

	&& Descuentos
	j_Parte07=ALLTRIM(STR(0,6,0)) && Porcentaje de descuento && NO APlica
	k_Parte07=ALLTRIM(STR(0.00,12,2)) && Monto de descuento && No APlica

	&&& Afectacion IGV
	igvlinea=ROUND(((Sunatmidetalle.subtotal*DocuIgv)/100),2)
	DO CASE && TaxAmount
		CASE MitipoDoc='F'
			IF Miserie=60  && Vta Sucesiva
				l_Parte07=ALLTRIM(STR(0.00,12,2))  && 0.00 x Inafecta
			ELSE
				IF x_isExport=1 OR IsInafecta=1 && Si es Exportación o es Inafecta
					l_Parte07=ALLTRIM(STR(0.00,12,2))  && 0.00 x Inafecta
				ELSE
					l_Parte07=ALLTRIM(STR(igvlinea,12,2))  && Monto Igv de la Linea
				ENDIF
			ENDIF
		OTHERWISE && Mitipodoc='B' Boleta
			DO CASE
				CASE ALLTRIM(SunatMidoc.condipag)='MG'  && Si es que es Muestra Gratis
					l_Parte07=ALLTRIM(STR(0.00,12,2))  && 0.00 x Inafecta
				CASE ALLTRIM(SunatMidoc.condipag)='OB'  && Si es que es por OBSEQUIO (Gravada)
					l_Parte07=ALLTRIM(STR(igvlinea,12,2))  && Monto Igv de la Linea
				OTHERWISE (Gravada)
					l_Parte07=ALLTRIM(STR(igvlinea,12,2))  && Monto Igv de la Linea
			ENDCASE
	ENDCASE && TaxAmount

	DO CASE &&TaxExemptionReasonCode
			&& Catalogo 07 Tipo de Afectacion del IGV
			&& 10 Gravado - Operacion Onerosa
			&& 13 GRavado - Retiro
			&& 30 Inafecto - Operacion Onerosa
			&& 32 Inafecto - Retiro
			&& 40 Exportación
			&& 36 Inafecto - Retiro por Publicidad
		CASE MitipoDoc='F'
			IF Miserie=60 OR IsInafecta=1 && Venta Sucesiva O Inafecta van al 30
				m_Parte07='30'
			ELSE
				IF x_isExport=1  && Si es Exportacion
					m_Parte07='40'
				ELSE  && Facturacion Gravada
					m_Parte07='10'
				ENDIF
			ENDIF
		OTHERWISE && Mitipodoc='B' Boleta
			DO CASE
				CASE ALLTRIM(SunatMidoc.condipag)='MG'  && Si es que es Muestra Gratis
					m_Parte07='36'
				CASE ALLTRIM(SunatMidoc.condipag)='OB'  && Si es que es por OBSEQUIO
					m_Parte07='10'
				OTHERWISE
					m_Parte07='10'
			ENDCASE
	ENDCASE &&TaxExemptionReasonCode

	n_Parte07='1000'  && Catalog 05 Codigo de Tributo IGV
	o_Parte07='IGV'  && cATALO 05 nOMBRE DEL TRIBUTO
	p_Parte07='VAT' && Catalogo 05, codigo internacional del tributo

	&& Afectacion ISC
	q_Parte07=ALLTRIM(STR(0.00,12,2)) && Monto ISC (no aplica)
	r_Parte07='' && Catalogo 8, Tipo de Sistema ISC
	s_Parte07='' && Catalogo 05 Codigo de tributo
	t_Parte07='' && Catalogo 05 NOmbre del tributo
	u_Parte07='' && Catalog 05 COdigo internacional del tributo

	&& ????
	v_Parte07=ALLTRIM(STR(Sunatmidetalle.precio,12,2))  &&& PriceAmount

	&& Venta Primaria
	IF MitipoDoc='F' AND Miserie=60  && Si es Factura Vta Sucesiva
		w_Parte07= ALLTRIM(Sunatmidetalle.lotefab)
	ELSE
		w_Parte07='' && LOte Explicar ??
	ENDIF
	Subdetalle=a_Parte07+'|'+b_Parte07+'|'+c_Parte07+'|'+d_Parte07+'|'+e_Parte07+'|'+f_Parte07+'|'+g_Parte07+'|'+h_Parte07+'|'+i_Parte07+'|'+;
		j_Parte07+'|'+k_Parte07+'|'+l_Parte07+'|'+m_Parte07+'|'+n_Parte07+'|'+o_Parte07+'|'+p_Parte07+'|'+q_Parte07+'|'+r_Parte07+'|'+;
		s_Parte07+'|'+t_Parte07+'|'+u_Parte07+'|'+v_Parte07+'|'+w_Parte07+'|'+'}'

	x07_StrBody=x07_StrBody+Subdetalle
ENDSCAN

x07_StrBody=x07_StrBody+'~'

********Fin Parte07 ****************************************************************************************************************************************
********Inicio Parte05**************************************************************************************************************************************

a_Parte05='' &&ALLTRIM(STR(0.00,12,2)) && Otros Cargos (No manejamos)
IF MitipoDoc='B' AND ALLTRIM(SunatMidoc.condipag)='MG'
	b_Parte05=ALLTRIM(STR(SunatMidoc.total,12,2)) && Para MG graba el acumulado x q en BD=0
ELSE
	b_Parte05=ALLTRIM(STR(SunatMidoc.total,12,2)) && Total de la Factura o Boleta
ENDIF
c_Parte05='' &&ALLTRIM(STR(0.00,12,2)) && Descuentos (NO manejamos)

x05_StrBody=a_Parte05+'|'+b_Parte05+'|'+c_Parte05+'|'+'}'+'~'

********Fin Parte05 ****************************************************************************************************************************************

********Inicio Parte08**************************************************************************************************************************************
LOCAL x_PassDetrac  &&&&&&++++AQUI+++++++++++++++++++++++++++
x_PassDetrac=0

IF MitipoDoc='F'
	DO CASE
		CASE Miserie=10 OR Miserie=20 OR Miserie=40  OR Miserie=30 OR Miserie=50 OR Miserie=60 OR Miserie=70 OR Miserie=80 && Revisar si es importacion
			DO CASE
				CASE Miserie=60 OR x_isExport=1 OR IsInafecta=1 &&& Si es Vta Sucesiva o Factura de Exportacion o Inafecta
					a_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Gravada
					b_Parte08=ALLTRIM(STR(SunatMidoc.neto,12,2))  && Inafecta
					c_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Exonerada
				OTHERWISE
					a_Parte08=ALLTRIM(STR(SunatMidoc.neto,12,2))  && Gravada
					b_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Inafecta
					c_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Exonerada
			ENDCASE

			d_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Venta Gratuita
			e_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Total Descuentos

			DO CASE
				CASE x_isExport=1  && Es Exportacion
					f_Parte08='02'  && Tipo operacion SUNAT  -- 02 Exportacion?? Catalogo 17
				OTHERWISE
					f_Parte08='01'  && Tipo operacion SUNAT  -- 01 venta Interna?? Catalogo 17
			ENDCASE

			&& Percepcion
			g_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && Moneda Nacional Percepcion  Base Imponible
			h_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && Moneda Nacional -- Monto de la Percepcion
			i_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && Moneda Nacional -- Total de la Percepcion

			&& Detraccion
			IF Miserie=50   &&& Facturacion de Servicios

				IF LEN(ALLTRIM(SunatMidoc.tipodetraccion))>1
					j_Parte08=ALLTRIM(STR(PctjeDetracServ,12,2))  && Pctje de la detraccion
					k_Parte08=ALLTRIM(STR(ROUND((VAL(b_Parte05)*PctjeDetracServ)/100,2),12,2)) && monto de la detraccion
					l_Parte08='00068294282' && Numero Cta Banco de la nacion ++++++++++++++++++++DUDA+++++++++++++++++++++++++++
					m_Parte08='' && Total recargo
				ELSE && No Alcanza el monto minimo
					j_Parte08='' &&ALLTRIM(STR(0.00,6,0))  && Pctje de la detraccion
					k_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && monto de la detraccion
					l_Parte08='' && Numero Cta Banco de la nacion
					m_Parte08='' && Total recargo
				ENDIF

			ELSE &&& No es Serie 5
				j_Parte08='' &&ALLTRIM(STR(0.00,6,0))  && Pctje de la detraccion
				k_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && monto de la detraccion
				l_Parte08='' && Numero Cta Banco de la nacion
				m_Parte08='' && Total recargo
			ENDIF
	ENDCASE

ELSE  &&& Para Boletas
	DO CASE
		CASE  ALLTRIM(SunatMidoc.condipag)='MG'  && Boleta Muestra Gratis
			a_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Gravada
			b_Parte08=ALLTRIM(STR(SunatMidoc.neto,12,2))  && Inafecta
			c_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Exonerada
		OTHERWISE
			a_Parte08=ALLTRIM(STR(SunatMidoc.neto,12,2))  && Gravada
			b_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Inafecta
			c_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Exonerada
	ENDCASE

	d_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Venta Gratuita
	e_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Total Descuentos
	f_Parte08='01'  && Tipo operacion SUNAT  -- 01 venta Interna??

	&& Percepcion
	g_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && Moneda Nacional Percepcion  Base Imponible
	h_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && Moneda Nacional -- Monto de la Percepcion
	i_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && Moneda Nacional -- Total de la Percepcion

	&& Detraccion
	j_Parte08='' &&ALLTRIM(STR(0.00,6,0))  && Pctje de la detraccion
	k_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && monto de la detraccion
	l_Parte08='' && Numero Cta Banco de la nacion
	m_Parte08='' && Total recargo
ENDIF

sub01P08=a_Parte08+'|'+b_Parte08+'|'+c_Parte08+'|'+d_Parte08+'|'+e_Parte08+'|'+f_Parte08+'|'+'}'
sub02P08=g_Parte08+'|'+h_Parte08+'|'+i_Parte08+'|'+'}'
sub03P08=j_Parte08+'|'+k_Parte08+'|'+l_Parte08+'|'+m_Parte08+'|'+'}'

x08_StrBody=sub01P08+sub02P08+sub03P08+'~'

********Fin Parte08 ****************************************************************************************************************************************
********Inicio Parte09**************************************************************************************************************************************

IF MitipoDoc='F' AND Miserie=60 &&& Solo Para Vta Sucesiva
	a_Parte09=ALLTRIM(Datavs.bl)  && BL Conocimiento de Embarque
	e_Parte09=ALLTRIM(Datavs.incoterm)  && Descripcion INCOTERMS
	f_Parte09=ALLTRIM(STR(Datavs.fvalorfob,12,2)) && Total FOB
	g_Parte09=ALLTRIM(STR(Datavs.fvalorflete,12,2)) && Total Flete
	h_Parte09=ALLTRIM(STR(Datavs.fvalorseguro,12,2)) && Total Seguro
	k_Parte09=ALLTRIM(Datavs.pedido)  && Lista de Empaque / OC
ELSE
	a_Parte09=''  && BL Conocimiento de Embarque
	e_Parte09=''  && Incoterms
	f_Parte09=''  && Total FOB
	g_Parte09=''  && Total Flete
	h_Parte09=''  && Total Seguro
	k_Parte09=''  && Lista de Empaque / OC
ENDIF

DO CASE
	CASE MitipoDoc='B'
		IF ALLTRIM(SunatMidoc.condipag)='MG'
			b_Parte09=' MUESTRA PROMOCIONAL '
		ELSE
			b_Parte09=ALLTRIM(SunatMidoc.Nompago)
		ENDIF
	OTHERWISE && Factura
		IF Miserie=60  &&& Si es Vta Sucesiva
			b_Parte09=ALLTRIM(Datavs.condicionpago)
		ELSE
			b_Parte09=ALLTRIM(SunatMidoc.Nompago)
		ENDIF
ENDCASE

c_Parte09=ALLTRIM(SunatMidoc.codigoc)  &&& Codigo de CLiente

DO CASE
	CASE MitipoDoc='B' && Boleta
		IF ALLTRIM(SunatMidoc.condipag)='MG'
			d_Parte09=FraseMG+' '+IIF(d_Parte01='PEN','S/','US$')+' '+ALLTRIM(STR(AcumulaMG,12,2))+' '+FraseBoleta
		ELSE
			d_Parte09=FraseBoleta
		ENDIF
	CASE MitipoDoc='F' && Factura
		DO CASE
			CASE Miserie=50  && Servicios Averiguar si por el monto aplica la Percepcion
				DO CASE
					CASE ALLTRIM(SunatMidoc.tipodetraccion)='020-01'
						d_Parte09=FraseDetrac01
					CASE ALLTRIM(SunatMidoc.tipodetraccion)='037-01'
						d_Parte09=FraseDetrac02
					CASE ALLTRIM(SunatMidoc.tipodetraccion)='022-01'
						d_Parte09=FraseDetrac03
					OTHERWISE
						d_Parte09=''
				ENDCASE
			CASE Miserie=60  &&  Factura Vta Sucesiva
				d_Parte09=FraseVs01
			OTHERWISE
				d_Parte09=''
		ENDCASE
ENDCASE

&&e_Parte09='' al lado de a_Parte09
&&f_Parte09='' al lado de k_Parte09
&&g_Parte09=''
&&h_Parte09=''
i_parte09=''
j_Parte09=''
&&k_Parte09 al lado de e_Parte09

sub01P09=a_Parte09+'|'+b_Parte09+'|'+c_Parte09+'|'+d_Parte09+'|'+e_Parte09+'|'+f_Parte09+'|'+g_Parte09+'|'+h_Parte09+'|'+i_parte09+'|'+j_Parte09+'|'+k_Parte09+'|'+'}'

k_Parte09=''  && Observacion
l_parte09=alltrim(Convnum(VAL(b_Parte05)))+iif(d_Parte01='PEN'," SOLES", " DOLARES AMERICANOS")   && Letras del Monto total

**** Configurando lista de correo a enviar ***
yy_01=ALLTRIM(Micliente.cpe01)
yy_02=ALLTRIM(Micliente.cpe02)

IF LEN(yy_02)<7 && Longitud minima correo
	MyListaCorreo=yy_01
ELSE
	MyListaCorreo=yy_01+';'+yy_02
ENDIF
MyListaCorreo = MyListaCorreo+ ';'+ 'cpe_sqm@sociedadquimica.com.pe'
**********************************************

m_parte09=MyListaCorreo
*m_parte09='egutierrez@sociedadquimica.com.pe'
n_parte09=''  && Nombre de Impresora
o_parte09='' &&& Copias

sub02P09=k_Parte09+'|'+l_parte09+'|'+m_parte09+'|'+n_parte09+'|'+o_parte09+'|'+'}'

x09_StrBody=sub01P09+sub02P09+'~'+'\'

********Fin Parte09 ****************************************************************************************************************************************

**xControl='X:\'+b_Parte01+'.txt'
xControl='c:\VENTAS\'+b_Parte01+'.txt'

** Prueba
*xControl='\\SQMSERVER\d\'+b_Parte01+'.txt'

*IF FILE(xControl)  && Does file exist?
*	gnErrFile = FOPEN(xControl)
*ELSE
gnErrFile = FCREATE(xControl)  && If not create it
*ENDIF

IF gnErrFile>0
	StrBody=x01_StrBody+x02_StrBody+x03_StrBody+x04_StrBody+x05_StrBody+x06_StrBody+x07_StrBody+x08_StrBody+x09_StrBody

	=FPUTS(gnErrFile,StrBody) &&Graba la variable en el archivo txt

	*!*	   =FPUTS(gnErrFile,x01_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x02_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x03_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x04_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x05_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x06_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x07_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x08_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x09_StrBody) &&Graba la variable en el archivo txt

	SET CENTURY OFF

	=FCLOSE(gnErrFile) &&cerramos el archivo.
ELSE
	WAIT WINDOW "Error al abrir el archivo"
ENDIF

SELECT Sunatmidetalle
DELETE ALL
SELECT SunatMidoc
DELETE ALL
