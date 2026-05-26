SET ECHO OFF
SET TALK OFF
SET SAFETY OFF
SET DELETED ON
SET DATE BRITISH



Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


Mystring2 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.252;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=indicolor;" + ;
                    "OPTIONS=0;"



lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0    

   cmd2=SQLEXEC(lnHandle," select * from clientes where origen='C'","Mibase")
                                                                        
  SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF




lnHandle = SQLSTRINGCONNECT(Mystring2)
IF lnHandle > 0    
 
  SELECT Mibase
  GO top
  SCAN 
    a1=Mibase.codigo
    a2=STRCONV(Mibase.nombre,9)
    a3=Mibase.ruc
  
   cmd2=SQLEXEC(lnHandle,"insert into clientes2 (codigo,nombre,ruc) values (?a1,?a2,?a3)")
  ENDSCAN 
                                                                        
  SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF










