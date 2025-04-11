SET DELETED ON
SET DATE BRITISH


PUBLIC Varstop1,Mystring,My120
My120=DATE()-120

Varstop1=0

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd2=SQLEXEC(lnHandle,"SELECT a.unico,b.fecha as grmpdfec,a.producto as codigo,a. cantidad as grmdqart FROM "+;
                          " detaguiasremision a , guiasremision b "+;
                          "WHERE a.unico=b.unico and fecha>=?My120 and fecha<=curdate()","Hijo")    

    
   IF cmd2>0
   
   ELSE
       AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
   ENDIF     
       
                                             
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF




