

SET TALK OFF
SET ECHO OFF
SET DELETED ON
SET DATE BRITISH


Myini=DATE()-360

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    && verifica Factura
    *cmd2=SQLEXEC(lnHandle,"SELECT a.id,b.fecha,b.numero,a.producto,a.cantidad,a.precio,a.subtotal,ROUND(a.precio*a.cantidad,2) as sub2 "+;
                          " FROM detafacturas a,factura b where a.unico=b.unico and b.fecha>'2009-04-01' and b.estado<>'AN'","Tep1")
     
    &&verifica Boleta
    *cmd1=SQLEXEC(lnHandle,"SELECT a.id,b.fecha,b.numero,a.producto,a.cantidad,a.precio,a.subtotal,ROUND(a.precio*a.cantidad,2) as sub2 "+;
                          " FROM detaboletas a,boleta b where a.unico=b.unico and b.fecha>'2009-04-01' and b.estado<>'AN'","Tep1")                                                                                
   SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT tep1
GO top
BROWSE FOR subtotal<>sub2


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
   
    SELECT tep1
    GO top

   SCAN  FOR subtotal<>sub2
    a1=tep1.id
    a2=tep1.sub2
    
    &&&&& Cuidado
    *****cmd2=SQLEXEC(lnHandle,"Update detafacturas set subtotal=?a2 WHERE id=?a1")
                          
   ENDSCAN 
                                                                              
   SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF
 








