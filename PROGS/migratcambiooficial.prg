
SET DELETED ON
SET DATE TO BRITISH 



Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"




SELECT 0
USE f:\comercio\files\tcmpquim SHARED

SELECT tcmpdfec as fecha,tcmpveno as venta,tcmpcomo as compra FROM tcmpquim WHERE YEAR(tcmpdfec)>=2008 ORDER BY 1 INTO CURSOR mientras

SELECT tcmpquim
USE 


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
    SELECT mientras
    GO top
    SCAN 
     av1=fecha
     av2=venta
     av3=compra
    
      cmd3=SQLEXEC(lnHandle,"INSERT INTO tcoficial (fecha,venta,compra) values (?av1,?av2,?av3)" ) 
            
    ENDSCAN 
                                             
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


&& codigo Mysql para grabar direcciones pasadas

** UPDATE guiasremision,direcciones SET guiasremision.ptollegada=direcciones.unico
*      WHERE guiasremision.cliente=direcciones.cliente and year(fecha)>2008