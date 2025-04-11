
** unico de mastersalida enlaza con contrapartida de masteringresos ***

*SELECT id,unico,fecha,codtipo,CONCAT( DATE_FORMAT(fecha, '%d%m%Y') ,@rownum:=@rownum+1 ) AS ref 
*FROM (SELECT @rownum:=0)r,mastersalidas 
*WHERE codtipo='F' AND YEAR(fecha)=2012 AND MONTH(fecha)=10 ORDER BY id


*SELECT id,fecha,tipo,CONCAT( DATE_FORMAT(fecha, '%d%m%Y') ,@rownum:=@rownum+1 ) AS ref 
*FROM (SELECT @rownum:=0)r,masteringresos 
*WHERE tipo='F' AND YEAR(fecha)=2012 AND MONTH(fecha)=10 ORDER BY id