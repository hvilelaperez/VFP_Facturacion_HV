*SUSPEND

SET PROCEDURE TO funciones
mSL = '' && CHR(13)+ CHR(10)

Mystring_ofi01 ="DRIVER={MySQL ODBC 3.51 Driver};" + ; 
           		"SERVER=192.168.1.179;" + ;                                                               		
           		"PORT=3306;" + ;
           		"UID=sistemas;" + ;
           		"PWD=d3b14nfw123;" + ;           		
           		"DATABASE=sqmdata;" + ;                             
           		"OPTIONS=0;"
           		
Codigosqm='S030'

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0
	cmd1 = SQLEXEC(lnHandle,"Select c.seriecr, c.numerocr, d.id, c.Fechacr, c.FechaPago, c.tipocam, c.porcretencion, c.tpagado, c.tretenido, c.observaciones, "+ ;
							"p.tiposunat, p.ruc, p.nombre, p.direccion, p.prov, p.dpto, p.dist, p.pais, p.ubigeo, "+ ;
							"d.tipodoc, d.serie, d.numero, d.femision, d.moneda, d.totaldoc, d.correlpago, d.pagadodol, d.retenciondol, d.pagadosol, d.retencionsol " + ;
							"from Retencionp c inner join Detaretencionp d on c.idcr = d.idcr inner join Clientes p on c.codigop = p.codigo order by 1,2,3","cCR")
	
	cmd2 = SQLEXEC(lnHandle,"SELECT * FROM clientes WHERE Codigo=?codigosqm","Empresa")
	cmd3=SQLEXEC(lnHandle,"SELECT * FROM k_sunatelectronica ","SunatDE")
	SQLDISCONNECT(lnHandle)
ELSE
	AERROR(laErr)
	MESSAGEBOX("No se pudo conectar a la base de datos"+ CHR(13)+ "Error: " + laErr[2])
	SQLDISCONNECT(lnHandle)
	RETURN
ENDIF

a_Parte02 = ALLTRIM(Empresa.ruc)
b_Parte02 = '6' &&& Tipo de Documento Catalogo 6 RUC para sqm
c_Parte02 = ALLTRIM(Empresa.nombre)
d_Parte02 = ALLTRIM(Empresa.nombre)
e_Parte02 = ALLTRIM(SunatDE.c_myubigeo)
f_Parte02 = ALLTRIM(Empresa.direccion)
g_Parte02 = ALLTRIM(SunatDE.c_myurbanizacion) 
h_Parte02 = ALLTRIM(Empresa.prov)
i_parte02 = ALLTRIM(Empresa.dpto)
j_parte02 = ALLTRIM(Empresa.dist)
k_Parte02 = ALLTRIM(Empresa.pais)  && Basado en Catalogo 04

SELECT cCR
GO Top
DO WHILE !EOF()
	SCATTER MEMVAR Memo
	IF ISNULL(m.Observaciones)
		m.Observaciones = ''
	ENDIF
	
	mNroCR = ALLTRIM(m.SerieCR)+ '-'+ TRans(m.numerocr, '@L 9999999')
	mFecCR = LEFT(DTOS(m.FechaCR),4)+ '-'+ SUBSTR(DTOS(m.FechaCR),5,2)+ '-'+ RIGHT(DTOS(m.FechaCR), 2)
	
	mParte01 = '20' + '|'+ mNroCR+ '|'+ mFecCR+ '}'+ mSL+ '~'+ mSL
	mParte02 = a_Parte02+'|'+b_Parte02+'|'+c_Parte02+'|'+d_Parte02+'|'+e_Parte02+'|'+f_Parte02+'|'+g_Parte02+'|'+h_Parte02+'|'+i_parte02+'|'+;
			j_parte02+'|'+k_Parte02+'|'+'}'+ mSL
	
	** Datos del proveedor
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
	
	mParte03 =a_Parte03+ '|'+b_Parte03+'|'+c_Parte03+'|'+d_Parte03+'|'+e_Parte03+'|'+f_parte03+'|'+g_parte03+'|'+h_Parte03+'|'+i_Parte03+'|'+j_Parte03+'|'+k_Parte03+'|'+'}'+ mSL+ '~' + mSL
	
	mParte04 = '01'+ '|'+ ALLTRIM(STR(m.PorcRetencion, 5,2))+ '|'+ ALLTRIM(m.Observaciones)+ '|'+ ALLTRIM(STR(m.tretenido,10,2))+ '|'+ 'PEN'+ '|'+ ALLTRIM(STR(m.tpagado,10,2))+ '|'+ ;
				'PEN'+ '|'+ '}' + mSL+ '~' + mSL       && Regimen retencion / tasa retencion / observaciones / ...
	
	mDeta_05_08 = ''
	SCAN WHILE seriecr = m.seriecr AND numerocr = m.numerocr
		SCATTER MEMVAR FIELD EXCEPT Observaciones
		** Detalle
		mDocProv = ALLTRIM(m.serie)+ '-'+ Trans(m.numero, '@L 9999999')
		mFDocPro = LEFT(DTOS(m.FEmision),4)+ '-'+ SUBSTR(DTOS(m.FEmision),5,2)+ '-'+ RIGHT(DTOS(m.FEmision), 2)
		mMonProv = IIF(m.Moneda = 'M1', 'PEN', 'USD')
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
		
		mParte07 = mRetenSol+ '|'+ mMonSoles+ '|'+ mFecPago+ '|'+ mBaseRetSol+ '|'+ mMonSoles+ '|'
		
		** Tipo de cambio
		IF m.TipoDoc = '07'    && En Nota de crédito no se envian los datos del tipo de cambio
			mTipoCam = ''
		ELSE
			mTipoCam = ALLTRIM(STR(m.tipocam,6,3))
		ENDIF
		mParte08 = mMonProv+ '|'+ mMonSoles+ '|'+ mTipoCam+ '|'+ mFecPago+ '|'+ '}'+ mSL
		
		mDeta_05_08 = mDeta_05_08+ mParte05+ mParte06+ mParte07+ mParte08
	ENDSCAN
	mDeta_05_08 = mDeta_05_08 + '~' + mSL
	
	** Adjuntos
	mMontoPalabra = ALLT(Convnum(m.tretenido))+ " NUEVOS SOLES"
	mCorreoProv = 'egutierrez@sociedadquimica.com.pe'
	mObserv2    = ''   && Esta observacion ya no se considera.
	mImpresora  = ''
	mCopias     = ''
	mParte09 = '|'+ '|'+ '|'+ '|'+ '|'+ '|'+ '}'+ mSL+ mObserv2+ '|'+ mMontoPalabra+ '|'+ mCorreoProv+ '|'+ mImpresora+ '|'+ mCopias+ '|'+ '}'+ ;
	mSL+ '~'+ mSL+ '\'
	
	mPartes = mParte01+ mParte02+ mParte03+ mParte04+ mDeta_05_08+ mParte09
	
	xControl='c:\VENTAS\'+ mNroCR+'.txt'
	gnErrFile = FCREATE(xControl)
	IF gnErrFile>0
		=FPUTS(gnErrFile,mPartes)
	ENDIF
	=FCLOSE(gnErrFile)
ENDDO
