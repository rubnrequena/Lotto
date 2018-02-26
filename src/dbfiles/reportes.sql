--bancas
SELECT ticket.bancaID,SUM( elementos.monto) jugado, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.anulado = 0 AND sorteos.fecha BETWEEN :inicio AND :fin GROUP BY ticket.bancaID
--banca
SELECT sorteos.fecha, SUM( elementos.monto) jugado, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.anulado = 0 AND sorteos.fecha BETWEEN :inicio AND :fin AND ticket.bancaID = :bancaID GROUP BY sorteos.fecha ORDER BY sorteos.fecha
--banca_sorteo
SELECT numero, SUM(premio) premio, SUM(elementos.monto) monto FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID 
WHERE ticket.anulado = 0 AND ticket.bancaID = :bancaID AND sorteoID = :sorteoID GROUP BY elementos.numero ORDER BY elementos.numero
--banca_sorteo_taquillas
SELECT ticket.taquillaID, SUM(premio) premio, sum(elementos.monto) monto FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID WHERE ticket.anulado = 0 AND ticket.bancaID = :bancaID AND sorteoID = :sorteoID GROUP BY ticket.taquillaID
--taquillas
SELECT ticket.taquillaID, SUM( elementos.monto) jugado, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID WHERE ticket.anulado = 0 AND sorteos.fecha BETWEEN :inicio AND :fin AND ticket.bancaID = :bancaID GROUP BY ticket.taquillaID
--taquilla
SELECT sorteos.fecha, sorteos.descripcion, elementos.sorteoID, ticket.bancaID,SUM( elementos.monto) jugado, SUM(premio) premio FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID WHERE ticket.anulado = false AND sorteos.fecha BETWEEN :inicio AND :fin AND ticket.taquillaID = :taquillaID GROUP BY sorteos.fecha ORDER BY sorteos.fecha
--banca_diario
SELECT sorteos.descripcion desc, sorteos.ganador, SUM(elementos.monto*taquillas.comision*0.01) comision, SUM(elementos.monto) jugado, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago 
FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID 
JOIN us.taquillas ON taquillas.taquillaID = ticket.taquillaID 
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID
LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.anulado = 0 AND ticket.tiempo BETWEEN  :inicio AND :final AND ticket.bancaID = :bancaID 
GROUP BY elementos.sorteoID ORDER BY elementos.sorteoID
--banca_diario_taq
SELECT taquillas.nombre desc, SUM(elementos.monto*taquillas.comision*0.01) comision, SUM(elementos.monto) jugado, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago 
FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID 
JOIN us.taquillas ON taquillas.taquillaID = ticket.taquillaID 
LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.anulado = 0 AND ticket.tiempo BETWEEN  :inicio AND :final AND ticket.bancaID = :bancaID 
GROUP BY ticket.taquillaID ORDER BY ticket.taquillaID
--usuario_diario
SELECT sorteos.ganador, sorteos.descripcion desc, SUM(elementos.monto) jugado, SUM(elementos.premio) premios, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago
FROM "vt".ticket 
JOIN "vt"."elementos" ON ticket.ticketID = elementos.ticketID 
JOIN us.bancas ON bancas.bancaID = ticket.bancaID
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID
LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.tiempo BETWEEN :inicio AND :final AND bancas.usuarioID = :usuarioID and ticket.anulado = 0 
GROUP BY elementos.sorteoID ORDER BY elementos.sorteoID
--taq_sorteo_elem
SELECT numero, SUM(elementos.monto) monto FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID WHERE ticket.anulado = 0 AND ticket.taquillaID = :taquillaID AND elementos.sorteoID = :sorteoID GROUP BY numero
--taq_dia_ventas
SELECT ticket.codigo, ticket.ticketID, ticket.anulado, SUM(elementos.monto) monto, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID LEFT JOIN vt.pagos ON elementos.ventaID = pagos.ventaID WHERE ticket.taquillaID = :taquillaID AND ticket.tiempo BETWEEN :inicio AND :final GROUP BY ticket.ticketID
--taq_ventas
SELECT ticket.ticketID id, ticket.anulado a, SUM(elementos.monto) m, SUM(premio) pr, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pg FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID LEFT JOIN vt.pagos ON elementos.ventaID = pagos.ventaID WHERE ticket.taquillaID = :taquillaID AND ticket.tiempo BETWEEN :inicio AND :final GROUP BY ticket.ticketID
--taq_ventas_banca
SELECT ticket.codigo c, ticket.ticketID id, ticket.anulado a, SUM(elementos.monto) m, SUM(premio) pr, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pg FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID LEFT JOIN vt.pagos ON elementos.ventaID = pagos.ventaID WHERE ticket.taquillaID = :taquillaID AND ticket.tiempo BETWEEN :inicio AND :final GROUP BY ticket.ticketID
--taq_sorteo_ventas
SELECT ticket.ticketID, ticket.anulado, SUM(elementos.monto) monto, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID LEFT JOIN vt.pagos ON elementos.ventaID = pagos.ventaID 
WHERE ticket.taquillaID = :taquillaID AND elementos.sorteoID = :sorteoID GROUP BY ticket.ticketID
--taq_diario
SELECT elementos.sorteoID, sorteos.descripcion sorteo, ganador, SUM(elementos.monto) jugado, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago 
FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID 
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.anulado = 0 AND ticket.tiempo BETWEEN :inicio AND :final AND ticket.taquillaID = :taquillaID 
GROUP BY sorteos.sorteoID ORDER BY elementos.sorteoID
--rp_taqs_gen
SELECT taquillas.nombre desc, SUM(jugada) jugada, SUM(premio) premio, SUM(jugada*reportes.comision*0.01) comision, SUM(jugada*comisionBanca) cmBanca, round(SUM(jugada*renta),0) renta
FROM vt.reportes 
JOIN us.taquillas ON taquillas.taquillaID = reportes.taquillaID
WHERE fecha BETWEEN :inicio AND :fin AND reportes.bancaID = :bancaID 
GROUP BY reportes.taquillaID ORDER BY reportes.taquillaID
--rp_taqs_gen_sorteo2
SELECT main.sorteos.nombre desc, SUM(jugada) jugada, SUM(premio) premio, SUM(jugada*reportes.comision*0.01) comision, SUM(jugada*renta) renta FROM vt.reportes 
JOIN vt.sorteos ON vt.sorteos.sorteoID = reportes.sorteoID 
JOIN main.sorteos ON main.sorteos.sorteoID = vt.sorteos.sorteo
WHERE reportes.fecha BETWEEN :inicio AND :fin AND reportes.bancaID = :bancaID 
GROUP BY vt.sorteos.sorteo ORDER BY vt.sorteos.sorteo
--rp_taqs_gen_fecha
SELECT fecha desc, SUM(jugada) jugada, SUM(premio) premio, SUM(jugada*reportes.comision*0.01) comision, SUM(jugada*renta) renta FROM vt.reportes 
WHERE fecha BETWEEN :inicio AND :fin AND reportes.bancaID = :bancaID 
GROUP BY reportes.fecha ORDER BY reportes.fecha
--sorteo_glb
SELECT usuarios.nombre desc, SUM(reportes.jugada) jugada, SUM(reportes.premio) premio, SUM(jugada*reportes.comision*0.01) comision FROM reportes
JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID 
JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
JOIN us.usuarios ON usuarios.usuarioID = bancas.usuarioID
WHERE sorteos.sorteo = :sorteo AND reportes.fecha BETWEEN :inicio AND :fin
GROUP BY bancas.usuarioID
--sorteo_glb_fecha
SELECT reportes.fecha desc, SUM(reportes.jugada) jugada, SUM(reportes.premio) premio, SUM(jugada*reportes.comision*0.01) comision FROM reportes
JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID WHERE sorteos.sorteo = :sorteo AND reportes.fecha BETWEEN :inicio AND :fin
GROUP BY reportes.fecha
--sorteo_glb_grupo
SELECT bancas.nombre desc, SUM(reportes.jugada) jugada, SUM(reportes.premio) premio, SUM(jugada*reportes.comision*0.01) comision FROM reportes
JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID 
JOIN us.bancas ON bancas.bancaID = reportes.bancaID
WHERE sorteos.sorteo = :sorteo AND reportes.fecha BETWEEN :inicio AND :fin
GROUP BY bancas.bancaID
--midas
SELECT * FROM 
	(SELECT elementos.sorteoID es, SUM(monto) ej, SUM(premio) ep FROM elementos 
	 	JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
	 	WHERE fecha = :fecha AND anulado = 0 GROUP BY elementos.sorteoID ORDER BY elementos.sorteoID asc) AS jg
	LEFT JOIN (SELECT sorteoID rs, SUM(jugada) rj, SUM(premio) rp FROM reportes 
		WHERE fecha = :fecha GROUP BY sorteoID ORDER BY sorteoID asc) AS rp 
ON rp.rs = jg.es
--midas_sorteo
SELECT * FROM 
	(SELECT elementos.sorteoID es, SUM(monto) ej, SUM(premio) ep FROM elementos 
	 	JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
	 	WHERE elementos.sorteoID = :sorteoID AND anulado = 0 GROUP BY elementos.sorteoID ORDER BY elementos.sorteoID asc) AS jg
	LEFT JOIN (SELECT sorteoID rs, SUM(jugada) rj, SUM(premio) rp FROM reportes 
		WHERE reportes.sorteoID = :sorteoID GROUP BY sorteoID ORDER BY sorteoID asc) AS rp 
ON rp.rs = jg.es