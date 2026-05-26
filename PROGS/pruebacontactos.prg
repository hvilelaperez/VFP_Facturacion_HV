SET DELETED ON
SET DATE BRITISH


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"



lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0  	                      
	cmd3=SQLEXEC(lnHandle,"select a.cliente,b.nombre,a.nombre as Contacto,a.area,b.VENDEDOR from contactos a ,clientes b where a.cliente=b.codigo and b.activo=1 and b.vendedor='XB' order by a.cliente ","Basex")  	                                                
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT cliente,ALLTRIM(STRCONV(nombre,11)) as Nombre,;
       CAST(ALLTRIM(STRCONV(contacto,11)) as Character(100)) as Contacto,area,vendedor FROM basex ;
       INTO CURSOR Basecontactos

SELECT basecontactos
BROWSE 


