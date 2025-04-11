SET DELETED ON
SET DATE BRITISH

OPEN DATABASE f:\newcompras\data\sqm.dbc SHARED

SELECT 0
USE f:\newcompras\data\productos shared

SELECT 0
USE f:\newcompras\data\proveedores shared

SELECT 0
USE f:\newcompras\data\tipoprodu shared


SELECT c.Nombre as Tipo,a.codigo,a.nombre,;
	   ROUND(((ROUND((iif(a.actprelocal,a.prelocal,((a.precioxlista+b.fletestandar)*b.factordes))),2))*(1+(a.factorgan/100))),2) as Pstock, ;    
	   ROUND(IIF(a.actprelocal,a.prelocal,((a.precioxlista+b.fletestandar)*b.factordes)),2) as Costo,;
	   a.factorgan,;	   
       IIF(b.fletestandar2=0,0,ROUND(iif(a.actprelocal,a.prelocal,((a.precioxlista+b.fletestandar2)*b.factordes)),2)) as Costo2;       
       FROM sqm!productos as a ;
       LEFT JOIN sqm!proveedores as b ON a.proveedor=b.codigo ;
       LEFT JOIN sqm!tipoprodu as c ON a.tipoproducto=c.codigo ; 
       WHERE a.activo=.t. AND (SUBSTR(a.codigo,1,2)="00" .OR. BETWEEN(VAL(SUBSTR(a.codigo,1,2)),1,12)) ;
       AND (SUBSTR(a.codigo,3,2)<>"X0" AND SUBSTR(a.codigo,3,2)<>"Y0" AND SUBSTR(a.codigo,3,2)<>"I0" AND ;
            SUBSTR(a.codigo,3,2)<>"10" AND SUBSTR(a.codigo,3,2)<>"40" AND SUBSTR(a.codigo,3,2)<>"Z0" AND ;
            SUBSTR(a.codigo,3,2)<>"W0" AND SUBSTR(a.codigo,3,2)<>"K0" AND SUBSTR(a.codigo,3,2)<>"30" );
       ORDER BY 2,1 INTO CURSOR listax
        

SELECT listax
BROWSE





*SELECT lista
*ZAP IN lista
*APPEND FROM DBF('listax')
*GO top
*USE IN listax


*SELECT Lista
* SCAN FOR factorgan=0
*    Replace Pstock WITH 0 
* ENDSCAN   
* GO top	


*IF Thisform.combo1.Value="F0"
*   Thisform.label2.Visible=.t.
*   Thisform.label3.Visible=.t.
*   Replace ALL Factor2 WITH Round(((Pstock/Costo2)-1)*100,0)  
*   GO top 
*ELSE
*   Thisform.label2.Visible=.f.
*   Thisform.label3.Visible=.f.
*ENDIF
   
*Thisform.grid1.Refresh  