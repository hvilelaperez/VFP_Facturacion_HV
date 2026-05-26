
Set Procedure To funciones
Set Century On
#Define LF_CR Chr(10)+Chr(13)
#Define TABU Chr(9)
Set Deleted On

Local xControl,Snt_Documento,StrBody,Pase1,Codigosqm,DocuIgv,Miserie,MitipoDoc,Seriedoc,Numerodoc,Hoy
Local FraseMG,FraseBoleta,AcumulaMG,FraseDetrac01,FraseDetrac02,FraseDetrac03,MinSolesDetrac,MinDolarDetrac,TcVentaHoy,PctjeDetracServ,x_isExport,x_EsLibre
Local MiPedVtaSuc,CtaRegVs,CtaMiReg,NotaVs01,FraseVs01,MyUbigeo,MyUrbanizacion
Local MyListaCorreo,Isvtasucesiva,IsInafecta

Isvtasucesiva=0
Codigosqm='S030'
DocuIgv=0
AcumulaMG=0
x_isExport=0
x_EsLibre=0
CtaRegVs=0
CtaMiReg=0
Hoy=Date()

x01_StrBody=''
x02_StrBody=''
x03_StrBody=''
x04_StrBody=''
x05_StrBody=''
x06_StrBody=''
x07_StrBody=''
x08_StrBody=''
StrBody=''

MitipoDoc='F'
Seriedoc=60
Numerodoc=11

lnHandle = Sqlstringconnect(MyString_ofi01)
If lnHandle > 0
	cmd0=SQLExec(lnHandle,"SELECT * FROM constantes ","MiDatosPlus")
	cmd3=SQLExec(lnHandle,"SELECT * FROM k_sunatelectronica ","KonsMess")
	cmd2=SQLExec(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codigosqm","MiDatasqm")
	cmd5=SQLExec(lnHandle,"SELECT venta FROM tcoficial WHERE fecha=?hoy","Cambiooficial")
	If MitipoDoc='F'
		If Seriedoc=60 && Si es Factura Vta Sucesiva
			Isvtasucesiva=1
			cmd1=SQLExec(lnHandle,"SELECT a.*,' ' as NomPago FROM factura a WHERE a.cpe='F' AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
			cmd5=SQLExec(lnHandle,"SELECT * FROM im_vsucesiva WHERE fcpe='F' AND fserie=?Seriedoc and fnumero=?Numerodoc","Datavs") && Revisa
		Else
			cmd1=SQLExec(lnHandle,"SELECT a.*,b.nombre as NomPago FROM factura a,condicionpago b WHERE a.condipag=b.codigo AND "+;
				"a.cpe='F' AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
		Endif
	Else
		cmd1=SQLExec(lnHandle,"SELECT a.*,b.nombre as NomPago FROM boleta a,condicionpago b WHERE a.condipag=b.codigo AND "+;
			"a.cpe='B' AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
	Endif
	SQLDisconnect(lnHandle)
Else
	Aerror(laErr)
	Messagebox("No se pudo conectar a mySQL. Error: " + Chr(13) + laErr[2])
Endif

MyUbigeo=Alltrim(KonsMess.c_myubigeo)
MyUrbanizacion=Alltrim(KonsMess.c_myurbanizacion)
FraseMG=Alltrim(KonsMess.c_frasemg)
FraseBoleta=Alltrim(KonsMess.c_fraseboleta)
FraseDetrac01=Alltrim(KonsMess.c_frasedetrac01)
FraseDetrac02=Alltrim(KonsMess.c_frasedetrac02)
FraseDetrac03=Alltrim(KonsMess.c_frasedetrac03)
FraseVs01=Alltrim(KonsMess.c_frasevs01)
NotaVs01=Alltrim(KonsMess.c_notavtasucesiva)

TcVentaHoy=Cambiooficial.venta
PctjeDetracServ=MiDatosPlus.percepcionserv
MinSolesDetrac=MiDatosPlus.minperservsoles
MinDolarDetrac=Round(MinSolesDetrac/TcVentaHoy,2)
Igv_ele=MiDatosPlus.igv
Miserie=SunatMidoc.serie
If MitipoDoc='F'
	MiPedVtaSuc=SunatMidoc.vspedido
	IsInafecta=SunatMidoc.inafecta
Else
	MiPedVtaSuc=''
	IsInafecta=0
Endif

Select SunatMidoc

*******Inicio Parte01 ***********************************************************************************************************************************
If MitipoDoc='F'
	a_Parte01='01'  && Factura
Else
	a_Parte01='03'  && Boleta
Endif

b_Parte01=MitipoDoc+Transform(serie,'@L 999')+'-'+Transform(numero,'@L 99999999')

y_Pyear=Str(Year(SunatMidoc.fecha),4,0)
y_Pmont=Transform(Month(SunatMidoc.fecha),"@L 99")
y_PDayy=Transform(Day(SunatMidoc.fecha),"@L 99")

c_Parte01=y_Pyear+'-'+y_Pmont+'-'+y_PDayy


Do Case  && Catalogo 02 Anexo 08
Case SunatMidoc.Moneda='M1'
	d_Parte01='PEN'
Case SunatMidoc.Moneda='M2'
	d_Parte01='USD'
Endcase

If SunatMidoc.directa=1
	e_Parte01='' && No hay guia de Remision
Else
	If MitipoDoc='F' &&& Hay Facturacion Agrupada
		If SunatMidoc.agrupada=1
			e_Parte01=Alltrim(SunatMidoc.variasguias)
		Else
			If SunatMidoc.guiaserie=0 Or SunatMidoc.guianum=0
				e_Parte01=''
			Else
				e_Parte01=Transform(guiaserie,'@L 999')+'-'+Transform(guianum,'@L 99999999')
			Endif
		Endif
	Else  && Si es Boleta (No hay Boletas Agrupadas)
		If SunatMidoc.guiaserie=0 Or SunatMidoc.guianum=0
			e_Parte01=''
		Else
			e_Parte01=Transform(guiaserie,'@L 999')+'-'+Transform(guianum,'@L 99999999')
		Endif
	Endif
Endif

f_Parte01='09' && Ver Catalogo 01 -- Valor Guia de remision remitente  Validar vacias ???

g_Parte01='' && No Aplica (NUmero - Otro documento referido a la operacion)
h_Parte01='' && No Aplica (Tipo - Otro documento referido a la operacion) && Catalogo Nro12

Do Case
Case MitipoDoc='F'
	If SunatMidoc.directa=1
		i_Parte01=Alltrim(SunatMidoc.ocdirecta)  && Ver si es asi NO va OC
	Else
		If SunatMidoc.agrupada=1
			i_Parte01=''  &&& no se como llenar para las agrupadas, Como va NO va OC
		Else
			LocM1=SunatMidoc.guiaserie
			LocM2=SunatMidoc.guianum

			lnHandle = Sqlstringconnect(MyString_ofi01)
			If lnHandle > 0
				cmd2=SQLExec(lnHandle,"SELECT oc FROM guiasremision WHERE serie=?LocM1 and numero=?LocM2","LocMx")
				SQLDisconnect(lnHandle)
			Else
				Aerror(laErr)
				Messagebox("No se pudo conectar a mySQL. Error: " + Chr(13) + laErr[2])
			Endif

			i_Parte01=Alltrim(LocMx.oc) && Orden de Compra  (Busqueda en Guia de Remision)
		Endif
	Endif
Case MitipoDoc='B'
	i_Parte01=''
Endcase

x01_StrBody=a_Parte01+'|'+b_Parte01+'|'+c_Parte01+'|'+d_Parte01+'|'+e_Parte01+'|'+f_Parte01+'|'+g_Parte01+'|'+h_Parte01+'|'+i_Parte01+'|'+'}'

********Fin Parte01 ****************************************************************************************************************************************

********Inicio Parte02**************************************************************************************************************************************

Select MiDatasqm

a_Parte02=Alltrim(MiDatasqm.ruc)
b_Parte02='6' &&& Tipo de Documento Catalogo 6 RUC para sqm
c_Parte02=Alltrim(MiDatasqm.nombre)
d_Parte02=Alltrim(MiDatasqm.nombre)
e_Parte02=MyUbigeo
f_Parte02=Alltrim(MiDatasqm.direccion)
g_Parte02=MyUrbanizacion
h_Parte02=Alltrim(MiDatasqm.prov)
i_parte02=Alltrim(MiDatasqm.dpto)
j_parte02=Alltrim(MiDatasqm.Dist)
k_Parte02=Alltrim(MiDatasqm.pais)  && Basado en Catalogo 04

x02_StrBody=a_Parte02+'|'+b_Parte02+'|'+c_Parte02+'|'+d_Parte02+'|'+e_Parte02+'|'+f_Parte02+'|'+g_Parte02+'|'+h_Parte02+'|'+i_parte02+'|'+;
	j_parte02+'|'+k_Parte02+'|'+'}'

********Fin Parte02 ****************************************************************************************************************************************

********Inicio Parte03**************************************************************************************************************************************
Local Codcli
Codcli=SunatMidoc.codigoc

lnHandle = Sqlstringconnect(MyString_ofi01)
If lnHandle > 0
	cmd1=SQLExec(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codcli","MiCliente")
	SQLDisconnect(lnHandle)
Else
	Aerror(laErr)
	Messagebox("No se pudo conectar a mySQL. Error: " + Chr(13) + laErr[2])
Endif
Select Micliente

a_Parte03=Alltrim(Micliente.ruc)
b_Parte03=Alltrim(Micliente.tiposunat) &&& Tipo de Documento Catalogo 6  Revisar la Validacion solo asumimmos ruc mIentras
c_Parte03=Alltrim(Micliente.nombre)
d_Parte03=Alltrim(Micliente.direccion)
e_Parte03='' && Urbanizacion (SE HA QUITADO DE LA STRUCTURA)
f_Parte03=Alltrim(Micliente.prov)
g_parte03=Alltrim(Micliente.dpto)
h_parte03=Alltrim(Micliente.Dist)
i_Parte03=Alltrim(Micliente.pais)  && Basado en Catalogo 04

x03_StrBody=a_Parte03+'|'+b_Parte03+'|'+c_Parte03+'|'+d_Parte03+'|'+f_Parte03+'|'+g_parte03+'|'+h_parte03+'|'+i_Parte03+'|'+'}'+'~'

********Fin Parte03 ****************************************************************************************************************************************

********Inicio Parte04**************************************************************************************************************************************
***&&& Sub para IGV
a_Parte04=Alltrim(Str(SunatMidoc.igv,12,2))  && Sumatoria IGV
b_Parte04=Alltrim(Str(Igv_ele,5,0))    && ALLTRIM(STR(ROUND(((SunatMidoc.igv*100)/SunatMidoc.neto),0),15,0))  && Porcentaje del IGV
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
DocuIgv=Val(b_Parte04)

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
Local MyUnico,Subdetalle,igvlinea
MyUnico=SunatMidoc.Unico
x07_StrBody=''
Subdetalle='' && Enlazar cada linea del detalle

lnHandle = Sqlstringconnect(MyString_ofi01)
If lnHandle > 0
	If MitipoDoc='F'
		If Miserie=60
			cmd0=SQLExec(lnHandle,"SELECT a.producto,a.cantidad,a.um,a.precioventa as precio,ROUND((a.cantidad*a.precioventa),2) as subtotal,b.nombre, "+;
				"a.lote as lotefab FROM im_detallevsucesiva a ,productos b "+;
				"WHERE a.producto=b.codigo AND a.codigo=?MiPedVtaSuc","SunatMidetalle")
		Else
			cmd0=SQLExec(lnHandle,"SELECT a.*,b.nombre  FROM detafacturas a , productos b WHERE a.producto=b.codigo AND a.unico=?Myunico","SunatMidetalle")
		Endif
	Else
		cmd0=SQLExec(lnHandle,"SELECT a.*,b.nombre  FROM detaboletas a , productos b WHERE a.producto=b.codigo AND a.unico=?Myunico","SunatMidetalle")
	Endif

	SQLDisconnect(lnHandle)
Else
	Aerror(laErr)
	Messagebox("No se pudo conectar a mySQL. Error: " + Chr(13) + laErr[2])
Endif

*******Agrupacion de Items solo para el TXT *********************************************************************************************
If Isvtasucesiva=0
	Select producto,nombre,lotefab,um,cantidad,precio,subtotal,es_alter,txt_alternativo From Sunatmidetalle Into Cursor way01 Readwrite
	Select Sunatmidetalle
	Delete All
	Select way01
	Scan
		var1=Alltrim(producto)
		var2=Alltrim(nombre)
		var3=Alltrim(lotefab)
		var4=Alltrim(um)
		var5=cantidad
		var6=precio
		var7=subtotal
		var8=es_alter
		var9=txt_alternativo
		Select Sunatmidetalle
		Locate For Alltrim(producto)=var1 And Alltrim(um)=var4 And precio=var6
		If Found()
			Replace lotefab With lotefab+'-'+var3
			Replace cantidad With cantidad+var5
			Replace subtotal With subtotal+var7
		Else
			Append Blank
			Replace producto With var1
			Replace nombre With var2
			Replace lotefab With var3
			Replace um With var4
			Replace cantidad With var5
			Replace precio With var6
			Replace subtotal With var7
			Replace es_alter With var8
			Replace txt_alternativo With var9
		Endif
		Select way01
	Endscan
	Select Sunatmidetalle
Endif
******************************************************************************************************************

Select Sunatmidetalle
CtaRegVs=Reccount()
Go Top
Scan
	CtaMiReg=CtaMiReg+1
	AcumulaMG=AcumulaMG+Sunatmidetalle.subtotal
	igvlinea=0
	If MitipoDoc='F' And Miserie=60  &&& Es Vta Sucesiva
		If CtaMiReg=CtaRegVs  && Es el ultimo registro del detalle
			a_Parte07=Alltrim(Sunatmidetalle.nombre)
			b_Parte07='^^'+'^ORIGEN:'+Alltrim(Datavs.paisorigen)+'^'+Alltrim(Datavs.aranceles)+'^'+NotaVs01 &&Detalle adicional
		Else
			a_Parte07=Alltrim(Sunatmidetalle.nombre)
			b_Parte07=''  && Detalle adicional
		Endif
	Else
		If Sunatmidetalle.es_alter=0
			a_Parte07=Alltrim(Sunatmidetalle.nombre)+' '+Alltrim(Sunatmidetalle.lotefab)
			b_Parte07=''  && Detalle adicional
		Else
			a_Parte07=Alltrim(Sunatmidetalle.txt_alternativo)
			b_Parte07=''  && Detalle adicional
		Endif
	Endif
	c_Parte07=Alltrim(Sunatmidetalle.producto)
	If Alltrim(Upper(Sunatmidetalle.um))='UN'
		d_Parte07='NIU'  && NIU
	Else
		d_Parte07=Upper(Alltrim(Sunatmidetalle.um)) && Catalogo 03
	Endif
	e_Parte07=Alltrim(Str(Sunatmidetalle.cantidad,13,2))

	f_Parte07=Alltrim(Str(Sunatmidetalle.subtotal,13,2))

	preconigv=Round(((Sunatmidetalle.subtotal*DocuIgv)/100),2)+Sunatmidetalle.subtotal

	mPU = Round(Sunatmidetalle.precio * (1+ (DocuIgv/100)), 2)

	Do Case &&& PriceAmount,
		&&& PriceTypeCode
		&&& Código de Precio Catalogo 16 Revisar  (revisar)
		&&& 01 Precion Unitario (inc IGV)
		&&& 02 Valor referencial unitario en operaciones no onerosas
	Case MitipoDoc='F' && Facturas
		If Miserie=60  && Es Vta Sucesiva (Inafecta)
			* 20/09/2018 Edgard: Correccion en el campo g_Parte07
			*g_Parte07=ALLTRIM(STR(SunatMidetalle.subtotal,12,2)) && PriceAmount  && p*q *igv (en este caso no hay igv)
			g_Parte07=Alltrim(Str(Sunatmidetalle.precio,12,2)) && PriceAmount  && p*q *igv (en este caso no hay igv)
			h_Parte07='01' && PriceTypeCode
		Else && Otras Series
			If x_isExport=1 Or IsInafecta=1 && Es Por Exportacion (Inafecta)  u Otras Causas  que se apliquen inafecta
				* 20/09/2018 Edgard: Correccion en el campo g_Parte07
				*g_Parte07=ALLTRIM(STR(SunatMidetalle.subtotal,12,2)) && PriceAmount  && p*q *igv (en este caso no hay igv)
				g_Parte07=ALLTRIM(STR(SunatMidetalle.Precio,12,2)) && PriceAmount  && p*q *igv (en este caso no hay igv)
				h_Parte07='01' && PriceTypeCode
			Else  &&& Factura gravada
				* 20/09/2018 Edgard: Correccion en el campo g_Parte07
				*g_Parte07=Alltrim(Str(preconigv,12,2)) && Price Amount
				g_Parte07=Alltrim(Str(mPU,12,2)) && Price Amount
				h_Parte07='01' && PriceTypeCode
			Endif
		Endif
	Otherwise  && MiTipoDoc='B' Boletas
		Do Case
		Case Alltrim(SunatMidoc.condipag)='MG'  && Si es que es Muestra Gratis (Inafecta)
			* 20/09/2018 Edgard: Correccion en el campo g_Parte07
			*g_Parte07=Alltrim(Str(Sunatmidetalle.subtotal,12,2)) && PriceAmount
			g_Parte07=Alltrim(Str(Sunatmidetalle.Precio,12,2)) && PriceAmount
			h_Parte07='02' && PriceTypeCode
		Case Alltrim(SunatMidoc.condipag)='OB'  && Si es que es por OBSEQUIO (Gravada)
			* 20/09/2018 Edgard: Correccion en el campo g_Parte07
			*g_Parte07=Alltrim(Str(preconigv,12,2)) && Price Amount
			g_Parte07=Alltrim(Str(mPU,12,2)) && Price Amount
			h_Parte07='01' && PriceTypeCode
		Otherwise  &&  Gravada
			* 20/09/2018 Edgard: Correccion en el campo g_Parte07
			*g_Parte07=Alltrim(Str(preconigv,12,2)) && Price Amount
			g_Parte07=Alltrim(Str(mPU,12,2)) && Price Amount
			h_Parte07='01' && PriceTypeCode
		Endcase
	Endcase  &&& PriceAmount,PriceTypeCode

	i_Parte07='' &&& Indicador , Colocar False (vacio)

	&& Descuentos
	j_Parte07=Alltrim(Str(0,6,0)) && Porcentaje de descuento && NO APlica
	k_Parte07=Alltrim(Str(0.00,12,2)) && Monto de descuento && No APlica

	&&& Afectacion IGV
	igvlinea=Round(((Sunatmidetalle.subtotal*DocuIgv)/100),2)

	Do Case && TaxAmount
	Case MitipoDoc='F'
		If Miserie=60  && Vta Sucesiva
			l_Parte07=Alltrim(Str(0.00,12,2))  && 0.00 x Inafecta
		Else
			If x_isExport=1 Or IsInafecta=1 && Si es Exportación o es Inafecta
				l_Parte07=Alltrim(Str(0.00,12,2))  && 0.00 x Inafecta
			Else
				l_Parte07=Alltrim(Str(igvlinea,12,2))  && Monto Igv de la Linea
			Endif
		Endif
	Otherwise && Mitipodoc='B' Boleta
		Do Case
		Case Alltrim(SunatMidoc.condipag)='MG'  && Si es que es Muestra Gratis
			l_Parte07=Alltrim(Str(0.00,12,2))  && 0.00 x Inafecta
		Case Alltrim(SunatMidoc.condipag)='OB'  && Si es que es por OBSEQUIO (Gravada)
			l_Parte07=Alltrim(Str(igvlinea,12,2))  && Monto Igv de la Linea
		Otherwise (Gravada)
			l_Parte07=Alltrim(Str(igvlinea,12,2))  && Monto Igv de la Linea
		Endcase
	Endcase && TaxAmount

	Do Case &&TaxExemptionReasonCode
		&& Catalogo 07 Tipo de Afectacion del IGV
		&& 10 Gravado - Operacion Onerosa
		&& 13 GRavado - Retiro
		&& 30 Inafecto - Operacion Onerosa
		&& 32 Inafecto - Retiro
		&& 40 Exportación
		&& 36 Inafecto - Retiro por Publicidad
	Case MitipoDoc='F'
		If Miserie=60 Or IsInafecta=1 && Venta Sucesiva O Inafecta van al 30
			m_Parte07='30'
		Else
			If x_isExport=1  && Si es Exportacion
				m_Parte07='40'
			Else  && Facturacion Gravada
				m_Parte07='10'
			Endif
		Endif
	Otherwise && Mitipodoc='B' Boleta
		Do Case
		Case Alltrim(SunatMidoc.condipag)='MG'  && Si es que es Muestra Gratis
			m_Parte07='36'
		Case Alltrim(SunatMidoc.condipag)='OB'  && Si es que es por OBSEQUIO
			m_Parte07='10'
		Otherwise
			m_Parte07='10'
		Endcase
	Endcase &&TaxExemptionReasonCode

	n_Parte07='1000'  && Catalog 05 Codigo de Tributo IGV
	o_Parte07='IGV'  && cATALO 05 nOMBRE DEL TRIBUTO
	p_Parte07='VAT' && Catalogo 05, codigo internacional del tributo

	&& Afectacion ISC
	q_Parte07=Alltrim(Str(0.00,12,2)) && Monto ISC (no aplica)
	r_Parte07='' && Catalogo 8, Tipo de Sistema ISC
	s_Parte07='' && Catalogo 05 Codigo de tributo
	t_Parte07='' && Catalogo 05 NOmbre del tributo
	u_Parte07='' && Catalog 05 COdigo internacional del tributo

	&& ????
	v_Parte07=Alltrim(Str(Sunatmidetalle.precio,12,2))  &&& PriceAmount

	&& Venta Primaria
	If MitipoDoc='F' And Miserie=60  && Si es Factura Vta Sucesiva
		w_Parte07= Alltrim(Sunatmidetalle.lotefab)
	Else
		w_Parte07='' && LOte Explicar ??
	Endif
	Subdetalle=a_Parte07+'|'+b_Parte07+'|'+c_Parte07+'|'+d_Parte07+'|'+e_Parte07+'|'+f_Parte07+'|'+g_Parte07+'|'+h_Parte07+'|'+i_Parte07+'|'+;
		j_Parte07+'|'+k_Parte07+'|'+l_Parte07+'|'+m_Parte07+'|'+n_Parte07+'|'+o_Parte07+'|'+p_Parte07+'|'+q_Parte07+'|'+r_Parte07+'|'+;
		s_Parte07+'|'+t_Parte07+'|'+u_Parte07+'|'+v_Parte07+'|'+w_Parte07+'|'+'}'

	x07_StrBody=x07_StrBody+Subdetalle
Endscan

x07_StrBody=x07_StrBody+'~'

********Fin Parte07 ****************************************************************************************************************************************
********Inicio Parte05**************************************************************************************************************************************

a_Parte05='' &&ALLTRIM(STR(0.00,12,2)) && Otros Cargos (No manejamos)
If MitipoDoc='B' And Alltrim(SunatMidoc.condipag)='MG'
	b_Parte05=Alltrim(Str(SunatMidoc.Total,12,2)) && Para MG graba el acumulado x q en BD=0
Else
	b_Parte05=Alltrim(Str(SunatMidoc.Total,12,2)) && Total de la Factura o Boleta
Endif
c_Parte05='' &&ALLTRIM(STR(0.00,12,2)) && Descuentos (NO manejamos)

x05_StrBody=a_Parte05+'|'+b_Parte05+'|'+c_Parte05+'|'+'}'+'~'

********Fin Parte05 ****************************************************************************************************************************************

********Inicio Parte08**************************************************************************************************************************************
Local x_PassDetrac  &&&&&&++++AQUI+++++++++++++++++++++++++++
x_PassDetrac=0

If MitipoDoc='F'
	Do Case
	Case Miserie=10 Or Miserie=20 Or Miserie=40  Or Miserie=30 Or Miserie=50 Or Miserie=60 && Revisar si es importacion
		Do Case
		Case Miserie=60 Or x_isExport=1 Or IsInafecta=1 &&& Si es Vta Sucesiva o Factura de Exportacion o Inafecta
			a_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Gravada
			b_Parte08=Alltrim(Str(SunatMidoc.neto,12,2))  && Inafecta
			c_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Exonerada
		Otherwise
			a_Parte08=Alltrim(Str(SunatMidoc.neto,12,2))  && Gravada
			b_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Inafecta
			c_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Exonerada
		Endcase

		d_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Venta Gratuita
		e_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Total Descuentos

		Do Case
		Case x_isExport=1  && Es Exportacion
			f_Parte08='02'  && Tipo operacion SUNAT  -- 02 Exportacion?? Catalogo 17
		Otherwise
			f_Parte08='01'  && Tipo operacion SUNAT  -- 01 venta Interna?? Catalogo 17
		Endcase

		&& Percepcion
		g_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && Moneda Nacional Percepcion  Base Imponible
		h_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && Moneda Nacional -- Monto de la Percepcion
		i_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && Moneda Nacional -- Total de la Percepcion

		&& Detraccion
		If Miserie=50   &&& Facturacion de Servicios

			If Len(Alltrim(SunatMidoc.tipodetraccion))>1
				j_Parte08=Alltrim(Str(PctjeDetracServ,12,2))  && Pctje de la detraccion
				k_Parte08=Alltrim(Str(Round((Val(b_Parte05)*PctjeDetracServ)/100,2),12,2)) && monto de la detraccion
				l_Parte08='00068294282' && Numero Cta Banco de la nacion ++++++++++++++++++++DUDA+++++++++++++++++++++++++++
				m_Parte08='' && Total recargo
			Else && No Alcanza el monto minimo
				j_Parte08='' &&ALLTRIM(STR(0.00,6,0))  && Pctje de la detraccion
				k_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && monto de la detraccion
				l_Parte08='' && Numero Cta Banco de la nacion
				m_Parte08='' && Total recargo
			Endif

		Else &&& No es Serie 5
			j_Parte08='' &&ALLTRIM(STR(0.00,6,0))  && Pctje de la detraccion
			k_Parte08='' &&ALLTRIM(STR(0.00,12,2)) && monto de la detraccion
			l_Parte08='' && Numero Cta Banco de la nacion
			m_Parte08='' && Total recargo
		Endif
	Endcase

Else  &&& Para Boletas
	Do Case
	Case  Alltrim(SunatMidoc.condipag)='MG'  && Boleta Muestra Gratis
		a_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Gravada
		b_Parte08=Alltrim(Str(SunatMidoc.neto,12,2))  && Inafecta
		c_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Exonerada
	Otherwise
		a_Parte08=Alltrim(Str(SunatMidoc.neto,12,2))  && Gravada
		b_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Inafecta
		c_Parte08='' &&ALLTRIM(STR(0.00,12,2))  && Exonerada
	Endcase

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
Endif

sub01P08=a_Parte08+'|'+b_Parte08+'|'+c_Parte08+'|'+d_Parte08+'|'+e_Parte08+'|'+f_Parte08+'}'
sub02P08=g_Parte08+'|'+h_Parte08+'|'+i_Parte08+'}'
sub03P08=j_Parte08+'|'+k_Parte08+'|'+l_Parte08+'|'+m_Parte08+'}'

x08_StrBody=sub01P08+sub02P08+sub03P08+'~'

********Fin Parte08 ****************************************************************************************************************************************
********Inicio Parte09**************************************************************************************************************************************

If MitipoDoc='F' And Miserie=60 &&& Solo Para Vta Sucesiva
	a_Parte09=Alltrim(Datavs.bl)  && BL Conocimiento de Embarque
	e_Parte09=Alltrim(Datavs.incoterm)  && Descripcion INCOTERMS
	f_Parte09=Alltrim(Str(Datavs.fvalorfob,12,2)) && Total FOB
	g_Parte09=Alltrim(Str(Datavs.fvalorflete,12,2)) && Total Flete
	h_Parte09=Alltrim(Str(Datavs.fvalorseguro,12,2)) && Total Seguro
	k_Parte09=Alltrim(Datavs.pedido)  && Lista de Empaque / OC
Else
	a_Parte09=''  && BL Conocimiento de Embarque
	e_Parte09=''  && Incoterms
	f_Parte09=''  && Total FOB
	g_Parte09=''  && Total Flete
	h_Parte09=''  && Total Seguro
	k_Parte09=''  && Lista de Empaque / OC
Endif

Do Case
Case MitipoDoc='B'
	If Alltrim(SunatMidoc.condipag)='MG'
		b_Parte09=' MUESTRA PROMOCIONAL '
	Else
		b_Parte09=Alltrim(SunatMidoc.Nompago)
	Endif
Otherwise && Factura
	If Miserie=60  &&& Si es Vta Sucesiva
		b_Parte09=Alltrim(Datavs.condicionpago)
	Else
		b_Parte09=Alltrim(SunatMidoc.Nompago)
	Endif
Endcase

c_Parte09=Alltrim(SunatMidoc.codigoc)  &&& Codigo de CLiente

Do Case
Case MitipoDoc='B' && Boleta
	If Alltrim(SunatMidoc.condipag)='MG'
		d_Parte09=FraseMG+' '+Iif(d_Parte01='PEN','S/','US$')+' '+Alltrim(Str(AcumulaMG,12,2))+' '+FraseBoleta
	Else
		d_Parte09=FraseBoleta
	Endif
Case MitipoDoc='F' && Factura
	Do Case
	Case Miserie=50  && Servicios Averiguar si por el monto aplica la Percepcion
		Do Case
		Case Alltrim(SunatMidoc.tipodetraccion)='020-01'
			d_Parte09=FraseDetrac01
		Case Alltrim(SunatMidoc.tipodetraccion)='037-01'
			d_Parte09=FraseDetrac02
		Case Alltrim(SunatMidoc.tipodetraccion)='022-01'
			d_Parte09=FraseDetrac03
		Otherwise
			d_Parte09=''
		Endcase
	Case Miserie=60  &&  Factura Vta Sucesiva
		d_Parte09=FraseVs01
	Otherwise
		d_Parte09=''
	Endcase
Endcase

&&e_Parte09='' al lado de a_Parte09
&&f_Parte09='' al lado de k_Parte09
&&g_Parte09=''
&&h_Parte09=''
i_parte09=''
j_Parte09=''
&&k_Parte09 al lado de e_Parte09

sub01P09=a_Parte09+'|'+b_Parte09+'|'+c_Parte09+'|'+d_Parte09+'|'+e_Parte09+'|'+f_Parte09+'|'+g_Parte09+'|'+h_Parte09+'|'+i_parte09+'|'+j_Parte09+'|'+k_Parte09+'|'+'}'

k_Parte09=''  && Observacion
l_parte09=Alltrim(Convnum(Val(b_Parte05)))+Iif(d_Parte01='PEN'," SOLES", " DOLARES AMERICANOS")   && Letras del Monto total

**** Configurando lista de correo a enviar ***
yy_01=Alltrim(Micliente.cpe01)
yy_02=Alltrim(Micliente.cpe02)

If Len(yy_02)<7 && Longitud minima correo
	MyListaCorreo=yy_01
Else
	MyListaCorreo=yy_01+';'+yy_02
Endif
**********************************************

*m_parte09=MylistaCorreo &&&'wtone@sociedadquimica.com.pe' &&MylistaCorreo   &&MylistaCorreo &&'wtone@sociedadquimica.com.pe;cservat@sociedadquimica.com.pe'  &&& Mail receptor MylistaCorreo
m_parte09 = 'egutierrez@sociedadquimica.com.pe'
n_parte09=''  && Nombre de Impresora
o_parte09='' &&& Copias

sub02P09=k_Parte09+'|'+l_parte09+'|'+m_parte09+'|'+n_parte09+'|'+o_parte09+'|'+'}'

x09_StrBody=sub01P09+sub02P09+'~'+'\'

********Fin Parte09 ****************************************************************************************************************************************

*xControl='\\SQMSERVER\inputprod\'+b_Parte01+'.txt'
*xControl='X:\'+b_Parte01+'.txt'
xControl='c:\VENTAS\'+b_Parte01+'.txt'

If File(xControl)  && Does file exist?
	gnErrFile = Fopen(xControl)
Else
	gnErrFile = Fcreate(xControl)  && If not create it
Endif

If gnErrFile>0
	StrBody=x01_StrBody+x02_StrBody+x03_StrBody+x04_StrBody+x05_StrBody+x06_StrBody+x07_StrBody+x08_StrBody+x09_StrBody

	=Fputs(gnErrFile,StrBody) &&Graba la variable en el archivo txt

	*!*	   =FPUTS(gnErrFile,x01_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x02_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x03_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x04_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x05_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x06_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x07_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x08_StrBody) &&Graba la variable en el archivo txt
	*!*	   =FPUTS(gnErrFile,x09_StrBody) &&Graba la variable en el archivo txt

	Set Century Off

	=Fclose(gnErrFile) &&cerramos el archivo.
Else
	Wait Window "Error al abrir el archivo"
Endif

Select Sunatmidetalle
Delete All
Select SunatMidoc
Delete All
