SET DELETED ON
SET DATE BRITISH

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=d3b14nfw123;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
                    
                    
lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle > 0    
    cmd1=SQLEXEC(lnHandle,"SELECT id,origen,producto,lotefab FROM vtalotes WHERE tipoorigen='Y' AND YEAR(fingreso)='2015'","Mydata")                                              
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF                    

SELECT id,producto,origen,lotefab,CAST(0 as n(7,0)) as id_0,CAST('' as c(11)) as origen_0,CAST(0 as n(7,2)) as costo_0 FROM Mydata INTO CURSOR  Mydata1 READWRITE 

SELECT Mydata1
lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle > 0
    SCAN
        a1=ALLTRIM(Mydata1.producto)
        a2=ALLTRIM(Mydata1.lotefab)
        
   		cmd1=SQLEXEC(lnHandle,"SELECT id,origen,costo FROM vtalotes WHERE tipoorigen<>'Y' AND costo>0 and TRIM(producto)=?a1 and TRIM(lotefab)=?a2 "+;
   		                      "ORDER BY fingreso DESC LIMIT 1","MydataR")           
	    SELECT MydataR
	    
	    IF RECCOUNT()>0
	       b1=MydataR.id
	       b2=MydataR.origen
	       b3=MydataR.costo
	       SELECT Mydata1
	       replace id_0 WITH b1
	       replace origen_0 WITH b2
	       replace costo_0 WITH b3
	    ENDIF 
	    SELECT Mydata1
	    
     ENDSCAN 
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF      		

   		
SELECT Mydata1
GO TOP
lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle > 0
	SCAN
	  z1=Mydata1.id
	  z2=Mydata1.costo_0
  
      ***cmd1=SQLEXEC(lnHandle,"UPDATE vtalotes set costo=?z2 WHERE id=?z1 ")
    ENDSCAN
          
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF 
  
  


