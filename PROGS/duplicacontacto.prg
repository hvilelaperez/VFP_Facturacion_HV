
SET DELETED ON
SET DATE BRITISH

SET DEFAULT TO f:\ventas
SET PATH TO DATA,PROGS,FORMULARIOS,INFORMES
SET PROCEDURE TO FUNCIONES


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
                                                       
    ******cmd1=SQLEXEC(lnHandle," SELECT * FROM contactos WHERE area='VE'" ,"Auxi")       
    					       
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT auxi
replace ALL nombre WITH STRCONV(nombre,11) 

GO top
SCAN
    a1=CLIENTE
    a2='CO'
    a3=STRCONV(nombre,9)
    a4=telefono
    a5=fax
    a6=email
    a7=etiqueta

	lnHandle = SQLSTRINGCONNECT(Mystring)
	IF lnHandle > 0

                                                       
    	*************&&&cmd1=SQLEXEC(lnHandle," INSERT INTO contactos (cliente,area,nombre,telefono,fax,email,etiqueta) values (?a1,?a2,?a3,?a4,?a5,?a6,?a7)")       
    					       
    	SQLDISCONNECT(lnHandle)    
    
	ELSE
    	AERROR(laErr)
    	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	ENDIF

ENDSCAN 



