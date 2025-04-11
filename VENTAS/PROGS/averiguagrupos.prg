
SET DELETED ON
SET DATE TO BRITISH 



Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"




lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    
   
    
      cmd3=SQLEXEC(lnHandle,"select tipoproducto,colorindex,codigo,nombre from productos where activo=1 order by 1,2","Mydatito") 
  
                                             
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT Mydatito
REPORT FORM myclases NOCONSOLE TO PRINTER prompt

