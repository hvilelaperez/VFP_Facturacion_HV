SET DELETED ON
SET DATE BRITISH
SET DELETED ON 



Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

fec1=CTOD("01/08/2009")
fec2=CTOD("18/08/2009")

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

  	cmd2=SQLEXEC(lnHandle," SELECT MONTH(a.fecha) as mes,b.cantidad-b.cantidevuelta as Cantidad, "+;
	  		  	          " ROUND((b.cantidad-b.cantidevuelta)*b.precio,2) as Dinero,LEFT(b.producto,2) as Tipo "+;
						  " FROM factura a, detafacturas b  WHERE a.unico=b.unico and "+;
						  " a.fecha>=?fec1 and a.fecha<=?fec2 "+;
						  " and a.motivoguia=1 and a.estado<>'AN' ORDER BY 1 ","Factualx")
    
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


SELECT factualx
BROWSE


