--nuevo
INSERT INTO us.balances (resID,usID,fecha,desc,monto,balance,confirmado,tiempo) 
VALUES (:resID,:usID,:fecha,:desc,ROUND(:monto,2),ROUND(:monto+COALESCE((SELECT ROUND(balance,2) balance FROM balances WHERE usID = :usID ORDER BY tiempo desc LIMIT 1),0),2),:cdo,:tiempo);
--nuevo_pago
INSERT INTO us.balances (resID,usID,fecha,desc,monto,balance,confirmado,tiempo) 
VALUES (:resID,:usID,:fecha,:desc,ROUND(:monto,2),null,0,:tiempo);
--nuevo_bal
UPDATE us.balances SET balance = monto+(SELECT balance FROM balances WHERE usID = :usID GROUP BY usID ORDER BY tiempo desc) WHERE balID = :balID
--remover_balance
DELETE FROM balances WHERE balID = (SELECT balID FROM balances WHERE resID = :rID and usID = :usID ORDER BY tiempo desc LIMIT 1);
--remover_pendiente
DELETE FROM balances WHERE balID = :bID AND resID = :rID AND confirmado = 0;
--balance_operador
SELECT activo,balID,usID,fecha,desc,balance FROM (
	select activo,tiempo,balID,usID,fecha,nombre desc,balance from balances 
		JOIN usuarios ON usuarios.usuarioID = ltrim(usID,"cu") 
	where resID = :rID AND confirmado = 1 ORDER BY tiempo asc
) GROUP BY usID ORDER BY tiempo desc
--balance_operador_us
select balID,usID,fecha,desc,monto,balance from balances 
where resID = :rID AND usID = :usID AND confirmado = 1
ORDER BY tiempo DESC
--balance_mio
select balID,usID,resID,fecha,desc,monto,balance,confirmado c from balances 
where usID = :usID
ORDER BY tiempo DESC LIMIT :lm
--balance_usID
select balID,usID,resID,fecha,desc,monto,balance,confirmado c from balances 
where resID = :rID AND usID = :usID AND confirmado = 1 ORDER BY tiempo DESC LIMIT :lm
--balance_clientes_cm
SELECT activo,usID,fecha,desc,balance FROM (
	SELECT * FROM (
		SELECT activo,tiempo,balID,usID,fecha,nombre desc,round(balance,2) balance FROM balances 
		  JOIN usuarios ON "u"||usuarios.usuarioID = usID
		WHERE resID = :usID AND confirmado = 1 ORDER BY tiempo ASC)
	GROUP BY usID
	UNION
	SELECT * FROM (
		SELECT activa activo,tiempo,balID,usID,fecha,nombre desc,round(balance,2) balance FROM balances 
		  JOIN bancas ON "g"||bancas.bancaID = usID
		WHERE resID = :usID AND confirmado = 1 ORDER BY tiempo ASC)
	GROUP BY usID
) ORDER BY tiempo DESC
--balance_pagos_operador
select balID,usID,fecha,nombre,desc,abs(monto) monto from balances
	JOIN usuarios ON usuarios.usuarioID = ltrim(usID,"cu")
where monto < 0 and fecha between :inicio and :fin and resID = :rID AND confirmado = :c ORDER BY tiempo DESC
--balance_pagos_comer
SELECT balID,usID,fecha,nombre,desc,abs(monto) monto FROM (
select balID,usID,fecha,nombre,desc,abs(monto) monto,tiempo from balances
	JOIN usuarios ON "u"||usuarios.usuarioID = usID
where monto < 0 and fecha between :inicio and :fin and resID = :rID AND confirmado = :c
union
select balID,usID,fecha,nombre,desc,abs(monto) monto,tiempo from balances
	JOIN bancas ON "g"||bancas.bancaID = usID
where monto < 0 and fecha between :inicio and :fin and resID = :rID AND confirmado = :c
) ORDER BY tiempo DESC
--confirmar_pago
UPDATE balances SET confirmado = 1, monto = :monto, balance = (SELECT balance FROM balances WHERE usID == :usID AND confirmado = 1 ORDER BY tiempo desc LIMIT 1)-abs(:monto), tiempo = :tiempo 
WHERE balID = :bID AND resID = :rID;
--autoSuspension
SELECT *,hoy - ultPago diff FROM suspender
JOIN (SELECT usID,balance,
	  CAST(strftime('%Y%m%d', tiempo / 1000, 'unixepoch','localtime') AS INTEGER) ultPago,
	  CAST(STRFTIME('%Y%m%d', 'now') AS INTEGER) hoy
	  FROM balances WHERE confirmado = 1 GROUP BY usID ORDER BY tiempo asc) as bal 
ON suspender.sID = bal.usID
WHERE diff >= limite and balance > minmonto
--usuario_suspendido
SELECT * FROM suspender
JOIN (SELECT usID,balance,tiempo FROM balances WHERE confirmado = 1 GROUP BY usID ORDER BY tiempo asc) as bal 
ON suspender.sID = bal.usID WHERE usID = :usID