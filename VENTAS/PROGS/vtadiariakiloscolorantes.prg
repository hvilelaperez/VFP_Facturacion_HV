
SET DELETED ON
SET DATE TO BRITISH 

LOCAL dat1,dat2

dat1=CTOD("01/01/2009")
dat2=CTOD("22/05/2009")

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
         
      cmd3=SQLEXEC(lnHandle,"SELECT a.producto,a.cantidad,b.fecha  FROM detaguiasremision a,guiasremision b WHERE a.unico=b.unico and "+;
                            "b.anulada<>1 and b.fecha between ?dat1 and ?dat2 order by 3","Mydatito")            
                                                
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT Mydatito
GO top
SCAN
  IF SUBSTR(Mydatito.producto,1,2)="00" OR BETWEEN(VAL(SUBSTR(Mydatito.producto,1,2)),1,12)
     && se salvan
  ELSE 
     DELETE
  ENDIF
ENDSCAN 
GO top


SELECT fecha,SUM(cantidad) as Kilos FROM Mydatito GROUP BY 1 order BY 1 INTO CURSOR resumen

SELECT resumen
BROWSE













  
        
