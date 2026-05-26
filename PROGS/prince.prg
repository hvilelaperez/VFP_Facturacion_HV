*************************************
***DEFINICION PARA AMBIENTE DE RED***
*************************************
CLEAR MACROS
CLOSE ALL  
CLEAR ALL

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

** 20/07/2018: Tiempo de espera de conexion a MySQL modificado a 30 segundos.
SQLSETPROP(0,'ConnectTimeOut',30)

********************************

**DV.17.03.20************************************************************
Public m.pcFolderStyle, lgMaquina, GAMYARRAY
Local lcsys16, lcprogram
DIMENSION GAMYARRAY[1]
lcsys16 = Sys(16)
lcprogram = Substr(lcsys16,At(":", lcsys16) - 1)

lcRuta = STRTRAN(Left(lcprogram, Rat("\", lcprogram)),"\PROGS","")
Local lcPath

**SISTEMAS # Administrator
**DV.17.03.20************************************************************
Set Default To [&lcRuta]
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
cPathPc19 = m.lcPath + "SkinImage\"

**DV.17.03.20************************************************************
lcPathGeneral = cPathPc00 +","+ cPathPc10 +","+ cPathPc11 +","+ cPathPc12 ;
			+","+ cPathPc13 +","+ cPathPc14 +","+ cPathPc15  +","+ cPathPc16 ;
			+","+ cPathPc17 +","+ cPathPc18 +","+ cPathPc19 

lcPath  = "Set Path To "+lcPathGeneral
&lcPath

**DV.17.06.26************************************************************
ON ERROR DO ERRHAND WITH ERROR( ), MESSAGE( ), MESSAGE(1), SYS(16), LINENO( )
**DV.17.03.20************************************************************


_SCREEN.CAPTION="SISTEMA DE INVENTARIO VENTAS Y COBRANZAS - SQM S.A."
_SCREEN.WINDOWSTATE=2
_SCREEN.MINBUTTON=.T.
_SCREEN.MAXBUTTON=.F.
_SCREEN.CLOSABLE=.F.
********************
**DV.29.03.20************************************************************
Public lgMaquina
lgMaquina = ALLTRIM(SYS (0))
*************************************************************************

SET PROCEDURE TO FUNCIONES.PRG ADDITIVE 

PUBLIC vpRutaDBFSQM, vpRutaDBFInd
vpRutaDBFSQM = "\\SISTEMAS\newcomprassqm\DATA\"
vpRutaDBFInd = "\\SISTEMAS\newcompras\DATA\"

*********
DO FORM FORMCLAVE.SCX
READ EVENTS && INICIA EL PROCESAMIENTO DE EVENTOS
********************
*LO SIGUIENTE SE EJECUTARA CUANDO SE LLAME A CLEAR EVENTS EN ALGUNA PARTE DEL SISTEMA
********************
CLOSE ALL
CLEAR ALL
*****************************
RELEASE ALL EXTENDED  && LIBERA DE LA MEMORIA TODAS LAS VARIABLES Y MATRICES Y TODAS 
                      && LAS VARIABLES PUBLICAS
                      
SET SYSMENU TO DEFAULT


FUNCTION DisplayIP
LOCAL lowsock, lcip
  lowsock = CREATEOBJECTEX("{248DD896-BB45-11CF-9ABC-0080C7E7B78D}", "", "")
  lcip = lowsock.LocalIP
  RETURN (lcip)
ENDFUNC

*/* Procedimiento: detectar Errores y Almacenar en Errores.txt
PROCEDURE ERRHAND
	PARAMETER MERROR, MESS, MESS1, MPROG, MLINENO
	LCUSUARIOMAQUINA = 		SYS(0)
	*loSock = CREATEOBJECT('MSWinsock.Winsock.1')
	*loSock = DisplayIP()
	loSock = SYS(0)
	
	MSGEXIT =	"Sistema de Inventario Ventas y Cobranza" + CHR(13) +;
		"Número de error  : " + LTRIM(STR(MERROR))+ CHR(13)+ ;
		"Mensaje de error : " + MESS+CHR(13)+;
		"Línea de error   : " + MESS1+CHR(13)+;
		"Núm Línea error  : " + LTRIM(STR(MLINENO))+CHR(13)+;
		"Prog. con error  : " + MPROG+CHR(13)+;
		"Usuario/Maquina  : " + LCUSUARIOMAQUINA+CHR(13)+;
		"IP PC origen     : " + loSock+CHR(13)       &&    loSock.LocalIP+CHR(13)
		
	#DEFINE LF_CR CHR(10)+CHR(13)
	#DEFINE TABU CHR(9)
	LOCAL STRBODY
	STRBODY=MSGEXIT
	*************************************************************************
	*DO outlooco WITH 'dvilela@sociedadquimica.com.pe',msgEXIT,'Revisar en Sistema'
	*STRBODY="Este mail ha sido enviado automáticamente, por favor no responder a este remitente"
	********************
	TRY
		LOCAL LCSCHEMA, LOCONFIG, LOMSG, LOERROR, LCERR
		LCERR = ""
		LCSCHEMA = "http://schemas.microsoft.com/cdo/configuration/"
		LOCONFIG = CREATEOBJECT("CDO.Configuration")
		WITH LOCONFIG.FIELDS
			.ITEM(LCSCHEMA + "smtpserver") = "smtp.gmail.com"
			.ITEM(LCSCHEMA + "smtpserverport") = 465 && ó 587
			.ITEM(LCSCHEMA + "sendusing") = 2
			.ITEM(LCSCHEMA + "smtpauthenticate") = .T.
			.ITEM(LCSCHEMA + "smtpusessl") = .T.
			.ITEM(LCSCHEMA + "sendusername") = "automailer@sociedadquimica.com.pe"
			.ITEM(LCSCHEMA + "sendpassword") = "robot123"
			.UPDATE
		ENDWITH

		LOMSG = CREATEOBJECT ("CDO.Message")

		WITH LOMSG
			.CONFIGURATION = LOCONFIG
			.FROM = "automailer@sociedadquimica.com.pe (SQM.Sistemas)"
			.TO = "sistemas@sociedadquimica.com.pe"
			.SUBJECT = "MAIL ERROR : Aviso de error en Sistema de Laboratorio"
			.TEXTBODY = STRBODY
			.SEND()
		ENDWITH
	CATCH TO LOERROR
		LCERR = [Error: ] + STR(LOERROR.ERRORNO) + CHR(13) + ;
			[Linea: ] + STR(LOERROR.LINENO) + CHR(13) + ;
			[Mensaje: ] + LOERROR.MESSAGE
	FINALLY
		RELEASE LOCONFIG, LOMSG
		STORE .NULL. TO LOCONFIG, LOMSG
		IF EMPTY(LCERR)
			*MESSAGEBOX("El mensaje se envió con éxito", 64, "Aviso")
		ELSE
			MESSAGEBOX(LCERR, 16 , "Error")
		ENDIF
	ENDTRY

	LNANSWER = MESSAGEBOX(MSGEXIT,0+48,"El Error ya esta Registrado, en breve el area de sistemas atendera el problema.")

	READ EVENTS   && INICIA EL PROCESAMIENTO DE EVENTOS
	**************************
	*CLOSE ALL
	*CLEAR ALL
	CANCEL
	********************
	RELEASE ALL EXTENDED  && LIBERA DE LA MEMORIA TODAS LAS VARIABLES Y MATRICES Y TODAS
	CLEAR ALL

	&& LAS VARIABLES PUBLICAS
	SET SYSMENU TO DEFAULT


ENDPROC





