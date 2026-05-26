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
	cmd3=SQLEXEC(lnHandle,"SELECT a.codigo,a.nombre,a.ruc,a.telefono,a.direccion as dir1,a.dist as dist1,"+;
	                      "b.direccion as dir2,b.dist as dist2 from clientes a,direcciones b where "+;
	                      "a.codigo=b.cliente and vendedor='MB' order by a.codigo ","Basex")  	                                                
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT codigo,STRCONV(nombre,11) as Nombre,ruc,STRCONV(telefono,11) as telefono,;
       ALLTRIM(STRCONV(dir1,11))+" - "+ALLTRIM(STRCONV(dist1,11)) as dire1,;
       ALLTRIM(STRCONV(dir2,11))+" - "+ALLTRIM(STRCONV(dist2,11)) as dire2 ;
       FROM basex INTO CURSOR basexx
       

SELECT basexx
BROWSE 


