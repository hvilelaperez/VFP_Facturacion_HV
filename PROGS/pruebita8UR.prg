SET DELETED ON
SET DATE BRITISH


PUBLIC Varstop1,Mystring,My120


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

  cmd2=SQLEXEC(lnHandle,"SELECT codigo,nombre From tipoproductos order by codigo","Myprov")

    
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF



