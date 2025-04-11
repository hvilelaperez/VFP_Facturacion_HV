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
    
    cmd3=SQLEXEC(lnHandle,"SELECT fingreso,origen,producto,costo FROM Vtalotes WHERE tipoorigen='W' "+;
                          " and fingreso>='2009-04-01'","Data1")                          
                                             
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT data1


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
	SELECT data1
	GO top
	SCAN
	   a1=data1.producto
	   a2=data1.origen
	   a3=data1.costo
      * cmd3=SQLEXEC(lnHandle,"update kardex set precio=?a3 WHERE producto=?a1 and origen=?a2 AND TIPODOC='GE'")                             
    
	ENDSCAN 
                                                
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF   
