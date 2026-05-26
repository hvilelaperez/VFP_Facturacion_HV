SET DELETED ON
SET DATE BRITISH


PUBLIC Mystring,My60,My30

My60=DATE()-60
My30=DATE()-30


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
    cmd0=SQLEXEC(lnHandle,"SELECT producto,SUM(qsaldov) as saldo FROM vtalotes WHERE qsaldov>0 group by 1 ","Unico")
    
    cmd1=SQLEXEC(lnHandle,"SELECT b.codigo,b.tipoproducto,b.nombre,"+;
    					  " c.nombre as Tnombre,b.um FROM "+;
                          " productos b,tipoproductos c WHERE  b.tipoproducto=c.codigo  order by 1","Mistock")
  
                                             
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

SELECT a.*,b.saldo FROM mistock as a  ;
       LEFT JOIN unico as b ON a.codigo=b.producto INTO CURSOR  resultado readwrite

SELECT Resultado
DELETE FOR ISNULL(saldo)
GO top

SET REPORTBEHAVIOR 80   
REPORT FORM infostock2  PREVIEW 
REPORT FORM infostock2  NOCONSOLE TO PRINTER PROMPT 
