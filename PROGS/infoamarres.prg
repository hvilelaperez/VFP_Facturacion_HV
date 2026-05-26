
SET DATE BRITISH
SET DELETED ON
SET TALK OFF
SET ECHO OFF

lcStringCnxRemoto = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"                                                                                                
        
                                   
SQLSETPROP(0,"DispLogin" , 3 )
lnHandle = SQLSTRINGCONNECT(lcStringCnxRemoto)
IF lnHandle>0  
  
	cmd1=SQLEXEC(lnHandle,"Select codigo,nombre,idsqm from productos  order by idsqm","Prueba1")    	
	
    SQLDISCONNECT(lnHandle)
ELSE
   AERROR(laErr)
   MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT prueba1
DELETE FOR EMPTY(idsqm)
BROWSE 
