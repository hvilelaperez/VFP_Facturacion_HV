*---------------------------------------------
* Función que encripta una cadena
* Parámetros:
*    tcCadena - Cadena a encriptar
*    tcLlave - Llave para encriptar (Debe ser la misma para Desencriptar)
*    tlSinDesencripta - .F. para proceso que se puede usar Desencripta
*       Los textos encriptados con este tlSinDesencripta en .T. no se pueden
*       desencriptar, ya que el mecanismo de encriptamiento utilizado
*       produce perdida de informacion que impide la inversion del proceso
* Retorno: Caracter (el doble de largo que el texto pasado)
*---------------------------------------------
SET FDOW TO 2

FUNCTION Encripta(tcCadena, tcLlave, tlSinDesencripta)
	LOCAL lc, ln, lcRet
	LOCAL lnClaveMul, lnClaveXor
	IF EMPTY(tcLlave)
		tcLlave = ""
	ENDIF
	=GetClaves(tcLlave,@lnClaveMul,@lnClaveXor)
	lcRet = ""
	lc = tcCadena
	DO WHILE LEN(lc) > 0
		ln = BITXOR(ASC(lc)*(lnClaveMul+1),lnClaveXor)
		IF tlSinDesencripta
			*-- Encripta de modo que no se puede desencriptar
			ln = BITAND(ln+(ln%256)*17+INT(ln/256)*135+ ;
				INT(ln/256)*(ln%256),65535)
		ENDIF
		lcRet = lcRet+BINTOC(ln-32768,2)
		lnClaveMul = BITAND(lnClaveMul+59,0xFF)
		lnClaveXor = BITAND(BITNOT(lnClaveXor),0xFFFF)
		lc = IIF(LEN(lc) > 1,SUBS(lc,2),"")
	ENDDO
	RETURN lcRet
ENDFUNC

*---------------------------------------------
* Función que desencripta una cadena encriptada
* Parámetros:
*    tcCadena - Cadena a desencriptar
*    tcLlave - Llave para desencriptar (Debe ser la misma de Encriptar)
* Retorno: Caracter (la mitad de largo que el texto pasado)
*---------------------------------------------
FUNCTION Desencripta(tcCadena, tcLlave)
	LOCAL lc, ln, lcRet, lnByte
	LOCAL lnClaveMul, lnClaveXor
	IF EMPTY(tcLlave)
		tcLlave = ""
	ENDIF
	=GetClaves(tcLlave, @lnClaveMul, @lnClaveXor)
	lcRet = ""
	FOR ln = 1 TO LEN(tcCadena)-1 STEP 2
		lnByte = BITXOR(CTOBIN(SUBS(tcCadena, ln,2))+ ;
			32768,lnClaveXor)/(lnClaveMul+1)
		lnClaveMul = BITAND(lnClaveMul+59, 0xFF)
		lnClaveXor = BITAND(BITNOT(lnClaveXor), 0xFFFF)
		lcRet = lcRet+CHR(IIF(BETWEEN(lnByte,0,255),lnByte,0))
	ENDFOR
	RETURN lcRet
ENDFUNC

*---------------------------------------------
* Función usada por Encripta y Desencripta
*---------------------------------------------
FUNCTION GetClaves(tcLlave, tnClaveMul, tnClaveXor)
	LOCAL lc, ln
	lc = ALLTRIM(LOWER(tcLlave))
	tnClaveMul = 31
	tnClaveXor = 3131
	DO WHILE NOT EMPTY(lc)
		tnClaveMul = BITXOR(tnClaveMul,ASC(lc))
		tnClaveXor = BITAND((tnClaveXor+1)*(ASC(lc)+1),0xFFFF)
		lc = IIF(LEN(lc) > 1,SUBS(lc,2),"")
	ENDDO
ENDFUNC

*** Revisar la funcion encadenada para la version del 
*** 
FUNCTION Revisavalor
LPARAMETERS xc1,xc2,xc3
LOCAL Micampo,Mivalor

	IF xc2>xc3
	   RETURN .f.
	ELSE
	   SELECT Ensamble
	   Micampo=FIELD(2+xc2)
	   Mivalor=LEFT(ALLTRIM(EVALUATE(Micampo)),1)
	   DO CASE
	      CASE xc1='B'
	        IF Mivalor<>'@'
	           RETURN .t.
	        ELSE
	           RETURN .f.
	        ENDIF
	      CASE xc1='G'
	        IF Mivalor='@'
	           RETURN .t.
	        ELSE
	           RETURN .f.	           
	        ENDIF 
	    ENDCASE
	                 	
	ENDIF    
ENDFUNC 



*--------------------------------------------------
* Función para calcular el nro de dias que dura 
* el trámite de aduanas NUEVO
*--------------------------------------------------

FUNCTION diastramite
LPARAMETERS tip1,tip2,tip3,tip4

IF ISNULL(tip4)
   tip4=0
ENDIF    

IF PARAMETERS()=4
	IF tip3="M" && si es maritimo
		  IF tip1="Parcial"
   			 IF BETWEEN(DOW(tip2,2),5,7)
      			 transito=8-DOW(tip2,2)
    		 ELSE
       			transito=1
    		 ENDIF            
 	 	  ELSE     	
		  	 IF Tip1='CONTAINER' AND tip4=1 && 2 dias 
	   			 DO case 
	     			CASE BETWEEN(DOW(tip2,2),1,3)
	           			 transito=2
	      			CASE DOW(tip2,2)=4
	           			 transito=4
	      			OTHERWISE 
	                	 transito=2+(7-DOW(tip2,2))
	   		 	 ENDCASE 	   
		  	 ELSE
	   		 	 &&& Mas 5 dias sea CONTAINER o Consolidado 
	   		 	 IF BETWEEN(DOW(tip2,2),1,5) 
	      		 	transito=7	   	  	   	  
	   		 	 ELSE
	      		 	transito=5+(7-DOW(tip2,2))	 	   	  
	   		 	 ENDIF 	                    	
		     ENDIF     	       	   	
 		 ENDIF  		  
   ELSE && si es Aereo 02 dias    
   		IF DOW(tip2,2)=4
     		transito=4
   		ELSE     
    	    IF BETWEEN(DOW(tip2,2),5,7)
        	   transito=2+(7-DOW(tip2,2))  
     		ELSE
     		   transito=2
     		ENDIF
   		ENDIF         	      
   ENDIF
ELSE && no han pasado los parametros correctos
     =MESSAGEBOX("No se han pasado todos los parametros ",16,"")
     RETURN .F.
ENDIF        
	
RETURN transito		
ENDFUNC  


**
FUNCTION diastramiteI
LPARAMETERS tip1,tip2,tip3
IF tip3="M" && si es maritimo
	IF tip1="Parcial"
		IF BETWEEN(DOW(tip2,2),5,7)
			transito=8-DOW(tip2,2)
		ELSE
			transito=1
		ENDIF
	ELSE
		IF tip1="CONTAINER" && 7 dias sin contar s y d
			DO CASE
				CASE BETWEEN(DOW(tip2,2),1,3)
					transito=9
				CASE BETWEEN(DOW(tip2,2),4,5)
					transito=11
				CASE BETWEEN(DOW(tip2,2),6,7)
					transito=9+(7-DOW(tip2,2))
			ENDCASE
		ELSE  && 6 dias sin contar s y d  okok
			DO CASE
				CASE  BETWEEN(DOW(tip2,2),1,4)
					transito=8

				CASE  BETWEEN(DOW(tip2,2),6,7)
					transito=8+(7-DOW(tip2,2))

				CASE   DOW(tip2,2)=5
					transito=10
			ENDCASE
		ENDIF
	ENDIF
ELSE && si es Aereo
	IF DOW(tip2,2)=4
		transito=4
	ELSE
		IF BETWEEN(DOW(tip2,2),5,7)
			transito=2+(7-DOW(tip2,2))
		ELSE
			transito=2
		ENDIF
	ENDIF
ENDIF
RETURN transito
ENDFUNC
**


* Indicar el Flujo de la informacion* 

*------------------------------------------------
* Retorna el último día del mes (EndOfMonth)
* USO: _EOM(DATE())
* RETORNA: Fecha
*------------------------------------------------
FUNCTION _EOM(dFecha)
  LOCAL ld 
  ld = GOMONTH(dFecha,1)
  RETURN ld - day(ld)
ENDFUNC

*-------------------------------------------------
* funcion para imprimir pasando el informe como
* parametro
*-------------------------------------------------
FUNCTION imprereporte (nombrereporte)
 SET SYSMENU off
 
 DEFINE WINDOW wPreveer FROM 0,0 TO 31,133 Font "Arial",9 Title "Previsualización del Reporte" System Close Grow noFloat Zoom Color Scheme 10
 
 REPORT FORM &nombrereporte PREVIEW Window wPreveer
 REPORT FORM &nombrereporte TO PRINTER PROMPT NOCONSOLE 
 Release Window wPreveer
 SET SYSMENU on
 RETURN
ENDFUNC

*-------------------------------------------------
*  
* 
*-------------------------------------------------

FUNCTION Periodoxx(lafecha as Date)
LOCAL Miperiodo

DO case
   CASE BETWEEN(lafecha,DATE()-120,DATE()-91)
        Miperiodo="Per 091-120"
   CASE BETWEEN(lafecha,DATE()-90,DATE()-61)     
        Miperiodo="Per 061-090"
   CASE BETWEEN(lafecha,DATE()-60,DATE()-31)          
        Miperiodo="Per 031-060"   
   CASE BETWEEN(lafecha,DATE()-30,DATE())          
        Miperiodo="Per 000-030"    
ENDCASE        
RETURN Miperiodo
ENDFUNC 



*--------------------------------------------------
*   Funcion convierte numeros a letras 
*--------------------------------------------------

Function Convnum(Total)

  Dimension aUnidades(9), aDecenas(14), aCentenas(10)
  aUnidades(1) = 'UN'
  aUnidades(2) = 'DOS'
  aUnidades(3) = 'TRES'
  aUnidades(4) = 'CUATRO'
  aUnidades(5) = 'CINCO'
  aUnidades(6) = 'SEIS'
  aUnidades(7) = 'SIETE'
  aUnidades(8) = 'OCHO'
  aUnidades(9) = 'NUEVE'
  aDecenas(1) = 'DIEZ'
  aDecenas(2) = 'ONCE'
  aDecenas(3) = 'DOCE'
  aDecenas(4) = 'TRECE'
  aDecenas(5) = 'CATORCE'
  aDecenas(6) = 'QUINCE'
  aDecenas(7) = 'VEINTE'
  aDecenas(8) = 'TREINTA'
  aDecenas(9) = 'CUARENTA'
  aDecenas(10) = 'CINCUENTA'
  aDecenas(11) = 'SESENTA'
  aDecenas(12) = 'SETENTA'
  aDecenas(13) = 'OCHENTA'
  aDecenas(14) = 'NOVENTA'
  aCentenas(1) = 'CIEN'
  aCentenas(2) = 'DOSCIENTOS'
  aCentenas(3) = 'TRESCIENTOS'
  aCentenas(4) = 'CUATROCIENTOS'
  aCentenas(5) = 'QUINIENTOS'
  aCentenas(6) = 'SEISCIENTOS'
  aCentenas(7) = 'SETECIENTOS'
  aCentenas(8) = 'OCHOCIENTOS'
  aCentenas(9) = 'NOVECIENTOS'

  vTotal = str(int(Total), 12)

  Do case
    Case empty(val(vTotal))
      Texto = 'CERO '

    Case val(vTotal) = 1
      Texto = 'UN '

    Otherwise
      tCientos     = obt_cant(substr(vTotal,10,3))
      tMiles       = obt_cant(substr(vTotal,7,3))
      tMillones    = obt_cant(substr(vTotal,4,3))
      tMilMillones = obt_cant(substr(vTotal,1,3))

      tCientos = tCientos
      tMiles = iif(empty(tMiles), '', ;
               iif(tMiles='UN', '', tMiles + ' ') + 'MIL ')
      tMillones = iif(empty(tMillones), '', ;
               tMillones + ' MILLON' + iif(tMillones='UN', ' ', 'ES ') +;
               iif(empty(tMiles + tCientos), 'DE', ''))
      tMilMillones = iif(empty(tMilMillones), '', ;
               iif(tMilMillones='UN', '', tMilMillones + ' ') + 'MIL ' +; 
               iif(empty(tMillones), 'MILLONES ', ' ') +;
               iif(empty(tMillones + tMiles + tCientos), 'DE', ''))

      Texto = strtran(tMilMillones + tMillones + tMiles + tCientos, '  ', ' ') + ''
  Endcase
  
Return Texto + iif(!empty(Total), ' CON ' + ;
   strtran(transform(int((total - int(total)) * ;
   100), '**'), '*', '0') + '/100', '')

Function obt_cant(valor)
  Public Unidades, Decenas, Centenas

  If empty(val(valor))
    Return ''
  Endif

  Store '' to tUnidades, tDecenas, tCentenas
  Unidades = int(val(substr(valor,3,1)))		&&          123
  Decenas  = int(val(substr(valor,2,1)))		&& vTotal = 999
  Centenas = int(val(substr(valor,1,1)))		&&          ^^^
  valor = int(val(valor))

  tUnidades = iif(!empty(unidades), aUnidades(Unidades), '')

  If !empty(decenas)
    If decenas = 1
      tDecenas = iif(val(right(str(valor,3),2)) >= 10 and ;
      val(right(str(valor,3),2)) <= 15, aDecenas(val(right(str(valor,3),2)) - 9), 'DIECI' + tUnidades)
      tUnidades = ''
    Else
      tDecenas = aDecenas(decenas + 5)
      if !empty(unidades)
        tDecenas = left(tDecenas, len(tDecenas) - 1) + 'I'
      Endif
    Endif
  Endif

  If !empty(centenas)
    tCentenas = aCentenas(centenas)
    If valor > 100
      If centenas = 1
        tCentenas = tCentenas + 'TO '
      Else
        tCentenas = tCentenas + ' '
      Endif
    Endif
  Endif
  
Return tCentenas + tDecenas + tUnidades


***** para quitar caracteres como la ñ y las tildes *************

FUNCTION Noutf8(as)

LOCAL Newas
Newas=""
FOR i= 1 TO LEN(ALLTRIM(as))
    ax=substr(as,i,1)
    DO case
       CASE ax="º"
            Newas=Newas+"#"
       CASE ax="Ñ"
            Newas=Newas+"N"
       CASE ax="ñ"
            Newas=Newas+"n"    
       CASE ax="Á"
            Newas=Newas+"A"         
       CASE ax="É"    
            Newas=Newas+"E"          
       CASE ax="Í"         
            Newas=Newas+"I"  
       CASE ax="Ó"         
            Newas=Newas+"O"                      
       CASE ax="Ú"              
            Newas=Newas+"U"          
       CASE ax="á"
            Newas=Newas+"a"               
       CASE ax="é"
            Newas=Newas+"e"                   
       CASE ax="í"     
            Newas=Newas+"i"                          
       CASE ax="ó"          
            Newas=Newas+"o"                                      
       CASE ax="ú"                      
            Newas=Newas+"u"                                                  
       OTHERWISE
            Newas=Newas+ax
    ENDCASE 
ENDFOR

RETURN Newas

ENDFUNC 
************************************************************************************

FUNCTION cmonth_es(tdFecha)
LOCAL la(12)
la(1) = "Enero"
la(2) = "Febrero"
la(3) = "Marzo"
la(4) = "Abril"
la(5) = "Mayo"
la(6) = "Junio"
la(7) = "Julio"
la(8) = "Agosto"
la(9) = "Setiembre"
la(10) = "Octubre"
la(11) = "Noviembre"
la(12) = "Diciembre"
RETURN la(MONTH(tdFecha))
ENDFUNC


********************************************************************
********************************************************************
*!* FUNCTION Exp2Excel( [cCursor, [cFileSave, [cTitulo]]] )
*!*
*!* Exporta un Cursor de Visual FoxPro a Excel, utilizando la
*!* técnica de importación de datos externos en modo texto.
*!*
*!* PARAMETROS OPCIONALES:
*!* - cCursor  Alias del cursor que se va a exportar.
*!*            Si no se informa, utiliza el alias
*!*            en que se encuentra.
*!*
*!* - cFileName  Nombre del archivo que se va a grabar.
*!*              Si no se informa, muestra el libro generado
*!*              una vez concluída la exportación.
*!*
*!* - cTitulo  Titulo del informe. Si se informa, este
*!*            ocuparía la primera file de cada hoja del libro.
********************************************************************
********************************************************************
FUNCTION Exp2Excel( cCursor, cFileSave, cTitulo )
  LOCAL cWarning
  cWarning = "Exportar a EXCEL"
  IF EMPTY(cCursor)
    cCursor = ALIAS()
  ENDIF
  IF TYPE('cCursor') # 'C' OR !USED(cCursor)
    MESSAGEBOX("Parámetros Inválidos",16,cWarning)
    RETURN .F.
  ENDIF
  *********************************
  *** Creación del Objeto Excel ***
  *********************************
  WAIT WINDOW 'Abriendo aplicación Excel.' NOWAIT NOCLEAR
  oExcel = CREATEOBJECT("Excel.Application")
  WAIT CLEAR

  IF TYPE('oExcel') # 'O'
    MESSAGEBOX("No se puede procesar el archivo porque no tiene la aplicación" ;
      + CHR(13) + "Microsoft Excel instalada en su computador.",16,cWarning)
    RETURN .F.
  ENDIF

  oExcel.workbooks.ADD

  LOCAL lnRecno, lnPos, lnPag, lnCuantos, lnRowTit, lnRowPos, i, lnHojas, cDefault

  cDefault = ADDBS(SYS(5)  + SYS(2003))

  SELECT (cCursor)
  lnRecno = RECNO(cCursor)
  GO TOP

  *************************************************
  *** Verifica la cantidad de hojas necesarias  ***
  *** en el libro para la cantidad de datos     ***
  *************************************************
  lnHojas = ROUND(RECCOUNT(cCursor)/65000,0)
  DO WHILE oExcel.Sheets.COUNT < lnHojas
    oExcel.Sheets.ADD
  ENDDO

  lnPos = 0
  lnPag = 0

  DO WHILE lnPos < RECCOUNT(cCursor)

    lnPag = lnPag + 1 && Hoja que se está procesando

    WAIT WINDOWS 'Exportando cursor '  + UPPER(cCursor)  + ' a Microsoft Excel...' ;
      + CHR(13) + '(Hoja '  + ALLTRIM(STR(lnPag))  + ' de '  + ALLTRIM(STR(lnHojas)) ;
      + ')' NOCLEAR NOWAIT

    IF FILE(cDefault  + cCursor  + ".txt")
      DELETE FILE (cDefault  + cCursor  + ".txt")
    ENDIF

    COPY  NEXT 65000 TO (cDefault  + cCursor  + ".txt") DELIMITED WITH CHARACTER ";"
    lnPos = RECNO(cCursor)

    oExcel.Sheets(lnPag).SELECT

    XLSheet = oExcel.ActiveSheet
    XLSheet.NAME = cCursor + '_' + ALLTRIM(STR(lnPag))

    lnCuantos = AFIELDS(aCampos,cCursor)

    ********************************************************
    *** Coloca título del informe (si este es informado) ***
    ********************************************************
    IF !EMPTY(cTitulo)
      XLSheet.Cells(1,1).FONT.NAME = "Arial"
      XLSheet.Cells(1,1).FONT.SIZE = 12
      XLSheet.Cells(1,1).FONT.BOLD = .T.
      XLSheet.Cells(1,1).VALUE = cTitulo
      XLSheet.RANGE(XLSheet.Cells(1,1),XLSheet.Cells(1,lnCuantos)).MergeCells = .T.
      XLSheet.RANGE(XLSheet.Cells(1,1),XLSheet.Cells(1,lnCuantos)).Merge
      XLSheet.RANGE(XLSheet.Cells(1,1),XLSheet.Cells(1,lnCuantos)).HorizontalAlignment = 3
      lnRowPos = 3
    ELSE
      lnRowPos = 2
    ENDIF

    lnRowTit = lnRowPos - 1
    **********************************
    *** Coloca títulos de Columnas ***
    **********************************
    FOR i = 1 TO lnCuantos
      lcName  = aCampos(i,1)
      lcCampo = ALLTRIM(cCursor) + '.' + aCampos(i,1)
      XLSheet.Cells(lnRowTit,i).VALUE=lcname
      XLSheet.Cells(lnRowTit,i).FONT.bold = .T.
      XLSheet.Cells(lnRowTit,i).Interior.ColorIndex = 15
      XLSheet.Cells(lnRowTit,i).Interior.PATTERN = 1
      XLSheet.RANGE(XLSheet.Cells(lnRowTit,i),XLSheet.Cells(lnRowTit,i)).BorderAround(7)
    NEXT

    XLSheet.RANGE(XLSheet.Cells(lnRowTit,1),XLSheet.Cells(lnRowTit,lnCuantos)).HorizontalAlignment = 3

    *************************
    *** Cuerpo de la hoja ***
    *************************
    oConnection = XLSheet.QueryTables.ADD("TEXT;"  + cDefault  + cCursor  + ".txt", ;
      XLSheet.RANGE("A"  + ALLTRIM(STR(lnRowPos))))

    WITH oConnection
      .NAME = cCursor
      .FieldNames = .T.
      .RowNumbers = .F.
      .FillAdjacentFormulas = .F.
      .PreserveFormatting = .T.
      .RefreshOnFileOpen = .F.
      .RefreshStyle = 1 && xlInsertDeleteCells
      .SavePassword = .F.
      .SaveData = .T.
      .AdjustColumnWidth = .T.
      .RefreshPeriod = 0
      .TextFilePromptOnRefresh = .F.
      .TextFilePlatform = 850
      .TextFileStartRow = 1
      .TextFileParseType = 1 && xlDelimited
      .TextFileTextQualifier = 1 && xlTextQualifierDoubleQuote
      .TextFileConsecutiveDelimiter = .F.
      .TextFileTabDelimiter = .F.
      .TextFileSemicolonDelimiter = .T.
      .TextFileCommaDelimiter = .F.
      .TextFileSpaceDelimiter = .F.
      .TextFileTrailingMinusNumbers = .T.
      .REFRESH
    ENDWITH

    XLSheet.RANGE(XLSheet.Cells(lnRowTit,1),XLSheet.Cells(XLSheet.ROWS.COUNT,lnCuantos)).FONT.NAME = "Arial"
    XLSheet.RANGE(XLSheet.Cells(lnRowTit,1),XLSheet.Cells(XLSheet.ROWS.COUNT,lnCuantos)).FONT.SIZE = 8

    XLSheet.COLUMNS.AUTOFIT
    XLSheet.Cells(lnRowPos,1).SELECT
    oExcel.ActiveWindow.FreezePanes = .T.

    WAIT CLEAR

  ENDDO

  oExcel.Sheets(1).SELECT
  oExcel.Cells(lnRowPos,1).SELECT

  IF !EMPTY(cFileSave)
    oExcel.DisplayAlerts = .F.
    oExcel.ActiveWorkbook.SAVEAS(cFileSave)
    oExcel.QUIT
  ELSE
    oExcel.VISIBLE = .T.
  ENDIF

  GO lnRecno

  RELEASE oExcel,XLSheet,oConnection

  IF FILE(cDefault + cCursor + ".txt")
    DELETE FILE (cDefault + cCursor + ".txt")
  ENDIF

  RETURN .T.

ENDFUNC



FUNCTION CMes
LPARAMETERS mNMes
	mCMes= ''
	DO Case
		CASE mNMes= 1
			mCMes= 'Enero'
		CASE mNMes= 2
			mCMes= 'Febrero'
		CASE mNMes= 3
			mCMes= 'Marzo'
		CASE mNMes= 4
			mCMes= 'Abril'
		CASE mNMes= 5
			mCMes= 'Mayo'
		CASE mNMes= 6
			mCMes= 'Junio'
		CASE mNMes= 7
			mCMes= 'Julio'
		CASE mNMes= 8
			mCMes= 'Agosto'
		CASE mNMes= 9
			mCMes= 'Setiembre'
		CASE mNMes= 10
			mCMes= 'Octubre'
		CASE mNMes= 11
			mCMes= 'Noviembre'
		CASE mNMes= 12
			mCMes= 'Diciembre'
	ENDCASE
	RETURN mCMes
ENDFUNC
