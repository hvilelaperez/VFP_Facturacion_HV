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

    cmd2=SQLEXEC(lnHandle,"SELECT a.anio,a.correlativo,a.fecha,b.nombre,a.codreferencia,a.vcmtopdirecto,a.fobpedido,a.acumdespachos "+;
                          " FROM cotizaciones a, clientes b where a.cliente=b.codigo and a.especialactiva=1 and a.anulada<>1","Prueba")    
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT prueba
GO top
SCAN FOR codreferencia=4  && dando 30 dias a las cotis por unica vez
     replace vcmtopdirecto WITH fecha+30
ENDSCAN 


SELECT anio,correlativo,fecha,CAST(nombre as c(45)) as nombre,IIF(codreferencia=4,"Pre. Unica Vez","Pedido Directo") as Tipo,;
       vcmtopdirecto,vcmtopdirecto+7 as Real,fobpedido,acumdespachos FROM prueba  ORDER BY real INTO CURSOR final
       
SELECT final
BROWSE 
       


  



