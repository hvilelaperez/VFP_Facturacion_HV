
SET DELETED ON
SET DATE BRITISH
SET TALK OFF

LOCAL a1,a2,a3,a4

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=d3b14nfw123;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle > 0                                                       
    cmd1=SQLEXEC(lnHandle,"SELECT id,producto FROM vtalotes WHERE tipoorigen='Y' AND costo=0 AND YEAR(fingreso)=2016","Midato")				  						      					       
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Midato
lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle > 0
      
	SCAN
	  a1=Midato.id
	  a2=Midato.producto	 	 
	  cmd1=SQLEXEC(lnHandle,"SELECT costo FROM vtalotes WHERE producto=?a2 AND costo>0 ORDER BY fingreso DESC LIMIT 1","Mydetalle")
	  SELECT Mydetalle
	  a3=RECCOUNT()
	  IF a3>0
	     a4=Mydetalle.costo
	     SELECT Midato
	     ***cmd1=SQLEXEC(lnHandle,"UPDATE vtalotes SET costo=?a4 WHERE id=?a1")
	  ENDIF 
	  SELECT Midato
	ENDSCAN                                                   
       				  						      					       
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF



 
