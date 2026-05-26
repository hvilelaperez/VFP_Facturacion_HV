
SET DELETED ON
SET DATE BRITISH
LOCAL Mystring_ofi01,fini,ffin


Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=d3b14nfw123;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
OPEN DATABASE f:\newcompras\data\sqm.dbc SHARED
SELECT 0
USE f:\newcompras\data\productos.dbf SHARED
                    


lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0
    cmd1=SQLEXEC(lnHandle,"SELECT * FROM productos Where tipoproducto='14' and proveedor='C0'","MyDat")
                          
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF    
         

SELECT MyDat
GO top
SCAN
  a1=ALLTRIM(Mydat.codigo)
  b1=STRCONV(Mydat.nombre,11)
  SELECT productos
  GO top
  LOCATE FOR ALLTRIM(productos.codigo)=a1
  IF FOUND()
     replace productos.nombre WITH b1
  ENDIF 
  SELECT Mydat   
ENDSCAN

