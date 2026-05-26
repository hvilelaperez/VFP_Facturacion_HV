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
    
    cmd1=SQLEXEC(lnHandle,"SELECT b.tipoproducto,b.nombre,a.producto AS Codigo,a.origen ,a.qsaldov as Saldo,"+;
    					  " a.fingreso,a.lotefab,c.nombre as Tnombre, a.qexterno FROM vtalotes a, "+;
                          " productos b,tipoproductos c WHERE a.producto=b.codigo and "+;
                          "b.tipoproducto=c.codigo and a.qsaldov>0 and a.ubicacion<>'P' order by 1,3,6","Mistock")
  
                                             
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT Mistock
SET REPORTBEHAVIOR 80
REPORT FORM infostock FOR tipoproducto="00" OR BETWEEN(VAL(tipoproducto),1,12) PREVIEW 
REPORT FORM infostock FOR tipoproducto="00" OR BETWEEN(VAL(tipoproducto),1,12) NOCONSOLE TO PRINTER PROMPT 
