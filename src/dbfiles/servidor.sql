--login
SELECT * FROM "main"."admins" WHERE usuario = :usr AND clave = :clv
--sorteos_admin
SELECT sorteoID, nombre  FROM admins_meta 
JOIN main.sorteos ON admins_meta.valor = sorteos.sorteoID 
WHERE adminID = :adminID
--sorteos
SELECT sorteoID, descripcion 
FROM main.sorteos
--sorteos_dia
SELECT sorteos.fecha, sorteos.sorteoID, sorteos.descripcion, sorteos.ganador, elementos.bancaID, elementos.taquillaID, 
	ROUND(SUM(monto),2) jugado, ROUND(SUM(premio),2) premio
FROM elementos 
JOIN numeros ON elementos.numero = numeros.elementoID 
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
JOIN us.taquillas ON taquillas.taquillaID = elementos.taquillaID 
JOIN us.bancas ON bancas.bancaID = elementos.bancaID 
WHERE sorteos.fecha = :fecha AND elementos.anulado = 0 
GROUP BY elementos.sorteoID 
ORDER BY elementos.sorteoID, elementos.bancaID ASC, elementos.taquillaID ASC
--sorteo_dia
SELECT sorteos.fecha, sorteos.sorteoID, sorteos.descripcion, sorteos.ganador,
	ROUND(SUM(monto),2) jugado, ROUND(SUM(premio),2) premio, ROUND(SUM(taquillas.comision*monto/100),2) comision
FROM elementos 
JOIN numeros ON elementos.numero = numeros.elementoID 
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
JOIN us.taquillas ON taquillas.taquillaID = elementos.taquillaID 
JOIN us.bancas ON bancas.bancaID = elementos.bancaID 
WHERE sorteos.fecha = :fecha AND sorteos.sorteo = :sorteo AND elementos.anulado = 0 
GROUP BY elementos.sorteoID 
ORDER BY sorteos.cierra ASC
--sorteos_num_ultimos
SELECT elementoID id,fecha f, descripcion d from numeros JOIN (SELECT fecha,ganador from vt.sorteos  where sorteo = :srt  GROUP BY ganador ORDER BY fecha DESC) as tiempo ON tiempo.ganador = elementoID where sorteo = :srt
--sorteos_num_historia
SELECT descripcion d, fecha f from vt.sorteos WHERE ganador = :n ORDER BY FECHA DESC LIMIT 5
--monitor_vnt_ticket_num
SELECT elementos.taquillaID tq, taquillas.nombre tqn, elementos.bancaID bc, bancas.nombre bnc, usuarios.nombre usn, usuarios.usuarioID us, elementos.monto m, elementos.ticketID id, numero n,
	strftime('%H:%M:%S', ticket.tiempo / 1000, 'unixepoch','localtime') h
FROM vt.elementos 
  JOIN taquillas ON taquillas.taquillaID = elementos.taquillaID 
  JOIN bancas ON bancas.bancaID = elementos.bancaID 
  JOIN usuarios ON usuarios.usuarioID = bancas.usuarioID 
  JOIN ticket ON elementos.ticketID = ticket.ticketID 
WHERE sorteoID = :sorteo and numero = :numero and elementos.anulado = false
ORDER BY elementos.ticketID DESC
--count_ventas
select * from elementos where sorteoID = :sorteo GROUP BY ticketID
--numeros_admin
SELECT elementoID, numero, descripcion, numeros.sorteo FROM numeros JOIN admins_meta ON admins_meta.valor = numeros.sorteo WHERE adminID = :adminID ORDER BY numeros.sorteo, numeros.numero
--numeros_admin_sorteo
SELECT elementoID, numero, descripcion, numeros.sorteo FROM numeros JOIN admins_meta ON admins_meta.valor = numeros.sorteo WHERE adminID = :adminID and sorteo = :sorteo ORDER BY numeros.sorteo, numeros.numero
--usuario_reg_sorteo
INSERT INTO us.usuario_sorteos (usuarioID,sorteo) VALUES (:usuarioID,:sorteo)
--usuario_del_sorteo
DELETE FROM us.usuario_sorteos WHERE sid = :sid AND sorteo = :sorteo
--usuario_sorteos
SELECT sid, usuarios.usuarioID, usuarios.nombre, usuarios.usuario, sorteos.nombre
FROM usuario_sorteos 
LEFT JOIN us.usuarios ON usuarios.usuarioID = usuario_sorteos.usuarioID 
JOIN main.sorteos ON sorteos.sorteoID = usuario_sorteos.sorteo
ORDER BY usuario_sorteos.sorteo
--usuario_sorteo_id
SELECT sid, usuarios.usuarioID, usuarios.nombre, usuarios.usuario, sorteos.nombre
FROM usuario_sorteos 
JOIN us.usuarios ON usuarios.usuarioID = usuario_sorteos.usuarioID 
JOIN main.sorteos ON sorteos.sorteoID = usuario_sorteos.sorteo
WHERE sorteo = :sorteo
ORDER BY usuario_sorteos.sorteo