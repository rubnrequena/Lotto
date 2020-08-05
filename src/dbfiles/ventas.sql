--venta
INSERT INTO "temp"."ch_ticket" (ticketID,taquillaID,bancaID,tiempo,monto,anulado,codigo) VALUES (:ticketID, :taquillaID,:bancaID,:tiempo,:monto,0,:codigo);
--venta_elemento
INSERT INTO "temp"."ch_elementos" (ticketID,sorteoID,numero,monto,premio,taquillaID,bancaID) VALUES (:ticketID,:sorteoID,:numero,:monto,0,:taquillaID,:bancaID)
--ventas_elemento_sorteos_taquilla
SELECT ch_elementos.sorteoID, ch_elementos.numero, SUM( ch_elementos.monto) monto FROM "temp"."ch_ticket" 
JOIN "temp"."ch_elementos" ON ch_ticket.ticketID = ch_elementos.ticketID 
JOIN vt.sorteos ON sorteos.sorteoID = ch_elementos.sorteoID 
WHERE ch_ticket.anulado = 0 AND sorteos.fecha = :fecha AND ch_ticket.taquillaID = :taquillaID 
GROUP BY ch_elementos.numero, ch_elementos.sorteoID ORDER BY ch_elementos.sorteoID, ch_elementos.numero
--ventas_elemento_sorteos_banca
SELECT ch_elementos.sorteoID, ch_elementos.numero, SUM( ch_elementos.monto) monto FROM "temp"."ch_ticket" 
JOIN "temp"."ch_elementos" ON ch_ticket.ticketID = ch_elementos.ticketID 
JOIN vt.sorteos ON sorteos.sorteoID = ch_elementos.sorteoID 
WHERE ch_ticket.anulado = 0 AND sorteos.fecha = :fecha AND ch_ticket.bancaID = :bancaID 
GROUP BY ch_elementos.numero, ch_elementos.sorteoID ORDER BY ch_elementos.sorteoID, ch_elementos.numero
--ventas_elemento_sorteos_usuario
SELECT ch_elementos.sorteoID, ch_elementos.numero, SUM( ch_elementos.monto) monto FROM "temp"."ch_ticket" 
JOIN us.taquillas ON taquillas.taquillaID = ch_ticket.taquillaID 
JOIN "temp"."ch_elementos" ON ch_ticket.ticketID = ch_elementos.ticketID 
JOIN vt.sorteos ON sorteos.sorteoID = ch_elementos.sorteoID 
WHERE ch_ticket.anulado = 0 AND sorteos.fecha = :fecha AND taquillas.usuarioID = :usuarioID 
GROUP BY ch_elementos.numero, ch_elementos.sorteoID ORDER BY ch_elementos.sorteoID, ch_elementos.numero
--ventas_elementos_ticketID
SELECT cierra, sorteos.sorteoID, numero, monto FROM "temp"."ch_elementos" 
JOIN vt.sorteos ON sorteos.sorteoID = ch_elementos.sorteoID 
WHERE ticketID = :ticket
--ventas_elementos_ventaID
SELECT * FROM vt.elementos WHERE ventaID = :ventaID
--reporte_gen_upd_pago
UPDATE reportes SET pago = pago+:pago WHERE taquillaID = :taquillaID AND sorteoID = :sorteoID
--anular
INSERT INTO vt.anulados (ticketID,tiempo) VALUES (:ticketID,:tiempo)
--anulado
SELECT * FROM anulados WHERE ticketID = :ticketID
--remover_taq
DELETE FROM vt.ticket WHERE taquillaID = :taquillaID
--anular_ticket_cache
UPDATE ch_ticket SET anulado = 1 WHERE ticketID = :ticketID
--anular_elemento_cache
UPDATE ch_elementos SET anulado = 1 WHERE ventaID = :ventaID
--anular_elementos
UPDATE vt.elementos SET anulado = 1 WHERE ticketID = :ticketID
--pagar
INSERT INTO vt.pagos (ventaID, ticketID, tiempo) VALUES (:id, :tk, :tiempo)
--ticket
SELECT usuarioID, ticketID, ticket.taquillaID, ticket.bancaID, monto, anulado, tiempo FROM vt.ticket 
JOIN us.taquillas ON taquillas.taquillaID = ticket.taquillaID WHERE ticketID = :ticketID
--ticket_codigo
SELECT usuarioID, codigo, ticketID, ticket.taquillaID, ticket.bancaID, monto, anulado, tiempo FROM vt.ticket 
JOIN us.taquillas ON taquillas.taquillaID = ticket.taquillaID 
WHERE ticketID = :ticketID AND codigo = :codigo
--ticket_animales
SELECT * FROM vt.elementos WHERE ticketID = :ticketID
--ticket_premios
SELECT elementos.ventaID ventaID, elementos.ticketID ticketID, elementos.sorteoID sorteoID, sorteos.descripcion sorteo, numero, monto, premio, tiempo pago FROM vt.elementos 
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE elementos.ticketID = :ticketID AND premio > 0
--tickets_taquilla
SELECT * FROM vt.ticket WHERE taquillaID = :taquillaID
--tickets_ultimo
SELECT * FROM vt.ticket WHERE taquillaID = :ultimo AND anulado = 0 ORDER BY ticketID DESC LIMIT 1
--premiar
UPDATE vt.sorteos SET ganador = :numero WHERE sorteoID = :sorteoID
--premiar_ventas
UPDATE vt.elementos SET premio = (monto*:premio) WHERE ventaID = :ventaID AND anulado = 0
--premiar_ventas_temp
UPDATE "temp"."ch_elementos" SET premio = (monto*:premio) WHERE ventaID = :ventaID AND anulado = 0
--premiar_reinicio
UPDATE vt.elementos SET premio = 0 WHERE sorteoID = :sorteoID
--premiar_reinicio_temp
UPDATE "temp"."ch_elementos" SET premio = 0 WHERE sorteoID = :sorteoID
--premiar_ventas_v2
UPDATE elementos SET premio = :paga * monto WHERE sorteoID = :sorteoID and bancaID = :bancaID and numero = :numero AND anulado = 0
--premiar_ventas_v2_temp
UPDATE "temp"."ch_elementos" SET premio = :paga * monto WHERE sorteoID = :sorteoID and bancaID = :bancaID and numero = :numero AND anulado = 0
--premiar_ventas_v2_all
UPDATE elementos SET premio = :paga * monto WHERE sorteoID = :sorteoID and numero = :numero AND anulado = 0
--premiar_ventas_v2_alltemp
UPDATE "temp"."ch_elementos" SET premio = :paga * monto WHERE sorteoID = :sorteoID and numero = :numero AND anulado = 0
--premiar_bancas
SELECT bancaID FROM "vt"."elementos" WHERE sorteoID = :sorteoID GROUP BY bancaID
--premiar_bancas_temp
SELECT bancaID FROM "temp"."ch_elementos" WHERE sorteoID = :sorteoID GROUP BY bancaID
--tickets_premiados
SELECT elementos.ventaID, ticket.taquillaID, ticket.bancaID, elementos.monto, premio FROM vt.elementos 
JOIN vt.ticket ON ticket.ticketID = elementos.ticketID 
WHERE sorteoID = :sorteoID AND numero = :numero
--tickets_premiados_ram
SELECT ch_elementos.ventaID, ch_ticket.taquillaID, ch_ticket.bancaID, ch_elementos.monto, premio FROM "temp"."ch_elementos" 
JOIN "temp"."ch_ticket" ON ch_ticket.ticketID = ch_elementos.ticketID WHERE sorteoID = :sorteoID AND numero = :numero
--ventas_elemento_sorteos
SELECT elementos.sorteoID, elementos.numero, SUM( elementos.monto) jugado FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID 
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
WHERE ticket.anulado = 0 AND sorteos.fecha = :fecha 
GROUP BY elementos.numero, elementos.sorteoID ORDER BY elementos.sorteoID, elementos.numero
--ventas_elementos_ticket
SELECT elementos.ventaID, elementos.ticketID, sorteos.sorteoID, elementos.numero num, sorteos.descripcion sorteo, numeros.numero, numeros.descripcion, monto, premio, tiempo pago 
FROM vt.elementos 
JOIN numeros ON elementos.numero = numeros.elementoID 
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE elementos.ticketID = :ticketID
--ventas_elementos_repetir
SELECT sorteoID, numero, monto FROM vt.elementos WHERE elementos.ticketID = :ticketID
--reporte_nuevo
INSERT INTO reportes (fecha,sorteoID,bancaID,taquillaID,jugada,premio,comisionBanca, partBanca, comision) 
SELECT sorteos.fecha, sorteos.sorteoID, elementos.bancaID, elementos.taquillaID, ROUND(SUM(monto),2) jugado, ROUND(SUM(premio),2) premio, bancas.comision comisionBanca, bancas.participacion partBanca,
COALESCE((SELECT comision FROM taquillas_comision WHERE 
  sorteo = sorteos.sorteo  AND 
	(taquillaID = taquillas.taquillaID OR taquillaID = 0) AND 
	(grupoID = taquillas.bancaID OR grupoID = 0) AND 
	(bancaID = taquillas.usuarioID)
  ORDER BY grupoID ASC, taquillaID ASC  LIMIT 1),taquillas.comision) comision
FROM elementos 
	JOIN numeros ON elementos.numero = numeros.elementoID 
	JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
	JOIN us.taquillas ON taquillas.taquillaID = elementos.taquillaID 
	JOIN us.bancas ON bancas.bancaID = elementos.bancaID 
WHERE elementos.sorteoID = :sorteoID AND elementos.anulado = 0 
GROUP BY elementos.taquillaID
ORDER BY elementos.bancaID ASC, elementos.taquillaID ASC
--verificar_jugada_premiar
SELECT COUNT(*) n FROM vt.elementos WHERE sorteoID = :sorteoID
--jugadas_srv_banca
SELECT usuarios.nombre banca, ROUND(SUM(elementos.monto),2) jugada  FROM vt.elementos 
JOIN vt.ticket ON ticket.ticketID = elementos.ticketID JOIN us.taquillas ON taquillas.taquillaID = ticket.taquillaID JOIN us.usuarios ON usuarios.usuarioID = taquillas.usuarioID 
WHERE elementos.anulado = 0 AND sorteoID = :sorteoID 
GROUP BY taquillas.usuarioID ORDER BY jugada DESC
--jugadas_srv_num
SELECT (SELECT fecha FROM vt.sorteos WHERE ganador = numeros.elementoID AND sorteo = sorteos.sorteo ORDER BY cierra DESC LIMIT 1) ultimoPremio,
  numeros.elementoID n, numeros.numero, numeros.descripcion desc, jugada, n tickets, ROUND(jugada*relacion_pago.valor,2) premios FROM 
  (SELECT numero, ROUND(sum(jugada),2) jugada, count(numero) n, sorteoID FROM
  (SELECT numero, ROUND(monto,2) jugada, ticketID, sorteoID  FROM vt.elementos WHERE sorteoID = :sorteoID and anulado = false)
GROUP BY numero) tn
JOIN numeros ON numeros.elementoID = tn.numero
JOIN vt.sorteos ON sorteos.sorteoID = tn.sorteoID
CROSS JOIN us.relacion_pago ON relacion_pago.sorteo = sorteos.sorteo AND bancaID = 0
--jugadas_banca_taq
SELECT taquillas.nombre banca, ROUND(SUM(elementos.monto),2) jugada  FROM vt.elementos 
JOIN vt.ticket ON ticket.ticketID = elementos.ticketID JOIN us.taquillas ON taquillas.taquillaID = ticket.taquillaID 
WHERE elementos.anulado = 0 AND sorteoID = :sorteoID AND ticket.bancaID = :bancaID 
GROUP BY ticket.taquillaID ORDER BY ticket.taquillaID
--jugadas_banca_num
SELECT numeros.numero numero, numeros.descripcion desc, SUM(elementos.monto) jugada, g.glb FROM vt.elementos JOIN vt.ticket ON ticket.ticketID = elementos.ticketID JOIN numeros ON numeros.elementoID = elementos.numero JOIN (SELECT numeros.numero, SUM(elementos.monto) glb FROM vt.elementos JOIN vt.ticket ON ticket.ticketID = elementos.ticketID JOIN numeros ON numeros.elementoID = elementos.numero WHERE elementos.anulado = 0 AND sorteoID = :sorteoID GROUP BY elementos.numero ORDER BY elementos.numero) as g ON g.numero = numeros.numero WHERE elementos.anulado = 0 AND sorteoID = :sorteoID AND ticket.bancaID = :bancaID GROUP BY elementos.numero ORDER BY elementos.numero
--jugadas_usuario_bnc
SELECT bancas.nombre banca, SUM(elementos.monto) jugada  FROM vt.elementos JOIN vt.ticket ON ticket.ticketID = elementos.ticketID JOIN us.bancas ON bancas.bancaID = ticket.bancaID WHERE elementos.anulado = 0 AND sorteoID = :sorteoID AND bancas.usuarioID = :usuarioID GROUP BY ticket.bancaID ORDER BY ticket.bancaID
--jugadas_usuario_num
SELECT numeros.numero numero, numeros.descripcion desc, SUM(elementos.monto) jugada, g.glb FROM vt.elementos JOIN vt.ticket ON ticket.ticketID = elementos.ticketID JOIN numeros ON numeros.elementoID = elementos.numero JOIN (SELECT numeros.numero, SUM(elementos.monto) glb FROM vt.elementos JOIN vt.ticket ON ticket.ticketID = elementos.ticketID JOIN numeros ON numeros.elementoID = elementos.numero WHERE elementos.anulado = 0 AND sorteoID = :sorteoID GROUP BY elementos.numero ORDER BY elementos.numero) as g ON g.numero = numeros.numero JOIN us.bancas ON bancas.bancaID = ticket.bancaID WHERE elementos.anulado = 0 AND sorteoID = :sorteoID AND bancas.usuarioID = :usuarioID GROUP BY elementos.numero ORDER BY elementos.numero

--jugadas_comercial_bnc
SELECT cID, usuarioID, bancas.nombre banca, SUM(elementos.monto) jugada FROM vt.elementos 
	JOIN vt.ticket ON ticket.ticketID = elementos.ticketID 
	JOIN us.bancas ON bancas.bancaID = ticket.bancaID 
	JOIN us.comer_usuario ON usuarioID = comer_usuario.uID
WHERE elementos.anulado = 0 AND sorteoID = :sorteoID AND cID = :comercialID
--jugadas_comercial_num
SELECT usuarioID, numeros.numero numero, numeros.descripcion desc, SUM(elementos.monto) jugada, g.glb FROM vt.elementos 
  JOIN vt.ticket ON ticket.ticketID = elementos.ticketID 
  JOIN numeros ON numeros.elementoID = elementos.numero 
  JOIN us.comer_usuario ON usuarioID = comer_usuario.uID
  JOIN (
    SELECT numeros.numero, SUM(elementos.monto) glb FROM vt.elementos 
	  JOIN vt.ticket ON ticket.ticketID = elementos.ticketID 
	  JOIN numeros ON numeros.elementoID = elementos.numero 
	  WHERE elementos.anulado = 0 AND sorteoID = :sorteoID 
	  GROUP BY elementos.numero ORDER BY elementos.numero) as g ON g.numero = numeros.numero 
  JOIN us.bancas ON bancas.bancaID = ticket.bancaID 
  WHERE elementos.anulado = 0 AND sorteoID = :sorteoID AND comer_usuario.cID = :comercialID 
  GROUP BY elementos.numero ORDER BY elementos.numero
--jugadas_global_num
SELECT numeros.numero numero, numeros.descripcion desc, SUM(elementos.monto) jugada  FROM elementos JOIN ticket ON ticket.ticketID = elementos.ticketID JOIN numeros ON numeros.elementoID = elementos.numero WHERE elementos.anulado = 0 AND sorteoID = :sorteoID GROUP BY elementos.numero ORDER BY elementos.numero
--jugadas_banca_sorteo
SELECT elementos.numero, SUM(elementos.monto) monto FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID WHERE ticket.anulado = 0 AND ticket.bancaID = :bancaID AND elementos.sorteoID = :sorteoID GROUP BY numero
--jugadas_banca
SELECT elementos.sorteoID, elementos.numero, SUM(elementos.monto) monto FROM ticket JOIN elementos ON ticket.ticketID = elementos.ticketID WHERE ticket.anulado = 0 AND ticket.bancaID = :bancaID GROUP BY numero, sorteoID ORDER BY sorteoID, numero
--relacion_pago
SELECT usuarioID, bancaID, valor FROM us.relacion_pago WHERE sorteo = :sorteo ORDER BY bancaID
--reporte_nuevo__VIEJO
INSERT INTO reportes (fecha,sorteoID,bancaID,taquillaID,jugada,premio,renta,comisionBanca,comision,pago) 
SELECT sorteos.fecha, sorteos.sorteoID, elementos.bancaID, elementos.taquillaID, ROUND(SUM(monto),2) jugado, ROUND(SUM(premio),2) premio, bancas.renta, bancas.comision, 
COALESCE((SELECT comision FROM taquillas_comision WHERE (taquillaID = taquillas.taquillaID OR bancaID = taquillas.bancaID OR bancaID = taquillas.usuarioID) AND sorteo = sorteos.sorteo ORDER BY bancaID ASC, taquillaID ASC LIMIT 1),taquillas.comision) comision,
ROUND(SUM((case when pagos.tiempo > 0 then premio else 0 end)),2) pago
FROM elementos 
	JOIN numeros ON elementos.numero = numeros.elementoID 
	JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
	JOIN us.taquillas ON taquillas.taquillaID = elementos.taquillaID 
	JOIN us.bancas ON bancas.bancaID = elementos.bancaID 
	LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID
WHERE elementos.sorteoID = :sorteoID AND elementos.anulado = 0 
GROUP BY elementos.taquillaID
ORDER BY elementos.bancaID ASC, elementos.taquillaID ASC