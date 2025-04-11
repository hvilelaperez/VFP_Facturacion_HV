SET DELETED ON
SET DATE BRITISH


Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


CodAntiguo='14V0ZH'
CodNuevo='14V1ZA'



lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd2=SQLEXEC(lnHandle,"SELECT * FROM preciostockclientes where producto=?Codantiguo","Mybase")
                                
                                             
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT Mybase
GO top
lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    SCAN 
      a1=cliente      
      a3=um
      a4=fechaingreso
      a5=precio
      a6=moneda
      a7=fechamodifi
      a8=activoespecial
      a9=precioespecial
      a10=fechaprecioesp
      a11=ultimacompra
      a12=masivo
      a13=idcotiespecial
    
    
     ** cmd2=SQLEXEC(lnHandle,"insert into preciostockclientes (cliente,producto,um,fechaingreso,precio,moneda,"+;
                            " fechamodifi,activoespecial,precioespecial,fechaprecioesp, "+;
                            " ultimacompra,masivo,idcotiespecial) values (?a1,?codNuevo,?a3,?a4,?a5,?a6,?a7,?a8,?a9,?a10,?a11,?a12,?a13)")                                 
    ENDSCAN 
                                             
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF




