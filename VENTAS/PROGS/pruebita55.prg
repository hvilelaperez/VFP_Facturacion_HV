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


Mytope=DATE()-60

ad1="A066"
ad2="01B01"

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

        cmd1=SQLEXEC(lnHandle,"Select a.precio from preciostockclientes a,productos b where a.producto=b.codigo "+;
  	                           " and a.cliente=?ad1 and b.idsqm=?ad2 and a.fechamodifi>=?mytope","XXX")
   IF cmd1>0
   
   ELSE
       AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
   ENDIF     
       
                                             
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF




