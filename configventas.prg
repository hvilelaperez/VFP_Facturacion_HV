SET NOTIFY OFF
SET SAFETY OFF
SET EXCLUSIVE OFF
SET DELETED ON
SET DEFAULT TO ..\ventas
SET PATH TO ..\VENTAS,..\VENTAS\PROGS,..\VENTAS\INFORMES,..\VENTAS\FORMULARIOS,..\VENTAS\DIBUJOS,..\VENTAS\Data,..\VENTAS\librerias
SET PROCEDURE TO funciones


PUBLIC Mystring_ofi01, MyString_ofi02, Vusuario, PASE32, lcStringCnxRemoto, MyString_ofi03
PUBLIC Localr, VLOGO 

PUBLIC vpRutaDBFSQM, vpRutaDBFInd
vpRutaDBFSQM = "\\SISTEMAS\newcomprassqm\DATA\"
vpRutaDBFInd = "\\SISTEMAS\newcompras\DATA\"

VLOGO = 'SQM'
Localr = 2   && San Isidro

mServerPrueba= 0   && Variable que activa o desactiva el uso de la base de datos de prueba

IF mServerPrueba= 1
	WAIT WINDOW 'Data de SQM - PRUEBA. Presione una tecla para continuar..'  nowait
	MyString_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;   && SQM Prueba
				"SERVER=192.168.1.169;" + ;
				"PORT=3306;" + ;
				"UID=sqmdata;" + ;
				"PWD=sqmdata;" + ;
				"DATABASE=sqmdata;" + ;
				"OPTIONS=0;"

	Mystring_ofi02 ="DRIVER={MySQL ODBC 3.51 Driver};" + ; && Indicolor Prueba
           		"SERVER=192.168.1.169;" + ;
           		"PORT=3306;" + ;
           		"UID=sqmdata;" + ;
           		"PWD=sqmdata;" + ;
           		"DATABASE=indicolor;" + ;
           		"OPTIONS=0;"

	
ELSE
	WAIT WINDOW 'Data de SQM - PRODUCCION. Presione una tecla para continuar..' nowait
	IF Localr = 1
		Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;   && San Isidro
	           		"SERVER=192.168.1.179;" + ;
	           		"PORT=3306;" + ;
	           		"UID=sqmsistemas;" + ;
	           		"PWD=t1s9m.2712;" + ;
	           		"DATABASE=sqmdata;" + ;
	           		"OPTIONS=0;"
	           		
		Mystring_ofi02 ="DRIVER={MySQL ODBC 3.51 Driver};" + ; && Server Datos Indicolor
	           		"SERVER=192.168.1.180;" + ;
	           		"PORT=3306;" + ;
	           		"UID=sqmsistemas;" + ;
	           		"PWD=t1s9m.2712;" + ;
	           		"DATABASE=indicolor;" + ;
	           		"OPTIONS=0;"
	ELSE
		Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
					"SERVER=192.168.1.179;" + ;
					"PORT=3306;" + ;
					"UID=sqmsistemas;" + ;
					"PWD=t1s9m.2712;" + ;
					"DATABASE=sqmdata;" + ;
					"OPTIONS=0;"
		
		Mystring_ofi02 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
					"SERVER=192.168.1.180;" + ;
					"PORT=3306;" + ;
					"UID=sqmsistemas;" + ;
					"PWD=t1s9m.2712;" + ;
					"DATABASE=indicolor;" + ;
					"OPTIONS=0;"
	ENDIF
ENDIF


Mystring_ofi03 = "DRIVER={MySQL ODBC 3.51 Driver};" + ; && Server Datos Lince
				"SERVER=192.168.10.100;" + ;
				"PORT=3306;" + ;
				"UID=sqmsistemas;" + ;
				"PWD=t1s9m.2712;" + ;
				"DATABASE=laboratorio;" + ;
				"OPTIONS=0;"


lcStringCnxRemoto = Mystring_ofi01

*Vusuario = 'SISTEMAS'
*Vusuario = 'CDSQM'
*Vusuario = 'JHANDY'
*Vusuario = 'ORLANDO'
*Vusuario = 'ALMACEN'
*Vusuario = 'EDGAR'
*Vusuario = 'YOLANDA'
*Vusuario = 'ELNOR'
*Vusuario = 'JAIME'
*Vusuario = 'CECILIA'
Vusuario = 'KATE'
*Vusuario = 'CINTHYA'
*Vusuario = 'WILLY'
*Vusuario = 'TATIANA'
PASE32=1
