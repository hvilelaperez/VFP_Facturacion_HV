
SET DELETED ON
SET DEFAULT TO ..\ventas
SET PATH TO ..\VENTAS,..\VENTAS\PROGS,..\VENTAS\INFORMES,..\VENTAS\FORMULARIOS,..\VENTAS\DIBUJOS,..\VENTAS\Data,..\VENTAS\librerias
SET PROCEDURE TO funciones
SET EXCLUSIVE OFF

PUBLIC Mystring_ofi01, MyString_ofi02, Vusuario, PASE32, lcStringCnxRemoto, MyString_ofi03

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
           		"SERVER=192.168.1.179;" + ;
           		"PORT=3306;" + ;
           		"UID=sistemas;" + ;
           		"PWD=d3b14nfw123;" + ;
           		"DATABASE=sqmdata;" + ;
           		"OPTIONS=0;"

Mystring_ofi02 ="DRIVER={MySQL ODBC 3.51 Driver};" + ; && Server Datos Indicolor
           		"SERVER=192.168.1.79;" + ;
           		"PORT=3304;" + ;
           		"UID=sistemas;" + ;
           		"PWD=informatica;" + ;
           		"DATABASE=indicolor;" + ;
           		"OPTIONS=0;"

Mystring_ofi03 = "DRIVER={MySQL ODBC 3.51 Driver};" + ; && Server Datos Lince
				"SERVER=190.41.164.110;" + ;
				"PORT=3306;" + ;
				"UID=laboratorio;" + ;
				"PWD=d3b14nfw123;" + ;
				"DATABASE=laboratorio;" + ;
				"OPTIONS=0;"           		

lcStringCnxRemoto = Mystring_ofi01

*Vusuario = 'SISTEMAS'
Vusuario = 'KATE'
PASE32=1