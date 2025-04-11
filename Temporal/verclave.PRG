LPARAMETERS mClave
mClave = ALLTRIM(mClave)
mPos = 1
mCadena=""
DO WHILE mPos < LEN(mClave)
   mCadena = mCadena+ CHR((VAL(SUBSTR(mClave, mPos, 3))-2)/3)
   mPos = mPos + 3
ENDDO
RETURN ALLTRIM(mCadena)