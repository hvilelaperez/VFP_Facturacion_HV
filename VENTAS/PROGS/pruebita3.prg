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
as1="F0"

as="%"
ad=as1

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd2=SQLEXEC(lnHandle,"SELECT * FROM productos WHERE tipoproducto like ?as and proveedor like ?ad","Mydatai")
                         
    
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




