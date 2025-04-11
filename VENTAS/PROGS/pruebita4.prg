
SET DELETED ON
SET ECHO OFF
SET TALK OFF
SET DATE BRITISH



OPEN DATABASE f:\newcompras\data\sqm SHARED
SELECT 0
USE color SHARED



PUBLIC Mystring 

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


SELECT color 
GO top


	lnHandle = SQLSTRINGCONNECT(Mystring)
	IF lnHandle > 0
	   SCAN  
          a1=codigo
          a2=STRCONV(nombre,9)
            
    	 ****** cmd1=SQLEXEC(lnHandle," insert into color (codigo,nombre) values (?a1,?a2)")    
    	  
       ENDSCAN 	  
                                             
    	SQLDISCONNECT(lnHandle)
	ELSE
    	AERROR(laErr)
    	MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
	ENDIF

