SET DELETED on
SET PROCEDURE TO funciones
SET CENTURY ON 
#DEFINE LF_CR CHR(10)+CHR(13)
#DEFINE TABU CHR(9) 

LOCAL xControl,Snt_Documento,StrBody,Pase1,Codigosqm,DocuIgv,Miserie,MitipoDoc,Seriedoc,Numerodoc,Hoy
LOCAL FraseMG,FraseBoleta,AcumulaMG,FraseDetrac01,FraseDetrac02,MinSolesDetrac,MinDolarDetrac,TcVentaHoy,PctjeDetracServ,x_isExport,x_EsLibre
LOCAL MiPedVtaSuc,CtaRegVs,CtaMiReg,NotaVs01,FraseVs01,MyUbigeo,MyUrbanizacion,MyListaCorreo,x_ChargeNc

codigosqm='S030'
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

Mitipodoc='C' && x_Sunatipodoc 
Seriedoc=10 &&Myserienc
Numerodoc=58  &&Mynumeronc
x_SunatipoApli='F'

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0  
    cmd0=SQLEXEC(lnHandle,"SELECT * FROM constantes ","MiDatosPlus") 
    cmd3=SQLEXEC(lnHandle,"SELECT * FROM k_sunatelectronica ","KonsMess")
    cmd2=SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codigosqm","MiDatasqm")
    cmd5=SQLEXEC(lnHandle,"SELECT venta FROM tcoficial WHERE fecha=?hoy","Cambiooficial")  
    IF Mitipodoc='D'  && Debito
	   cmd1=SQLEXEC(lnHandle,"SELECT a.* FROM ndebito a WHERE cpe=?x_SunatipoApli AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")                    
    ELSE  && Credito
        cmd1=SQLEXEC(lnHandle,"SELECT a.* FROM ncredito a  WHERE cpe=?x_SunatipoApli AND a.serie=?Seriedoc AND a.numero=?Numerodoc","SunatMidoc")
    ENDIF    
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


MyUbigeo=ALLTRIM(STRCONV(KonsMess.c_myubigeo,11))
MyUrbanizacion=ALLTRIM(STRCONV(KonsMess.c_myurbanizacion,11))
FraseMg=ALLTRIM(STRCONV(KonsMess.c_frasemg,11))
FraseBoleta=ALLTRIM(STRCONV(KonsMess.c_fraseboleta,11))
FraseDetrac01=ALLTRIM(STRCONV(KonsMess.c_frasedetrac01,11))
FraseDetrac02=ALLTRIM(STRCONV(KonsMess.c_frasedetrac02,11))
FraseVs01=ALLTRIM(STRCONV(KonsMess.c_frasevs01,11))
NotaVs01=ALLTRIM(STRCONV(KonsMess.c_notavtasucesiva,11))

TcVentaHoy=Cambiooficial.venta
PctjeDetracServ=MiDatosPlus.percepcionserv
MinSolesDetrac=MiDatosPlus.minperservsoles
MinDolarDetrac=ROUND(MinSolesDetrac/TcVentahoy,2)
Igv_ele=MiDatosPlus.igv
Miserie=SunatMidoc.serie

MiPedVtaSuc=''
    

SELECT SunatMidoc

*******Inicio Parte01 ***********************************************************************************************************************************
IF Mitipodoc='D'
   a_Parte01='08'  && Nota Debito
ELSE
   a_Parte01='07'  && Nota Credito
ENDIF
    
b_Parte01=x_SunatipoApli+TRANSFORM(serie,'@L 999')+'-'+TRANSFORM(numero,'@L 99999999')


y_Pyear=STR(YEAR(SunatMidoc.fecha),4,0)
y_Pmont=TRANSFORM(MONTH(SunatMidoc.fecha),"@L 99")
y_PDayy=TRANSFORM(DAY(SunatMidoc.fecha),"@L 99")

c_Parte01=y_Pyear+'-'+y_Pmont+'-'+y_Pdayy


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
c_Parte02=ALLTRIM(STRCONV(MiDatasqm.nombre,11))
d_Parte02=ALLTRIM(STRCONV(MiDatasqm.nombre,11))
e_Parte02=MyUbigeo
f_Parte02=ALLTRIM(STRCONV(MiDatasqm.direccion,11))
g_Parte02=MyUrbanizacion
h_Parte02=ALLTRIM(STRCONV(MiDatasqm.prov,11))
i_parte02=ALLTRIM(STRCONV(MiDatasqm.dpto,11))
j_parte02=ALLTRIM(STRCONV(MiDatasqm.dist,11))
k_Parte02=ALLTRIM(STRCONV(MiDatasqm.pais,11))  && Basado en Catalogo 04

x02_StrBody=a_Parte02+'|'+b_Parte02+'|'+c_Parte02+'|'+d_Parte02+'|'+e_Parte02+'|'+f_Parte02+'|'+g_Parte02+'|'+h_Parte02+'|'+i_Parte02+'|'+;
            j_Parte02+'|'+k_Parte02+'|'+'}'

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
c_Parte03=ALLTRIM(STRCONV(Micliente.nombre,11))
d_Parte03=ALLTRIM(STRCONV(Micliente.direccion,11))
e_Parte03='' && Urbanizacion (SE HA QUITADO DE LA STRUCTURA)---
f_Parte03=ALLTRIM(STRCONV(Micliente.prov,11))
g_parte03=ALLTRIM(STRCONV(Micliente.dpto,11))
h_parte03=ALLTRIM(STRCONV(Micliente.dist,11))
i_Parte03=ALLTRIM(STRCONV(Micliente.pais,11))  && Basado en Catalogo 04

x03_StrBody=a_Parte03+'|'+b_Parte03+'|'+c_Parte03+'|'+d_Parte03+'|'+f_Parte03+'|'+g_Parte03+'|'+h_Parte03+'|'+i_Parte03+'|'+'}'+'~'

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
    CASE Mitipodoc='D' &&& Para Nota de Debito
  
       a_Parte05=ALLTRIM(SunatMidoc.cpe_apli)+TRANSFORM(SunatMidoc.serie_apli,'@L 999')+'-'+TRANSFORM(SunatMidoc.numero_apli,'@L 99999999') &&38
       b_Parte05='03' && 39 Catalogo 10 Penalidades
       c_Parte05=ALLTRIM(STRCONV(SunatMidoc.motivo,11))  &&40
       d_Parte05=TRANSFORM(SunatMidoc.tiposunat_apli,'@L 99')  &&41
       
       y_Pyearg=STR(YEAR(SunatMidoc.fecha_apli),4,0)
	   y_Pmontg=TRANSFORM(MONTH(SunatMidoc.fecha_apli),"@L 99")
       y_PDayyg=TRANSFORM(DAY(SunatMidoc.fecha_apli),"@L 99")       
       e_Parte05=y_Pyearg+'-'+y_Pmontg+'-'+y_Pdayyg &&42    
              
    OTHERWISE  && Para Nota de Credito
	      a_Parte05=ALLTRIM(SunatMidoc.cpef)+TRANSFORM(SunatMidoc.serief,'@L 999')+'-'+TRANSFORM(SunatMidoc.numerof,'@L 99999999') &&38        
	      DO CASE 
	         CASE SunatMidoc.tipo=1
	         	  b_Parte05='07' && 39 Catalogo 09  Devolucion por Item   
	              c_Parte05=ALLTRIM(STRCONV('Devolucion',11))  &&40
	         CASE SunatMidoc.tipo=2 
	              b_Parte05='04' && 39 Catalogo 09  Descuento Global   
	              c_Parte05=ALLTRIM(STRCONV('Descuento de Precio',11))  &&40
	         CASE SunatMidoc.tipo=9   
	              b_Parte05='01' && 39 Catalogo 09  Anulacion de la operacion
	              c_Parte05=ALLTRIM(STRCONV('Anulacion de Documento.',11))  &&40  
	         CASE SunatMidoc.tipo=10  
	              b_Parte05='09' && 39 Catalogo 09  Disminucion en el valor
	              c_Parte05=ALLTRIM(STRCONV('Nota de Crédito Libre',11))  &&40    
	      ENDCASE 
      
	      DO CASE                                       
	         CASE SunatMidoc.tipodoc='F'     
	              d_Parte05='01'  &&41
	         CASE SunatMidoc.tipodoc='B'     
	              d_Parte05='03'  &&41
	      ENDCASE   
      
          y_Pyearg=STR(YEAR(SunatMidoc.fechaf),4,0)
	      y_Pmontg=TRANSFORM(MONTH(SunatMidoc.fechaf),"@L 99")
          y_PDayyg=TRANSFORM(DAY(SunatMidoc.fechaf),"@L 99")       
          e_Parte05=y_Pyearg+'-'+y_Pmontg+'-'+y_Pdayyg &&42     
		                                
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
Myunico=SunatMidoc.unico
x07_StrBody=''
Subdetalle='' && Enlazar cada linea del detalle


DO CASE 
   CASE Mitipodoc='D'
        SELECT SunatMidoc
        a_Parte07=ALLTRIM(STRCONV(SunatMidoc.observacion,11))
        b_Parte07=''
        
        c_Parte07='' &&53 OK
        d_Parte07='NIU'   &&54 OK
        e_Parte07='' &&55 OK
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
   		   
   		        IF SunatMidoc.tipodoc='F'   		     
   		            xx_trx='POR LA ANULACION DE LA FACTURA '+ALLTRIM(SunatMidoc.cpef)+TRANSFORM(SunatMidoc.serief,'@L 999')+'-'+TRANSFORM(SunatMidoc.numerof,'@L 99999999')+' DE FECHA '+DTOC(SunatMidoc.fechaf)
   		        ELSE 
   		            xx_trx='POR LA ANULACION DE LA BOLETA '+ALLTRIM(SunatMidoc.cpef)+TRANSFORM(SunatMidoc.serief,'@L 999')+'-'+TRANSFORM(SunatMidoc.numerof,'@L 99999999')+' DE FECHA '+DTOC(SunatMidoc.fechaf)
   		        ENDIF 
   		        
		        a_Parte07=ALLTRIM(STRCONV(xx_trx,11))
		        b_Parte07=''
		        
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
		        
		   CASE SunatMidoc.tipo=2  && Es por anulacion  
		        strbody=''
		   
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
				    strbody=strbody+PADR(ALLTRIM(Sunatmidetalle.producto),8,' ')+' '+PADR(ALLTRIM(SUBSTR(Sunatmidetalle.nombre,1,50)),50,' ')+' '+'Cant:'+STR(Sunatmidetalle.cantaplicada,10,2)+' '+'PU:'+STR(Sunatmidetalle.precioorigen,10,2)+' '+'NPU:'+STR(Sunatmidetalle.nuevoprecio,10,2)+' '+'Subtotal:'+STR(Sunatmidetalle.subtotal,10,2)+'^' 				    
				ENDSCAN 
		   		   
		   		a_Parte07='Por descuento de precio, le abonamos a su cuenta:'
		        b_Parte07=strbody 
		        
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
		        strbody=''
		   
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
				    strbody=strbody+PADR(ALLTRIM(Sunatmidetalle.producto),8,' ')+' '+PADR(ALLTRIM(SUBSTR(Sunatmidetalle.nombre,1,55)),55,' ')+'   '+'Cant:'+STR(Sunatmidetalle.cantaplicada,10,2)+'   '+'PU:'+STR(Sunatmidetalle.precioorigen,10,2)+'^'
				ENDSCAN 
		   		   
		   		a_Parte07='Por Devolucion de Mercaderia, le abonamos a su cuenta:'
		        b_Parte07=strbody 
		        
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
   CASE Mitipodoc='D'
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
h_parte09=alltrim(Convnum(VAL(b_Parte06)))+iif(d_Parte01='PEN'," NUEVOS SOLES", " DOLARES AMERICANOS")   && Letras del Monto total

	**** Configurando lista de correo a enviar ***
	yy_01=ALLTRIM(MiCliente.cpe01)
	yy_02=ALLTRIM(MiCliente.cpe02)
	
	IF LEN(yy_02)<7 && Longitud minima correo
	   MylistaCorreo=yy_01
	ELSE  
	   MylistaCorreo=yy_01+';'+yy_02	    
	ENDIF 
	**********************************************

i_parte09='wtone@sociedadquimica.com.pe' &&MylistaCorreo &&'wtone@sociedadquimica.com.pe' &&  &&&   &&& &&& Mail receptor &&&MylistaCorreo
j_parte09=''  && Nombre de Impresora
k_parte09='' &&& Copias

sub02P09=g_Parte09+'|'+h_Parte09+'|'+i_Parte09+'|'+j_Parte09+'|'+k_Parte09+'|'+'}'
x09_StrBody=sub01P09+sub02P09+'~'+'\'

********Fin Parte09 ****************************************************************************************************************************************

 *xControl='X:\'+ALLTRIM(Mitipodoc)+b_Parte01+'.txt'
xControl='C:\VENTAS\'+ALLTRIM(Mitipodoc)+b_Parte01+'.txt'
 
IF FILE(xControl)  && Does file exist? 
   gnErrFile = FOPEN(xControl)
ELSE
   gnErrFile = FCREATE(xControl)  && If not create it
ENDIF
 
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
IF Mitipodoc='C' AND x_ChargeNc=1
   SELECT SunatMidetalle
   DELETE ALL
ENDIF    
SELECT SunatMidoc
DELETE ALL 