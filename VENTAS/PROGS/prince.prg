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
********************************

*SET PATH TO z:\VENTAS,z:\VENTAS\PROGS,z:\VENTAS\INFORMES,z:\VENTAS\FORMULARIOS,z:\VENTAS\DIBUJOS,z:\VENTAS\Data,z:\VENTAS\librerias


**DV.17.03.20************************************************************
Public m.pcFolderStyle, lgMaquina, GAMYARRAY
Local lcsys16, lcprogram
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

**DV.17.03.20************************************************************
lcPathGeneral = cPathPc00 +";"+ cPathPc10 +";"+ cPathPc11 +";"+ cPathPc12 +";"+ cPathPc13 +";"+ cPathPc14 +";"+ cPathPc15  +";"+ cPathPc16 +";"+ cPathPc17 +";"+ cPathPc18
m.lcPath  = lcPathGeneral

Set Path To ..\VENTAS,..\VENTAS\PROGS,..\VENTAS\INFORMES,..\VENTAS\FORMULARIOS,..\VENTAS\DIBUJOS,..\VENTAS\Data,..\VENTAS\librerias,(m.lcPath);
*Set Path To z:\VENTAS;z:\VENTAS\PROGS;z:\VENTAS\INFORMES;z:\VENTAS\FORMULARIOS;z:\VENTAS\DIBUJOS;z:\VENTAS\Data;z:\VENTAS\librerias;(m.lcPath);
*************************************************************************

_SCREEN.CAPTION="SISTEMA DE INVENTARIO VENTAS Y COBRANZAS - SOCIEDAD QUIMICA MERCANTIL S.A."
_SCREEN.WINDOWSTATE=2
_SCREEN.MINBUTTON=.T.
_SCREEN.MAXBUTTON=.F.
_SCREEN.CLOSABLE=.F.
********************
**DV.29.03.20************************************************************
Public lgMaquina, lcListPrinter
lgMaquina = ALLTRIM(SYS (0))
lcListPrinter=""
*************************************************************************

OPEN DATABASE almacendata SHARED 
SET PROCEDURE TO FUNCIONES.PRG ADDITIVE 

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







