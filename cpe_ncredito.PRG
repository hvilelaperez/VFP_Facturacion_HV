SET DELETED on
SET PROCEDURE TO funciones
SET CENTURY ON
#DEFINE LF_CR CHR(10)+CHR(13)
#DEFINE TABU CHR(9)

LOCAL xControl,Snt_Documento,StrBody,Pase1,Codigosqm,DocuIgv,Miserie,MitipoDoc,Seriedoc,Numerodoc,Hoy
LOCAL FraseMG,FraseBoleta,AcumulaMG,FraseDetrac01,FraseDetrac02,MinSolesDetrac,MinDolarDetrac,TcVentaHoy,PctjeDetracServ,x_isExport,x_EsLibre
LOCAL MiPedVtaSuc,CtaRegVs,CtaMiReg,NotaVs01,FraseVs01,MyUbigeo,MyUrbanizacion,MyListaCorreo,x_ChargeNc, mSwExporta

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

x_ChargeNc=0

MitipoDoc='C'
x_SunatipoApli = 'F'
Seriedoc=10
Numerodoc=255

mSwExporta = 0

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0
	cmd0=SQLEXEC(lnHandle,"SELECT * FROM constantes ","MiDatosPlus")
	cmd3=SQLEXEC(lnHandle,"SELECT * FROM k_sunatelectronica ","KonsMess")
	cmd2=SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codigosqm","MiDatasqm")
	cmd5=SQLEXEC(lnHandle,"SELECT venta FROM tcoficial WHERE fecha=?hoy","Cambiooficial")
	IF MitipoDoc='D'  && Debito
		cmd1=SQLEXEC(lnHandle,"SELECT a.* FROM ndebito a WHERE cpe=?x_SunatipoApli AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
	ELSE  && Credito
		cmd1=SQLEXEC(lnHandle,"SELECT a.* FROM ncredito a  WHERE cpe=?x_SunatipoApli AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
		GO TOP IN SunatMidoc
		mCpe_ref= SunatMidoc.CpeF
		mSer_ref= SunatMidoc.SerieF
		mNro_ref= SunatMidoc.NumeroF
		IF SunatMidoc.TipoDoc= 'F'
			cmd= SQLEXEC(lnHandle,"SELECT guiaserie, guianum, Exportacion FROM Factura WHERE cpe=?mCpe_ref AND serie=?mSer_ref AND numero=?mNro_ref","cFacGuiaRef")
			GO TOP in cFacGuiaRef
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
				EndIF
			ENDIF
			USE IN cFacGuiaRef
		ENDIF
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

*******Inicio Parte01 ***********************************************************************************************************************************
IF MitipoDoc='D'
	a_Parte01='08'  && Nota Debito
ELSE
	a_Parte01='07'  && Nota Credito
ENDIF

b_Parte01=x_SunatipoApli+TRANSFORM(serie,'@L 999')+'-'+TRANSFORM(numero,'@L 99999999')

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

x01_StrBody=a_Parte01+'|'+b_Parte01+'|'+c_Parte01+'|'+d_Parte01+'|'+'}'

********Fin Parte01 ****************************************************************************************************************************************

********Inicio Parte02**************************************************************************************************************************************

SELECT MiDatasqm

a_Parte02=ALLTRIM(MiDatasqm.ruc)
b_Parte02='6' &&& Tipo de Documento Catalogo 6 ruc
*!*	c_Parte02=ALLTRIM(STRCONV(MiDatasqm.nombre,11))
*!*	d_Parte02=ALLTRIM(STRCONV(MiDatasqm.nombre,11))
c_Parte02=ALLTRIM(MiDatasqm.nombre)
d_Parte02=ALLTRIM(MiDatasqm.nombre)

e_Parte02=MyUbigeo
*f_Parte02=ALLTRIM(STRCONV(MiDatasqm.direccion,11))
f_Parte02=ALLTRIM(MiDatasqm.direccion)
g_Parte02=MyUrbanizacion
*!*	h_Parte02=ALLTRIM(STRCONV(MiDatasqm.prov,11))
*!*	i_parte02=ALLTRIM(STRCONV(MiDatasqm.dpto,11))
*!*	j_parte02=ALLTRIM(STRCONV(MiDatasqm.dist,11))
*!*	k_Parte02=ALLTRIM(STRCONV(MiDatasqm.pais,11))  && Basado en Catalogo 04

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
b_Parte03=ALLTRIM(Micliente.tiposunat)  &&& Tipo de Documento Catalogo 6  Revisar la Validacion solo asumimmos ruc mIentras
*!*	c_Parte03=ALLTRIM(STRCONV(Micliente.nombre,11))
*!*	d_Parte03=ALLTRIM(STRCONV(Micliente.direccion,11))
*!*	e_Parte03='' && Urbanizacion (SE HA QUITADO DE LA STRUCTURA)---
*!*	f_Parte03=ALLTRIM(STRCONV(Micliente.prov,11))
*!*	g_parte03=ALLTRIM(STRCONV(Micliente.dpto,11))
*!*	h_parte03=ALLTRIM(STRCONV(Micliente.dist,11))
*!*	i_Parte03=ALLTRIM(STRCONV(Micliente.pais,11))  && Basado en Catalogo 04

c_Parte03=ALLTRIM(Micliente.nombre)
d_Parte03=ALLTRIM(Micliente.direccion)
e_Parte03='' && Urbanizacion (SE HA QUITADO DE LA STRUCTURA)---
f_Parte03=ALLTRIM(Micliente.prov)
g_parte03=ALLTRIM(Micliente.dpto)
h_parte03=ALLTRIM(Micliente.dist)
i_Parte03=ALLTRIM(Micliente.pais)  && Basado en Catalogo 04

x03_StrBody=a_Parte03+'|'+b_Parte03+'|'+c_Parte03+'|'+d_Parte03+'|'+f_Parte03+'|'+g_parte03+'|'+h_parte03+'|'+i_Parte03+'|'+'}'+'~'

********Fin Parte03 ****************************************************************************************************************************************

********Inicio Parte04**************************************************************************************************************************************
***&&& Sub para IGV
a_Parte04=ALLTRIM(STR(SunatMidoc.igv,12,2))  && Sumatoria IGV
b_Parte04='1000' && Ver Catalogo 05
c_Parte04='IGV' && Ver Catalogo 05
x_Parte04='18.00'

sub01P04=a_Parte04+'|'+b_Parte04+'|'+c_Parte04+'|'+x_Parte04+'|'  +'}'

***&& Sub Para ISC (NO aplica)
d_Parte04=''
e_Parte04='' && ISC Ver Catalogo 05
f_Parte04='' && ISC Ver Catalogo 05

sub02P04=d_Parte04+'|'+e_Parte04+'|'+f_Parte04+'|'+'}'

***&& Sub Para Otros (NO aplica)
g_Parte04=''
h_Parte04='' && ISC Ver Catalogo 05
i_Parte04='' && ISC Ver Catalogo 05

sub03P04=g_Parte04+'|'+h_Parte04+'|'+i_Parte04+'|'+'}'

x04_StrBody=sub01P04+sub02P04+sub03P04+'~'
DocuIgv=VAL(b_Parte04)

********Fin Parte04 ****************************************************************************************************************************************

******* Inicio Parte 05 ************************************************************************************************************************************
DO CASE
	CASE MitipoDoc='D' &&& Para Nota de Debito

		a_Parte05=ALLTRIM(SunatMidoc.cpe_apli)+TRANSFORM(SunatMidoc.serie_apli,'@L 999')+'-'+TRANSFORM(SunatMidoc.numero_apli,'@L 99999999') &&38
		b_Parte05='03' && 39 Catalogo 10 Penalidades
		*c_Parte05=ALLTRIM(STRCONV(SunatMidoc.motivo,11))  &&40
		c_Parte05=ALLTRIM(SunatMidoc.motivo)  &&40
		d_Parte05=TRANSFORM(SunatMidoc.tiposunat_apli,'@L 99')  &&41

		y_Pyearg=STR(YEAR(SunatMidoc.fecha_apli),4,0)
		y_Pmontg=TRANSFORM(MONTH(SunatMidoc.fecha_apli),"@L 99")
		y_PDayyg=TRANSFORM(DAY(SunatMidoc.fecha_apli),"@L 99")
		e_Parte05=y_Pyearg+'-'+y_Pmontg+'-'+y_PDayyg &&42

	OTHERWISE  && Para Nota de Credito
		DO CASE
			CASE SunatMidoc.tipo=1
				b_Parte05='06' && 39 Catalogo 09  Devolucion por ItEM (07) --- TOTAL (06)
				*c_Parte05=ALLTRIM(STRCONV('Devolucion',11))  &&40
				c_Parte05='Devolucion'  &&40
			CASE SunatMidoc.tipo=2
				b_Parte05='04' && 39 Catalogo 09  Descuento Global
				*c_Parte05=ALLTRIM(STRCONV('Descuento de Precio',11))  &&40
				c_Parte05='Descuento de Precio'
			CASE SunatMidoc.tipo=9
				b_Parte05='01' && 39 Catalogo 09  Anulacion de la operacion
				*c_Parte05=ALLTRIM(STRCONV('Anulacion de Documento.',11))  &&40
				c_Parte05='Anulacion de Documento.'
			CASE SunatMidoc.tipo=10
				*b_Parte05='09' && 39 Catalogo 09  Disminucion en el valor
				*c_Parte05=ALLTRIM(STRCONV('Nota de Crédito Libre',11))  &&40
				b_Parte05='04' && 39 Catalogo 09  Descuento Global
				*c_Parte05=ALLTRIM(STRCONV('Descuento',11))  &&40
				c_Parte05='Descuento'  &&40
		ENDCASE
		
		IF !EMPTY(ALLTRIM(SunatMidoc.xmodifica))
			a_Parte05= ALLTRIM(SunatMidoc.xmodifica)
			IF ALLTRIM(SunatMidoc.xTipoDoc)= 'Factura'
				d_Parte05= '01'
			ELSE
				d_Parte05= '03'
			ENDIF
		ELSE
			a_Parte05=ALLTRIM(SunatMidoc.cpef)+TRANSFORM(SunatMidoc.serief,'@L 999')+'-'+TRANSFORM(SunatMidoc.numerof,'@L 99999999') &&38
			DO CASE
				CASE SunatMidoc.tipodoc='F'
					d_Parte05='01'  &&41
				CASE SunatMidoc.tipodoc='B'
					d_Parte05='03'  &&41
			ENDCASE
		ENDIF
		
		y_Pyearg=STR(YEAR(SunatMidoc.fechaf),4,0)
		y_Pmontg=TRANSFORM(MONTH(SunatMidoc.fechaf),"@L 99")
		y_PDayyg=TRANSFORM(DAY(SunatMidoc.fechaf),"@L 99")
		e_Parte05=y_Pyearg+'-'+y_Pmontg+'-'+y_PDayyg &&42

ENDCASE
x05_StrBody=a_Parte05+'|'+b_Parte05+'|'+c_Parte05+'|'+d_Parte05+'|'+e_Parte05+'|'+'}'+'~'

*** Fin Parte 5 ****

********Inicio Parte06**************************************************************************************************************************************
a_Parte06=''
b_Parte06=ALLTRIM(STR(SunatMidoc.total,12,2))

x06_StrBody=a_Parte06+'|'+b_Parte06+'|'+'}'+'~'
********Fin Parte06 ****************************************************************************************************************************************


********Inicio Parte07**************************************************************************************************************************************
LOCAL MyUnico,Subdetalle,igvlinea
MyUnico=SunatMidoc.unico
x07_StrBody=''
Subdetalle='' && Enlazar cada linea del detalle


DO CASE
	CASE MitipoDoc='D'
		SELECT SunatMidoc
		*a_Parte07=ALLTRIM(STRCONV(SunatMidoc.observacion,11))
		a_Parte07=ALLTRIM(SunatMidoc.observacion)
		b_Parte07=''
		
		c_Parte07='' &&53 OK
		d_Parte07='NIU'   &&54 OK
		e_Parte07='1' &&55 OK
		f_Parte07=ALLTRIM(STR(SunatMidoc.neto,12,2)) &&56
		g_Parte07=ALLTRIM(STR(SunatMidoc.total,12,2)) &&57 opcional solo vacío (si no hay detalles??)
		h_Parte07='01' &&58  operacion onerosa catalog 16

		i_Parte07=ALLTRIM(STR(SunatMidoc.igv,12,2))  &&&igv
		j_Parte07='10'  &&Afectacion catalogo 07 && Gravado - Operacion Onerosa??
		k_Parte07='VAT'  &&Nombre del tributo catalgo 05
		l_Parte07='IGV'  &&Nombre del tributo catalgo 05
		m_Parte07='VAT'  &&codigo internacional del tributo catalgo 05

		n_Parte07='' && Monto ISC (no aplica)
		o_Parte07='' && Catalogo 08 - Tipo de Sistema de ISC
		p_Parte07='' && Codigo de tributo - catalogo 05
		q_Parte07='' && NOmbre de tributo - catalogo 05
		r_Parte07='' && Codigo Internacional tributo - Catálogo 05
		s_Parte07=ALLTRIM(STR(SunatMidoc.neto,12,2)) &&'' &&69  opcional solo vacío (si no hay detalles)

		x07_StrBody=a_Parte07+'|'+b_Parte07+'|'+c_Parte07+'|'+d_Parte07+'|'+e_Parte07+'|'+f_Parte07+'|'+g_Parte07+'|'+h_Parte07+'|'+i_Parte07+'|'+j_Parte07+'|'+k_Parte07+'|'+l_Parte07+'|'+m_Parte07+'|'+n_Parte07+'|'+o_Parte07+'|'+p_Parte07+'|'+q_Parte07+'|'+r_Parte07+'|'+s_Parte07+'|'+'}'+'~'
		
	OTHERWISE  && Nota de Credito
		DO CASE
			CASE SunatMidoc.tipo=9  && Es por anulacion
				***   02/10/2018 Edgard: Se agregó por caso de anulación de factura / boleta por muestra promocional.
				mCpe_ref= ALLTRIM(SunatMidoc.CpeF)
				mSer_ref= SunatMidoc.SerieF
				mNro_ref= SunatMidoc.NumeroF
				lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
				IF lnHandle > 0
					IF SunatMidoc.TipoDoc= 'F'
						cmd= SQLEXEC(lnHandle,"SELECT SUM(SubTotal) as SubTotal FROM DetaFacturas d Inner Join Factura c on d.Unico= c.Unico "+ ;
								"WHERE c.cpe=?mCpe_ref AND c.serie=?mSer_ref AND c.numero=?mNro_ref","cSubTotal")
					ELSE
						cmd= SQLEXEC(lnHandle,"SELECT SUM(SubTotal) as SubTotal FROM DetaBoletas d Inner Join Boleta c on d.Unico= c.Unico "+ ;
								"WHERE c.cpe=?mCpe_ref AND c.serie=?mSer_ref AND c.numero=?mNro_ref","cSubTotal")
					ENDIF
					SQLDISCONNECT(lnHandle)
				ELSE
					AERROR(laErr)
					MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
				ENDIF
				***
				IF SunatMidoc.tipodoc='F'
					xx_trx='POR LA ANULACION DE LA FACTURA '+ALLTRIM(SunatMidoc.cpef)+TRANSFORM(SunatMidoc.serief,'@L 999')+'-'+TRANSFORM(SunatMidoc.numerof,'@L 99999999')+' DE FECHA '+DTOC(SunatMidoc.fechaf)
				ELSE
					xx_trx='POR LA ANULACION DE LA BOLETA '+ALLTRIM(SunatMidoc.cpef)+TRANSFORM(SunatMidoc.serief,'@L 999')+'-'+TRANSFORM(SunatMidoc.numerof,'@L 99999999')+' DE FECHA '+DTOC(SunatMidoc.fechaf)
				ENDIF
				
				a_Parte07=ALLTRIM(xx_trx)
				b_Parte07=''
				
				c_Parte07='' &&53 OK
				d_Parte07='NIU'   &&54 OK
				e_Parte07='1' &&55 OK

				mNetoNC = SunatMidoc.neto
				mTotalNC= SunatMidoc.total
				IF mNetoNC= 0
					mNetoNC = cSubTotal.SubTotal
					mTotalNC= mNetoNC+ SunatMidoc.igv
				ENDIF
				
				f_Parte07=ALLTRIM(STR(mNetoNC,12,2)) &&56
				g_Parte07=ALLTRIM(STR(mTotalNC,12,2)) &&'' &&57 opcional solo vacío (si no hay detalles??)
				h_Parte07='01' &&58  operacion onerosa catalog 16
				
				IF mSwExporta= 1
					i_Parte07=ALLTRIM(STR(0,12,2))  &&&igv
					j_Parte07='40'  &&Afectacion catalogo 07 && Gravado - Operacion Onerosa??  && 40- EXPORTACION
				ELSE
					i_Parte07=ALLTRIM(STR(SunatMidoc.igv,12,2))  &&&igv
					j_Parte07='10'  &&Afectacion catalogo 07 && Gravado - Operacion Onerosa??  && 40- EXPORTACION
				ENDIF
				k_Parte07='VAT'  &&Nombre del tributo catalgo 05
				l_Parte07='IGV'  &&Nombre del tributo catalgo 05
				m_Parte07='VAT'  &&codigo internacional del tributo catalgo 05

				n_Parte07='' && Monto ISC (no aplica)
				o_Parte07='' && Catalogo 08 - Tipo de Sistema de ISC
				p_Parte07='' && Codigo de tributo - catalogo 05
				q_Parte07='' && NOmbre de tributo - catalogo 05
				r_Parte07='' && Codigo Internacional tributo - Catálogo 05
				s_Parte07=ALLTRIM(STR(mNetoNC,12,2)) &&'' &&69  opcional solo vacío (si no hay detalles)
				
				USE IN cSubTotal
			CASE SunatMidoc.tipo=2  && Es por Descuento
				StrBody=''

				lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
				IF lnHandle > 0
					cmd0=SQLEXEC(lnHandle,"SELECT a.*,b.nombre  FROM detallencredito a ,productos b WHERE a.producto=b.codigo AND a.unico=?Myunico","SunatMidetalle")
					SQLDISCONNECT(lnHandle)
				ELSE
					AERROR(laErr)
					MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
				ENDIF
				
				StrBody1 = ''
				StrBody2 = ''
				SELECT SunatMidetalle
				GO top
				SCAN
					StrBody=StrBody+PADR(ALLTRIM(SunatMidetalle.producto),8,' ')+' '+ALLTRIM(SUBSTR(SunatMidetalle.nombre,1,55))+'   '+'Cant: '+ALLTRIM(STR(SunatMidetalle.cantaplicada,10,2))+'   '+'PU: '+ALLTRIM(STR(SunatMidetalle.precioorigen,10,2))+'   '+'NPU: '+ALLTRIM(STR(SunatMidetalle.nuevoprecio,10,2))+'   '+'Subtotal: '+ALLTRIM(STR(SunatMidetalle.subtotal,10,2))+'^'
					
					IF LEN(StrBody) <= 200
						StrBody1 = StrBody1+ PADR(ALLTRIM(SunatMidetalle.producto),8,' ')+' '+ALLTRIM(SUBSTR(SunatMidetalle.nombre,1,55))+'   '+'Cant: '+ALLTRIM(STR(SunatMidetalle.cantaplicada,10,2))+'   '+'PU: '+ALLTRIM(STR(SunatMidetalle.precioorigen,10,2))+'   '+'NPU: '+ALLTRIM(STR(SunatMidetalle.nuevoprecio,10,2))+'   '+'Subtotal: '+ALLTRIM(STR(SunatMidetalle.subtotal,10,2))+'^'
					ELSE
						StrBody2 = StrBody2+ PADR(ALLTRIM(SunatMidetalle.producto),8,' ')+' '+ALLTRIM(SUBSTR(SunatMidetalle.nombre,1,55))+'   '+'Cant: '+ALLTRIM(STR(SunatMidetalle.cantaplicada,10,2))+'   '+'PU: '+ALLTRIM(STR(SunatMidetalle.precioorigen,10,2))+'   '+'NPU: '+ALLTRIM(STR(SunatMidetalle.nuevoprecio,10,2))+'   '+'Subtotal: '+ALLTRIM(STR(SunatMidetalle.subtotal,10,2))+'^'
					ENDIF
				ENDSCAN
				
				a_Parte07='Por descuento de precio, le abonamos a su cuenta:'
				IF LEN(StrBody) <= 250
					b_Parte07=StrBody
				ELSE
					a_Parte07='Por descuento de precio, le abonamos a su cuenta:'+ '^'+ StrBody1
					b_Parte07=StrBody2
				ENDIF
				
				c_Parte07='' &&53 OK
				d_Parte07='NIU'   &&54 OK
				e_Parte07='1' &&55 OK
				f_Parte07=ALLTRIM(STR(SunatMidoc.neto,12,2)) &&56
				g_Parte07=ALLTRIM(STR(SunatMidoc.total,12,2)) &&'' &&57 opcional solo vacío (si no hay detalles??)
				h_Parte07='01' &&58  operacion onerosa catalog 16
				
				i_Parte07=ALLTRIM(STR(SunatMidoc.igv,12,2))  &&&igv
				j_Parte07='10'  &&Afectacion catalogo 07 && Gravado - Operacion Onerosa??
				k_Parte07='VAT'  &&Nombre del tributo catalgo 05
				l_Parte07='IGV'  &&Nombre del tributo catalgo 05
				m_Parte07='VAT'  &&codigo internacional del tributo catalgo 05
				
				n_Parte07='' && Monto ISC (no aplica)
				o_Parte07='' && Catalogo 08 - Tipo de Sistema de ISC
				p_Parte07='' && Codigo de tributo - catalogo 05
				q_Parte07='' && NOmbre de tributo - catalogo 05
				r_Parte07='' && Codigo Internacional tributo - Catálogo 05
				s_Parte07=ALLTRIM(STR(SunatMidoc.neto,12,2)) &&'' &&69  opcional solo vacío (si no hay detalles)
				
			CASE SunatMidoc.tipo=1  && Es por DEVOLUCION
				StrBody=''

				lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
				IF lnHandle > 0
					cmd0=SQLEXEC(lnHandle,"SELECT a.*,b.nombre  FROM detallencredito a ,productos b WHERE a.producto=b.codigo AND a.unico=?Myunico","SunatMidetalle")
					SQLDISCONNECT(lnHandle)
				ELSE
					AERROR(laErr)
					MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
				ENDIF
				SELECT SunatMidetalle
				GO top
				SCAN
					StrBody=StrBody+PADR(ALLTRIM(SunatMidetalle.producto),8,' ')+' '+PADR(ALLTRIM(SUBSTR(SunatMidetalle.nombre,1,55)),55,' ')+'   '+'Cant:'+STR(SunatMidetalle.cantaplicada,10,2)+'   '+'PU:'+STR(SunatMidetalle.precioorigen,10,2)+'^'
				ENDSCAN
				
				a_Parte07='Por Devolucion de Mercaderia, le abonamos a su cuenta:'
				b_Parte07=StrBody

				c_Parte07='' &&53 OK
				d_Parte07='NIU'   &&54 OK
				e_Parte07='1' &&55 OK
				f_Parte07=ALLTRIM(STR(SunatMidoc.neto,12,2)) &&56
				g_Parte07=ALLTRIM(STR(SunatMidoc.total,12,2)) &&'' &&57 opcional solo vacío (si no hay detalles??)
				h_Parte07='01' &&58  operacion onerosa catalog 16

				i_Parte07=ALLTRIM(STR(SunatMidoc.igv,12,2))  &&&igv
				j_Parte07='10'  &&Afectacion catalogo 07 && Gravado - Operacion Onerosa??
				k_Parte07='VAT'  &&Nombre del tributo catalgo 05
				l_Parte07='IGV'  &&Nombre del tributo catalgo 05
				m_Parte07='VAT'  &&codigo internacional del tributo catalgo 05

				n_Parte07='' && Monto ISC (no aplica)
				o_Parte07='' && Catalogo 08 - Tipo de Sistema de ISC
				p_Parte07='' && Codigo de tributo - catalogo 05
				q_Parte07='' && NOmbre de tributo - catalogo 05
				r_Parte07='' && Codigo Internacional tributo - Catálogo 05
				s_Parte07=ALLTRIM(STR(SunatMidoc.neto,12,2)) &&'' &&69  opcional solo vacío (si no hay detalles)

			CASE SunatMidoc.tipo= 10  && Es por Disminucion de valor
				
				*a_Parte07=ALLTRIM(STRCONV(SunatMidoc.Obsvlibre,11))
				a_Parte07=ALLTRIM(SunatMidoc.Obsvlibre)
				b_Parte07=''
				
				c_Parte07='' &&53 OK
				d_Parte07='NIU'   &&54 OK
				e_Parte07='1' &&55 OK
				f_Parte07=ALLTRIM(STR(SunatMidoc.neto,12,2)) &&56
				g_Parte07=ALLTRIM(STR(SunatMidoc.total,12,2)) &&'' &&57 opcional solo vacío (si no hay detalles??)
				h_Parte07='01' &&58  operacion onerosa catalog 16
				
				IF mSwExporta= 1
					i_Parte07=ALLTRIM(STR(0,12,2))  &&&igv
					j_Parte07='40'  &&Afectacion catalogo 07 && Gravado - Operacion Onerosa??  && 40- EXPORTACION
				ELSE
					i_Parte07=ALLTRIM(STR(SunatMidoc.igv,12,2))  &&&igv
					j_Parte07='10'  &&Afectacion catalogo 07 && Gravado - Operacion Onerosa??  && 40- EXPORTACION
				ENDIF
				k_Parte07='VAT'  &&Nombre del tributo catalgo 05
				l_Parte07='IGV'  &&Nombre del tributo catalgo 05
				m_Parte07='VAT'  &&codigo internacional del tributo catalgo 05

				n_Parte07='' && Monto ISC (no aplica)
				o_Parte07='' && Catalogo 08 - Tipo de Sistema de ISC
				p_Parte07='' && Codigo de tributo - catalogo 05
				q_Parte07='' && NOmbre de tributo - catalogo 05
				r_Parte07='' && Codigo Internacional tributo - Catálogo 05
				s_Parte07=ALLTRIM(STR(SunatMidoc.neto,12,2)) &&'' &&69  opcional solo vacío (si no hay detalles)
		ENDCASE

		x07_StrBody=a_Parte07+'|'+b_Parte07+'|'+c_Parte07+'|'+d_Parte07+'|'+e_Parte07+'|'+f_Parte07+'|'+g_Parte07+'|'+h_Parte07+'|'+i_Parte07+'|'+j_Parte07+'|'+k_Parte07+'|'+l_Parte07+'|'+m_Parte07+'|'+n_Parte07+'|'+o_Parte07+'|'+p_Parte07+'|'+q_Parte07+'|'+r_Parte07+'|'+s_Parte07+'|'+'}'+'~'
ENDCASE

********Fin Parte07 ****************************************************************************************************************************************

********Inicio Parte08**************************************************************************************************************************************
a_Parte08=ALLTRIM(STR(SunatMidoc.neto,12,2))  && 73 Total
b_Parte08='' && 74
c_Parte08='' && 75
d_Parte08='' && 76

x08_StrBody=a_Parte08+'|'+b_Parte08+'|'+c_Parte08+'|'+d_Parte08+'|'+'}'+'~'

********Fin Parte08 ****************************************************************************************************************************************
********Inicio Parte09**************************************************************************************************************************************
DO CASE
	CASE MitipoDoc='D'
		a_Parte09=''
	OTHERWISE
		a_Parte09=''
ENDCASE

b_Parte09='' && 80
c_Parte09='' && 81
d_Parte09='' && 82
e_Parte09='' && 83
f_Parte09='' && 84

sub01P09=a_Parte09+'|'+b_Parte09+'|'+c_Parte09+'|'+d_Parte09+'|'+e_Parte09+'|'+f_Parte09+'|'+'}'

g_Parte09=''  && Observacion
h_parte09=alltrim(Convnum(VAL(b_Parte06)))+iif(d_Parte01='PEN'," SOLES", " DOLARES AMERICANOS")   && Letras del Monto total

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
*i_parte09=MyListaCorreo
i_parte09='egutierrez@sociedadquimica.com.pe'

j_parte09=''  && Nombre de Impresora
k_parte09='' &&& Copias

sub02P09=g_Parte09+'|'+h_parte09+'|'+i_parte09+'|'+j_parte09+'|'+k_parte09+'|'+'}'
x09_StrBody=sub01P09+sub02P09+'~'+'\'

********Fin Parte09 ****************************************************************************************************************************************

*xControl='\\SQMSERVER\inputprod\'+ ALLTRIM(MitipoDoc)+ b_Parte01+'.txt'
*xControl='X:\'+ALLTRIM(MitipoDoc)+b_Parte01+'.txt'
xControl='C:\VENTAS\'+ALLTRIM(MitipoDoc)+b_Parte01+'.txt'

gnErrFile = FCREATE(xControl)  && If not create it

IF gnErrFile>0

	StrBody=x01_StrBody+x02_StrBody+x03_StrBody+x04_StrBody+x05_StrBody+x06_StrBody+x07_StrBody+x08_StrBody+x09_StrBody

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