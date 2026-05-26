SET DELETED ON
SET DATE BRITISH

PUBLIC Mystring 
Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd2=SQLEXEC(lnHandle," SELECT a.unico as ncunico,a.tipo,a.serie,a.numero,a.fecha,a.codigoc,a.serief,a.numerof,b.unico,"+;
    					  " c.producto,c.cantidad,c.um,c.id,c.precio,c.subtotal "+;
                          " FROM ncredito a,factura b,detafacturas c WHERE a.serief=b.serie and a.numerof=b.numero "+;
                          " and b.unico=c.unico and a.tipo=9 and "+;
                          " a.estado<>'AN' AND a.fecha >='2009-10-01' order by a.serie, a.numero,c.producto ","Revisa")
                                                 
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT revisa
GO top
BROWSE  


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
  SCAN 
    a1=ncunico
    a2=producto
    a3=unico
    a4=cantidad
    a5=um
    a6=precio
    a7=subtotal  
    a8=id
    
   **** cmd2=SQLEXEC(lnHandle,"insert into detallencredito (unico,producto,unicoorigen,cantorigen,cantaplicada,um,"+;
                          "precioorigen,subtotal,idorigen) values (?a1,?a2,?a3,?a4,?a4,?a5,?a6,?a7,?a8)")                          
  ENDSCAN 
                                                 
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF





