

SET TALK OFF
SET ECHO OFF
SET DELETED ON
SET DATE BRITISH


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


Mycod="0930M0"
Myidsqm="09M01"

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd2=SQLEXEC(lnHandle,"SELECT a.cliente,a.producto,a.um,a.moneda,a.precio,a.fechamodifi,b.idsqm FROM preciostockclientes a,"+;    
                          " productos b WHERE a.producto=b.codigo and b.idsqm=?Myidsqm order by 1,6,2 ","Mydata") 
                                                                               
   SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT * FROM Mydata INTO CURSOR MydataMirror

SELECT Mydatamirror
GO top
SCAN FOR ALLTRIM(producto)=Mycod
         as=ALLTRIM(cliente)
         SELECT Mydata
         DELETE ALL FOR cliente=as
         SELECT Mydatamirror
ENDSCAN 

SELECT MAX(fechamodifi) as Maxi,cliente FROM Mydata GROUP BY 2 INTO CURSOR alfa

SELECT distinct a.maxi,a.cliente,b.precio,b.um,b.moneda FROM alfa as a LEFT JOIN Mydata as b;
       ON a.maxi=b.fechamodifi AND a.cliente=b.cliente ORDER BY 2 INTO CURSOR lasting
       



lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
   SELECT lasting
   GO top
   SCAN       
      a1=lasting.cliente
      a2=DATE()
      a3=lasting.precio
      a4=lasting.um
      a5=lasting.moneda      
          
     * cmd2=SQLEXEC(lnHandle,"INSERT INTO preciostockclientes (cliente,producto,um,fechaingreso,precio,moneda,fechamodifi) "+;
                            " values (?a1,?Mycod,?a4,?a2,?a3,?a5,?a2) ")
                          
   ENDSCAN 
                                                                               
   SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

