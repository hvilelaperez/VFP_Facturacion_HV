
SET DELETED ON
SET DATE BRITISH
SET TALK OFF

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.179;" + ;
                    "PORT=3306;" + ;
                    "UID=sqmsistemas;" + ;
                    "PWD=t1s9m.2712;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"
                    
anio=2016
elmes=5

lnHandle = SQLSTRINGCONNECT(Mystring_ofi01)
IF lnHandle > 0
                                                       
    cmd1=SQLEXEC(lnHandle,"SELECT a.*,b.nombre AS nombrec,c.nombre AS nombrev FROM w_visitascliente a,clientes b,vendedores c "+;
                          "WHERE a.cod_cli=b.codigo AND a.cod_ven=c.codigo AND YEAR(fecha)=?anio AND MONTH(fecha)=?elmes ORDER BY cod_cli,fecha","Mydato")						  						  						      					       
    SQLDISCONNECT(lnHandle)        
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT Mydato
replace ALL observaciones WITH STRCONV(observaciones,11)

REPORT FORM  01detallevisitas TO PRINTER PROMPT NODIALOG PREVIEW
