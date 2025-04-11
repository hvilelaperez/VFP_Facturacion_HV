SET DELETED ON
SET DATE BRITISH
SET TALK OFF



Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"


lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0

    cmd2=SQLEXEC(lnHandle,"select * from preciostockclientes where cliente='N001' and precio>0","Midata")
                             
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


SELECT midata
replace ALL cliente WITH "P047"
GO top
 

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
  
   SCAN FOR SUBSTR(ALLTRIM(producto),1,2)="10"
       a1=cliente
       a2=producto
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
       
      ****cmd2=SQLEXEC(lnHandle,"insert into preciostockclientes (cliente,producto,um,fechaingreso,precio,moneda,"+;
                          "fechamodifi,activoespecial,precioespecial,fechaprecioesp,ultimacompra,masivo) "+;
                          " values (?a1,?a2,?a3,?a4,?a5,?a6,?a7,?a8,?a9,?a10,?a11,?a12)")
                          
   ENDSCAN 
                             
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF



