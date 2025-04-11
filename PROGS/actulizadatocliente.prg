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
                    


Mystring2 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.76;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
                    

                    
lnHandle = SQLSTRINGCONNECT(Mystring2)
IF lnHandle > 0  	                      
	**cmd3=SQLEXEC(lnHandle,"SELECT codigo,vendedor FROM clientes WHERE activo=1 ","Mibase")
		                      
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF                    
                 
SELECT Mibase
GO top


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0  	
     
    SCAN                  	  
	  a1=codigo
	  b1=vendedor
	  
	** cmd3=SQLEXEC(lnHandle,"UPDATE clientes SET vendedor=?b1 WHERE codigo=?a1 ")	  
    ENDSCAN 
     		                      
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF   









