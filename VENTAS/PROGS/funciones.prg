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