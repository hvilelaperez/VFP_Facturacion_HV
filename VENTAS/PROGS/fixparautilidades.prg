SET DELETED ON
SET DATE BRITISH


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

  cmd2=SQLEXEC(lnHandle,"SELECT a.*,b.fecha,b.serie,b.numero FROM detafacturas a,factura b "+;
                        " where a.unico=b.unico and b.fecha>='2009-07-01' and b.fecha<='2009-08-31' and idorigen=0","Var01")
      
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF
SELECT var01
BROWSE


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
   
     SELECT var01 
	 GO TOP
     SCAN 
        Myid=Var01.id
        Myun=Var01.unicoorigen
        Mypro=Var01.producto
        Mylote=Var01.lotefab
         
       * cmd2=SQLEXEC(lnHandle,"SELECT id,unico,producto,costo FROM vtalotes WHERE unico=?Myun and producto=?Mypro and lotefab=?Mylote ","Mywill")
        SELECT Mywill
        asd=RECCOUNT()
        IF asd=1
           GO top
           TransId=Mywill.id
        *   cmd2=SQLEXEC(lnHandle,"update detafacturas set idorigen=?TransId where id=?Myid")
        ENDIF          
        SELECT var01                 
     ENDSCAN 
    
   SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


    
        