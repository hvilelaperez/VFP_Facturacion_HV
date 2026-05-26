SET TALK OFF
SET ECHO OFF
SET FDOW TO 2
SET DELETED ON
SET DATE BRITISH
SET PROCEDURE TO funciones 

PUBLIC My60,My30

My60=DATE()-60
My30=DATE()-30
My90=DATE()-90
My180=DATE()-180
HoyMk=DATE()

Mystring_ofi01 = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0    
    cmd01=SQLEXEC(lnHandle,'call nucleoctacte(?HoyMk)')          				                                                                                                                                                                                                                                                                                
    SQLDISCONNECT(lnHandle)    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF


