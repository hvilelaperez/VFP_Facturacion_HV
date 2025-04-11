lnHandle = SQLSTRINGCONNECT(MyString_ofi01)
IF lnHandle > 0    
    cmd1=SQLEXEC(lnHandle,"SELECT b.tipoproducto,b.nombre,a.producto AS Codigo,a.origen,a.qsaldov,a.qsaldov-a.qexterno as saldo,a.qexterno,a.fingreso,"+;
                          "a.lotefab,c.nombre as Tnombre,a.costo,a.ubicacion,c.escolorante FROM vtalotes a,"+;
                          " productos b,tipoproductos c WHERE a.producto=b.codigo and b.tipoproducto=c.codigo and a.qsaldov>0 order by 1,3,6","Mistock")                                               
    SQLDISCONNECT(lnHandle)
ELSE
    AERROR(laErr)
    MESSAGEBOX("No se pudo conectar a mySQL. Error: " + CHR(13) + laErr[2])
ENDIF
BROWSE
