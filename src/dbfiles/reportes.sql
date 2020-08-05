--bancas
SELECT ticket.bancaID,ROUND(SUM(elementos.monto),2) jugado, ROUND(SUM(premio),2) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.anulado = 0 AND sorteos.fecha BETWEEN :inicio AND :fin GROUP BY ticket.bancaID
--banca
SELECT sorteos.fecha, ROUND(SUM(elementos.monto),2) jugado, ROUND(SUM(premio),2) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.anulado = 0 AND sorteos.fecha BETWEEN :inicio AND :fin AND ticket.bancaID = :bancaID GROUP BY sorteos.fecha ORDER BY sorteos.fecha
--banca_sorteo
SELECT numero, ROUND(SUM(premio),2) premio, ROUND(SUM(elementos.monto),2) monto FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID 
WHERE ticket.anulado = 0 AND ticket.bancaID = :bancaID AND sorteoID = :sorteoID GROUP BY elementos.numero ORDER BY elementos.numero
--banca_sorteo_numeros
SELECT ticket.taquillaID, ROUND(SUM(premio),2) premio, ROUND(SUM(elementos.monto),2) monto FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID WHERE ticket.anulado = 0 AND ticket.bancaID = :bancaID AND sorteoID = :sorteoID GROUP BY ticket.taquillaID
--banca_sorteo_taquillas
SELECT reportes.taquillaID, taquillas.nombre, reportes.comision, SUM(jugada) jugada, SUM(premio) premio, reportes.fecha, sorteo FROM reportes 
  JOIN taquillas ON taquillas.taquillaID = reportes.taquillaID
  JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID
WHERE reportes.fecha BETWEEN :inicio AND :fin AND reportes.bancaID = :bancaID AND taquillas.usuarioID = :usuarioID AND sorteo = :sorteo
GROUP BY reportes.taquillaID
--banca_sorteo_bancas
SELECT reportes.bancaID, bancas.nombre, bancas.participacion, reportes.comisionBanca pBanca, reportes.comision, round(SUM(jugada*comisionBanca),2) cmBanca, round(SUM(jugada),2) jugada, round(SUM(premio),2) premio, reportes.fecha, sorteo FROM reportes 
  JOIN bancas ON bancas.bancaID = reportes.bancaID
  JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID
WHERE reportes.fecha BETWEEN :inicio AND :fin AND bancas.usuarioID = :usuarioID AND sorteo = :sorteo
GROUP BY reportes.bancaID
--taquillas
SELECT ticket.taquillaID, ROUND(SUM(elementos.monto),2) jugado, ROUND(SUM(premio),2) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID WHERE ticket.anulado = 0 AND sorteos.fecha BETWEEN :inicio AND :fin AND ticket.bancaID = :bancaID GROUP BY ticket.taquillaID
--taquilla
SELECT sorteos.fecha, sorteos.descripcion, elementos.sorteoID, ticket.bancaID,ROUND(SUM(elementos.monto),2) jugado, ROUND(SUM(premio),2) premio FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID WHERE ticket.anulado = false AND sorteos.fecha BETWEEN :inicio AND :fin AND ticket.taquillaID = :taquillaID GROUP BY sorteos.fecha ORDER BY sorteos.fecha
--taq_general
SELECT sorteos.fecha, SUM(elementos.monto) jugado, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID WHERE ticket.anulado = 0 AND sorteos.fecha BETWEEN :inicio AND :fin AND ticket.taquillaID = :taquillaID  GROUP BY sorteos.fecha ORDER BY sorteos.fecha
--rp_taq_gen
SELECT fecha descripcion, SUM(jugada) jugada, SUM(premio) premio, SUM(jugada*reportes.comision*0.01) comision FROM vt.reportes WHERE fecha BETWEEN :inicio AND :fin AND reportes.taquillaID = :taquillaID GROUP BY reportes.fecha ORDER BY reportes.fecha
--rp_taq_gen_sorteosDia
SELECT descripcion, SUM(jugada) jugada, SUM(premio) premio, SUM(jugada*reportes.comision*0.01) comision  FROM vt.reportes JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID WHERE reportes.fecha BETWEEN :inicio AND :fin AND reportes.taquillaID = :taquillaID GROUP BY reportes.sorteoID ORDER BY reportes.fecha
--banca_diario
SELECT sorteos.descripcion desc, sorteos.ganador, SUM(elementos.monto*taquillas.comision*0.01) comision, ROUND(SUM(elementos.monto),2) jugado, ROUND(SUM(premio),2) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago 
FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID 
JOIN us.taquillas ON taquillas.taquillaID = ticket.taquillaID 
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID
LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.anulado = 0 AND ticket.tiempo BETWEEN  :inicio AND :final AND ticket.bancaID = :bancaID 
GROUP BY elementos.sorteoID ORDER BY elementos.sorteoID
--banca_diario_taq
SELECT taquillas.nombre desc, SUM(elementos.monto*taquillas.comision*0.01) comision, ROUND(SUM(elementos.monto),2) jugado, ROUND(SUM(premio),2) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago 
FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID 
JOIN us.taquillas ON taquillas.taquillaID = ticket.taquillaID 
LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.anulado = 0 AND ticket.tiempo BETWEEN  :inicio AND :final AND ticket.bancaID = :bancaID 
GROUP BY ticket.taquillaID ORDER BY ticket.taquillaID
--usuario_diario
SELECT numeros.descripcion ganadorNombre, sorteos.descripcion desc, ROUND(SUM(elementos.monto),2) jugado, ROUND(SUM(elementos.premio),2) premios
FROM "vt".ticket 
JOIN "vt"."elementos" ON ticket.ticketID = elementos.ticketID 
JOIN us.bancas ON bancas.bancaID = ticket.bancaID
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID
LEFT JOIN numeros ON numeros.elementoID = sorteos.ganador
WHERE ticket.tiempo BETWEEN :inicio AND :final AND bancas.usuarioID = :usuarioID and ticket.anulado = 0 
GROUP BY elementos.sorteoID ORDER BY elementos.sorteoID
--comercial_diario
SELECT elementos.sorteoID, usuarioID, sorteos.ganador, sorteos.descripcion desc, ROUND(SUM(elementos.monto),2) jugado, ROUND(SUM(elementos.premio),2) premios, SUM((case when pagos.tiempo > 0 then ROUND(premio,2) else 0 end)) pago FROM "vt".ticket 
	JOIN "vt"."elementos" ON ticket.ticketID = elementos.ticketID  
	JOIN us.bancas ON bancas.bancaID = ticket.bancaID 
	JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
	LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID
	JOIN us.comer_usuario ON comer_usuario.uID = bancas.usuarioID 
WHERE ticket.tiempo BETWEEN :inicio AND :final and cID = :comercialID and ticket.anulado = 0 
GROUP BY elementos.sorteoID ORDER BY elementos.sorteoID
--taq_sorteo_elem
SELECT numero, ROUND(SUM(elementos.monto),2) monto FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID WHERE ticket.anulado = 0 AND ticket.taquillaID = :taquillaID AND elementos.sorteoID = :sorteoID GROUP BY numero
--taq_dia_ventas
SELECT ticket.codigo, ticket.ticketID, ticket.anulado, ROUND(SUM(elementos.monto),2) monto, ROUND(SUM(premio),2) premio, SUM((case when pagos.tiempo > 0 then ROUND(premio,2) else 0 end)) pago FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID LEFT JOIN vt.pagos ON elementos.ventaID = pagos.ventaID WHERE ticket.taquillaID = :taquillaID AND ticket.tiempo BETWEEN :inicio AND :final GROUP BY ticket.ticketID
--taq_ventas
SELECT ticket.ticketID id, ticket.anulado a, ROUND(SUM(elementos.monto),2) m, ROUND(SUM(premio),2) pr, SUM((case when pagos.tiempo > 0 then ROUND(premio,2) else 0 end)) pg FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID LEFT JOIN vt.pagos ON elementos.ventaID = pagos.ventaID WHERE ticket.taquillaID = :taquillaID AND ticket.tiempo BETWEEN :inicio AND :final GROUP BY ticket.ticketID
--taq_ventas_banca
SELECT ticket.codigo c, ticket.ticketID id, ticket.anulado a, ROUND(SUM(elementos.monto),2) m, ROUND(SUM(premio),2) pr, SUM((case when pagos.tiempo > 0 then ROUND(premio,2) else 0 end)) pg FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID LEFT JOIN vt.pagos ON elementos.ventaID = pagos.ventaID WHERE ticket.taquillaID = :taquillaID AND ticket.tiempo BETWEEN :inicio AND :final GROUP BY ticket.ticketID
--taq_sorteo_ventas
SELECT ticket.ticketID, ticket.anulado, ROUND(SUM(elementos.monto),2) monto, ROUND(SUM(premio),2) premio, SUM((case when pagos.tiempo > 0 then ROUND(premio,2) else 0 end)) pago FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID LEFT JOIN vt.pagos ON elementos.ventaID = pagos.ventaID 
WHERE ticket.taquillaID = :taquillaID AND elementos.sorteoID = :sorteoID GROUP BY ticket.ticketID
--taq_diario
SELECT elementos.sorteoID, sorteos.descripcion sorteo, ganador, ROUND(SUM(elementos.monto),2) jugado, ROUND(SUM(premio),2) premio, SUM((case when pagos.tiempo > 0 then ROUND(premio,2) else 0 end)) pago 
FROM vt.ticket 
JOIN vt.elementos ON ticket.ticketID = elementos.ticketID 
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID 
WHERE ticket.anulado = 0 AND ticket.tiempo BETWEEN :inicio AND :final AND ticket.taquillaID = :taquillaID 
GROUP BY sorteos.sorteoID ORDER BY elementos.sorteoID
--rp_taqs_gen
SELECT taquillas.taquillaID id, taquillas.nombre desc, ROUND(SUM(jugada),2) jugada, ROUND(SUM(premio),2) premio, ROUND(SUM(jugada*reportes.comision*0.01),2) comision, ROUND(SUM(jugada*comisionBanca),2) cmBanca
FROM vt.reportes 
JOIN us.taquillas ON taquillas.taquillaID = reportes.taquillaID
WHERE fecha BETWEEN :inicio AND :fin AND reportes.bancaID = :bancaID and taquillas.usuarioID = :usuarioID
GROUP BY reportes.taquillaID ORDER BY reportes.taquillaID
--rp_taqs_gen_sorteo2
SELECT main.sorteos.nombre desc, ROUND(SUM(jugada),2) jugada, ROUND(SUM(premio),2) premio, SUM(jugada*reportes.comision*0.01) comision, SUM(jugada*renta) renta FROM vt.reportes 
JOIN vt.sorteos ON vt.sorteos.sorteoID = reportes.sorteoID 
JOIN main.sorteos ON main.sorteos.sorteoID = vt.sorteos.sorteo
WHERE reportes.fecha BETWEEN :inicio AND :fin AND reportes.bancaID = :bancaID 
GROUP BY vt.sorteos.sorteo ORDER BY vt.sorteos.sorteo
--rp_taqs_gen_fecha
SELECT fecha desc, ROUND(SUM(jugada),2) jugada, ROUND(SUM(premio),2) premio, SUM(jugada*reportes.comision*0.01) comision, SUM(jugada*renta) renta FROM vt.reportes 
WHERE fecha BETWEEN :inicio AND :fin AND reportes.bancaID = :bancaID 
GROUP BY reportes.fecha ORDER BY reportes.fecha
--sorteo_glb
SELECT cID, sorteo, usuarios.nombre desc, jugada, premio, r.comision FROM (
  SELECT sorteos.sorteo, cid, usuarios.nombre desc, SUM(reportes.jugada) jugada, SUM(reportes.premio) premio, ROUND(SUM(jugada*reportes.comision*0.01),0) comision FROM reportes
  JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID 
  JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
  JOIN us.usuarios ON usuarios.usuarioID = bancas.usuarioID
  JOIN us.comer_usuario ON comer_usuario.uid = bancas.usuarioID
  WHERE 
  sorteos.sorteo IN (SELECT sorteoID  FROM admins_meta JOIN main.sorteos ON admins_meta.valor = sorteos.sorteoID WHERE adminID = :aID)
  AND reportes.fecha BETWEEN :inicio AND :fin
  GROUP BY sorteos.sorteo, comer_usuario.cID
  ORDER BY sorteos.sorteo
) as r JOIN us.usuarios ON usuarios.usuarioID = r.cID
--sorteo_glb_fecha
SELECT fecha, cID, sorteo, usuarios.nombre desc, jugada, premio, r.comision FROM (
  SELECT reportes.fecha, sorteos.sorteo, cid, usuarios.nombre desc, SUM(reportes.jugada) jugada, SUM(reportes.premio) premio, ROUND(SUM(jugada*reportes.comision*0.01),0) comision FROM reportes
  JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID 
  JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
  JOIN us.usuarios ON usuarios.usuarioID = bancas.usuarioID
  JOIN us.comer_usuario ON comer_usuario.uid = bancas.usuarioID
  WHERE 
  sorteos.sorteo IN (SELECT sorteoID  FROM admins_meta JOIN main.sorteos ON admins_meta.valor = sorteos.sorteoID WHERE adminID = :aID)
  AND reportes.fecha BETWEEN :inicio AND :fin
  GROUP BY reportes.fecha, comer_usuario.cID
  ORDER BY reportes.fecha
) as r JOIN us.usuarios ON usuarios.usuarioID = r.cID
--sorteo_glb_grupo
SELECT bancas.nombre desc, SUM(reportes.jugada) jugada, SUM(reportes.premio) premio, SUM(jugada*reportes.comision*0.01) comision FROM reportes
JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID 
JOIN us.bancas ON bancas.bancaID = reportes.bancaID
WHERE sorteos.sorteo = :sorteo AND reportes.fecha BETWEEN :inicio AND :fin
GROUP BY bancas.bancaID
--sorteo_glb_sorteo
SELECT sum(jugada) jg, sorteos.descripcion from reportes 
	JOIN vt.sorteos ON reportes.sorteoID = sorteos.sorteoID
WHERE reportes.fecha between :inicio AND :fin 
	AND sorteos.sorteo IN (SELECT sorteoID  FROM admins_meta JOIN main.sorteos ON admins_meta.valor = sorteos.sorteoID WHERE adminID = 2)
GROUP BY reportes.sorteoID
--comercial_general
SELECT 'usuario' tipo, bancas.usuarioID id,usuarios.nombre desc, usuarios.comision cb, usuarios.participacion pb,
	ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, ROUND(SUM(jugada*usuarios.comision),2) cm, 
	round(SUM(jugada*reportes.renta),2) rt, ROUND(SUM((jugada-premio-(jugada*usuarios.comision))*usuarios.participacion),2) prt	
FROM vt.reportes
JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID 
JOIN us.comer_usuario ON comer_usuario.uID = bancas.usuarioID
WHERE fecha BETWEEN :inicio AND :fin AND cID = :comercial
GROUP BY bancas.usuarioID ORDER BY usuarios.nombre ASC
--comercial_general_operadora
SELECT 'operadora' tipo,main.sorteos.sorteoID id,main.sorteos.nombre desc, "" cb, "" pb,
	ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, ROUND(SUM(jugada*usuarios.comision),2) cm, 
	round(SUM(jugada*reportes.renta),2) rt, ROUND(SUM((jugada-premio-(jugada*usuarios.comision))*usuarios.participacion),2) prt	
FROM vt.reportes
JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID 
JOIN us.comer_usuario ON comer_usuario.uID = bancas.usuarioID 
JOIN vt.sorteos ON vt.sorteos.sorteoID = reportes.sorteoID 
JOIN main.sorteos ON main.sorteos.sorteoID = vt.sorteos.sorteo
WHERE reportes.fecha BETWEEN :inicio AND :fin AND cID = :comercial
GROUP BY sorteos.sorteo, bancas.usuarioID ORDER BY usuarios.nombre ASC
--comercial_banca
SELECT 'grupo' tipo,bancas.bancaID id, bancas.nombre desc, ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, partGrupo pb, cmGrupo cb, 
	ROUND(SUM(jugada*cmGrupo),2) cm, SUM(jugada*reportes.comision*0.01) cmt, round(SUM(jugada*reportes.renta),2) rt, 
	ROUND(SUM((jugada-premio-(jugada*cmGrupo))*partGrupo),2) prt
FROM vt.reportes
JOIN us.bancas ON bancas.bancaID = reportes.bancaID
WHERE fecha BETWEEN :inicio AND :fin AND bancas.usuarioID = :usuarioID 
GROUP BY bancas.bancaID ORDER BY bancas.nombre ASC
--comercial_recogedor
SELECT 'taquilla' tipo,taquillas.taquillaID id, taquillas.nombre desc, ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, partGrupo pb, cmGrupo cb, 
	SUM(jugada*reportes.comision*0.01) cmt, round(SUM(jugada*reportes.renta),2) rt 
FROM vt.reportes
JOIN us.taquillas ON taquillas.taquillaID = reportes.taquillaID
WHERE fecha BETWEEN :inicio AND :fin AND reportes.bancaID = :bancaID
GROUP BY reportes.taquillaID ORDER BY taquillas.nombre ASC
--comercial_fecha
SELECT 'fecha' tipo,reportes.fecha id,reportes.fecha desc, "" cb, "" pb,
	ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, ROUND(SUM(jugada*usuarios.comision),2) cm, 
	round(SUM(jugada*reportes.renta),2) rt, ROUND(SUM((jugada-premio-(jugada*usuarios.comision))*usuarios.participacion),2) prt	
FROM vt.reportes
JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID 
JOIN us.comer_usuario ON comer_usuario.uID = bancas.usuarioID 
WHERE reportes.fecha BETWEEN :inicio AND :fin AND cID = :comercial
GROUP BY reportes.fecha ORDER BY reportes.fecha ASC
--midas
SELECT * FROM 
	(SELECT elementos.sorteoID es, ROUND(SUM(monto),2) ej, ROUND(SUM(premio),2) ep FROM elementos 
	 	JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
	 	WHERE fecha = :fecha AND anulado = 0 GROUP BY elementos.sorteoID ORDER BY elementos.sorteoID asc) AS jg
	LEFT JOIN (SELECT sorteoID rs, ROUND(SUM(jugada),2) rj, ROUND(SUM(premio),2) rp FROM reportes 
		WHERE fecha = :fecha GROUP BY sorteoID ORDER BY sorteoID asc) AS rp 
ON rp.rs = jg.es
--midas_sorteo
SELECT * FROM 
	(SELECT elementos.sorteoID es, ROUND(SUM(monto),2) ej, ROUND(SUM(premio),2) ep FROM elementos 
	 	JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
	 	WHERE elementos.sorteoID = :sorteoID AND anulado = 0 GROUP BY elementos.sorteoID ORDER BY elementos.sorteoID asc) AS jg
	LEFT JOIN (SELECT sorteoID rs, ROUND(SUM(jugada),2) rj, ROUND(SUM(premio),2) rp FROM reportes 
		WHERE reportes.sorteoID = :sorteoID GROUP BY sorteoID ORDER BY sorteoID asc) AS rp 
ON rp.rs = jg.es
--rp_usuario_gen
SELECT bancas.comision bn_comision, bancas.participacion, bancas.nombre desc, bancas.bancaID gID, ROUND(SUM(jugada),2) jugada, ROUND(SUM(premio),2) premio, ROUND(SUM(jugada*reportes.comision*0.01),2) comision, round(SUM(jugada*comisionBanca),2) cmb, round(SUM(jugada*reportes.renta),2) renta 
FROM vt.reportes 
JOIN us.bancas ON bancas.bancaID = reportes.bancaID JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID 
WHERE reportes.fecha BETWEEN :inicio AND :fin AND bancas.usuarioID = :usuarioID 
GROUP BY bancas.bancaID ORDER BY bancas.nombre
--rp_usuario_gen_sorteo
SELECT sorteos.descripcion desc, ROUND(SUM(jugada),2) jugada, ROUND(SUM(premio),2) premio, SUM(jugada*reportes.comision*0.01) comision, round(SUM(jugada*comisionBanca),2) cmb, round(SUM(jugada*reportes.renta),2) renta FROM vt.reportes JOIN us.bancas ON bancas.bancaID = reportes.bancaID JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID WHERE reportes.fecha BETWEEN :inicio AND :fin AND bancas.usuarioID = :usuarioID GROUP BY sorteos.sorteo ORDER BY sorteos.sorteoID
--rp_usuario_gen_fecha
SELECT reportes.fecha desc, ROUND(SUM(jugada),2) jugada, ROUND(SUM(premio),2) premio, SUM(jugada*reportes.comision*0.01) comision, round(SUM(jugada*comisionBanca),2) cmb, round(SUM(jugada*reportes.renta),2) renta FROM vt.reportes JOIN us.bancas ON bancas.bancaID = reportes.bancaID WHERE reportes.fecha BETWEEN :inicio AND :fin AND bancas.usuarioID = :usuarioID GROUP BY reportes.fecha ORDER BY reportes.fecha
--rp_usuarios_gen
SELECT bancas.usuarioID, usuarios.nombre desc, ROUND(SUM(jugada),2) jugada, ROUND(SUM(premio),2) premio, ROUND(SUM(jugada*reportes.comision*0.01),2) comision, ROUND(SUM(jugada*reportes.renta),2) renta 
FROM vt.reportes JOIN us.bancas ON bancas.bancaID = reportes.bancaID JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID 
WHERE fecha BETWEEN :inicio AND :fin GROUP BY bancas.usuarioID ORDER BY bancas.usuarioID, bancas.bancaID
--rp_bancas_gen
SELECT bancas.nombre desc, ROUND(SUM(jugada),2) jugada, ROUND(SUM(premio),2) premio, SUM(jugada*reportes.comision*0.01) comision, ROUND(SUM(jugada*reportes.renta),2) renta 
FROM vt.reportes JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
WHERE fecha BETWEEN :inicio AND :fin 
GROUP BY reportes.bancaID  ORDER BY bancas.usuarioID, bancas.bancaID
--rp_fecha_gen
SELECT bancas.usuarioID, reportes.fecha desc, ROUND(SUM(jugada),2) jugada, ROUND(SUM(premio),2) premio, SUM(jugada*reportes.comision*0.01) comision, ROUND(SUM(jugada*reportes.renta),2) renta FROM vt.reportes JOIN us.bancas ON bancas.bancaID = reportes.bancaID JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID WHERE fecha BETWEEN :inicio AND :fin GROUP BY reportes.fecha ORDER BY reportes.fecha
--rp_comer_gen
SELECT cID, rpt.jugada, rpt.premio, rpt.comision, rpt.renta, usuarios.nombre desc FROM 
(SELECT cID, ROUND(SUM(jugada),2) jugada, ROUND(SUM(premio),2) premio, ROUND(SUM(jugada*reportes.comision*0.01),2) comision, ROUND(SUM(jugada*reportes.renta),2) renta 
FROM vt.reportes 
	JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
	JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID 
	JOIN us.comer_usuario ON uID = bancas.usuarioID
WHERE fecha BETWEEN :inicio AND :fin 
GROUP BY cID ORDER BY bancas.usuarioID, bancas.bancaID) AS rpt
	JOIN us.usuarios ON rpt.cID = usuarios.usuarioID
--rp_cobro_comergen
SELECT cID, jugada jg, usuarios.nombre desc, abs(usuarios.comision) cm FROM (
	SELECT cID, ROUND(SUM(jugada),2) jugada, usuarios.nombre desc
	  FROM vt.reportes 
		  JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
		  JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID
		  JOIN us.comer_usuario ON uID = bancas.usuarioID
	  WHERE fecha BETWEEN :inicio AND :fin
	  GROUP BY cID
) as rpt 
	JOIN us.usuarios ON rpt.cID = usuarios.usuarioID
ORDER BY usuarios.comision ASC
--rp_cobro_usergen
SELECT usuarios.usuarioID uID, ROUND(SUM(jugada),2) jg, usuarios.nombre desc, abs(usuarios.comision) cm
  FROM vt.reportes 
	  JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
	  JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID
	  JOIN us.comer_usuario ON uID = bancas.usuarioID
  WHERE fecha BETWEEN :inicio AND :fin and cID = :cid
  GROUP BY bancas.usuarioID
  ORDER BY usuarios.comision ASC
--rp_cobro_grupogen
SELECT reportes.bancaID gID, bancas.nombre desc, abs(bancas.comision) cm, ROUND(SUM(reportes.jugada),2) jg FROM vt.reportes 
  JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
WHERE fecha BETWEEN :inicio AND :fin AND bancas.usuarioID = :uid
GROUP BY reportes.bancaID
--backup_sorteo
SELECT reporteID, jugada, premio, reportes.fecha, reportes.renta, reportes.comision,
	reportes.sorteoID, sorteos.descripcion sorteo,
	reportes.taquillaID, taquillas.nombre taquillaNombre,
	reportes.bancaID, bancas.nombre bancaNombre,
	taquillas.usuarioID usuarioID, usuarios.nombre usuarioNombre
FROM reportes
	JOIN us.taquillas ON taquillas.taquillaID = reportes.taquillaID
	JOIN us.bancas ON bancas.bancaID = reportes.bancaID
	JOIN us.usuarios ON usuarios.usuarioID = bancas.usuarioID
	JOIN vt.sorteos ON sorteos.sorteoID = reportes.sorteoID
WHERE reportes.sorteoID = :sorteoID
--banca_general
SELECT  bancas.bancaID id,bancas.nombre desc, bancas.comision cb, bancas.participacion pb,
	ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, ROUND(SUM(jugada*bancas.comision),2) cm, 
	round(SUM(jugada*reportes.renta),2) rt, ROUND(SUM((jugada-premio-(jugada*bancas.comision))*bancas.participacion),2) prt	
FROM vt.reportes
JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
WHERE fecha BETWEEN :inicio AND :fin AND bancas.usuarioID = :usuarioID
GROUP BY bancas.usuarioID ORDER BY bancas.nombre ASC
--gcomercial
SELECT 'banca' tipo, usuarios.usuarioID id, sorteos.nombre operadora, sorteos.sorteo, reportes.fecha, usuarios.nombre desc, usuarios.comision cb, usuarios.participacion pb,
	ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, ROUND(SUM(jugada*usuarios.comision),2) cm, 
	round(SUM(jugada*reportes.renta),2) rt, ROUND(SUM((jugada-premio-(jugada*usuarios.comision))*usuarios.participacion),2) prt	
FROM vt.reportes
JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID 
JOIN us.comer_usuario ON comer_usuario.uID = bancas.usuarioID 
JOIN vt.sorteos ON vt.sorteos.sorteoID = reportes.sorteoID 
JOIN main.sorteos ON main.sorteos.sorteoID = vt.sorteos.sorteo
WHERE reportes.fecha BETWEEN :inicio AND :fin AND cID = :comercial
GROUP BY usuarios.usuarioID, sorteos.sorteo, sorteos.fecha ORDER BY usuarios.nombre ASC
--gbanca
SELECT 'grupo' tipo, bancas.bancaID id, sorteos.sorteo, sorteos.nombre operadora, reportes.fecha, bancas.nombre desc, usuarios.comision cb, usuarios.participacion pb,
	ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, ROUND(SUM(jugada*usuarios.comision),2) cm, 
	round(SUM(jugada*reportes.renta),2) rt, ROUND(SUM((jugada-premio-(jugada*usuarios.comision))*usuarios.participacion),2) prt	
FROM vt.reportes
JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID 
JOIN us.comer_usuario ON comer_usuario.uID = bancas.usuarioID 
JOIN vt.sorteos ON vt.sorteos.sorteoID = reportes.sorteoID 
JOIN main.sorteos ON main.sorteos.sorteoID = vt.sorteos.sorteo
WHERE reportes.fecha BETWEEN :inicio AND :fin AND cID = :comercial AND bancas.usuarioID = :banca
GROUP BY bancas.bancaID, sorteos.sorteo, sorteos.fecha ORDER BY usuarios.nombre ASC
--ggrupo
SELECT 'taquilla' tipo, reportes.taquillaID id, taquillas.nombre desc,  sorteos.sorteo, sorteos.nombre operadora, reportes.fecha,usuarios.comision cb, usuarios.participacion pb,
	ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, ROUND(SUM(jugada*usuarios.comision),2) cm, 
	round(SUM(jugada*reportes.renta),2) rt, ROUND(SUM((jugada-premio-(jugada*usuarios.comision))*usuarios.participacion),2) prt	
FROM vt.reportes
JOIN us.bancas ON bancas.bancaID = reportes.bancaID 
JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID 
JOIN us.comer_usuario ON comer_usuario.uID = bancas.usuarioID
JOIN us.taquillas ON taquillas.taquillaID = reportes.taquillaID 
JOIN vt.sorteos ON vt.sorteos.sorteoID = reportes.sorteoID 
JOIN main.sorteos ON main.sorteos.sorteoID = vt.sorteos.sorteo
WHERE reportes.fecha BETWEEN :inicio AND :fin AND bancas.bancaID = :grupo AND cID = :comercial
GROUP BY reportes.taquillaID, sorteos.sorteo, reportes.fecha ORDER BY usuarios.nombre ASC
--gtaquilla
SELECT reportes.taquillaID id, taquillas.nombre desc,  sorteos.sorteo, sorteos.nombre operadora, reportes.fecha,ROUND(taquillas.comision*0.01) cb, 0 pb,
	ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, ROUND(SUM(jugada*(taquillas.comision*0.01)),2) cm, 0 prt	
FROM vt.reportes
JOIN us.comer_usuario ON comer_usuario.uID = taquillas.usuarioID
JOIN us.taquillas ON taquillas.taquillaID = reportes.taquillaID 
JOIN vt.sorteos ON vt.sorteos.sorteoID = reportes.sorteoID 
JOIN main.sorteos ON main.sorteos.sorteoID = vt.sorteos.sorteo
WHERE reportes.fecha BETWEEN :inicio AND :fin AND taquillas.taquillaID = :taquilla AND cID = :comercial
GROUP BY sorteos.sorteo, reportes.fecha ORDER BY taquillas.nombre ASC