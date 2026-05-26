
PUBLIC Mystring

Mystring = "DRIVER={MySQL ODBC 3.51 Driver};" + ;
                    "SERVER=192.168.1.79;" + ;
                    "PORT=3306;" + ;
                    "UID=sistemas;" + ;
                    "PWD=informatica;" + ;
                    "DATABASE=sqmdata;" + ;
                    "OPTIONS=0;"

LOCAL Hoy,Myreserva,Mynewsaldo,Pa1,Pa2,Myestado,Mycuenta
hoy=DATE()


pa1="02F0F3"
Mycliente="C004"
pa2=30

lnHandle = SQLSTRINGCONNECT(Mystring)
IF lnHandle > 0
        
       cmd1=SQLEXEC(lnHandle,"select a.id,a.producto,c.nombre,a.cantidad as reserva,a.despachado,a.cantidad-a.despachado as pendiente,b.fechaini,b.fechafin FROM "+;
    					     "detareservas a,reserva b,clientes c WHERE a.unico=b.id and b.cliente=c.codigo "+;
    					     "and b.fechafin>=?hoy and b.estado=1 and a.estado=1 and a.producto=?Pa1 and b.cliente=?Mycliente","Hayreserva")
       SELECT Hayreserva
       Mycuenta=RECCOUNT()					     
       IF Mycuenta>0
          Myid=Hayreserva.id
          Myreserva=Hayreserva.reserva
          Mynewsaldo=Hayreserva.despachado+Pa2
          Myestado=IIF(Mynewsaldo>=Myreserva,0,1)
          
          cmd2=SQLEXEC(lnHandle,"UPDATE detareservas SET despachado=?Mynewsaldo,estado=?Myestado WHERE id=?Myid")
          
       ENDIF 
     
 					  
    					                                              
    SQLDISCONNECT(lnHandle)    
    
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF

