SET DELETED ON
SET DATE BRITISH

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

DIMENSION Milista(14) as Character 

Milista(1)='C067'
Milista(2)='A066'
Milista(3)='JJ03'
Milista(4)='C028'
Milista(5)='T003'
Milista(6)='T060'
Milista(7)='S008'
Milista(8)='M001'
Milista(9)='C063'
Milista(10)='J034'
Milista(11)='L030'
Milista(12)='L098'
Milista(13)='P046'
Milista(14)='T004'

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
    FOR i=1 TO 14 
    
      a1=Milista(i)      
      a2='01W0P0'
      a3='KG'
      a4=CTOD('11/11/2009')
      a5=8.25
      a6='M2'
        
     **** cmd2=SQLEXEC(lnHandle,"INSERT INTO preciostockclientes (cliente,producto,um,fechaingreso,precio,moneda) "+;                            
                            "  VALUES (?a1,?a2,?a3,?a4,?a5,?a6) ")
    ENDFOR  
                                             
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF
