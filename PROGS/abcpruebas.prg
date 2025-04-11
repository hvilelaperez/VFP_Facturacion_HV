
SET DELETED ON
SET DATE BRITISH



Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sqmsistemas;" + ;
                    "PWD=t1s9m.2712;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle > 0
                                                       
    cmd1=SQLEXEC(lnHandle," SELECT empresa,cliente FROM k_etiquetas ","MyDato")						      					       
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT CAST(empresa as c(90)) as empresa,CAST(cliente as c(90)) as cliente FROM mydato INTO CURSOR myyyy
SELECT myyyy
BROWSE












