--sorteo
SELECT * FROM vt.sorteos WHERE sorteoID = :sorteoID
--sorteos
SELECT * FROM sorteos
--sorteos_fecha
SELECT * FROM vt.sorteos WHERE fecha = :fecha ORDER BY cierra
--sorteos_fecha_taq
SELECT vt.sorteos.sorteoID, descripcion, fecha, abierta, abre, cierra, ganador, vt.sorteos.sorteo, main.sorteos.zodiacal FROM vt.sorteos 
JOIN (SELECT * FROM (SELECT * FROM us.taquillas_sorteo 
 WHERE (taquillas_sorteo.banca = :banca OR taquillas_sorteo.banca = 0) AND (taquillas_sorteo.taquilla = :taquilla OR taquillas_sorteo.taquilla = 0) ORDER BY taquilla ASC, banca ASC, ID ASC) GROUP BY sorteo ) as taquillas 
ON taquillas.sorteo = vt.sorteos.sorteo 
JOIN main.sorteos ON main.sorteos.sorteoID = vt.sorteos.sorteo
WHERE vt.sorteos.fecha = :fecha AND taquillas.publico = 1
--sorteos_dia
SELECT * FROM vt.sorteos WHERE fecha = :dia AND abierta = true ORDER BY abre
--sorteos_fecha_lista
SELECT sorteoID,sorteos.descripcion,sorteos.sorteo,numeros.numero g,numeros.descripcion gn FROM vt.sorteos 
LEFT JOIN numeros ON numeros.elementoID = sorteos.ganador 
WHERE fecha = :lista ORDER BY sorteos.sorteo, cierra
--sorteos_fecha_lista_admin
SELECT sorteoID,sorteos.descripcion,sorteos.sorteo,abierta,numeros.numero g,numeros.descripcion gn FROM vt.sorteos 
LEFT JOIN numeros ON numeros.elementoID = sorteos.ganador JOIN admins_meta ON admins_meta.valor = sorteos.sorteo 
WHERE fecha = :lista AND adminID = :adminID ORDER BY sorteos.sorteo, cierra
--sorteos_fecha_nombres
SELECT sorteoID,descripcion,sorteo FROM vt.sorteos WHERE fecha = :nombres ORDER BY sorteos.sorteo, sorteoID
--sorteos_fecha_agrupado
SELECT descripcion, sorteo FROM vt.sorteos WHERE fecha = :gfecha GROUP BY sorteo
--nuevo
INSERT INTO vt.sorteos (descripcion,fecha,abre,cierra,abierta,sorteo) VALUES (:descripcion,:fecha,:abre,:cierra,:abierta,:sorteo)
--remover
DELETE FROM vt.sorteos WHERE sorteoID = :sorteoID
--editar
UPDATE vt.sorteos SET abierta = :abierta WHERE sorteoID = :sorteo
--premio
SELECT sorteoID,descripcion,ganador FROM vt.sorteos WHERE sorteoID = :sorteoID
--presorteos
SELECT * FROM pre_sorteos ORDER BY sorteo, sorteoID
--presorteo_nuevo
INSERT INTO pre_sorteos (descripcion,inicio,final,sorteo) VALUES (:descripcion,:inicio,:final,:sorteo)
--presorteo_remover
DELETE FROM pre_sorteos WHERE sorteoID = :sorteoID
--publicar
INSERT INTO us.taquillas_sorteo (taquilla,banca,sorteo,publico) VALUES (:taquillaID,:bancaID,:sorteo,:publico)
--publicos
SELECT ID,taquilla,sorteo,publico FROM us.taquillas_sorteo WHERE banca = :bancaID
--remover_publico
DELETE FROM us.taquillas_sorteo WHERE ID = :id AND banca = :bancaID
--editar_publico
UPDATE us.taquillas_sorteo SET publico = :publico WHERE ID = :id AND banca = :bancaID
--usuario_publico
SELECT sorteoID, nombre FROM us.usuario_sorteos JOIN main.sorteos ON usuario_sorteos.sorteo = sorteos.sorteoID WHERE (usuarioID = :usuarioID OR usuarioID = 0)
--fecha_usuario
SELECT sorteos.sorteoID, sorteos.sorteo, sorteos.descripcion, cierra, abierta, ganador, numeros.numero g, numeros.descripcion gn 
FROM vt.sorteos 
JOIN us.usuario_sorteos ON sorteos.sorteo = usuario_sorteos.sorteo 
LEFT JOIN main.numeros ON sorteos.ganador = numeros.elementoID 
WHERE fecha = :fecha AND (usuarioID = :usuarioID OR usuarioID = 0) 
ORDER BY sorteos.sorteo, sorteos.cierra
--lista_usuario
SELECT sorteos.sorteoID, sorteos.descripcion, numeros.numero g, numeros.descripcion gn, cierra, abierta
FROM vt.sorteos 
JOIN us.usuario_sorteos ON sorteos.sorteo = usuario_sorteos.sorteo
LEFT JOIN main.numeros ON sorteos.ganador = numeros.elementoID 
WHERE fecha = :lista AND (usuarioID = :usuarioID OR usuarioID = 0) 
ORDER BY sorteos.sorteo, sorteos.cierra
--remover_sorteo
DELETE FROM sorteos WHERE sorteoID = :sID;
DELETE FROM pre_sorteos WHERE sorteo = :sID;
DELETE FROM numeros WHERE sorteo = :sID;
DELETE FROM admins_meta WHERE meta = "prm_sorteo" AND valor = :sID;
DELETE FROM us.relacion_pago WHERE sorteo = :sID;
DELETE FROM us.taquillas_comision WHERE sorteo = :sID;
DELETE FROM us.taquillas_sorteo WHERE sorteo = :sID;
DELETE FROM us.topes WHERE sorteo = :sID;
DELETE FROM us.usuario_sorteos WHERE sorteo = :sID;
DELETE from vt.sorteos WHERE sorteo = :sID;
--pendientes
SELECT fecha,descripcion,sorteo,sorteoID,ganador gid FROM vt.sorteos 
WHERE ganador = 0 AND fecha BETWEEN :desde and :hasta and abierta = false
and sorteos.sorteo IN (SELECT sorteoID  FROM admins_meta JOIN main.sorteos ON admins_meta.valor = sorteos.sorteoID WHERE adminID = :aID)
--auto_premiar
SELECT *
FROM autoPremiar
WHERE (sorteoID = :sorteoID OR sorteoID = 0) AND (fecha = :fecha OR fecha = "")
AND sorteo = :sorteo
ORDER BY sorteoID DESC, fecha DESC LIMIT 1
--auto_premiar_venta
SELECT relacion, q.numero, jugada, premios, tickets, numeros.numero numeroTexto, sorteo, (SELECT clase FROM main.sorteos WHERE sorteoID = sorteo) operadora,
  (SELECT fecha FROM vt.sorteos WHERE ganador = q.numero AND sorteo = sorteos.sorteo ORDER BY cierra DESC LIMIT 1) ultimoPremio 
  FROM (SELECT ROUND((jugada*relacion_pago.valor *100) / (SELECT SUM(monto) monto FROM vt.elementos where sorteoID = :sorteoID GROUP BY sorteoID),2) relacion, tn.numero, jugada, n tickets, ROUND(jugada*relacion_pago.valor,2) premios 
FROM (SELECT numero, ROUND(sum(jugada),2) jugada, count(numero) n, sorteoID FROM
  (SELECT numero, ROUND(monto,2) jugada, ticketID, sorteoID 
   FROM vt.elementos WHERE sorteoID = :sorteoID and anulado = false)
GROUP BY numero) tn
JOIN vt.sorteos ON sorteos.sorteoID = tn.sorteoID
JOIN us.relacion_pago ON relacion_pago.sorteo = sorteos.sorteo AND bancaID = 0
ORDER BY ABS(:relacion - relacion), tickets DESC LIMIT 10) as q
  JOIN main.numeros ON numeros.elementoID = q.numero
	WHERE (SELECT fecha FROM vt.sorteos WHERE ganador = q.numero AND sorteo = sorteos.sorteo ORDER BY cierra DESC LIMIT 1) != date()
	LIMIT 1
--auto_premiar_venta_OMITIR_REPETIR_MISMO_DIA
SELECT  ROUND((jugada*relacion_pago.valor *100) / (SELECT SUM(monto) monto FROM vt.elementos where sorteoID = :sorteoID GROUP BY sorteoID),2) relacion, tn.numero, jugada, n tickets, ROUND(jugada*relacion_pago.valor,2) premios 
FROM (SELECT numero, ROUND(sum(jugada),2) jugada, count(numero) n, sorteoID FROM
  (SELECT numero, ROUND(monto,2) jugada, ticketID, sorteoID 
   FROM vt.elementos WHERE sorteoID = :sorteoID and anulado = false)
GROUP BY numero) tn
JOIN vt.sorteos ON sorteos.sorteoID = tn.sorteoID
JOIN us.relacion_pago ON relacion_pago.sorteo = sorteos.sorteo AND bancaID = 0
ORDER BY ABS(:relacion - relacion), tickets DESC LIMIT 1
--bot_lista
SELECT botID, sorteos.descripcion sorteo, creado, autoPremiar.fecha, autoPremiar.sorteoID, relacion FROM main.autoPremiar 
LEFT JOIN vt.sorteos ON autoPremiar.sorteoID = sorteos.sorteoID
WHERE autoPremiar.sorteo = :operadora
--bot_nuevo
INSERT INTO main.autoPremiar (sorteo, sorteoID, adminID, relacion, fecha, creado) 
VALUES (:sorteo, :sorteoID, :adminID, :relacion, :fecha, :creado)
--bot_remover
DELETE FROM main.autoPremiar WHERE botID = :botID AND adminID = :adminID