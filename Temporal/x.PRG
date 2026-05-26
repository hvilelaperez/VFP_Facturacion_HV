SELECT usuarios
SCAN
	mVerCla= verclave(ALLTRIM(usuarios.Clave))
	Replace DesClave WITH mVerCla
ENDSCAN
