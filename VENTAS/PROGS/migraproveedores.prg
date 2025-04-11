
SET DELETED ON
SET DATE TO BRITISH 



Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


OPEN DATABASE c:\newcompras\data\sqm.dbc SHARED

SELECT 0
USE c:\newcompras\data\proveedores SHARED 


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
    SELECT proveedores
    SCAN 
     av1=codigo
     av2=nombre
    
    
     ***** cmd3=SQLEXEC(lnHandle,"INSERT INTO proveedores (codigo,nombre) values (?av1,?av2)" ) 
            
    ENDSCAN 
                                             
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


&& codigo Mysql para grabar direcciones pasadas

** UPDATE guiasremision,direcciones SET guiasremision.ptollegada=direcciones.unico
*      WHERE guiasremision.cliente=direcciones.cliente and year(fecha)>2008