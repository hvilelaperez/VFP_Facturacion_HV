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
	cmd3=SQLEXEC(lnHandle,"select a.codigo,a.nombre,b.nombre as Condicion FROM clientes a, condicionpago b "+;
	                      "WHERE a.condipago=b.codigo and LEFT(a.condipago,1)='L' and a.activo=1 ","Basex")
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT codigo,strconv(nombre,11) as Nombre ,STRCONV(condicion,11) as Condicion FROM Basex INTO CURSOR BaseY

SELECT BaseY
BROWSE 


