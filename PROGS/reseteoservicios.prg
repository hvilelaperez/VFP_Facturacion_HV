SET DELETED ON
SET DATE BRITISH
SET SAFETY OFF


LOCAL hoy 

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

hoy=DATE()

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
       
    cmd1=SQLEXEC(lnHandle,"SELECT * FROM preciostockclientes WHERE SUBSTRING(producto,1,2)='SS'","base1")     
  
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT base1
GO top

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
    SCAN 
    	var1=base1.id  
    	var2=base1.cliente
    	var3=base1.producto
    	    
    	cmd1=SQLEXEC(lnHandle," UPDATE preciostockclientes SET precio=0, fechamodifi=?hoy WHERE id=?var1")
    	cmd1=SQLEXEC(lnHandle," INSERT INTO masdetalleprecios (cliente,fecha,precio,producto,fechahora) values (?var2,?hoy,0,?var3,now())")
    	
    ENDSCAN 
    
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF









