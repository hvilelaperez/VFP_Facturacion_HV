SET DELETED ON
SET DATE BRITISH


PUBLIC Varstop1,Mystring,My120
My180=DATE()-180

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

    cmd2=SQLEXEC(lnHandle,"SELECT a.producto,a.cantidad,c.nombre,c.idsqm,b.fecha FROM "+;
                          " detafacturas a,factura b,productos c WHERE a.unico=b.unico and "+;
                          " a.producto=c.codigo and b.fecha>=?My180 and b.estado<>'AN' and "+;
                          " b.motivoguia=1 and LEFT(a.producto,2)='10'","Myresul")
    

    
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

SELECT Myresul

SELECT idsqm,SUM(cantidad) as Cantidad FROM Myresul GROUP BY 1 INTO CURSOR Migrupo 

SELECT CAST(" " as c(80)) as Minombre,idsqm,cantidad FROM Migrupo INTO CURSOR Mifinal READWRITE 

SELECT Mifinal
GO top
SCAN
  as=idsqm
  SELECT Myresul
  GO top
  LOCATE FOR Myresul.idsqm=as
    IF FOUND()
       replace Mifinal.minombre WITH Myresul.nombre
    ENDIF
  SELECT Mifinal     
   
ENDSCAN

