--nuevo
INSERT INTO us.balances (resID,usID,fecha,desc,monto,balance) 
VALUES (:resID,:usID,:fecha,:desc,ROUND(:monto,2),ROUND(:monto+COALESCE((SELECT balance FROM balances WHERE usID == :usID GROUP BY usID ORDER BY balID desc),0),2));
--nuevo_bal
UPDATE us.balances SET balance = monto+(SELECT balance FROM balances WHERE usID = :usID GROUP BY usID ORDER BY balID desc) WHERE balID = :balID
--balance_operador
select balID,usID,fecha,nombre desc,balance from balances 
	JOIN usuarios ON usuarios.usuarioID = ltrim(usID,"cu")
where resID = :rID GROUP BY usID
--balance_operador_us
select balID,usID,fecha,desc,monto,balance from balances 
where resID = :rID AND usID = :usID ORDER BY balID DESC
--balance_mio
select balID,usID,fecha,desc,monto,balance from balances 
where usID = :usID ORDER BY balID DESC LIMIT :lm
--balance_usID
select balID,usID,fecha,desc,monto,balance from balances 
where resID = :rID AND usID = :usID ORDER BY balID DESC LIMIT :lm
--balance_clientes_cm
select balID,usID,fecha,nombre desc,balance from balances 
	JOIN usuarios ON "u"||usuarios.usuarioID = usID
where resID = :usID GROUP BY usID
union
select balID,usID,fecha,nombre desc,balance from balances 
	JOIN bancas ON "g"||bancas.bancaID = usID
where resID = :usID GROUP BY usID
ORDER BY balance DESC